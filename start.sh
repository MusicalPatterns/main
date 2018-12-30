#!/usr/bin/env bash

pushd lab
	webpack-dev-server --config webpack.dev.js --color
popd
