#!/usr/bin/env bash

set -e

. services/cli/bin/support/services.sh
. services/cli/bin/support/patterns.sh

for SERVICE in "${SERVICES[@]}"
do
	pushd services/${SERVICE} > /dev/null 2>&1
		ncu -u
		npm i
		make ship msg="${msg}"
	popd > /dev/null 2>&1
done

for PATTERN in "${PATTERNS[@]}"
do
	pushd patterns/${PATTERN} > /dev/null 2>&1
		ncu -u
		npm i
		make ship msg="${msg}"
	popd > /dev/null 2>&1
done

pushd services/lab > /dev/null 2>&1
	ncu -u
	npm i
	make ship msg="${msg}"
	make deploy
popd > /dev/null 2>&1

make ship msg="${msg}"
