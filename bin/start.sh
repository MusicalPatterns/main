#!/usr/bin/env bash

pushd lab > /dev/null 2>&1
	webpack-dev-server --config webpack.dev.js --color
popd > /dev/null 2>&1
