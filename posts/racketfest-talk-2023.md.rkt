#lang punct "../common.rkt"

---
title: Racketfest 2023 Talk: Native Apps with Racket
date: 2023-03-19T18:00:00+01:00
---

[Racketfest] 2023 was held yesterday and I gave a short talk about
building native apps with Racket.  Nothing new if you've read my
recent posts, but below is a transcript.  A recording might also be
posted later, in which case I'll update this post to link to it.

## Transcript

### Native Apps

•(define (slide n)
   (img (format "racketfest2023-slides/slide-~a.jpg" n)
        (format "Slide number ~a." n)))

•(slide 0)

My name is Bogdan Popa, and today I will be talking about an approach
I've been using to build native desktop apps with Racket.

### Native Applications?

•(slide 1)

First, what do I mean by "Native Application"? I mean an application
that uses the system libraries and frameworks for building
applications.  Applications that look and feel like other applications
that ship with the system and that implies they have access to all
available widgets on the system.

### With Racket?

•(slide 2)

Why with Racket?  Because I like using the language and I've built up
a large collection of libraries over the years and because I'd like
the core logic to be portable between operating systems.

### Approaches

•(slide 3)

So far, I've used three approaches to building desktop apps in Racket:

1. `racket/gui`
1. Embedding Racket as a subprocess.
1. Embedding Racket directly, which is the focus of this talk.

## racket/gui{,easy}

•(slide 4)

`racket/gui` comes with Racket and supports a combination of native
and custom widgets on Linux, macOS and Windows.  But, the set of
widgets it supports out of the box is limited, and not all widgets
(eg. input fields) are truly native.  Additionally, because it aims to
support all of the aforementioned platforms, it's hard to extend it
with new widgets because analogs of a widget on one platform might not
exist on others.

### Embedding as Subprocess

•(slide 5)

Another approach I've used is embedding Racket as a subprocess.  The
idea here being that the GUI app runs Racket in a subprocess and
communicates with it via pipes.  I've actually shipped an
[app][remember] to the Mac App Store using this approach.

One downside with this approach is that memory consumption is
relatively high (but that's more of a Racket problem in general, than
one particular to this approach).  Another is that, since these are
two separate processes, the Racket code can't call back into Swift
without help.

### Embedding Directly

•(slide 6)

The approach I used with [Franz] is to compile Racket as a static
library and link it into a Swift app.  Like in the subprocess
approach, I've opted to run the Racket runtime in its own thread and
communicate with it via pipes[^1].  By running Racket in its own OS
thread, it can keep scheduling its own threads as normal and I can run
an RPC server that listens on a pipe for requests and serves responses
asynchronously.  An advantage over the previous approach is here the
Swift and Racket sides share memory so it's possible for the Racket
side to call out to Swift directly.

Memory use is still a downside, though slightly better than the
subprocess approach because process overhead is reduced and things
like shared libraries can be shared between the two runtimes.

[^1]: A couple folks asked about why I opted to serialize the data
    between Racket and Swift instead of just sharing the objects
    directly between the two languages.  After thinking about it for a
    bit, I remembered two main reasons why I preferred the serde
    approach: 1) I didn't want to have to interrupt the Racket runtime
    every time the Swift side needed to access a Racket object and 2)
    the Racket CS GC is free to move objects in memory.  While there
    are ways to tell the runtime not to move individual values, it
    just doesn't seem worth it as long as the serde approach doesn't
    add tons of overhead.

### Demo

•(haml
  (:center
   (:p
    (:em
     "[No transcript for the demo portion, but see the "
     (:a ([:href "https://franz.defn.io"]) "Franz website")
     ".]"))))

### Code Stats

•(slide 8)

In terms of code, the Swift portion is about 9k lines and the Racket
portion about 18k lines, but the Racket portion also includes the
Kafka [client].

### How it Works

•(slide 9)

As mentioned, this approach works by compiling Racket to a static
library and linking it directly into a Swift application.  The Racket
code is then compiled using `raco ctool` to a `.zo` bytecode file and
shipped alongside the app.

### How it Works (cont'd)

•(slide 10)

On boot, the Swift application starts Racket in a background thread,
loads the `.zo` code from the application bundle, and there's a small
interface for setting up the RPC system between the two languages.  A
"main" procedure is loaded from the `.zo` code, then that procedure is
called with a set of pipe file descriptors, which are then converted
into ports on the Racket side.

### Noise

•(slide 11)

To abstract over some of this stuff, I've written a set of Swift and
Racket libraries (with plans to add C# support for Windows soon).
They live under the Noise repo, linked at the top, and they are split
up in roughly three layers.  The lowest layer handles embedding
`libracketcs` and provides a Swift wrapper for its C ABI.  The layer
above that implements a protocol for serializing and deserializing
data between the two languages and the layer above that implements a
protocol for communicating via pipes.

### NoiseRacket

•(slide 12)

NoiseRacket is the lowest layer and, as mentioned, it handles the
embedding of `libracketcs`.  From Swift code, you just import `Noise`,
then create an instance of the `Racket` class to initialize the Racket
runtime.  Then, every time you want to call Racket, you pass a closure
to that object's `bracket` method.  In this example, we load a `.zo`
file, construct a module path and require a function named `fib` then
apply it and print the result.  As you can see, this is pretty
laborious.

### NoiseSerde

•(slide 13)

NoiseSerde provides a set of macros on the Racket side and a code
generator that produces Swift code from record and enum definitions.
The example on the left expands to a struct definition that knows how
to serialize and deserialize itself.  Additionally, it stores
information for the code generator so that it can produce a matching
struct on the Swift side so that the two sides can pass data around
transparently.

### NoiseBackend

•(slide 14)

This layer provides a macro for defining remote procedure calls in
Racket.  On the Racket side, defined RPCs expand to regular functions,
but they get registered with the RPC server.  On the Swift side, they
expand to method declarations that handle the details of serializing
arguments and returning a `Future` value representing the
to-be-received response.

### Performance

•(slide 15)

This might sound like it's a lot of overhead, but in practice it
isn't.  The cost of the RPCs themselves is negligible, and the cost of
ser/de on average is on the order of 1 to 100 microseconds.  All of
this is dwarfed by the overhead of the business logic
(i.e. communicating with Kafka, which takes on the order of 1ms+ even
on loopback).

### Closing Thoughts

•(slide 16)

I'm very happy with this approach.  It feels natural to write apps in
this way, and the app that I demoed is already in customers' hands
(some even paid for it!).  In future, I plan to work on Windows
support and we'll have to see how that pans out.  All that said, if
you want to make cross-platform desktop apps, probably something like
Electron is a safer bet, despite not being native.  This approach is
still quite a lot of work.  But, if you're a crazy-person who really
wants to use Racket to make desktop apps for some reason, give it a
try.

### Thanks

•(slide 17)

Thank you for attending my talk!  You can find Franz at
[franz.defn.io], and [Noise] on GitHub.


[racketfest]: https://racketfest.com
[franz.defn.io]: https://franz.defn.io
[Franz]: https://franz.defn.io
[Noise]: https://github.com/Bogdanp/Noise
[client]: https://github.com/Bogdanp/racket-kafka
[remember]: /2020/01/02/ann-remember/
