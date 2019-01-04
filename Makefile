MAKEFLAGS += --no-print-directory

commit:
	@cli/bin/commit.sh

deploy:
	@deploy.sh

new:
	@new.sh

pull:
	@cli/bin/pull.sh

push:
	@cli/bin/push.sh

ship:
	@ship.sh

setup:
	@setup.sh

start:
	@start.sh

stash:
	@cli/bin/stash.sh

stash_pop:
	@cli/bin/stash_pop.sh

test:
	@:

update:
	@update.sh
