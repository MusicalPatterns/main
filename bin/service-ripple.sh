#!/usr/bin/env bash

set -e

. services/cli/bin/non_cli/services.sh
. services/cli/bin/non_cli/patterns.sh

FROM_INDEX=0
for i in "${!SERVICES[@]}" ; do
	if [[ "${SERVICES[i]}" = "${from}" ]] ; then
		FROM_INDEX=i
		break
	fi
done

SERVICES=("${SERVICES[@]:FROM_INDEX}")

for SERVICE in "${SERVICES[@]}"
do
	pushd services/${SERVICE} > /dev/null 2>&1
		make update
		make ship msg="${msg}"
	popd > /dev/null 2>&1
done

for PATTERN in "${PATTERNS[@]}"
do
	pushd patterns/${PATTERN} > /dev/null 2>&1
		make update
		make ship msg="${msg}"
	popd > /dev/null 2>&1
done

make ship msg="${msg}"
