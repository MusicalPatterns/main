#!/usr/bin/env bash

set -e

export PATTERN_ID=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L_&/g' <<< ${PATTERN} | sed -r 's/[a-z]+/\U&/g')
export PATTERN_TITLE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\ &/g' <<< ${PATTERN} | sed 's/\b\(.\)/\u\1/g')
export PATTERN_PACKAGE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\-&/g' <<< ${PATTERN})

create_pattern_repo() {
	set +e
	git ls-remote git@github.com:MusicalPatterns/pattern-${PATTERN} > /dev/null 2>&1
	if [[ $? == 0 ]] ; then
		echo "${PATTERN} repo already exists in the 'MusicalPatterns' GitHub Organization."
		return 0
	else
		set -e
		if [[ ${GITHUB_ACCESS_TOKEN}} == "" ]] ; then
			echo "Your GitHub Access Token is not available in this environment. It is required to automatically create this repo. Please follow instructions at https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/, selecting at least the 'repo' scope, then export it as GITHUB_ACCESS_TOKEN in your '.bash_profile'."
		fi
		curl -u $(git config user.email):${GITHUB_ACCESS_TOKEN} https://api.github.com/orgs/MusicalPatterns/repos -d "{\"name\":\"pattern-${PATTERN}\",\"auto_init\":true}"
	fi
}

register_pattern() {
	set +e
	REGISTRY_FILE=services/registry/src/registry.ts
	grep -q ${PATTERN_ID} ${REGISTRY_FILE}
	if [[ $? == 0 ]] ; then
		echo "${PATTERN_ID} pattern ID already registered with the registry service."
		return
	fi
	set -e

	sed -i "/${PATTERN_ID}/d" ${REGISTRY_FILE}
	LINE_NUMBER=0
	IN_REGISTRY=false
	while read LINE ; do
		LINE_NUMBER=$((LINE_NUMBER+1))
		if [[ "${IN_REGISTRY}" == true && ${LINE} > ${PATTERN_ID} ]] ; then
			break
		fi
		if [[ ${LINE} == "enum PatternId {" ]] ; then
			IN_REGISTRY=true
		fi
	done < ${REGISTRY_FILE}
	sed -i "${LINE_NUMBER}i\ \ \ \ ${PATTERN_ID} = '${PATTERN_ID}'," ${REGISTRY_FILE}

	pushd services/registry > /dev/null 2>&1
		make ship MSG="registering ${PATTERN_ID}" PATTERN=""
	popd > /dev/null 2>&1
}

submodule_pattern() {
	if [[ -d patterns/${PATTERN} ]] ; then
		echo "${PATTERN} already submoduled."
		return
	fi

	git submodule add --force --name ${PATTERN} git@github.com:MusicalPatterns/pattern-${PATTERN}.git patterns/${PATTERN} || return
}

clone_pattern_from_template() {
	if [[ "$(ls -A patterns/${PATTERN})" != "" ]] ; then
		echo "${PATTERN} already initialized by cloning from the template pattern."
		return
	fi

	PATTERN_DIR=patterns/${PATTERN}/

	cp -r patterns/template/* ${PATTERN_DIR} || return

	pushd ${PATTERN_DIR} > /dev/null 2>&1
		sed -i "s/Template/${PATTERN_TITLE}/g" README.md || return
		sed -i "s/travis-ci\.com\/MusicalPatterns\/pattern-template/travis-ci\.com\/MusicalPatterns\/pattern-${PATTERN}/g" README.md || return
		sed -i "s/copy\ me\ for\ quicker\ provisioning\ of\ new\ patterns/description\ TBA/g" README.md || return

		sed -i "s/PatternId.TEMPLATE/PatternId.${PATTERN_ID}/g" src/patterns.ts || return
		sed -i "s/Template/${PATTERN_TITLE}/g" src/patterns.ts || return

		sed -i "s/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-template\.git\"/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-${PATTERN}\.git\"/g" package.json || return
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package.json || return
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package-lock.json || return

		mv .idea/template.iml .idea/${PATTERN}.iml || return
		sed -i "s/template/${PATTERN}/g" .idea/modules.xml || return

		npm version 1.0.0
	popd > /dev/null 2>&1
}

include_pattern_in_lab() {
	pushd services/lab > /dev/null 2>&1
		if [[ $(npm list -depth 0 2>/dev/null | grep -m1 @musical-patterns/pattern-${PATTERN_PACKAGE}) ]] ; then
			echo "${PATTERN_PACKAGE} already installed into the lab service."
		else
			npm i -D @musical-patterns/pattern-${PATTERN_PACKAGE}
			echo "export { pattern as ${PATTERN_ID} } from '@musical-patterns/pattern-${PATTERN_PACKAGE}'" >> src/patterns.ts
		fi
	popd > /dev/null 2>&1
}

exclude_pattern_directories() {
	sed -i "/${PATTERN}\/node_modules/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/node_modules\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${PATTERN}\/node_modules\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/dist/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${PATTERN}\/dist\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/\.idea/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/\.idea\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${PATTERN}\/\.idea\" \/>" .idea/main.iml || return
}

create_pattern_repo
register_pattern
submodule_pattern
clone_pattern_from_template
include_pattern_in_lab
exclude_pattern_directories

make setup
