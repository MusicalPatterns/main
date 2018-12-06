#!/usr/bin/env sh

set -e

pushd cli
	npm update
	VERSION=$(npm version patch)
	git add .
	git commit -m "${VERSION}: ${MSG}"
	git push
	npm publish --access public
popd

declare -a REPOS=("utilities" "performer" "compiler" "pattern" "playroom" "lab")
for REPO in "${REPOS[@]}"
do
	pushd ${REPO}
		npm i
		npm update
		make ship MSG="${MSG}"
	popd
done

git add .
git commit -m "${MSG}"
git push
