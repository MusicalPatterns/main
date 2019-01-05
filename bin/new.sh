#!/usr/bin/env bash

set -e

export PATTERN_ID=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L_&/g' <<< ${PATTERN} | sed -r 's/[a-z]+/\U&/g')
export PATTERN_TITLE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\ &/g' <<< ${PATTERN} | sed 's/\b\(.\)/\u\1/g')
export PATTERN_PACKAGE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\-&/g' <<< ${PATTERN})

echo $PATTERN_ID
echo $PATTERN_TITLE
echo $PATTERN_PACKAGE

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
	grep -q ${PATTERN_ID} registry/src/registry.ts
	if [[ $? == 0 ]] ; then
		echo "${PATTERN_ID} already registered with '@musical-patterns/registry'."
		return
	fi
	set -e

	sed -i "/${PATTERN_ID}/d" registry/src/registry.ts
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
	done < registry/src/registry.ts
	sed -i "${LINE_NUMBER}i\ \ \ \ ${PATTERN_ID} = '${PATTERN_ID}'," registry/src/registry.ts

	pushd registry > /dev/null 2>&1
		make ship MSG="registering ${PATTERN_ID}" PATTERN=""
	popd > /dev/null 2>&1
}

add_pattern() {
	if [[ -d lab/src/${PATTERN} ]] ; then
		echo "${PATTERN} already added to '@musical-patterns/lab'."
		return
	fi

	pushd lab > /dev/null 2>&1
		make update || return
		make update PATTERN=template || return

		git submodule add --force --name ${PATTERN} https://github.com/MusicalPatterns/pattern-${PATTERN}.git src/${PATTERN} || return

		PATTERN_DIR=src/${PATTERN}/

		cp -r src/template/* ${PATTERN_DIR} || return

		pushd ${PATTERN_DIR} > /dev/null 2>&1
			sed -i "s/Template/${PATTERN_TITLE}/g" README.md || return
			sed -i "s/pattern-template\.svg\?branch/pattern-${PATTERN}\.svg\?branch/g" README.md || return
			sed -i "s/copy\ me\ for\ quicker\ provisioning\ of\ new\ patterns/description\ TBA/g" README.md || return

			sed -i "s/PatternId.TEMPLATE/PatternId.${PATTERN_ID}/g" src/patterns.ts || return
			sed -i "s/Template/${PATTERN_TITLE}/g" src/patterns.ts || return

			sed -i "s/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-template\.git\"/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-${PATTERN}\.git\"/g" package.json || return
			sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package.json || return
			sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package-lock.json || return
			npm version 1.0.0
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
}

exclude_pattern_directories() {
	sed -i "/${PATTERN}\/node_modules/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/template\/node_modules\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/${PATTERN}\/node_modules\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/dist/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/template\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/${PATTERN}\/dist\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/\.idea/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/template\/\.idea\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/${PATTERN}\/\.idea\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/node_modules/d" lab/.idea/lab.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/template\/node_modules\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/${PATTERN}\/node_modules\" \/>" lab/.idea/lab.iml || return
	sed -i "/${PATTERN}\/dist/d" lab/.idea/lab.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/template\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/${PATTERN}\/dist\" \/>" lab/.idea/lab.iml || return
	sed -i "/${PATTERN}\/\.idea/d" lab/.idea/lab.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/template\/\.idea\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/${PATTERN}\/\.idea\" \/>" lab/.idea/lab.iml || return
}

create_pattern_repo
register_pattern
add_pattern
exclude_pattern_directories
