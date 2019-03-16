SHELL := /bin/bash

MAKEFLAGS += --no-print-directory --always-make

Makefile:
	@:

commit:
	@services/cli/bin/commit.sh

deploy:
	@bin/deploy.sh

fast-ship:
	@services/cli/bin/fast-ship.sh msg="${msg}"

lint:
	@:

match-config:
	@:

new:
	@bin/new.sh

publish:
	@:

pull:
	@services/cli/bin/pull.sh

push:
	@services/cli/bin/push.sh

propagate:
	@bin/propagate.sh

setup:
	@bin/setup.sh

ship:
	@CLI_DIR=services/cli/ services/cli/bin/ship.sh msg="${msg}"

start:
	@bin/start.sh

stash:
	@services/cli/bin/stash.sh

stash-pop:
	@services/cli/bin/stash-pop.sh

stop:
	@services/cli/bin/stop.sh

test:
	@:

update:
	@bin/update.sh
