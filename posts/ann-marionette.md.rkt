#lang punct

---
title: Announcing marionette
date: 2019-06-08T15:45:00+03:00
---

I just released the first version of [marionette][marionette] (named
after [the protocol] it implements), a Racket library that lets you
remotely control the Firefox web browser. Think "puppeteer", but for
Firefox.

You can install it from the package server with:

    raco pkg install marionette

And the docs should show up on the package server within the next couple
of days. In the mean time, you can run

    raco docs marionette

after installing the package to read its docs locally.

It's still early days, but the library already supports most of the
basic things you would expect it to. If you try it out, let me know what
you think!

[marionette]: https://github.com/Bogdanp/marionette
[the protocol]: https://firefox-source-docs.mozilla.org/testing/marionette/marionette/Protocol.html
