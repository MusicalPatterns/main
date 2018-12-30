#!/usr/bin/env bash

set -e

update_recursively() {
	make clean_updates
	npm update || return
	git submodule foreach update_recursively
}
export -f update_recursively
update_recursively
