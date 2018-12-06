#!/usr/bin/env sh

set -e

make build
gcloud config configurations activate musical-patterns
pushd lab
	gcloud app deploy -q
popd
