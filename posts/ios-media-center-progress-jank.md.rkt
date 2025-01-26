#lang punct "../common.rkt"

---
title: iOS Media Center Progress Jank
date: 2025-01-26T15:00:00+02:00
---

If you listen to podcasts on iOS, chances are you've noticed an issue
some apps have when displaying the playing episode's progress in the
media center. For example, notice how in the video below, playback
pauses at 0:39, then skips forward in real time to 0:45 when I hit
resume, before the app finally resets the elapsed time back to 0:38.

•`(div
   ([style "float: right; padding: 0 0 1rem 1rem"])
   (video
    ([controls ""]
     [height "480px"]
     [muted ""]
     [src "/img/media-center-demo.mp4"])))

Pictured is one of the most popular iOS apps[^1] for playing podcasts,
but others I've tested have this issue as well. [Podcatcher] used to
also have this problem until a couple months ago.

The reason this happens is because the iOS Now Playing view calculates
the playback position automatically according to the last [elapsed
time] and [playback rate] values it was given. That seems sensible as a
performance optimization, and it would normally be fine, but it appears
that the media center doesn't take into account the time that the item
spends being paused.

One workaround is to set the playback rate to `0` before pausing and
to reset it and the elapsed time before resuming. That works fine for
most apps, but isn't quite right in Podcatcher's case since the playback
rate may be constantly varying when the Trim Silence feature is turned
on. Instead, I always set the playback rate to `0` and manually update
the elapsed time as part of the audio engine tap that keeps track of
playback.

```swift
internal func updateMediaCenterProgress() {
  let center = MPNowPlayingInfoCenter.default()
  var info = center.nowPlayingInfo ?? [String: Any]()
  info[MPMediaItemPropertyPlaybackDuration] = duration
  info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
  // The info center computes its own elapsed time based on the
  // playback rate. So, to avoid visual discrepancies between it and
  // our own progress tracking, always set the playback rate to 0.
  info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
  center.nowPlayingInfo = info
}
```

Since the tap was already running in the background during playback,
this approach doesn't seem to have had any measurable impact on power
consumption[^2] and the accuracy improvement is well worth it to me,
even though it feels somewhat gross to be working against the intent of
the media center API.

•`(div ([style "clear: both"]))

[^1]: Identity elided to protect the innocent.
[^2]: And Podcatcher is already much better in this area than other apps in the space.

[Podcatcher]: https://podcatcher.net

[elapsed time]: https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfopropertyelapsedplaybacktime
[playback rate]: https://developer.apple.com/documentation/mediaplayer/mpnowplayinginfopropertyplaybackrate
