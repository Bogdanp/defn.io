#lang punct

---
title: Announcing Try Racket
date: 2020-01-31T12:00:00+02:00
---

I'd been meaning to play with Racket's built-in [sandboxing]
capabilities for a while so yesterday I sat down and made [Try Racket].
It's a web app that lets you type in Racket code and run it. The code
you run is tied to your session and each session is allocated up to 60
seconds of run time per evaluation, with up to 128MB of memory used.
Filesystem and network access is not permitted and neither is access to
the FFI. The application itself runs inside a further-restricted Docker
container.

You can find the source code on [GitHub]. Contributions and improvements
are totally welcome!

[sandboxing]: https://docs.racket-lang.org/reference/Sandboxed_Evaluation.html?q=racket%2Fsandbox
[Try Racket]: https://try-racket.defn.io
[GitHub]: https://github.com/bogdanp/try-racket
