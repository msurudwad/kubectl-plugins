#!/usr/bin/env bash

# This script verifies that a preflight build can be installed to a system using
# itself as the documented installation method.

set -euo pipefail

[[ -n "${DEBUG:-}" ]] && set -x

#SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
build_dir="./dist"

goos="$(go env GOOS)"
goarch="$(go env GOARCH)"

preflight_manifest="${build_dir}/krew.yaml"
if [[ ! -f "${preflight_manifest}" ]]; then
  echo >&2 "Could not find manifest ${preflight_manifest}."
  echo >&2 "Did you run hack/make-all.sh?"
  exit 1
fi

preflight_archive="${build_dir}/preflight.tar.gz"
if [[ ! -f "${preflight_archive}" ]]; then
  echo >&2 "Could not find archive ${preflight_archive}."
  echo >&2 "Did you run hack/make-all.sh?"
  exit 1
fi



#temp_dir="$(mktemp -d)"
#trap 'rm -rf -- "${temp_dir}"' EXIT
#echo >&2 "Extracting krew from tarball."
#tar zxf "${preflight_archive}" -C "${temp_dir}"
#krew_binary="${temp_dir}/krew-${goos}_${goarch}"
#
#krew_root="$(mktemp -d)"
#trap 'rm -rf -- "${krew_root}"' EXIT
#system_path="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"
#
#echo >&2 "Installing the krew build to a temporary directory."
#env -i KREW_ROOT="${krew_root}" \
#  "${krew_binary}" install \
#  --manifest="${preflight_manifest}" \
#  --archive "${preflight_archive}"
#
#echo >&2 "Verifying krew installation (symlink)."
#env -i PATH="${krew_root}/bin:${system_path}" /bin/bash -c \
#  "which kubectl-krew 1>/dev/null"
