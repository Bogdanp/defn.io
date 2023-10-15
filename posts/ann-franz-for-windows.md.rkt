#lang punct "../common.rkt"

---
title: Franz for Windows
date: 2023-10-15T09:00:00+02:00
---

Today marks the first beta release of [Franz] for Windows!

•(fig
  "Franz_for_Windows.png"
  "Franz is a desktop client for Apache Kafka."
  #:alt "A screenshot of a Franz for Windows workspace.")

I had been planning to work on a Windows version of Franz since last
year. Originally, I was going to implement the UI in C# (or possibly F#
after a strong recommendation from Michael Sperber), but then [Ben] and
I wrote [a paper] [^1] about my declarative wrapper around `racket/gui`
earlier this year and that inspired me to try using it to implement the
Windows (and, soon, Linux!) version.

On macOS, Franz is •(@ "Announcing Franz" "implemented") using a
combination of Racket for the core logic and Swift for the UI. The
Windows version reuses the core and implements all the app's views
afresh using [gui-easy]. The end result is about 5k lines of GUI code,
including many small component "tests" that let me easily exercise views
in isolation (think SwiftUI Previews, but, well, functional[^2] and
interactive). For comparison, the Swift version has about 8.2k lines
of Swift code — a mix of AppKit and SwiftUI — and about 4.5k of XML
representing XIBs built using the Xcode Interface Builder. Being that
`racket/gui` is a cross-platform library, and therefore it has to target
the least common denominator of the three platforms it supports in terms
of features, the end result isn't as polished as the Mac version or as a
Windows Forms[^3] version could be, but it gets reasonably close.

Since the source is all Racket, distribution is trivial: just call `raco
exe` to generate an executable and then `raco dist` to package it up.
The only snag has been Microsoft's SmartScreen. I'm not willing to pay
for an EV certificate[^4] from one of the blessed vendors, so I need to
manually submit new Windows releases to Microsoft to check for malware,
but that hasn't been a huge hassle so far, apart from the processing
times.

In •(@ "Announcing Franz" "my original announcement post") for Franz I
had mentioned that I think this kind of separation between backend and
frontend is a very productive way of developing desktop apps and I think
that bears out here. I only had to make minimal changes to the core code
in order to support this new version and I was able to get everything
done in about two months' worth of working in my free time. I think a
small team using this model can move very fast and build great native
apps for every platform.

Franz is •(@ "ann-franz-source-available" "source available") so you can
take a peek at [the implementation][src] yourself if you're interested.
If you use Franz for your work, I'd love to get your feedback!

[^1]: See also [Ben's talk at ICFP][talk].
[^2]: As in "working," not the programming paradigm.
[^3]: Or whatever the current Windows GUI framework _du jour_ is.
[^4]: What a _racket_!

[Franz]: https://franz.defn.io
[Ben]: https://benknoble.github.io/
[a paper]: /papers/fungui-funarch23.pdf
[gui-easy]: https://docs.racket-lang.org/gui-easy/index.html
[src]: https://github.com/Bogdanp/Franz/tree/master/FranzCross
[talk]: https://www.youtube.com/watch?v=2YAMKwQf3NA&t=9160s
