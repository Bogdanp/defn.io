#lang punct

---
title: Announcing forms
date: 2019-01-21T21:00:00+02:00
---

Today marks the first public release of [forms], a Racket library for
web form validation. Racket's [formlets] module from the standard
library already does something similar, but, unfortunately, it lacks any
facilities for easily showing validation errors to end users which is a
big part of what I want from this kind of library. Another nice thing
about this new library is it'll be able to validate things other than
forms -- like JSON -- soon!

I hope you check it out, and, if you do, let me know what you think!

[forms]: http://docs.racket-lang.org/forms/index.html
[formlets]: https://docs.racket-lang.org/web-server/formlets.html
