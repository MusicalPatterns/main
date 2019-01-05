MAKEFLAGS += --no-print-directory

commit:
	@services/cli/bin/commit.sh

deploy:
	@bin/deploy.sh

lint:
	@:

new:
	@bin/new.sh

publish:
	@:

pull:
	@services/cli/bin/pull.sh

push:
	@services/cli/bin/push.sh

service_ripple:
	@bin/service_ripple.sh

setup:
	@bin/setup.sh

ship:
	@services/cli/bin/ship.sh

start:
	@bin/start.sh

stash:
	@services/cli/bin/stash.sh

stash_pop:
	@services/cli/bin/stash_pop.sh

test:
	@:

update:
	@bin/update.sh
