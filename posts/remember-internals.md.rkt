#lang punct

---
title: Native Applications with Racket
date: 2020-01-04T13:00:00+02:00
---

A couple of days ago, I released a native macOS application called
[Remember][remember].  It is a small, keyboard-driven application for
stashing away notes/reminders for later.  One of the cool things about
it from a programming nerd perspective is that, while it is a
completely native Cocoa application whose frontend is built with
Swift, the core business logic is all in Racket!

## Why not use racket/gui?

I started out with a [proof of concept][poc] that used Racket for the
GUI, but I realized that I'd have to write a bunch of Objective-C FFI
code to get the UI to look the way I wanted (a carbon copy of
Spotlight) and it seemed like it would be a pain to try and integrate
[DDHotKey] and to add support for launching at login into a package
that is easy to distribute.  I was also unsure about how I could
notarize the distribution for macOS Catalina (more on this later).

## Why not do it all in Swift?

I don't know Swift particularly well, nor do I like it very much.  I
find Apple's documentation lackluster and Xcode is surprisingly buggy
(renaming a class and its associated file fails to rename the file on
disk, which causes Xcode to fail silently, for example).  I wouldn't
mind the documentation being bad if the core cocoa code was open
source/source available; at least then I could look at the
implementation to try and understand what's going on.

More importantly, I plan to support Windows and Linux which means that
writing the core in a portable language is going to minimize the
amount of work I have to do as well as the differences between the
implementations on each platform.

## How it Works

The [Racket core][core] runs a custom JSONRPC [server] that listens
for commands on `stdin` and sends responses on `stdout`.  Using
Racket's [`raco exe`] and [`raco distribute`] commands, that core gets
built into a native executable and copied into the Swift app's
resources folder.  The Swift application [runs the core][coms] as a
subprocess on startup and communicates with it via pipes.

RPC commands are asynchronously handled by the core and the core may
also send asynchronous notifications to the frontend to let it know
when entries are due.

### Notarization

It took me a couple of hours to figure out how to get everything
notarized.  I had to enable App Sandboxing for both the frontend and
the core application, figure out via trial and error which
entitlements were necessary, realize that I needed a separate set of
entitlements for the core application and that the
`com.apple.security.inherit` entitlement, for whatever reason, doesn't
let the subprocess inherit its parents entitlements, meaning that I
had to also explicitly assign the core application the "Allow JIT" and
"Allow Unsigned Executable Memory" entitlements, else the process
would get killed with a `SIGINT` and a red herring error message about
how the executable doesn't have a valid bundle identifier.

### Would I do this again?

I'll have to see how porting to other platforms goes, but so far I'm
very happy with this approach.  The result is fast and now that I've
built the RPC infrastructure I can easily copy all that code into
other projects.  Writing the business logic in Racket means that I can
iterate very quickly and writing the GUI code using the native tools
for each platform is advantageous in terms of look and feel and
distribution.

### What about iOS?

Unfortunately, the RPC approach breaks down on iOS where you're not
allowed to run subprocesses.  An approach that could work there is
building the app into a shared library, linking against it and doing
the RPC in-process.  I think that approach could work, but Racket
would have to be able to target `arm64` for that to be feasible.
Fortunately, now that Racket is able to run on top of Chez Scheme,
which already has backends for many platforms, including `arm32le`,
that might be a possibility in the future. [^1]

[^1]: `myfreeweb` pointed out on [lobste.rs] that this is already
    supported by Racket BC!


[remember]: https://gumroad.com/l/rememberapp
[source]: https://github.com/bogdanp/remember
[core]: https://github.com/Bogdanp/remember/tree/bfe3c0c56b59602852155247c37ef4243866c6ba/core
[coms]: https://github.com/Bogdanp/remember/blob/bfe3c0c56b59602852155247c37ef4243866c6ba/cocoa/remember/remember/ComsCenter.swift#L39
[server]: https://github.com/Bogdanp/remember/blob/bfe3c0c56b59602852155247c37ef4243866c6ba/core/server.rkt#L15
[poc]: https://gist.github.com/Bogdanp/3fa6dec42a9bd7fa4422e0e0cd1cd23b
[DDHotKey]: https://github.com/davedelong/DDHotKey
[lobste.rs]: https://lobste.rs/s/s4okil/native_applications_with_racket#c_etvpxp
[`raco distribute`]: https://docs.racket-lang.org/raco/exe-dist.html?q=raco%20distribute
[`raco exe`]: https://docs.racket-lang.org/raco/exe.html?q=raco%20exe
