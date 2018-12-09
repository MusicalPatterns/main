#!/usr/bin/env sh

set -e

git config --get user.name > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    printf "${Yellow}Please set your global git user name: ${NC}"
    read USER_NAME
    git config --global user.name $USER_NAME
fi

git config --get user.email > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    printf "${Yellow}Please set your global git user email: ${NC}"
    read USER_EMAIL
    git config --global user.email $USER_EMAIL
fi

function setup_submodules {
	git submodule update --init --recursive
	git submodule foreach setup_submodules
	git submodule foreach git checkout master
	git submodule foreach make pull
	git make pull
	npm i
}

setup_submodules

gcloud config configurations create musical-patterns
gcloud config set project musical-patterns
gcloud config set account kingwoodchuckii@gmail.com

gcloud auth application-default login

npm config set git-tag-version=false

PATHS="export PATH=\$PATH:~/workspace/MusicalPatterns/cli/node_modules/.bin/:~/workspace/MusicalPatterns/compiler/node_modules/.bin/:~/workspace/MusicalPatterns/lab/node_modules/.bin/:~/workspace/MusicalPatterns/pattern/node_modules/.bin/:~/workspace/MusicalPatterns/performer/node_modules/.bin/:~/workspace/MusicalPatterns/playroom/node_modules/.bin/:~/workspace/MusicalPatterns/utilities/node_modules/.bin/:~/workspace/MusicalPatterns/main/cli/node_modules/.bin/:~/workspace/MusicalPatterns/main/compiler/node_modules/.bin/:~/workspace/MusicalPatterns/main/lab/node_modules/.bin/:~/workspace/MusicalPatterns/main/pattern/node_modules/.bin/:~/workspace/MusicalPatterns/main/performer/node_modules/.bin/:~/workspace/MusicalPatterns/main/playroom/node_modules/.bin/:~/workspace/MusicalPatterns/main/utilities/node_modules/.bin"
sed -i -e "/${PATHS//\//\\/}/d" ~/.bash_profile
echo ${PATHS} >> ~/.bash_profile
