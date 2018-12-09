#!/usr/bin/env sh

set -e

git pull -r
git submodule update --init --recursive
git submodule foreach git checkout master
git submodule foreach pull -r
