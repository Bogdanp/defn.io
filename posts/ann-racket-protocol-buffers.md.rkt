#lang punct

---
title: Announcing racket-protocol-buffers
date: 2023-02-22T11:00:00+02:00
---

A couple of releases back, I added support for schema registries
to [Franz]. Some of its users use [Protocol Buffers] to serialize
their data, so I needed to be able to support that use case. So, I
wrote a parser for the `proto2` and `proto3` specs and a minimal
serializer/deserializer implementation that doesn't require code
generation on top of that.

You can find the [package][pkg] and [docs][doc] on the Package server
and the [source][src] on GitHub.

[Protocol Buffers]: https://protobuf.dev/
[Franz]: https://franz.defn.io
[pkg]: https://pkgs.racket-lang.org/package/protocol-buffers
[doc]: https://docs.racket-lang.org/protocol-buffers-manual/index.html
[src]: https://github.com/Bogdanp/racket-protocol-buffers
