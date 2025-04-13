#lang punct

---
title: Performing Widget Intents in-app on iOS
date: 2025-04-13T09:09:00+03:00
---

I'm currently adding widgets to [Podcatcher] and one issue I've run into
that's not very well documented is how to trigger an App Intent — for
example, to start playing a Podcast — from a widget, ensuring that the
intent is performed in the app.

There are two problems that need to be solved:

1. The intent has to be a part of both the main app target and the
widget extension target. How do we avoid including all of the app's
dependencies in the widget extension?

2. Since the intent is going to be included in both targets, after we
solve 1), how do we ensure that the intent gets run inside the main app
process.

To solve the first problem, I added an Active Compilation Condition
(`Build Settings -> Swift Compiler - Custom Flags -> Active Compilation
Conditions`) to the main app target for both Debug and Release builds.
I called it `MAIN_APP`. With the flag in place, I can conditionally
compile the `perform` method of the intent so that it only does stuff
when invoked within the app:

``` swift
struct TogglePlaybackIntent: AppIntent {
  nonisolated static let title: LocalizedStringResource = "Toggle Playback"
  nonisolated static let description = IntentDescription("Plays/pauses the Podcatcher queue.")

  @MainActor
  func perform() async throws -> some IntentResult {
#if MAIN_APP
    // actual playback code here
#endif
    return .result()
  }
}
```

This way, I can include the intent in the extension target and refer
to it in a button without bringing in all the other deps (models,
audio engine, etc.) that are needed to actually play a podcast.

To solve the second problem, you have to either set the `openAppWhenRun`
member to `true` within your intent implementation, or have the intent
implement the `AudioPlaybackIntent` instead of `AppIntent`. The latter
was more appropriate for this particular intent, so that's what I did:

``` diff
- struct TogglePlaybackIntent: AppIntent {
+ struct TogglePlaybackIntent: AudioPlaybackIntent {
```

[Podcatcher]: https://apps.apple.com/app/podcatcher-podcast-player/id6736467324
