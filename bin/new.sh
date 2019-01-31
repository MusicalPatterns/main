#!/usr/bin/env bash

set -e

export ID=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L_&/g' <<< ${pattern} | sed -r 's/[a-z]+/\U&/g')
export TITLE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\ &/g' <<< ${pattern} | sed 's/\b\(.\)/\u\1/g')
export PACKAGE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\-&/g' <<< ${pattern})

create_pattern_repo() {
	set +e
	git ls-remote git@github.com:MusicalPatterns/pattern-${pattern} > /dev/null 2>&1
	if [[ $? == 0 ]] ; then
		echo "${pattern} repo already exists in the 'MusicalPatterns' GitHub Organization."
		return 0
	else
		set -e
		if [[ ${GITHUB_ACCESS_TOKEN}} == "" ]] ; then
			echo "Your GitHub Access Token is not available in this environment. It is required to automatically create this repo. Please follow instructions at https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/, selecting at least the 'repo' scope, then export it as GITHUB_ACCESS_TOKEN in your '.bash_profile'."
		fi
		curl -u $(git config user.email):${GITHUB_ACCESS_TOKEN} https://api.github.com/orgs/MusicalPatterns/repos -d "{\"name\":\"pattern-${pattern}\",\"auto_init\":true}"
	fi
}

register_pattern() {
	set +e
	REGISTRY_FILE=services/pattern/src/registry.ts
	grep -q ${ID} ${REGISTRY_FILE}
	if [[ $? == 0 ]] ; then
		echo "${ID} pattern ID already registered with the pattern service."
		return
	fi
	set -e

	LINE_NUMBER=0
	FOUND_REGISTRY_SECTION_OF_FILE=false
	while read LINE ; do
		LINE_NUMBER=$((LINE_NUMBER+1))
		if [[ "${FOUND_REGISTRY_SECTION_OF_FILE}" == true && ${LINE} > ${ID} ]] ; then
			break
		fi
		if [[ ${LINE} == "enum Id {" ]] ; then
			FOUND_REGISTRY_SECTION_OF_FILE=true
		fi
	done < ${REGISTRY_FILE}
	sed -i "${LINE_NUMBER}i\ \ \ \ ${ID} = '${ID}'," ${REGISTRY_FILE}
}

filter_pattern() {
	set +e
	FILTER_FILE=services/pattern/src/filter.ts
	grep -q ${ID} ${FILTER_FILE}
	if [[ $? == 0 ]] ; then
		echo "${ID} pattern ID already filtered with the pattern service."
		return
	fi
	set -e

	LINE_NUMBER=0
	FOUND_FILTER_SECTION_OF_FILE=false
	while read LINE ; do
		LINE_NUMBER=$((LINE_NUMBER+1))
		if [[ "${FOUND_FILTER_SECTION_OF_FILE}" == true && ${LINE} > ${ID} ]] ; then
			break
		fi
		if [[ ${LINE} == "const idsToFilter: Id[] = [" ]] ; then
			FOUND_FILTER_SECTION_OF_FILE=true
		fi
	done < ${FILTER_FILE}
	sed -i "${LINE_NUMBER}i\ \ \ \ Id.${ID}," ${FILTER_FILE}
}

publish_updated_pattern_service() {
	pushd services/pattern > /dev/null 2>&1
		make ship msg="registering & filtering ${ID}"
	popd > /dev/null 2>&1
}

submodule_pattern() {
	if [[ -d patterns/${pattern} ]] ; then
		echo "${pattern} already submoduled."
		return
	fi

	git submodule add --force --name ${pattern} git@github.com:MusicalPatterns/pattern-${pattern}.git patterns/${pattern} || return
}

clone_pattern_from_template() {
	if [[ -f patterns/${pattern}/README.md ]] ; then
		echo "${pattern} already initialized by cloning from the template pattern."
		return
	fi

	DIR=patterns/${pattern}/

	cp -r patterns/template ${DIR} || return

	pushd ${DIR} > /dev/null 2>&1
		sed -i "s/Template/${TITLE}/g" README.md || return
		sed -i "s/travis-ci\.com\/MusicalPatterns\/pattern-template/travis-ci\.com\/MusicalPatterns\/pattern-${pattern}/g" README.md || return
		sed -i "s/copy\ me\ for\ quicker\ provisioning\ of\ new\ patterns/description\ TBA/g" README.md || return

		sed -i "s/Id.TEMPLATE/Id.${ID}/g" src/patterns.ts || return
		sed -i "s/Template/${TITLE}/g" src/patterns.ts || return

		sed -i "s/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-template\.git\"/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-${pattern}\.git\"/g" package.json || return
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PACKAGE}\"/g" package.json || return
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PACKAGE}\"/g" package-lock.json || return

		mv .idea/template.iml .idea/${pattern}.iml || return
		sed -i "s/template/${pattern}/g" .idea/modules.xml || return

		npm version 1.0.0
		npm i
		npm update
		make publish
	popd > /dev/null 2>&1
}

include_pattern_in_lab() {
	pushd services/lab > /dev/null 2>&1
		if [[ $(npm list -depth 0 2>/dev/null | grep -m1 @musical-patterns/pattern-${PACKAGE}) ]] ; then
			echo "${PACKAGE} already installed into the lab service."
		else
			npm i -D @musical-patterns/pattern-${PACKAGE}
			echo "export { pattern as ${ID} } from '@musical-patterns/pattern-${PACKAGE}'" >> src/allPatterns.ts
		fi
	popd > /dev/null 2>&1
}

exclude_pattern_directories() {
	sed -i "/${pattern}\/node_modules/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/node_modules\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${pattern}\/node_modules\" \/>" .idea/main.iml || return
	sed -i "/${pattern}\/dist/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${pattern}\/dist\" \/>" .idea/main.iml || return
	sed -i "/${pattern}\/\.idea/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/template\/\.idea\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/patterns\/${pattern}\/\.idea\" \/>" .idea/main.iml || return
}

add_pattern_package_binaries_to_path() {
	sed -i "/${pattern}\/node_modules\/\.bin\//d" bin/setup.sh || return
	sed -i '/template\/node_modules\/\.bin\//a ":~/workspace/MusicalPatterns/main/patterns/'${pattern}'/node_modules/.bin/"\\' bin/setup.sh || return
}

create_pattern_repo
register_pattern
filter_pattern
publish_updated_pattern_service
submodule_pattern
clone_pattern_from_template
include_pattern_in_lab
exclude_pattern_directories
add_pattern_package_binaries_to_path
