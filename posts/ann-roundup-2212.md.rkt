#lang punct

---
title: Announcing racket-{avro,iso-printf,lz4,messagepack}
date: 2022-12-05T10:15:00+02:00
---

Some of the feedback I've received on [Franz] so far has been that folks
need support for more compression and serialization formats. In that
vein, here are some Racket libraries I've released in the past couple of
weeks:

* `racket-avro` ([docs][racket-avro-docs], [src][racket-avro]) -- an
  implementation of the [Apache Avro] serialization protocol.  This is
  fairly complete, but it elides support for Avro RPC for now.
* `racket-iso-printf` ([docs][printf-docs], [src][racket-iso-printf])
  -- an implementation of the standard C family of `printf` functions.
  This is used in [racket-lua] to implement the `string.format`
  procedure.  Originally, this was going to just be an internal part
  of `#lang lua`, but I figured it might have some use beyond it. I've
  certainly wanted C-style `printf` in the past in Racket.
* `racket-lz4` ([docs][racket-lz4-docs], [src][racket-lz4]) -- a
  pure-Racket [LZ4] decompressor.  It doesn't yet support compression,
  but I may add it if there is interest.
* `racket-messagepack` ([docs][racket-messagepack-docs],
  [src][racket-messagepack]) -- an implementation of the [MessagePack]
  serialization format.  There is an existing [msgpack] package on the
  Package Server, but it is GPL-licensed, so I wanted to avoid
  distributing it with my app.

[Apache Avro]: https://avro.apache.org
[Franz]: https://franz.defn.io
[LZ4]: https://github.com/lz4/lz4
[MessagePack]: https://msgpack.org
[msgpack]: https://docs.racket-lang.org/msgpack/index.html
[printf-docs]: https://docs.racket-lang.org/iso-printf-manual/index.html
[racket-avro-docs]: https://docs.racket-lang.org/avro-manual/index.html
[racket-avro]: https://github.com/Bogdanp/racket-avro
[racket-iso-printf]: https://github.com/Bogdanp/racket-iso-printf
[racket-lua]: https://github.com/Bogdanp/racket-lua
[racket-lz4-docs]: https://docs.racket-lang.org/lz4-manual/index.html
[racket-lz4]: https://github.com/Bogdanp/racket-lz4
[racket-messagepack-docs]: https://docs.racket-lang.org/messagepack-manual/index.html
[racket-messagepack]: https://github.com/Bogdanp/racket-messagepack
