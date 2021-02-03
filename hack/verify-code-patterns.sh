#!/usr/bin/env bash

set -euo pipefail

# Disallow usage of ioutil.TempDir in tests in favor of testutil.
out="$(grep --include '*_test.go' --exclude-dir 'vendor/' -EIrn 'ioutil.\TempDir' || true)"
if [[ -n "$out" ]]; then
  echo >&2 "You used ioutil.TempDir in tests, use 'testutil.NewTempDir()' instead:"
  echo >&2 "$out"
  exit 1
fi

# use code constant for ".yaml"
out="$(grep --include '*.go' \
  --exclude "*_test.go" \
  --exclude 'constants.go' \
  --exclude-dir 'vendor/' \
  -EIrn '\.yaml"' || true)"
if [[ -n "$out" ]]; then
  echo >&2 'You used ".yaml" in production, use constants.ManifestExtension instead:'
  echo >&2 "$out"
  exit 1
fi

# Do not use glog/klog in test code
out="$(grep --include '*_test.go' --exclude-dir 'vendor/' -EIrn '[kg]log\.' || true)"
if [[ -n "$out" ]]; then
  echo >&2 "You used glog or klog in tests, use 't.Logf' instead:"
  echo >&2 "$out"
  exit 1
fi

# Do not use fmt.Errorf as it does not start a stacktrace at error site
out="$(grep --include '*.go' -EIrn 'fmt\.Errorf?' || true)"
if [[ -n "$out" ]]; then
  echo >&2 "You used fmt.Errorf; use pkg/errors.Errorf instead to preserve stack traces:"
  echo >&2 "$out"
  exit 1
fi

# Do not initialize index.{Plugin,Platform} structs in test code.
out="$(grep --include '*_test.go' --exclude-dir 'vendor/' -EIrn '[^]](index\.)(Plugin|Platform){' || true)"
if [[ -n "$out" ]]; then
  echo >&2 "Do not use index.Platform or index.Plugin structs directly in tests,"
  echo >&2 "use testutil.NewPlugin() or testutil.NewPlatform() instead:"
  echo >&2 "-----"
  echo >&2 "$out"
  exit 1
fi