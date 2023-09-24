#lang punct

---
title: Running Racket BC on iOS
date: 2020-01-05T20:00:00+02:00
---

**As of 2021-01-18, it is possible to [run Racket CS on iOS][new].**

[new]: /2021/01/19/racket-cs-on-ios

`/u/myfreeweb` pointed out to me in a [lobste.rs] thread yesterday
that Racket compiles just fine on `aarch64` and that led me down a
rabbit hole trying to get Racket running inside an iOS application.  I
finally succeeded so I figured I'd write down my findings in hopes of
helping future Racketeers (myself included) going down this path!

## Compile Racket for macOS

A recent-enough version of Racket is required in order to compile
Racket for iOS.  The best way to do that is to clone the [Racket repo]
and follow the [build instructions] which should be as simple as
running `make` in the repository root.

Assuming you're following along in a terminal session, run

``` bash
export RACKET_SRC=$(pwd)
```

You'll need to reference this directory in the following steps.


## Compile Racket for iOS

Once you've successfully compiled Racket for macOS, clone the Racket
repository again, this time under a different directory.  I called
this directory `racket-ios` to differentiate the two, but you can call
it whatever.  Make sure the same commit is checked out in both repos
and run through the following build steps starting at the repository
root:

``` bash
mkdir racket/src/build \
  && cd racket/src/build \
  && ../configure \
        --host=aarch64-apple-darwin \
        --enable-ios=iPhoneOS \
        --enable-racket="$RACKET_SRC/racket/bin/racket"
```

This will configure the build to create objects that can run on a
physical device.  To build Racket for the simulator instead, change
the `host` to `x86_64-apple-darwin` and `enable-ios` from `iPhoneOS`
to `iPhoneSimulator`.  For details on these flags, see the [cross
compiling instructions][cross instructions] in the Racket repo.

~~Although the instructions currently don't mention that `pthread`
support is required when configuring the build, the code will fail to
compile without it.~~  Matthew Flatt pushed [a fix] for this today!

[a fix]: https://github.com/racket/racket/commit/f0a63b59214d7885dc2d4872637e269eb38d5e49

Next, run `make cgc && make install-cgc` to compile the code and the
packages.  This builds the conservative GC variant of Racket.  I
started out trying to get everything running using the 3m variant of
Racket (with a precise GC), but I ran into a number of roadblocks,
including [an LLVM bug][bug] from 2015 so I eventually gave up and
switched to the CGC variant.


## Create the Xcode Project

Create a new iOS-based project in Xcode.  Inside that project, add a
new group called "Frameworks" and then drag and drop `racket/libmzgc.a`,
`racket/libracket.a` and `rktio/librktio.a` from the `racket/src/build`
directory into the "Frameworks" group.  Make sure "Copy items if needed"
is toggled.

![Drag n' Drop](/img/racket-on-ios-copy.png)

Open the project settings and, from the "Build Phases" -> "Link Binary
with Libraries" section, add `libiconv.tbd`.  Racket depends on this
library.

![Link iconv](/img/racket-on-ios-link-iconv.png)

Copy `racket/include` into your project and then from the "Build
Settings" -> "Search Paths" -> "Header Search Paths" section add
`$(SRCROOT)/include`.

![Headers](/img/racket-on-ios-headers.png)

Add a new header file called `BridgingHeader.h` and then from the
"Build Settings" -> "Swift Compiler - General" -> "Objective-C
Bridging Header" add the path to the file.  Everything defined in this
file will be made available to the Swift code.  Inside the file add:

```c
#include "Interop.h"
```

Create a new C file called `Interop.c` and add

```c
static int run(Scheme_Env *e, int argc, char *argv[]) {
    return 0;
}

void run_racket() {
    scheme_main_setup(1, run, 0, NULL);
}
```

In its associated header file, `Interop.h`, add

```c
#include "scheme.h"

void run_racket(void);
```

Finally, inside the `AppDelegate`'s `application:didFinishLaunchingWithOptions`
method, add a call to `run_racket` and run your project on your device
to ensure everything compiles and runs properly.

If everything runs correctly, then pat yourself on the back, you've
just run Racket on iOS!  Of course, Racket's not really doing much
at this point.  Let's embed a Racket module into the project.

In the project source directory, create a new file called `hello.rkt`
with the following contents:

``` racket
#lang racket/base

(displayln "Hello, World!")
```

From the command line, compile `hello.rkt` and all its transitive
dependencies into a C file:

``` bash
"$RACKET_SRC/racket/bin/raco" ctool --c-mods hello.c hello.rkt
```

Next, update `Interop.c` to include the resulting C file:

```c
#include "hello.c"
```

And then update `run` in that same file to initialize and run that
module:

```c
static int run(Scheme_Env *e, int argc, char *argv[]) {
    Scheme_Object *a[2];
    declare_modules(e);
    a[0] = scheme_make_pair(scheme_intern_symbol("quote"),
                            scheme_make_pair(scheme_intern_symbol("hello"),
                                             scheme_make_null()));
    a[1] = scheme_false;
    scheme_dynamic_require(2, a);
    return 0;
}
```

Note that the name of the module passed to `scheme_intern_symbol` is
`"hello"`, the same as the file name.

Run your project, and you should see "Hello, World!" in your console.

It took a little bit of work, but we got there!  From here, you should
be able to do more interesting stuff.  I'll get into some of that when
I start porting [Remember] to iOS.  In the mean time, you can read up
on this stuff [over here][docs]!

[lobste.rs]: https://lobste.rs/s/s4okil/native_applications_with_racket
[Racket repo]: https://github.com/racket/racket
[build instructions]: https://github.com/racket/racket/blob/fc258725ba7e5bd7289f15a08843fb2f62af4e27/build.md
[cross instructions]: https://github.com/racket/racket/blob/fc258725ba7e5bd7289f15a08843fb2f62af4e27/racket/src/README.txt#L336
[bug]: https://bugs.llvm.org/show_bug.cgi?id=22868
[Remember]: https://gum.co/rememberapp
[docs]: https://docs.racket-lang.org/inside/index.html?q=embed
