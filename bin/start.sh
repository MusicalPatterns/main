#!/usr/bin/env bash

pushd services/lab > /dev/null 2>&1
	node -r ts-node/register --max-old-space-size=4096 node_modules/webpack-dev-server/bin/webpack-dev-server.js --config webpack.lab.js --color
popd > /dev/null 2>&1
