#!/usr/bin/env bash

set -e

PATHS="export PATH=\$PATH"\
":~/workspace/MusicalPatterns/main/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/cli/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/id/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/lab/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/material/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/metadata/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/pattern/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/playroom/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/spec/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/services/utilities/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/beatenPath/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/hafuhafu/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/houndstoothtopiaTheme/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/materialQa/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/moeom/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/omnizonk/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/playroomTest/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/prototyper/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/stepwise/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/template/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/tsraxcfaubdj/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/xenharmonicSeries/node_modules/.bin/"\
":~/workspace/MusicalPatterns/main/patterns/zdaubyaos/node_modules/.bin/"\
""
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
#npm config set script-shell "C:\\Program Files\\git\\bin\\bash.exe"
npm config delete script-shell

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

pull_recursively() { # whenever this is updated, please compare with @musical-patterns/cli/bin/pull.sh
	git submodule update --init --recursive || return
	git checkout master || return
	git pull -r || return
	git submodule foreach pull_recursively
}
export -f pull_recursively
pull_recursively
