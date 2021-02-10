#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2046
# shellcheck disable=SC2006
current_tag=$(git describe --abbrev=0 --tags $(git rev-list --tags --max-count=1))
# shellcheck disable=SC2046
# shellcheck disable=SC2006
previous_tag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1))

# use hard coded values if required
#current_tag=v0.0.5-dev
#previous_tag=v0.0.4-dev

echo "current_tag=$current_tag and previous_tag=$previous_tag"

echo "checking paths of modified files-"
preflight_changed=false
log_collector_changed=false
tools_dir="tools"
preflight_dir="$tools_dir/preflight"
log_collector_dir="$tools_dir/log_collector"

# shellcheck disable=SC2086
git diff --name-only $previous_tag^ $current_tag $tools_dir >files.txt

count=$(wc -l < files.txt)
if [[ $count -eq 0 ]]; then
  echo "directory 'tools' has not been not modified"
  echo "::set-output name=create_release::false"
  exit
fi

echo "list of modified files-"
cat files.txt

while IFS= read -r file; do
  if [[ $preflight_changed == false && $file == $preflight_dir/* ]]; then
    echo "directory '$preflight_dir' has been modified"
    echo "::set-output name=release_preflight::true"
    preflight_changed=true
  elif [[ $log_collector_changed == false && $file == $log_collector_dir/* ]]; then
    echo "directory '$log_collector_dir' has been modified"
    echo "::set-output name=release_log_collector::true"
    log_collector_changed=true
  fi
done <files.txt

if [[ $preflight_changed == true || $log_collector_changed == true ]]; then
  echo "directory '$tools_dir' has been modified"
  echo "::set-output name=create_release::true"
fi
