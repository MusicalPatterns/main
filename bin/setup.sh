#!/usr/bin/env bash

set -e

if [[ $(gcloud config configurations list | grep -m1 musical-patterns) ]] ; then
	echo "The 'musical-patterns' configuration already exists."
else
	gcloud config configurations create musical-patterns
fi
gcloud config configurations activate musical-patterns
gcloud config set project musical-patterns
gcloud config set account kingwoodchuckii@gmail.com

npm config set git-tag-version=false
npm config set script-shell "C:\\Program Files\\git\\bin\\bash.exe"

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

pull_recursively() {
	git checkout master || return
	git submodule update --init --recursive || return
	git pull -r || return
	git submodule foreach pull_recursively
}
export -f pull_recursively
pull_recursively
