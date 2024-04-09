#lang punct "../common.rkt"

---
title: Announcing Remember for iOS
date: 2024-04-09T09:00:00+03:00
---

A little over four years ago, I released •@["ann-remember"]{Remember
for macOS}, a small reminders app written using a combination of Swift
and Racket. Today, I've released a version of [Remember on the iOS App
Store][app-store]!

I'd been meaning to get an iOS version going for a while, but ran into
•@["racket-on-ios"]{various} •@["racket-cs-on-ios"]{issues} getting
Racket to run on iOS. Thanks to some not-so-[recent][chez-libffi]
[improvements][chez-pbchunks] to Racket CS's portable bytecode
backend, it is now relatively easy to get Racket running on iOS[^1].
So, I updated [Noise] to add iOS support, [ported][Noise commit]
the macOS version of Remember to use Noise instead of its original
JSON-RPC-via-subprocess implementation, and [built][iOS PR] a simple
SwiftUI interface on top of the Racket core. The app is a bit plain,
but it supports all the same functionality of the desktop app and it
supports syncing data between the two platforms which is as much as I
need from it, so I'm happy with the result!

[^1]: With some limitations. For example, more work is needed to get
    the OpenSSL bindings to work. But, Remember doesn't need them so
    that wasn't a problem in this instance.

[Remember for macOS]: /2020/01/02/ann-remember/
[source]: https://github.com/bogdanp/remember
[chez-libffi]: https://github.com/racket/racket/commit/4480e643da
[chez-pbchunks]: https://github.com/racket/racket/commit/e3929bcf51
[Noise]: https://github.com/Bogdanp/Noise
[Noise commit]: https://github.com/Bogdanp/remember/commit/d15136e59a79468d8ae161738e9eb3f7dfa8179f
[iOS PR]: https://github.com/Bogdanp/remember/pull/6
[app-store]: https://apps.apple.com/ro/app/remember-quick-reminders/id1493354028?platform=iphone
