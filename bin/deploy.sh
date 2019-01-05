#!/usr/bin/env bash

set -e

gcloud config configurations activate musical-patterns
pushd services/lab > /dev/null 2>&1
	make build
	gcloud app deploy -q
popd > /dev/null 2>&1
