#lang punct "../common.rkt"

---
title: Screencast: SwiftUI + Racket
date: 2022-08-21T19:45:00+03:00
---

I've been playing with embedding Racket CS in desktop apps off and on
for a while and today I recorded a little screencast demoing some of the
stuff I've been working on. Here it is on [YouTube][video]:

•(haml
  (:center
   (:iframe
    ([:width "560"]
     [:height "315"]
     [:src "https://www.youtube-nocookie.com/embed/aTvU0j4hBR0"]
     [:title "YouTube video player"]
     [:frameborder "0"]
     [:allow "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"]
     [:allowfullscreen ""]))))

This is all pretty experimental and I'm just playing around, so nothing
is particularly stable, but if this stuff interests you, check out
[Noise] and [NoiseBackendExample].

[video]: https://www.youtube.com/watch?v=aTvU0j4hBR0
[Noise]: https://github.com/Bogdanp/Noise
[NoiseBackendExample]: https://github.com/Bogdanp/NoiseBackendExample
