#!/usr/bin/env bash

set -e

declare -a REPOS=("cli" "utilities" "performer" "compiler" "utilitiesPattern" "registry" "playroom" "lab")
for REPO in "${REPOS[@]}"
do
	pushd ${REPO}
		make clean_updates
		npm update
		make ship MSG="${MSG}"
	popd
done

git add .
git commit -m "${MSG}"
git push
