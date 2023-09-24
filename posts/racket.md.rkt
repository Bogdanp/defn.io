#lang punct

---
title: Racket
date: 2018-10-21T17:00:00+00:00
---

I've been playing around with [Racket] every chance I got since early
September of this year.  This post is going to serve as a sort of
experience report of my foray into Racket so far.

## Things I Like

### Editor Support

[Greg Hendershott]'s [racket-mode] for emacs has been wonderful to
work with.  It provides syntax highlighting, REPL integration and
auto-completion as well as a macro stepper.  All of which are highly
useful while working on Racket code.

### Documentation

There seems to be a huge emphasis on documentation within the
community, which is great.  Everything is thoroughly documented and
the documentation for installed packages is all built locally (with
cross-references!) so you have access to it regardless of
connectivity.  And it's pretty!  The Racket ecosystem has some of the
most readable websites I've ever been to.

### Consistency

The language is remarkably consistent, from the way modules and
packages are organized to the way documentation is written.

### Interactive Development

Despite primarily working with dynamic languages every day, I find
that I don't use the REPL with those languages nearly as much or as
tightly as I do with lisps.  I don't know for sure why that is but it
probably boils down to the nature of s-expressions: it's just *so
convenient* to `eval-last-sexp` in lisps in a way that you can only
approximate in a language like Python (and, believe me, I've tried!).

### Contracts

[Contracts] are a way to specify and validate the boundaries between
parts of a system.  They are highly expressive (eg. `in-range?`) and
composable and produce great error messages when the invariants they
describe get broken.  Unfortunately, they do incur a runtime cost and
there's no way to disable them automatically for production, but they
can be specified separately from the implementation of the things they
describe such that you can add them to the functions and structures
that your module exports and even have "unsafe" flavors of your
modules from which you export versions of the same functions and
structs without contracts for those times when performance really is
an issue.

For a cool-but-unrelated-to-Racket talk on contracts, check out
["Contracts For Getting More Programs Less Wrong"] by Rob Simmons from
this year's Strange Loop.

### Modules

I really like the fact that you have to be explicit about what things
your modules export.  This reminds me a lot of ML-style languages and
is great for encapsulation.

## Things I Dislike

"Dislike" may be too strong a word for what I'm about to describe.
Most of these things simply represent different tradeoffs to what I'm
normally used to.

### Error Reporting

This may just be because I'm not used to the error messages yet, but I
find Racket's exception reporting hard to decipher and I often run
into errors that contain no information regarding *where* in the
source code the error occurred.

### Lack of Docstrings

There's no built-in support for function docstrings and most of the
code I've read seems to separate code and documentation.  On the one
hand this makes it so looking up a function's documentation via the
REPL is not possible which is slightly annoying (though racket-mode
provides `racket-describe` for this purpose), but, on the other hand,
I like that there is a single documentation format that everyone
agrees on ([Scribble]) and the prevalence of cross-references makes
looking up a function's documentation easy enough.

### Unit Testing

Racket's [rackunit] is lacking support for a few things I'd expect
from such a library.  There doesn't seem to be any built-in way to do
set up and teardown (I've been using `dynamic-wind` for this purpose),
the facilities for grouping tests together feel flimsy and I don't
understand why `test-suite`s have to be run manually.


[Racket]: https://racket-lang.org
[Greg Hendershott]: http://greghendershott.com/
[racket-mode]: https://github.com/greghendershott/racket-mode
[Contracts]: https://docs.racket-lang.org/reference/contracts.html
["Contracts For Getting More Programs Less Wrong"]: https://www.youtube.com/watch?v=lNITrPhl2_A
[Scribble]: https://docs.racket-lang.org/scribble/
[rackunit]: https://docs.racket-lang.org/rackunit/
