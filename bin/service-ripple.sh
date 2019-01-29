#!/usr/bin/env bash

set -e

. services/cli/bin/non_cli/services.sh

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
		npm update
		make ship msg="${msg}"
	popd > /dev/null 2>&1
done

git submodule foreach npm update
make ship msg="${msg}"
