#!/usr/bin/env sh

set -e

update_recursively() {
	npm i
	npm update
	git submodule foreach update_recursively
}
export -f update_recursively
update_recursively
