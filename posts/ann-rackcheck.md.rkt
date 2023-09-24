#lang punct

---
title: Announcing rackcheck
date: 2020-03-12T14:00:00+02:00
---

I've been playing around with property-based testing in Racket this past
week. I started by forking the existing [quickcheck] library to try and
add support for shrinking, but I quickly realized that I'd have to make
a number of breaking changes to get it to work the way I wanted so, in
the end, I decided to start a new library from scratch.

The library is called [rackcheck] and you can grab it off of the package
server. The reference docs should show up on there soon and there are a
few examples in the repo. I'm pretty happy with the result so far, but
I may end up making some small API adjustments as I use it more so keep
that in mind!

[quickcheck]: https://github.com/ifigueroap/racket-quickcheck
[rackcheck]: https://github.com/Bogdanp/rackcheck
