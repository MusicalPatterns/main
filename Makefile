MAKEFLAGS += --no-print-directory

commit:
	@cli/bin/commit.sh

deploy:
	@bin/deploy.sh

new:
	@bin/new.sh

pull:
	@cli/bin/pull.sh

push:
	@cli/bin/push.sh

service_ripple:
	@bin/service_ripple.sh

setup:
	@bin/setup.sh

start:
	@bin/start.sh

stash:
	@cli/bin/stash.sh

stash_pop:
	@cli/bin/stash_pop.sh

test:
	@:

update:
	@bin/update.sh
