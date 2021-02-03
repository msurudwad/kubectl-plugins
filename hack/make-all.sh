#!/usr/bin/env bash

set -e -o pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#"${SCRIPTDIR}/make-binaries.sh"
"${SCRIPTDIR}/make-release-artifacts.sh"
