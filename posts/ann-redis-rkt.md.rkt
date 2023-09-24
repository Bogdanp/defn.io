#lang punct

---
title: Announcing redis-rkt
date: 2019-10-06T19:00:00+03:00
---

Another Racket thing! [redis-rkt] is a new Redis client for Racket that
I've been working on these past few weeks. Compared to the existing
`redis` and `rackdis` packages, it:

* is fully documented,
* is safer due to strict use of contracts,
* is faster,
* supports more commands and
* its API tries to be idiomatic, rather than being just a thin wrapper
  around Redis commands.

[Check it out!][redis-rkt]

[redis-rkt]: https://github.com/bogdanp/racket-redis
