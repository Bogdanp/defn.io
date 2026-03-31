#lang punct "../common.rkt"

---
title: Announcing Ruckus
date: 2026-03-31T10:21:00+02:00
---

I'm happy to announce the public release of [Ruckus], a Racket IDE for
iPhone and iPad. Check it out and let me know what you think!

Ruckus is [open source] and based on [Noise]. The frontend was coded
almost entirely by Claude Code, with a lot of architecture guidance and
code review from me. The project was on the back of my mind for a while,
but I probably would never have started it were it not for CC becoming
quite good at (what I find to be) mundane tasks like this.

My workflow was[^1] pretty simple. I would come up with a task and
tell CC to expand on it and write a plan to disk. Then I would ask it
to perform the task. It would summarize what it was about to do and
I'd correct it or tell it to go ahead. After it finished a first pass
at a task, I'd review the changes and concurrently ask it to review
them itself, either by running the `/simplify` command or by telling
it to "Ultrathink[^2] and review the pending changes for issues and
refactoring opportunities." While I don't have a counterexample to
compare with, my instinct is that this took overall less time than it
would've had I done everything manually -- which is not something I
would've felt even a few months ago with the state of the art at the
time.

I realize this is sounding like an ad for Anthropic, but I'm actually
ambivalent about these tools. On one hand, I love the act of programming
and I feel similarly to [Greg Knauss]. On the other hand, they are
becoming genuinely useful, so I guess I'll continue to use them for work
I don't feel like doing for now.

[^1]: It has since evolved to something more complicated that I'll
write about someday. But the version released today was built almost
entirely following this workflow.
[^2]: `ultrathink` is a keyword that temporarily turns on maximum
thinking effort. It only works interactively, so I would keep repeating
more or less the same phrasing after each task. At one point, I even
considered adding a keyboard macro for it.

[Ruckus]: https://ruckus.defn.io
[open source]: https://github.com/Bogdanp/Ruckus
[Noise]: https://github.com/Bogdanp/Noise
[Greg Knauss]: https://www.eod.com/blog/2026/02/lose-myself/
