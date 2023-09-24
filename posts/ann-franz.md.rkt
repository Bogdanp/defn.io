#lang punct

---
title: Announcing Franz
date: 2022-11-20T20:55:00+02:00
---

I've been using [Apache Kafka] for about a year now and I've wanted a
desktop client from the beginning. I couldn't find one I liked -- the
best I've found is Confluent's Cloud UI, but that's neither a desktop
app, nor is it a great experience[^1] -- so, a couple months ago I
started building a native macOS GUI for Kafka in my spare time and,
today, I'm proud to announce the first beta release of [Franz].

This release covers all the basic functionality you might expect: you
can manage topics and consumer groups, publish & consume records, and
even hook in and script part of the consumption process. So, if that
sounds appealing to you, please give it a try and let me know what you
think. I've had tons of fun working on this so far and I'd love to make
it even better.

In terms of tech, obviously, the sane approach would've been to make a
straight Swift app and embed [librdkafka] and I'd be off to the races.
But, that wouldn't be very fun. So, instead, Franz is a Swift app backed
by Racket (via the same approach described in [Screencast: SwiftUI +
Racket][screencast], though with many improvements to the process since
I recorded that video -- expect an updated screencast sometime soon!),
where the underlying Kafka client is the [same one][racket-kafka]
I've been working on off-and-on since the beginning of the year. The
aforementioned scripting support is provided by [racket-lua], which I
[announced][ann-lua] last week.

I've found this approach[^2] to building apps to be hugely productive
(and damn fun!). I get to alternate between quickly bashing out core
functionality in Racket, interacting with said code at the [racket-mode]
REPL, and switching to Swift where I can bang out whatever GUI idea
comes to mind pretty quickly at this point. It all makes for some very
productive moments, even when those moments are relatively few and
far-between (I have a dayjob so this was all done during my free time
and mostly during weekends).

[^1]: Unless you love being unconditionally logged out once an hour for
      some reason.
[^2]: I've used a similar approach to ship an app on the Mac App Store
      [a couple years ago][remember].

[Apache Kafka]: https://kafka.apache.org
[Franz]: https://franz.defn.io
[librdkafka]: https://github.com/edenhill/librdkafka
[screencast]: /2022/08/21/swiftui-plus-racket-screencast/
[racket-kafka]: /2022/03/12/ann-racket-kafka/
[racket-lua]: https://github.com/Bogdanp/racket-lua
[ann-lua]: /2022/11/12/ann-racket-lua/
[racket-mode]: https://github.com/greghendershott/racket-mode/
[remember]: /2020/01/02/ann-remember/
