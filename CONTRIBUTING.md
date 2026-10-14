<!--
SPDX-FileCopyrightText: © 2026 Jeffrey C. Ollie <jeff@ocjtech.us>
SPDX-License-Identifier: MIT
-->

# Contributing to zig-uuid

Thank you for wanting to help. This file covers what you need to know to make
a change and get it accepted. [README.md](README.md) says what zig-uuid is and
how it is used.

## Where to send changes

Report issues and send pull requests to the Tangled mirror:
<https://tangled.org/jcollie.dev/zig-uuid>.

## Setting up

Everything is pinned in the Nix flake, Zig 0.17.0 included:

```console
$ git clone https://git.jcollie.dev/jeff/zig-uuid.git
$ cd zig-uuid
$ nix develop
```

The development shell has `zig`, `reuse` and `git-pages-cli`. Without Nix,
you need Zig 0.17.0 and nothing else: the library has no dependencies.

The `zig-0.16` branch holds the version that builds with Zig 0.16. Only
critical fixes are backported to it; everything else goes to `main`.

## Before you send a change

CI runs these, and a change has to pass all of them:

```console
$ reuse lint                            # every file has a license
$ zig fmt --check --exclude zig-pkg .   # Zig is formatted
$ zig build test --summary all          # the tests
$ zig build                             # the example program
```

`zig build docs` should also succeed, since the documentation is published
from `main` once the tests pass.

## Where things are

| Path | What |
| --- | --- |
| `src/uuid.zig` | The whole library: the `UUID` type, creation, parsing and formatting, and the tests |
| `src/main.zig` | A small program that prints a random UUID, run with `zig build run` |
| `src/bench.zig` | Benchmarks of parsing and formatting, run with `zig build bench` |

## Making changes

### Tests

Every behavior change comes with a test, at the bottom of `src/uuid.zig`.
Where RFC 9562 gives an example value or a test vector, test against it and
link the section of the RFC in a comment beside the test.

### Errors

Malformed input is an error, never a panic. Parsing returns
`error.MalformedUUID` for anything that is not one of the accepted forms.

### Design

The library makes no allocations and reads nothing from the environment
implicitly: timestamps, randomness and node IDs come from the caller through
`UUID.NewOptions`. A change that adds a dependency, an allocation or a hidden
source of time or randomness will not be accepted. `UUID` stays a packed
union of exactly 128 bits.

### Performance

Parsing and formatting are on the hot path for many callers. If a change
touches them, run `zig build bench` before and after and say what changed.

### Documentation

The API documentation is generated from doc comments and published at
<https://jeff.jcollie.page/zig-uuid/>. A public declaration gets a doc
comment, with a link to the part of RFC 9562 it implements where there is
one. When behavior changes, update `README.md` to describe how things are
now, not how they changed.

## Licensing

zig-uuid is MIT licensed and follows [REUSE](https://reuse.software/). Every
new file starts with an SPDX header like the ones already in the tree; a
file that cannot hold one goes in `REUSE.toml`. By sending a change you agree
to license it under the MIT license.

## Commits

The first line is a short summary in the imperative ("add the Windows
registry form"). The body explains what changed and why.
