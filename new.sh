#!/usr/bin/env sh

set -e

export PATTERN_ID=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L_&/g' <<< ${PATTERN} | sed -r 's/[a-z]+/\U&/g')
export PATTERN_TITLE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\ &/g' <<< ${PATTERN} | sed 's/\b\(.\)/\u\1/g')
export PATTERN_PACKAGE=$(sed 's/^[[:upper:]]/\L&/;s/[[:upper:]]/\L\-&/g' <<< ${PATTERN})

register_pattern() {
	grep -q ${PATTERN_ID} pattern/src/registry.ts
	if [[ $? == 0 ]] ; then
		echo "${PATTERN_ID} already registered with '@musical-patterns/pattern'."
		return
	fi

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
		npm update
		make update PATTERN=template

		make add

		PATTERN_DIR=src/${PATTERN}/

		cp -r src/template/* ${PATTERN_DIR}

		sed -i "s/Template/${PATTERN_TITLE}/g" ${PATTERN_DIR}README.md
		sed -i "s/copy\ me\ for\ quicker\ provisioning\ of\ new\ patterns/description\ TBA/g" ${PATTERN_DIR}README.md

		sed -i "s/PatternId.TEMPLATE/PatternId.${PATTERN_ID}/g" ${PATTERN_DIR}src/patterns.ts
		sed -i "s/Template/${PATTERN_TITLE}/g" ${PATTERN_DIR}src/patterns.ts

		sed -i "s/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-template\.git\"/\"url\": \"https:\/\/github\.com\/MusicalPatterns\/pattern-${PATTERN}\.git\"/g" ${PATTERN_DIR}package/package.json
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" ${PATTERN_DIR}package/package.json
		sed -i "s/\"name\": \"@musical-patterns\/pattern-template\"/\"name\": \"@musical-patterns\/pattern-${PATTERN_PACKAGE}\"/g" ${PATTERN_DIR}package/package-lock.json
		npm version 1.0.0
	popd
}

exclude_pattern_directories() {
	sed -i "/${PATTERN}\/package\/dist/d" .idea/main.iml
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/template\/package\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/lab\/src\/${PATTERN}\/package\/dist\" \/>" .idea/main.iml
	sed -i "/${PATTERN}\/package\/dist/d" lab/.idea/lab.iml
	sed -i "/<excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/template\/package\/dist\" \/>/a \ \ \ \ \ \ <excludeFolder url=\"file:\/\/\$MODULE_DIR\$\/src\/${PATTERN}\/package\/dist\" \/>" lab/.idea/lab.iml
}

register_pattern
add_pattern
exclude_pattern_directories
