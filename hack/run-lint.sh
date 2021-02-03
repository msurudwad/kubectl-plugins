#!/usr/bin/env bash

set -euo pipefail

[[ -n "${DEBUG:-}" ]] && set -x

gopath="$(go env GOPATH)"

#
#if ! [[ -x "$gopath/bin/golangci-lint" ]]; then
#  echo >&2 'Installing golangci-lint'
#  curl --silent --fail --location \
#    https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b "$gopath/bin" v1.34.1
#fi
#
## configured by .golangci.yml
#"$gopath/bin/golangci-lint" run
#
#install_impi() {
#  impi_dir="$(mktemp -d)"
#  trap 'rm -rf -- ${impi_dir}' EXIT
#
#  cd "${impi_dir}"
#  go mod init foo
#  go get github.com/pavius/impi/cmd/impi@c1cbdcb
#  cd -
#}
#
## install impi that ensures import grouping is done consistently
#if ! [[ -x "${gopath}/bin/impi" ]]; then
#  echo >&2 'Installing impi'
#  install_impi
#fi
#
#"$gopath/bin/impi" --local sigs.k8s.io/krew --scheme stdThirdPartyLocal ./...

install_shfmt() {
  shfmt_dir="$(mktemp -d)"
  trap 'rm -rf -- ${shfmt_dir}' EXIT

  cd "${shfmt_dir}"
  go mod init foo
  go get mvdan.cc/sh/v3/cmd/shfmt@v3.0.0
  cd -
}

# install shfmt that ensures consistent format in shell scripts
if ! [[ -x "${gopath}/bin/shfmt" ]]; then
  echo >&2 'Installing shfmt'
  install_shfmt
fi


SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shfmt_out="$($gopath/bin/shfmt -l -i=2 ${SCRIPTDIR})"
if [[ -n "${shfmt_out}" ]]; then
  echo >&2 "The following shell scripts need to be formatted, run: 'shfmt -w -i=2 ${SCRIPTDIR}'"
  echo >&2 "${shfmt_out}"
  exit 1
fi
