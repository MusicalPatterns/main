#!/usr/bin/env bash

set -e

gcloud config configurations activate musical-patterns
pushd services/lab > /dev/null 2>&1
	make build config=deploy
	gcloud app deploy -q
popd > /dev/null 2>&1
