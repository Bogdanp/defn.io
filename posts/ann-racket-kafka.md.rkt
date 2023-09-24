#lang punct

---
title: Announcing racket-kafka
date: 2022-03-12T10:00:00+02:00
---

For the past month or so, I've been working on implementing a
pure-Racket client for [Apache Kafka]. Yesterday, it reached a point
where it can do the bare minimum you would expect from it: produce data
and join consumer groups to consume data. Kafka has a fairly large
feature-set so there's a ton left to do, but I figure this is a good
time to announce the library and get feedback. If you're interested in
using Kafka with Racket, please give it a try and let me know what you
think.

You can find the source code on [GitHub][src] and the docs on [the
Racket Package server][docs].

PS: While writing the library, I needed an easy way to write lots of
little wire procotol parsers, so I stacked my yaks and wrote a binary
format parser generator called [binfmt] ([docs][binfmt-docs]).

[Apache Kafka]: https://kafka.apache.org/
[src]: https://github.com/Bogdanp/racket-kafka
[docs]: https://docs.racket-lang.org/kafka/index.html
[binfmt]: https://github.com/Bogdanp/racket-binfmt
[binfmt-docs]: https://docs.racket-lang.org/binfmt-manual/index.html
