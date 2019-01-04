[![Build Status](https://travis-ci.com/MusicalPatterns/main.svg?branch=master)](https://travis-ci.com/MusicalPatterns/main)

# Musical Patterns - main

## development

`make deploy`

Sends the `lab` up to GCP.

`make setup`

Sets up your environment, including cloning down all the projects as siblings to main.
It's not always best to do your development in `main`.

`make ship MSG="new wave"`

Begins with the `cli` and working its way through the stack of intra-project dependencies up to the `lab`.
Each stop it updates dependencies, commits, pushes, and publishes. Everything but deploying the app.

Use `make ship FROM="performer"` to ship but instead of from `cli`, resuming from performer.
This is useful if your ship command failed partway through and you have no need to waste time on lower-level repos again.

`make start`

Starts up the `lab` locally.

`make update`

Updates dependencies, recursively.

## cli

[README.md](https://github.com/MusicalPatterns/cli/blob/master/README.md)

## compiler

[README.md](https://github.com/MusicalPatterns/compiler/blob/master/README.md)

## lab

[README.md](https://github.com/MusicalPatterns/lab/blob/master/README.md)

## pattern

[README.md](https://github.com/MusicalPatterns/pattern/blob/master/README.md)

## performer

[README.md](https://github.com/MusicalPatterns/performer/blob/master/README.md)

## playroom

[README.md](https://github.com/MusicalPatterns/playroom/blob/master/README.md)

## registry

[README.md](https://github.com/MusicalPatterns/registry/blob/master/README.md)

## utilities

[README.md](https://github.com/MusicalPatterns/utilities/blob/master/README.md)
