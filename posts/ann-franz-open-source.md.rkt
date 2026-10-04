#lang punct "../common.rkt"

---
title: Franz now Open Source
date: 2026-10-04T11:47:00+03:00
---

What it says on the tin. Almost 4 years after •(@ "Announcing Franz"),
I've decided to open source it under the 3-clause BSD license and to
stop selling commercial licenses. The code is available on [GitHub] and
free builds of the latest version are now available on [its website].

## Why now?

Sales tapered off and I wanted to have one less thing on my mind.

## Commercial Postmortem

Over its commercial lifetime, Franz made approximately $5.5k in license
sales, and I've given out on the order of 10-15 free licenses to
students. Amusingly, there was some piracy, either folks that built
the source-available version for themselves without having purchased a
license or folks that figured out a way to reset the trial period (not
that I made that hard at all).

## Was it worth it?

Yes! I learned a lot about the inner workings of Kafka while building
the client. The project fed back into some nice OSS for the Racket
ecosystem [^1], and I got paid for some of my time.

[^1]: `actor-lib`, `kafka-lib`, `Noise`, and improvements to
`gui-easy` to name a few.

[GitHub]: https://github.com/Bogdanp/Franz
[its website]: https://franz.defn.io
