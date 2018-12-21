#!/usr/bin/env sh

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
	grep -q ${PATTERN_ID} pattern/src/registry.ts
	if [[ $? == 0 ]] ; then
		echo "${PATTERN_ID} already registered with '@musical-patterns/pattern'."
		return
	fi
	set -e

	sed -i "/${PATTERN_ID}/d" pattern/src/registry.ts
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
	done < pattern/src/registry.ts
	sed -i "${LINE_NUMBER}i\ \ \ \ ${PATTERN_ID} = '${PATTERN_ID}'," pattern/src/registry.ts

	pushd pattern
		make ship MSG="registering ${PATTERN_ID}" PATTERN=""
	popd
}

add_pattern() {
	if [[ -d lab/src/${PATTERN} ]] ; then
		echo "${PATTERN} already added to '@musical-patterns/lab'."
		return
	fi

	pushd lab
		npm update || return
		make update PATTERN=template || return

		make add || return

		PATTERN_DIR=src/${PATTERN}/

		cp -r src/template/* ${PATTERN_DIR} || return

		pushd ${PATTERN_DIR}
			sed -i "s/Template/${PATTERN_TITLE}/g" README.md || return
			sed -i "s/copy\ me\ for\ quicker\ provisioning\ of\ new\ patterns/description\ TBA/g" README.md || return

			sed -i "s/PatternId.TEMPLATE/PatternId.${PATTERN_ID}/g" src/patterns.ts || return
			sed -i "s/Template/${PATTERN_TITLE}/g" src/patterns.ts || return

			pushd package
				sed -i "s/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-template\.git\"/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-${PATTERN}\.git\"/g" package.json || return
				sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package.json || return
				sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" package-lock.json || return
				npm version 1.0.0
			popd
		popd
	popd
}

exclude_pattern_directories() {
	sed -i "/${PATTERN}\/package\/dist/d" .idea/main.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/template\/package\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/${PATTERN}\/package\/dist\" \/>" .idea/main.iml || return
	sed -i "/${PATTERN}\/package\/dist/d" lab/.idea/lab.iml || return
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/template\/package\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/${PATTERN}\/package\/dist\" \/>" lab/.idea/lab.iml || return
}

create_pattern_repo
register_pattern
add_pattern
exclude_pattern_directories
