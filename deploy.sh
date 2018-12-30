#!/usr/bin/env bash

set -e

gcloud config configurations activate musical-patterns
pushd lab
	make build
	gcloud app deploy -q
popd
