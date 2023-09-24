#lang punct

---
title: Announcing north
date: 2019-01-31T07:00:00+02:00
---

A couple of days ago, I released [north], a database schema migration
tool written in Racket. It currently supports PostgreSQL and SQLite, but
new adapters are extremely easy to add and my main reason for building
it was because I wanted not only a CLI utility but also programmatic
access to do migrations from Racket. I'm going to make that last part
easy for everyone with the next release after I clean up some of the
internals and write more docs.

If you do check it out, let me know what you think!

[north]: http://docs.racket-lang.org/north/index.html
