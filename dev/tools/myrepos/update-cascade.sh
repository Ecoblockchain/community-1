#!/usr/bin/env bash

allRepos=$(mr run sh -c '
    org=$(basename $(dirname `pwd`)) &&
    repo=$(cat $(pwd)/package.json | jq -r .name) &&
    echo $org/$repo' |
  grep -v 'mr ' | grep -v 'package.json' |
  grep -P '\w/\w')
dirtyRepos=$(
  for d in $(mr -m status | grep 'mr status: ' | cut -d' ' -f3); do
    cd "$d" &&
    org=$(basename $(dirname `pwd`)) &&
    repo=$(cat $(pwd)/package.json | jq -r .name) &&
    echo $org/$repo
  done |
  grep -v 'package.json' |
  grep -P '\w/\w')

printf %s\\n "$allRepos"
printf %s\\n "$dirtyRepos"
