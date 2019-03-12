[![Build Status](https://travis-ci.com/MusicalPatterns/main.svg?branch=master)](https://travis-ci.com/MusicalPatterns/main)

# Musical Patterns - main

## development

`make deploy`

Sends the `lab` up to whatever IaaS we're using at the time.

`make new pattern=myPattern`

Adds a new pattern to Musical Patterns.

- creates a new repo in the `MusicalPatterns` GitHub org
- register pattern in the `@musical-patterns/cli` service
- register pattern in the `@musical-patterns/pattern` service
- submodule the pattern under the `patterns/` directory
- initializes the pattern code by cloning from the `@musical-patterns/pattern-template` repo
- includes the pattern in the `@musical-patterns/lab` so that it can be deployed (though it filters it initially, until it's ready)
- excludes directories in the `patterns/` directory from the IDE
- adds the pattern's `node_modules/.bin` to the `$PATH`

`make service-ripple msg="new wave"`

Begins with the `cli` and working its way through the stack of services up to the `lab`.
Each stop it updates dependencies, commits, pushes, and publishes. Everything but deploying the app.

`make setup`

Sets up your environment, including cloning down all the projects as siblings to main.
It's not always best to do your development in `main`.

`make start`

Starts up the `lab` locally.

`make update`

Updates dependencies, recursively.

## services

### cli

All about workflow. 
Provides all the common commands, configuration, and dependencies for developing a Musical Patterns repo.
Takes care of building, testing, linting, publishing, storing, and sharing the code in every other repo.

[README.md](https://github.com/MusicalPatterns/cli/blob/master/README.md)

### utilities

Shared generic utilities for code, math, music, testing, and nominal typing used throughout the other repos.

[README.md](https://github.com/MusicalPatterns/utilities/blob/master/README.md)

### performer

Given a pattern compiled by the `@musical-patterns/compiler`, hooks it up to the Web Audio and WebXR APIs and gives you the power to play it (and pause it, etc.)

[README.md](https://github.com/MusicalPatterns/performer/blob/master/README.md)

### compiler

Takes whatever amazing craziness a given pattern calls for and compiles it down into a basic format playable by the `@musical-patterns/performer`.

[README.md](https://github.com/MusicalPatterns/compiler/blob/master/README.md)

### snapshot

Uses the `@musical-patterns/compiler` to maintain an up-to-date copy of compiled pattern data in the repo.
This `snapshot.json` file is tested against before each shipment, ensuring your pattern doesn't change if you don't mean it to.
It also can be played directly by the `@musical-patterns/performer` if you are performing in an environment without a `@musical-patterns/compiler`, or simply don't need to modify the pattern's initial spec.

[README.md](https://github.com/MusicalPatterns/snapshot/blob/master/README.md)

### pattern

Defines the structure of patterns: `{ material, metadata, spec }`.
- `metadata` has no "effect" per se. It's the blog post, formatted name, timestamps, etc.
- `material` is the code that makes the sounds: its properties and how they affect the output scales and voices and notes.
- `spec` is the controls for the material: configuration for how the user can adjust the properties (constraints, custom validation, etc), and presets.
Starting with `@musical-patterns/pattern` and continuing in `@musical-patterns/playroom` and all pattern repos, to help organize thought, a common module structure matching this structure is used.

`@musical-patterns/pattern` is also the place where all patterns must be registered to get an ID.
This service also provides standard settings and some additional utilities that don't belong with the `@musical-patterns/utilities` because they use Musical Patterns specific resources from `@musical-patterns/performer`, `@musical-patterns/compiler`, or `@musical-patterns/pattern`.

[README.md](https://github.com/MusicalPatterns/pattern/blob/master/README.md)

### playroom

The web-based UI for playing (with) the patterns.
Just call `setupPlayroom` with whichever patterns you want.

[README.md](https://github.com/MusicalPatterns/playroom/blob/master/README.md)

### lab

The actual final web app which gets deployed online.
A thin wrapper around a `@musical-patterns/playroom` which is set up with every ready-to-go pattern.

[README.md](https://github.com/MusicalPatterns/lab/blob/master/README.md)

## patterns

Each pattern, like the services, is submoduled here.

Each pattern has the `@musical-patterns/playroom` as a dependency such that one can start up a playroom with just that pattern to get quick feedback on how it's sounding.
