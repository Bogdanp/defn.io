#lang punct

---
title: Announcing racket-crontab
date: 2022-08-20T12:00:00+03:00
---

Earlier this week, [Jesse Alama] brought up the topic of scheduling
cron jobs with [koyo] and we both agreed that it would be nice if koyo
had built-in support for that sort of thing. So, I wrote [crontab],
a little library for parsing cron-style schedules and executing
code based on them. On top of that functionality, I've added a new
[`koyo/crontab`][scheduling-doc] module to koyo that integrates with the
component system.

[Jesse Alama]: https://jessealama.net/
[koyo]: https://docs.racket-lang.org/koyo/index.html
[crontab]: https://docs.racket-lang.org/crontab-manual/index.html
[scheduling-doc]: https://docs.racket-lang.org/koyo/scheduling.html
