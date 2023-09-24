#lang punct "../common.rkt"

---
title: Franz now Source Available
date: 2023-08-10T08:20:00+03:00
---

The source code for [Franz], a desktop client for [Apache Kafka], is now
available for all to read on [on GitHub][source].

One of my goals with writing software in [Racket] is to help expand the
Racket ecosystem. I try do that by making parts of the apps I write
Open Source where possible[^1] and by making small contributions back
to Racket itself. Additionally, I [sometimes][discuss] see new users
ask for examples of real-world applications built with Racket so I've
been trying to make the source code of my own apps available as well
(where possible; see also [Nemea] and [Remember]). My hope is that folks
interested in using Racket can get an idea of what using it in practice
looks like by viewing the code for these apps and I like the thought
of letting my own users see what code they're running when they use my
apps.

[^1]: In the process of writing Franz, I've written a [Kafka client],
    libraries for serializing and deserializing [Avro], [MessagePack]
    and [Protocol Buffer] data, native decompressors for [LZ4] and
    [Snappy], and a hash-lang for [Lua] among [other things][Noise].

[Apache Kafka]: https://kafka.apache.org
[Avro]: https://github.com/Bogdanp/racket-avro
[Franz]: https://franz.defn.io
[Kafka client]: https://github.com/Bogdanp/racket-kafka
[LZ4]: https://github.com/Bogdanp/racket-lz4
[Lua]: https://github.com/Bogdanp/racket-lua
[MessagePack]: https://github.com/Bogdanp/racket-messagepack
[Nemea]: https://github.com/Bogdanp/nemea
[Noise]: https://github.com/Bogdanp/noise
[Protocol Buffer]: https://github.com/Bogdanp/racket-protocol-buffers
[Racket]: https://racket-lang.org
[Remember]: https://github.com/Bogdanp/Remember
[Snappy]: https://github.com/Bogdanp/racket-snappy
[source]: https://github.com/Bogdanp/Franz
[discuss]: https://racket.discourse.group/t/real-racket-applications-with-correct-idiomatic-style/1504
