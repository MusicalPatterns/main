#!/usr/bin/env bash

set -e

gcloud config configurations activate musical-patterns
pushd services/lab > /dev/null 2>&1
	node -r ts-node/register --max-old-space-size=4096 node_modules/webpack/bin/webpack.js --config webpack.deploy.js
	gcloud app deploy -q
popd > /dev/null 2>&1
