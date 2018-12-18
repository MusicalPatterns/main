#!/usr/bin/env sh

set -e

declare -a REPOS=("cli" "utilities" "performer" "compiler" "pattern" "playroom" "lab")
for REPO in "${REPOS[@]}"
do
	pushd ${REPO}
		make update
		make test
		make lint
	popd
done

for REPO in "${REPOS[@]}"
do
	pushd ${REPO}
		make ship MSG="${MSG}"
	popd
done

git add .
git commit -m "${MSG}"
git push
