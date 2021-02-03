#!/usr/bin/env bash

set -ex
rm -rf build
        mkdir build
        cp -r ./tools/preflight ./build
        cd ./build/
        mv ./preflight/preflight.sh ./preflight/preflight
        tar -cvzf preflight.tar.gz preflight/

sha256sum preflight.tar.gz > preflight-sha256.txt
set +ex