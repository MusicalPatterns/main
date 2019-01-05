#!/usr/bin/env bash

set -e

update_recursively() {
	npm update || return
	git submodule foreach update_recursively
}
export -f update_recursively
update_recursively
