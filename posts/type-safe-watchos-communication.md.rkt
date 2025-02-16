#lang punct

---
title: DSLs for Safe iOS/watchOS Communication
date: 2025-02-16T08:00:00+02:00
---

I'm currently writing an Apple Watch counterpart app for [Podcatcher].

The [Watch Connectivity] framework that iOS apps use to communicate with
watchOS apps offers a limited API for communication: you can either send
untyped dictionaries or arbitrary byte strings between the two.

In a large app, you want more structure than that framework offers. One
approach you can take is to encode shared structs as JSON and pass them
around as byte strings, manually writing all the boilerplate code to
ensure that a response to a certain message decodes to the right type,
and so on. A better approach is to write a little DSL to declare all the
message and response types and use that information to generate code to
handle the encoding/decoding boilerplate and to ensure that the right
message handlers are implemented on either side. In Podcatcher, that
currently looks like this:

``` racket
(define-enum AppPlaybackState
  [empty]
  [paused
   {item : (Delay WatchQueueItem)}
   {progress : UVarint}
   {duration : UVarint}]
  [playing
   {item : (Delay WatchQueueItem)}
   {progress : UVarint}
   {duration : UVarint}])

(define-record WatchQueueItem
  [podcast-title : String]
  [episode-id : UVarint]
  [episode-title : String]
  [episode-progress : UVarint]
  [episode-duration : (Optional UVarint)]
  [enclosure-path : (Optional String)]
  [completed? : Bool]
  [order : UVarint])

(define-record WatchQueue
  [items : (Listof WatchQueueItem)])

(define-watch-rpcs
  WatchMessage ;; watch -> app messages
  [get-playback-state : AppPlaybackState]
  [go-backward : Bool]
  [go-forward : Bool]
  [pause : Bool]
  [play {episode-id : UVarint} : Bool]
  [resume : Bool]
  [sync-queue {local-items : (Listof WatchQueueItem)} : WatchQueue]
  [want-files {episode-ids : (Listof UVarint)} : Bool])
```

This takes advantage of [Noise]'s [define-enum] and [define-record]
to generate Swift enums and structs that can be serialized and
deserialized to and from byte strings. On top of that functionality, the
`define-watch-rpcs` macro declares what all the watchOS to iOS messages
are and generates:

1. an enum representing the messages,
2. code to send a message from the watch app to the phone app,
3. a protocol for handling those messages in the phone app and
4. code to wire up the message-receiving side to the protocol implementation.

The generated `WatchMessage` enum looks like this:

``` swift
public enum WatchMessage: Readable, Sendable, Writable {
  case getPlaybackState
  case goBackward
  case goForward
  case pause
  case play(UVarint)
  case resume
  case syncQueue([WatchQueueItem])
  case wantFiles([UVarint])

  // ser/de code elided
}
```

The generated code for sending these messages from the watch app to the
phone app looks like this:

``` swift
extension WCSessionManager {
  func getPlaybackState() async throws -> AppPlaybackState {
    return try await send(message: WatchMessage.getPlaybackState)
  }

  func goBackward() async throws -> Bool {
    return try await send(message: WatchMessage.goBackward)
  }

  func goForward() async throws -> Bool {
    return try await send(message: WatchMessage.goForward)
  }

  func pause() async throws -> Bool {
    return try await send(message: WatchMessage.pause)
  }

  func play(episodeId: UVarint) async throws -> Bool {
    return try await send(message: WatchMessage.play(episodeId))
  }

  func resume() async throws -> Bool {
    return try await send(message: WatchMessage.resume)
  }

  func syncQueue(localItems: [WatchQueueItem]) async throws -> WatchQueue {
    return try await send(message: WatchMessage.syncQueue(localItems))
  }

  func wantFiles(episodeIds: [UVarint]) async throws -> Bool {
    return try await send(message: WatchMessage.wantFiles(episodeIds))
  }
}
```

The generated protocol for handling these messages in the phone app
looks like this:


``` swift
protocol WatchMessageHandler {
  func getPlaybackState(session: WCSession) -> AppPlaybackState
  func goBackward(session: WCSession) -> Bool
  func goForward(session: WCSession) -> Bool
  func pause(session: WCSession) -> Bool
  func play(session: WCSession, episodeId: UVarint) -> Bool
  func resume(session: WCSession) -> Bool
  func syncQueue(session: WCSession, localItems: [WatchQueueItem]) -> WatchQueue
  func wantFiles(session: WCSession, episodeIds: [UVarint]) -> Bool
}
```

Finally, the generated code to wire receiving the messages to an
implementation of the protocol looks like this:

``` swift
extension AppDelegate: WCSessionManagerDelegate {
  nonisolated func handle(session: WCSession, watchMessage message: WatchMessage) -> any Writable {
    switch message {
    case .getPlaybackState:
      return getPlaybackState(session: session)
    case .goBackward:
      return goBackward(session: session)
    case .goForward:
      return goForward(session: session)
    case .pause:
      return pause(session: session)
    case .play(let episodeId):
      return play(session: session, episodeId: episodeId)
    case .resume:
      return resume(session: session)
    case .syncQueue(let localItems):
      return syncQueue(session: session, localItems: localItems)
    case .wantFiles(let episodeIds):
      return wantFiles(session: session, episodeIds: episodeIds)
    }
  }
}
```

The watch app sends the phone app a message by calling one of the
methods defined in the `WCSessionManager` extension. The phone app
handles the message in its implementation of the `WatchMessageHandler`
protocol and returns a response.

That short `define-watch-rpcs` declaration from the first code snippet
saves me a lot of manual typing and error-prone wiring up of things.
When I add a new message case to the `WatchMessage` enum, all I have to
do is implement its associated handler. If I forget to do that, the app
doesn't compile.

You can find the full implementation of the `define-watch-rpcs` macro
and its associated codegen procedures [in this gist][gist].

Now that Swift also has macros in the language, you could probably write
a DSL like this directly in Swift, but I just used what I know, and
Swift macros look somewhat clunky compared to what Racket offers.

[Podcatcher]: https://apps.apple.com/us/app/podcatcher-podcast-app/id6736467324
[Watch Connectivity]: https://developer.apple.com/documentation/watchconnectivity
[Noise]: https://github.com/Bogdanp/Noise
[define-enum]: https://docs.racket-lang.org/noise-manual/index.html#%28form._%28%28lib._noise%2Fserde..rkt%29._define-enum%29%29
[define-record]: https://docs.racket-lang.org/noise-manual/index.html#%28form._%28%28lib._noise%2Fserde..rkt%29._define-record%29%29
[gist]: https://gist.github.com/Bogdanp/6d800c1064c60ff5d7579e2caed0ca51
