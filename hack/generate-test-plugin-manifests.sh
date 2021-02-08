#!/usr/bin/env bash

set -e -o pipefail

SRC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# get current git tag
# shellcheck disable=SC1090
source "$SRC_ROOT"/hack/get-git-tag.sh

build_dir="./build"

echo >&2 "Creating Preflight plugin manifest yaml"
cd "$SRC_ROOT"

# consistent timestamps for files in build dir to ensure consistent checksums
while IFS= read -r -d $'\0' f; do
  echo "modifying atime/mtime for $f"
  TZ=UTC touch -at "0001010000" "$f"
  TZ=UTC touch -mt "0001010000" "$f"
done < <(find $build_dir -print0)

tvk_preflight_yaml="tvk-preflight.yaml"
cp .krew/$tvk_preflight_yaml $build_dir/$tvk_preflight_yaml

tvk_preflight_yaml=$build_dir/$tvk_preflight_yaml

tar_checksum="$(awk '{print $1}' $build_dir/preflight-sha256.txt)"
sed -i "s/PREFLIGHT_TAR_CHECKSUM/${tar_checksum}/g" $tvk_preflight_yaml
echo >&2 "Written out preflight.yaml."

echo >&2 "Creating Log-Collector plugin manifest yaml"

build_dir="./dist"

# consistent timestamps for files in build dir to ensure consistent checksums
while IFS= read -r -d $'\0' f; do
  echo "modifying atime/mtime for $f"
  TZ=UTC touch -at "0001010000" "$f"
  TZ=UTC touch -mt "0001010000" "$f"
done < <(find $build_dir -print0)

checksum_cmd="shasum -a 256"
if hash sha256sum 2>/dev/null; then
  checksum_cmd="sha256sum"
fi

tvk_log_collector_yaml="tvk-log-collector.yaml"
cp .krew/$tvk_log_collector_yaml $build_dir/$tvk_log_collector_yaml

tvk_log_collector_yaml=$build_dir/$tvk_log_collector_yaml

# shellcheck disable=SC2154
log_collector_tar_archive="log-collector_${git_version}_linux_amd64.tar.gz"
tar_checksum="$(eval "${checksum_cmd[@]}" "$build_dir/${log_collector_tar_archive}" | awk '{print $1;}')"
sed -i "s/LOG_COLLECTOR_LINUX_TAR_CHECKSUM/${tar_checksum}/g" $tvk_log_collector_yaml

log_collector_tar_archive="log-collector_${git_version}_darwin_amd64.tar.gz"
tar_checksum="$(eval "${checksum_cmd[@]}" "$build_dir/${log_collector_tar_archive}" | awk '{print $1;}')"
sed -i "s/LOG_COLLECTOR_DARWIN_TAR_CHECKSUM/${tar_checksum}/g" $tvk_log_collector_yaml

log_collector_tar_archive="log-collector_${git_version}_windows_amd64.zip"
tar_checksum="$(eval "${checksum_cmd[@]}" "$build_dir/${log_collector_tar_archive}" | awk '{print $1;}')"
sed -i "s/LOG_COLLECTOR_WINDOWS_TAR_CHECKSUM/${tar_checksum}/g" $tvk_log_collector_yaml

echo >&2 "Written out logCollector.yaml."
