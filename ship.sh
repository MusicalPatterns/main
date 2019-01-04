#!/usr/bin/env bash

set -e

REPOS=("cli" "utilities" "performer" "compiler" "pattern" "registry" "playroom" "lab")
FROM_INDEX=0
for i in "${!REPOS[@]}" ; do
	if [[ "${REPOS[i]}" = "${FROM}" ]] ; then
		FROM_INDEX=i
		break
	fi
done

REPOS=("${REPOS[@]:FROM_INDEX}")

for REPO in "${REPOS[@]}"
do
	pushd ${REPO} > /dev/null 2>&1
		npm update
		make ship MSG="${MSG}"
	popd > /dev/null 2>&1
done

make commit
make push
