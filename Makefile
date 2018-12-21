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

ripple:
	@ripple.sh

setup:
	@setup.sh

start:
	@start.sh

update:
	@update.sh
