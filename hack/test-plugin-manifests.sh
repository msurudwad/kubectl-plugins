#!/usr/bin/env bash

set -euo pipefail

SRC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# install plugin validate-krew-manifest, if not present
if hash kubectl validate-krew-manifest 2>/dev/null; then
  echo >&2 "using validate-krew-manifest plugin from the host system and not reinstalling"
else
  go get sigs.k8s.io/krew/cmd/validate-krew-manifest@master
fi

# validate plugin manifests
for entry in "$SRC_ROOT"/plugins/*; do
  validate-krew-manifest -manifest "$entry"
  echo >&2 "Successfully validated plugin manifest $entry"
done
