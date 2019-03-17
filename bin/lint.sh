#!/usr/bin/env bash

git submodule foreach "make lint || true"
