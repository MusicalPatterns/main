#!/usr/bin/env sh

set -e

update_recursively() {
	npm i || return
	npm update || return
	git submodule foreach update_recursively
}
export -f update_recursively
update_recursively
