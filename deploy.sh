#!/usr/bin/env bash

[ -z "$LEAN_REMOTE_FP_LEAN" ] && echo "LEAN_REMOTE_FP_LEAN is not set" && exit 1;
cd functional-programming-lean/

## build
mdbook build
cd book/html
git init
git add .
git commit -m "deploy"
git remote add origin $LEAN_REMOTE_FP_LEAN
git push --force origin main:gh-pages