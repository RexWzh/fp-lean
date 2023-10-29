#!/usr/bin/env bash

[ -z "$LEAN_REMOTE_FP_LEAN" ] && echo "LEAN_REMOTE_FP_LEAN is not set" && exit 1;

## clean up
mkdir -p build
rm -rf build
mkdir build

## build
cp -r zhsrc/* build/
cd build
git init
git remote add $LEAN_REMOTE_FP_LEAN
git push --force $LEAN_REMOTE_FP_LEAN main:main