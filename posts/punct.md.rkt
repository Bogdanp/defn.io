#lang punct

---
title: Powered by •
date: 2023-09-25T21:00:00+03:00
---

Following in the long tradition of programmers writing blog engines
instead of blogging, this site is now powered by [Joel Dueck]'s [Punct].

I'd been meaning to make the switch ever since Joel posted [a video
of Punct in Practice] to the Racket Discord and I finally took the
plunge this weekend. You can find the source code for the new site [on
GitHub][src].

The [old site][old] was implemented using [Hugo] and it served me well,
but I never learned how to use Hugo properly because I could never make
my way effectively around their documentation, so I was always a bit
wary of making changes to the structure of the site (for example, making
my own theme and other kinds of enhancements).

Punct is similar to other Racket publishing tools like [Pollen] and
[Scribble] in that documents (i.e. pages) are just Racket modules with a
reader that makes it convenient to input regular markup, but that lets
you escape to and use inline Racket when necessary. This means that, at
any point in a document, you can fall back on the full power of Racket.
It's hard to overstate how nice this model is so I highly encourage you
to check out Joel's video and see for yourself.

[Joel Dueck]: https://joeldueck.com/
[Punct]: https://joeldueck.com/what-about/punct/
[a video of Punct in Practice]: https://www.youtube.com/watch?v=9zxna1tlvHU
[Hugo]: https://gohugo.io/
[old]: https://github.com/Bogdanp/personal-website
[Pollen]: https://docs.racket-lang.org/pollen/
[Scribble]: https://docs.racket-lang.org/scribble/index.html
[src]: https://github.com/Bogdanp/defn.io
