#!/usr/bin/env bash
set -eo pipefail; [[ $MKMRCONFIG_TRACE ]] && set -x

# Scans Github organizations and emits a config file for use with `myrepos`.
#
# Dependencies:
#   myrepos -- https://myrepos.branchable.com
#     e.g. apt-get install myrepos
#
# Usage:
#   > cd $GOPATH/src/github.com/
#   > path/to/mkmrconfig.sh > .mrconfig
#   > mr --trust-all checkout
#   > mr status
#
# Notes:
# - covers only repos starting in "go-", which excludes many gxed repos
# - watch out for Github API's requests limit

orgs=(ipfs ipld libp2p multiformats gxed)
filter='-P ^go-'

# github oauth, e.g. "-u lgierth:personalaccesstoken"
auth=""

list_repos () {
  org="$1"
  per_page=100
  page=1
  [ "$2" ] && page="$2"
  repos=$(curl $auth "https://api.github.com/orgs/$org/repos?page=$page&per_page=$per_page" 2>/dev/null | jq -r '.[] | "\(.name),\(.ssh_url)"')
  i=$(printf %s\\n "$repos" | wc -l)
  printf %s\\n "$repos"
  if test "$i" -ge "$per_page"; then
    list_repos "$org" $(expr "$page" + 1)
  fi
}

for org in ${orgs[@]}; do
  for r in `list_repos "$org" | grep $filter`; do
    name="$(echo "$r" | cut -d, -f1)"
    url="$(echo "$r" | cut -d, -f2)"
    echo "[$org/$name]"
    echo "checkout = git clone $url"
    echo
  done
done
