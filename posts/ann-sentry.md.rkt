#lang punct

---
title: Announcing racket-sentry
date: 2019-07-02T10:00:00+03:00
---

I just released the first version of [sentry][racket-sentry], a Racket
library that lets you capture exceptions using the [Sentry] API.

You can install it from the package server with:

    raco pkg install sentry

And the docs should show up on the package server within the next couple
of days. In the mean time, you can run

    raco docs sentry

after installing the package to read its docs locally.

[racket-sentry]: https://github.com/Bogdanp/racket-sentry
[sentry]: https://sentry.io
