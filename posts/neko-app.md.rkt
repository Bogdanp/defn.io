#lang punct "../common.rkt"

---
title: neko.app
date: 2021-01-02T00:00:00+00:00
---

I was watching [Systems with JT] the other day and he demoed a hobby
operating system called [skiftOS]. During the demo he ran one of the
built-in apps called "neko" which looks like a clone of an old Windows
"pet" program I remember from my childhood, also called "neko" (or
"neko32").

It's a really simple program: when you start it up, a cute little kitten
shows up on your screen and starts running around, trying to catch your
mouse cursor. I figured it would be fun to clone the program for macOS
and so I went ahead and spent most of yesterday doing it. [Here's][code]
the code and if you're feeling nostalgic and want to run it yourself,
you can grab a build from the releases tab.

•(haml
  (:center
   (img "neko.gif" "demo")))

[Systems with JT]: https://www.youtube.com/channel/UCrW38UKhlPoApXiuKNghuig
[skiftOS]: https://github.com/skiftOS/skift
[code]: https://github.com/bogdanp/neko
