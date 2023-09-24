#lang punct

---
title: Running Racket CS on iOS
date: 2021-01-19T10:25:00+02:00
---

**As of iOS 14.4, non-debugged builds (i.e. ones run outside of XCode)
fail with a dynamic code signing error and there is no way to work
around this at the moment.**

A couple of weeks ago, I started working on getting Racket CS to compile
and run on iOS and, with a lot of guidance from Matthew Flatt, I managed
to get it working (with some [caveats]). [Those changes][pr] have now
been merged, so I figured I'd write another [one of these guides][old]
while the information is still fresh in my head.


## Compile Racket for macOS and for iOS

To build Racket for iOS, clone the [Racket repository] and follow the
cross-compilation instructions under "racket/src/README.txt". The
easiest approach is to create a "build" directory under "racket/src",
then configure the build from within that directory by running

```bash
../configure \
  --host=aarch64-apple-darwin \
  --enable-ios=iPhoneOS \
  --enable-racket=auto
```

and then

```
make && make install
```

to compile Racket and set up a distribution. After running this series
of commands, you should end up with a cross-compiled Racket
distribution at "racket/" inside the source repository. Additionally,
under "racket/src/build/local/", you'll have a compiled version of
Racket CS for your host machine. You'll use that version of Racket to
cross-compile Racket sources for iOS.


## Cross-compile Racket modules for iOS

I added a section on [how to cross-compile Racket
modules][cross-section] to the "Inside Racket" docs so refer to that.
In short, if you save the following module under "app.rkt" somewhere

```racket
#lang racket/base

(provide echo)

(define (echo m)
  (displayln m))
```

then you can run

```bash
/path/to/racket/src/build/local/cs/c/racketcs \
  --cross-compiler tarm64osx /path/to/racket/racket/lib \
  -MCR /path/to/racket/src/build/cs/c/compiled: \
  -G /path/to/racket/racket/etc \
  -X /path/to/racket/racket/collects \
  -l- \
  raco ctool --mods app.zo app.rkt
```

to produce "app.zo", a binary object containing the cross-compiled
code for that module and all of its dependencies.


## Set up your XCode project

To link against and use Racket CS within an XCode project, copy
"racketcs.h", "racketcsboot.h" and "chezscheme.h" from "racket/include/"
into a sub-directory of your project, then add that sub-directory to the
"Header Search Paths" section under your project's "Build Settings" tab.

![Headers](/img/racket-cs-on-ios-headers.png)

Then, disable Bitcode from the same section.

![Bitcode](/img/racket-cs-on-ios-bitcode.png)

Next, copy "libracketcs.a", "petite.boot", "scheme.boot" and
"racket.boot" from "racket/lib" into a sub-directory of your project
called "vendor/" and drag-and-drop the "vendor/" directory into your
XCode project. Then, instruct XCode to link "libracketcs.a" and
"libiconv.tbd" with your code from the "Build Phases" tab. You'll
have to add "libracketcs.a" to your project using the "Add Other..."
sub-menu.

![Link](/img/racket-cs-on-ios-link.png)

Next, add a new C source file called "vendor.c" and answer "yes" if
prompted to create a bridging header for Swift. I tend to re-name the
bridging header to plain "bridge.h" because I don't like the name that
XCode generates by default. If you do this, you'll have to update the
"Objective-C Bridging Header" setting in your "Build Settings" tab. From
"bridge.h", include "vendor.h" and inside "vendor.h" add definitions for
`racket_init` and `echo`

```c
#ifndef vendor_h
#define vendor_h

#include <stdlib.h>

int racket_init(const char *, const char *, const char *, const char *);
void echo(const char *);

#endif
```

then, inside of `vendor.c`, implement them

```c
#include <string.h>

#include "chezscheme.h"
#include "racketcs.h"

#include "vendor.h"

int racket_init(const char *petite_path,
                const char *scheme_path,
                const char *racket_path,
                const char *app_path) {
    racket_boot_arguments_t ba;
    memset(&ba, 0, sizeof(ba));
    ba.boot1_path = petite_path;
    ba.boot2_path = scheme_path;
    ba.boot3_path = racket_path;
    ba.exec_file = "example";
    racket_boot(&ba);
    racket_embedded_load_file(app_path, 1);
    ptr mod = Scons(Sstring_to_symbol("quote"), Scons(Sstring_to_symbol("main"), Snil));
    racket_dynamic_require(mod, Sfalse);
    Sdeactivate_thread();
    return 0;
}

void echo(const char *message) {
    Sactivate_thread();
    ptr mod = Scons(Sstring_to_symbol("quote"), Scons(Sstring_to_symbol("main"), Snil));
    ptr echo_fn = Scar(racket_dynamic_require(mod, Sstring_to_symbol("echo")));
    racket_apply(fn, Scons(Sstring(message), Snil));
    Sdeactivate_thread();
}
```

Take a look at the [Inside Racket CS] documentation for details on the
embedding interface of Racket CS.  The gist of `racket_init` is that
it takes the paths to "petite.boot", "scheme.boot", "racket.boot" and
"app.zo" as arguments in order to initialize Racket and then load the
"app.zo" module, which you can do from the `AppDelegate`'s
`application(_:didFinishLaunchingWithOptions:)` method:

```swift
let vendorPath = Bundle.main.resourcePath!.appending("/vendor")
let ok = racket_init(
    vendorPath.appending("/petite.boot"),
    vendorPath.appending("/scheme.boot"),
    vendorPath.appending("/racket.boot"),
    vendorPath.appending("/app.zo"))
if ok != 0 {
    print("failed to initialize racket")
    exit(1)
}
```

Upon successful initialization, you should be able to call the Racket `echo`
function from Swift:

```swift
echo("Hello from Racket!".cString(using: .utf8))
```

Compile and run the project on a device and you should see "Hello from
Racket!" get printed in your debug console.

### Some XCode gotchas

If you copy "vendor/" into your project instead of creating "folder
references" when you drag-and-drop it, then code signing may fail with
an ambiguous error.

Avoid using symbolic links for any of your resources (like the stuff
in "vendor/").  Doing so makes copying the code over to the device
fail with a "security" error that doesn't mention the root problem at
all.

[caveats]: https://github.com/racket/racket/blob/351c0047d6371e36cf422b4627e020d14e8853fe/racket/src/ChezScheme/c/segment.c#L578-L587
[old]: /2020/01/05/racket-on-ios/
[pr]: https://github.com/racket/racket/pull/3607
[Racket repository]: https://github.com/racket/racket
[build instructions]: https://github.com/racket/racket/blob/08fa24304ebf80a21ade32e8e59bb51b27af1dae/build.md#1-building-racket-from-source
[cross-section]: https://www.cs.utah.edu/plt/snapshots/current/doc/inside/ios-cross-compilation.html?q=inside
[Inside Racket CS]: https://www.cs.utah.edu/plt/snapshots/current/doc/inside/cs.html?q=inside
