#!/usr/bin/env sh

set -e

declare -a REPOS=("cli" "utilities" "performer" "compiler" "pattern" "playroom" "lab")
for REPO in "${REPOS[@]}"
do
	pushd ${REPO}
		npm i
		npm update
		make test
		make lint
		make ship MSG="${MSG}"
	popd
done

git add .
git commit -m "${MSG}"
git push
