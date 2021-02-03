#!/usr/bin/env bash

set -e -o pipefail

SRC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"
preflight_tar_archive=preflight.tar.gz

echo >&2 "Creating ${preflight_tar_archive} archive."

build_dir="./build"
mkdir $build_dir
cp -r ./tools/preflight $build_dir
cd $build_dir
mv ./preflight/preflight.sh ./preflight/preflight

# consistent timestamps for files in build dir to ensure consistent checksums
while IFS= read -r -d $'\0' f; do
  echo "modifying atime/mtime for $f"
  TZ=UTC touch -at "0001010000" "$f"
  TZ=UTC touch -mt "0001010000" "$f"
done < <(find . -print0)

tar -cvzf ${preflight_tar_archive} preflight/
echo >&2 "Created ${preflight_tar_archive} archive successfully"

echo >&2 "Creating sha256 of ${preflight_tar_archive} archive."

checksum_cmd="shasum -a 256"
if hash sha256sum 2>/dev/null; then
  checksum_cmd="sha256sum"
fi

"${checksum_cmd[@]}" ${preflight_tar_archive} >preflight-sha256.txt
echo >&2 "Written sha256 of ${preflight_tar_archive} into preflight-sha256.txt successfully"

echo >&2 "Creating Preflight yaml"
cd "$SRC_ROOT"
cp plugins/preflight.yaml $build_dir/preflight.yaml
tar_checksum="$(cut -d' ' -f1 $build_dir/preflight-sha256.txt)"
sed -i "s/.*sha256: .*/      sha256: ${tar_checksum}/g" $build_dir/preflight.yaml
echo >&2 "Written out/preflight.yaml."
