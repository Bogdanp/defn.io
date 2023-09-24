#lang punct

---
title: Announcing setup-racket
date: 2019-11-03T10:00:00+02:00
---

[GitHub Actions] are going to become generally-available next week so
I created an action for installing Racket. You can find it [on the
marketplace][marketplace]. Here's what a minimal CI configuration for a
Racket package might look like:

```yaml
on: [push, pull_request]
name: CI
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - uses: Bogdanp/setup-racket@v0.1
        with:
          architecture: x64
          distribution: full
          variant: regular
          version: 7.4
      - run: raco test --drdr my-package-test/
```

And a more involved one using a test matrix:

```yaml
on: [push, pull_request]
name: CI
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        racket-version: ["7.3", "7.4"]
        racket-variant: ["regular", "CS"]
    name: "CI using Racket ${{ matrix.racket-version }} (${{ matrix.racket-variant }})"
    steps:
      - uses: actions/checkout@master
      - uses: Bogdanp/setup-racket@v0.1
        with:
          architecture: x64
          distribution: full
          variant: ${{ matrix.racket-variant }}
          version: ${{ matrix.racket-version }}
      - run: raco test --drdr my-package-test/
```

The above configuration will cause the tests to be run against regular
Racket 7.3 and 7.4 as well as Racket-on-Chez 7.3 and 7.4.

One limitation right now is that the Action only supports installing
Racket on Linux targets, but I can update it to support Windows and
macOS if there is interest.

Check it out an let me know what you think!


[GitHub Actions]: https://github.com/features/actions
[marketplace]: https://github.com/marketplace/actions/setup-racket-environment
