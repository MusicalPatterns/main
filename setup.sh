#!/usr/bin/env bash

set -e

PATHS="export PATH=\$PATH:~/workspace/MusicalPatterns/main/cli/node_modules/.bin/:~/workspace/MusicalPatterns/main/compiler/node_modules/.bin/:~/workspace/MusicalPatterns/main/lab/node_modules/.bin/:~/workspace/MusicalPatterns/main/registry/node_modules/.bin/:~/workspace/MusicalPatterns/main/performer/node_modules/.bin/:~/workspace/MusicalPatterns/main/playroom/node_modules/.bin/:~/workspace/MusicalPatterns/main/utilities/node_modules/.bin:~/workspace/MusicalPatterns/main/pattern/node_modules/.bin"
sed -i -e "/${PATHS//\//\\/}/d" ~/.bash_profile
echo ${PATHS} >> ~/.bash_profile

if [[ $(gcloud config configurations list | grep -m1 musical-patterns) ]] ; then
	echo "The 'musical-patterns' configuration already exists."
else
	gcloud config configurations create musical-patterns
fi
gcloud config configurations activate musical-patterns
gcloud config set project musical-patterns
gcloud config set account kingwoodchuckii@gmail.com

npm config set git-tag-version=false

git config --get user.name > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    printf "${Yellow}Please set your global git user name: "
    read USER_NAME
    git config --global user.name ${USER_NAME}
fi
git config --get user.email > /dev/null 2>&1
if [[ $? -ne 0 ]] ; then
    printf "Please set your global git user email: "
    read USER_EMAIL
    git config --global user.email ${USER_EMAIL}
fi
git config --global core.autocrlf false
git config --global core.eol lf

make pull
