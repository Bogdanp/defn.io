#lang punct "../common.rkt"

---
title: Screencast: Writing a Resource Pool Library for Racket
date: 2021-04-06T07:42:00+03:00
---

After hacking on [redis-lib] for a bit on Sunday, I decided to write
a general-purpose resource pooling library that I can re-use between
it and [http-easy] and I recorded the process. You can check it out on
[YouTube][video]:

•(haml
  (:center
   (:iframe
    ([:width "560"]
     [:height "315"]
     [:src "https://www.youtube-nocookie.com/embed/qzvZoiIxbmE"]
     [:title "YouTube video player"]
     [:frameborder "0"]
     [:allow "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"]
     [:allowfullscreen ""]))))

You can find the library on [GitHub][lib]. One particularly interesting
bit about the library, that I did not to record, is that [the
tests][tests] are all property-based. I might do another screencast at
some point to talk about how they work and the bugs they found in my
original implementation (from the video).


[lib]: https://github.com/bogdanp/racket-resource-pool
[redis-lib]: https://github.com/bogdanp/racket-redis
[http-easy]: https://github.com/bogdanp/racket-http-easy
[video]: https://www.youtube.com/watch?v=qzvZoiIxbmE
[tests]: https://github.com/Bogdanp/racket-resource-pool/blob/c6e82f0cb610f32beeef700ce897f613cb732fb6/resource-pool/test/data/pool.rkt
