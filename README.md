[![Build Status](https://travis-ci.com/MusicalPatterns/main.svg?branch=master)](https://travis-ci.com/MusicalPatterns/main)

# Musical Patterns - main

## development

`make deploy`

Sends the `lab` up to GCP.

`make new pattern=myPattern`

Adds a new pattern to Musical Patterns.

- creates a new repo in the `MusicalPatterns` GitHub org
- register pattern in the `@musical-patterns/pattern` service
- submodule the pattern under the `patterns/` directory
- initializes the pattern code by cloning from the `@musical-patterns/pattern-template` repo
- includes the pattern in the `@musical-patterns/lab` so that it will be deployed
- excludes directories in the `patterns/` directory from the IDE
- adds the pattern's `node_modules/.bin` to the `$PATH`

`make setup`

Sets up your environment, including cloning down all the projects as siblings to main.
It's not always best to do your development in `main`.

`make service-ripple msg="new wave"`

Begins with the `cli` and working its way through the stack of services up to the `lab`.
Each stop it updates dependencies, commits, pushes, and publishes. Everything but deploying the app.

Use `make service-ripple from="performer"` to ship but instead of from `cli`, resuming from performer.
This is useful if your ship command failed partway through and you have no need to waste time on lower-level repos again.

`make start`

Starts up the `lab` locally.

`make update`

Updates dependencies, recursively.

## services

### cli

[README.md](https://github.com/MusicalPatterns/cli/blob/master/README.md)

### compiler

[README.md](https://github.com/MusicalPatterns/compiler/blob/master/README.md)

### lab

[README.md](https://github.com/MusicalPatterns/lab/blob/master/README.md)

### pattern

[README.md](https://github.com/MusicalPatterns/pattern/blob/master/README.md)

### performer

[README.md](https://github.com/MusicalPatterns/performer/blob/master/README.md)

### playroom

[README.md](https://github.com/MusicalPatterns/playroom/blob/master/README.md)

### utilities

[README.md](https://github.com/MusicalPatterns/utilities/blob/master/README.md)
