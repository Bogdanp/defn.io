#lang punct

---
title: Improvements in koyo 0.9
date: 2021-07-30T10:40:00+03:00
---

Recently, [Daniel Holtby] [improved] the implementation of
[`racket/rerequire`][rere], which, in turn, inspired me to improve
koyo's own code-reloading implementation. Version 0.9 (released today)
no longer restarts the application process on every change and, instead,
uses `dynamic-rerequire` to only reload the modules that change as well
as any modules that depend on them. On Matchacha, which is about 11k
lines of Racket code (excluding whitespace), this improves reload times
by 5 to 10x, depending on the modules being reloaded.

Additionally, I added support for augmenting existing REPL
sessions with the functionality of `raco koyo console` via
[`start-console-here`][sch].

You can see the two changes in action in [this short
screencast][screencast].

[Daniel Holtby]: https://github.com/djholtby
[improved]: https://github.com/racket/racket/pull/3926
[rere]: https://docs.racket-lang.org/reference/interactive.html#%28mod-path._racket%2Frerequire%29
[sch]: https://koyoweb.org/console/index.html#%28def._%28%28lib._koyo%2Fconsole..rkt%29._start-console-here%29%29
[screencast]: https://www.youtube.com/watch?v=wWj7OPvXGgA
