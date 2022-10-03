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

You don’t need to use the `new` script for a new pattern within an existing pattern repo, only for new pattern repos.

`make propagate msg="new wave"`

The omnicommand.
Begins with the `cli` and works its way through the stack of services up to the `lab`.
Each stop it updates dependencies, commits, pushes, and publishes.
Then it combs over each pattern, updating them, committing, pushing, and publishing.
Then it updates the lab with the updated patterns, deploys it, and ships one final time.
Then it ships the whole `main` project.
Expect this to take a pretty long time.

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

### id

[README.md](https://github.com/MusicalPatterns/id/blob/master/README.md)

### metadata

[README.md](https://github.com/MusicalPatterns/metadata/blob/master/README.md)

### spec

[README.md](https://github.com/MusicalPatterns/spec/blob/master/README.md)

### material

Takes whatever amazing craziness a given pattern calls for and compiles it down into a basic playable format.
Then hooks it up to the Web Audio and WebXR APIs and gives you the power to play it (and pause it, etc.)

[README.md](https://github.com/MusicalPatterns/material/blob/master/README.md)

### pattern

Defines the structure of patterns: `{ material, metadata, spec }`.
- `id` uniquely identifies each pattern.
- `metadata` has no "effect" per se. It's the blog post, formatted name, timestamps, etc.
- `material` is the code that makes the sounds: its properties and how they affect the output scales and voices and notes.
- `spec` is the controls for the material: configuration for how the user can adjust the properties (constraints, custom validation, etc), and presets.
Starting with `@musical-patterns/pattern` and continuing in `@musical-patterns/playroom` and all pattern repos, to help organize thought, a common module structure matching this structure is used.

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
