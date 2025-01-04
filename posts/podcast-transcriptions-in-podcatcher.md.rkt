#lang punct "../common.rkt"

---
title: How Podcatcher Does Transcriptions
date: 2025-01-04T16:25:00+02:00
---

About a month ago, I added transcription support to [Podcatcher]. For
example, [here's a transcript][vergecast-transcript] of the latest
episode of the Vergecast, and [another one][appstories] from AppStories.

Years ago, I bought an M1 Mac Mini and, in the intervening time, I
haven't done much with it besides keep it on my desk. So, I figured
I'd put it to work for this purpose. I initially reached for Apple's
[Speech] Framework, but [SFSpeechRecognizer] turned out to be both
surprisingly slow – on that particular machine, it transcribes
at about a 1-to-1 ratio of audio time to wall clock time –, and
pretty inaccurate. I spent some time evaluating other alternatives
and eventually settled on OpenAI's open source [Whisper] model. In
particular, since I'm not yet at a point where it makes sense to spend
money on a machine with a powerful GPU to perform these transcriptions,
I'm currently using the `tiny.en` variant of the model. Running two
concurrent transcriptions at a time, on the CPU, I can get the model to
transcribe about 30-60 minutes of podcast time for every 5 minutes of
wall clock time. The accuracy is acceptable, though far from perfect.
Eventually, I'll probably run one of the larger models to redo them if
the app gets traction.

The actual guts of the transcriber are fairly simple. At its core, it's
a small Racket script that shells out to Python to run the Whisper
model. It runs in a loop where it leases transcriptions-to-be-done from
the server, downloads the podcast enclosure, runs Whisper on it to
produce an [SRT] file and then uploads the resulting output back to the
server using the lease token it receives at the beginning. If the lease
expires before the transcriber has a chance to upload it, the server
just ignores the request.

The server prioritizes recent English-language podcasts and keeps track
of leases in a Postgres table. A cron job removes leases from the table
after 24 hours in case one of the transcriber processes gets stuck or
crashes in the middle of transcribing. It hasn't actually crashed yet,
but we did have a brief power outage recently, so I suppose that counts.

On the client side, the app and the website request the SRT data from
the server, parse it (SRT is a simple line-oriented text format) and
display it. The iOS app uses the timing information in the file to sync
transcripts to playback, which works in general, but can go off the
rails when a podcast uses dynamic ad insertion.

[Podcatcher]: https://apps.apple.com/us/app/podcatcher-podcast-player/id6736467324
[vergecast-transcript]: https://podcatcher.net/podcasts/https%3A%2F%2Ffeeds.megaphone.fm%2Fvergecast/dd3b9ebc-bbe3-11ef-b3b0-9f7e98aa1a24?tab=transcript
[appstories]: https://podcatcher.net/podcasts/https%3A%2F%2Fappstories.net%2Fepisodes%2Ffeed%2F/36d30050-c2bf-4037-a901-52d13658fa6f?tab=transcript
[Speech]: https://developer.apple.com/documentation/speech
[SFSpeechRecognizer]: https://developer.apple.com/documentation/speech/sfspeechrecognizer
[Whisper]: https://github.com/openai/whisper
[SRT]: https://en.wikipedia.org/wiki/SubRip
