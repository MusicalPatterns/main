# Musical Patterns - main

## development

`make deploy`

Sends the `lab` up to GCP.

`make ripple MSG="new wave"`

Begins with the `cli` and working its way through the stack of intra-project dependencies up to the `lab`.
Each stop it updates dependencies, commits, pushes, and publishes.

`make setup`

Sets up your environment, including cloning down all the projects as siblings to main.
It's not always best to do your development in `main`.

`make start`

Starts up the `lab` locally.

`make update`

Updates dependencies for all repos, recursively.

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

## utilities

[README.md](https://github.com/MusicalPatterns/utilities/blob/master/README.md)
