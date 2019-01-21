#!/usr/bin/env bash

set -e

SERVICES=("cli" "utilities" "performer" "compiler" "pattern" "snapshot" "playroom" "lab")
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
