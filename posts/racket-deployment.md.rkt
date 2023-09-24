#lang punct

---
title: Deploying Racket Web Apps
date: 2020-06-28T15:00:00+03:00
---

Someone recently asked about how to deploy Racket web apps on the
Racket Slack.  The most common answers were

1. install Racket on the target machine, then ship your code there or
2. use Docker (basically a "portable" variant of option 1).

I wanted to take a few minutes today and write about my preferred way
of deploying Racket apps: build an executable with the application
code, libraries and assets embedded into it and ship that around.  I
prefer this approach because it means I don't have to worry about
installing a specific version of Racket on the target machine just to
run my code.  In fact, using this approach I can have different
versions of each application, each built with a different version of
Racket and easily switch between them.

[raco exe] embeds Racket modules along with the runtime into native
executables for the platform it's run on.  Take this program for
example:

```racket
#lang racket/base

(require racket/async-channel
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define ch (make-async-channel))
(define stop
  (serve
   #:dispatch (dispatch/servlet
               (lambda (_req)
                 (response/xexpr
                  '(h1 "Hello!"))))
   #:port 8000
   #:listen-ip "127.0.0.1"
   #:confirmation-channel ch))

(define ready-or-exn (sync ch))
(when (exn:fail? ready-or-exn)
  (raise ready-or-exn))

(with-handlers ([exn:break?
                 (lambda (_)
                   (stop))])
  (sync/enable-break never-evt))
```

If I save it to a file called `app.rkt` and then call `raco exe -o app
app.rkt`, I'll end up with a self-contained executable called `app` in
the current directory.

```
$ file app
app: Mach-O 64-bit executable x86_64
```

The resulting executable may still refer to dynamic libraries only
available on the current machine so it's not quite ready for
distribution at this stage.  That's where [raco distribute] comes in.
It takes a stand-alone executable created by `raco exe` and generates
a package containing the executable, dynamic libraries referenced by
it and any run-time files referenced by the app (more on this in a
sec).  The resulting package can then be copied over to other machines
running the same operating system.

Running `raco distribute dist app` produces a directory with the
following contents:

```
$ raco distribute dist app
$ tree dist/
dist/
├── bin
│   └── app
└── lib
    ├── Racket.framework
    │   └── Versions
    │       └── 7.7.0.9_CS
    │           ├── Racket
    │           └── boot
    │               ├── petite.boot
    │               ├── racket.boot
    │               └── scheme.boot
    └── plt
        └── app
            └── exts
                └── ert
                    ├── r0
                    │   └── error.css
                    ├── r1
                    │   ├── libcrypto.1.1.dylib
                    │   └── libssl.1.1.dylib
                    └── r2
                        └── bundles
                            ├── es
                            │   └── srfi-19
                            └── srfi-19

15 directories, 10 files
```

I can take that directory, zip it up and ship it to any other machine
running the same version of macOS as I am and it will run unmodified.
The same would be true if I built the code on a Linux machine and then
shipped it to other Linux machines to run on and that's exactly what I
do when I distribute my web apps.  I have a CI job in every project
that builds and tests the code, then generates distributions that it
copies to the destination servers.

At this point you might be thinking "that's nice, but what about files
needed by the app at run-time?"  Let's modify the app so it reads a
file from disk then serves its contents on request:

```racket
#lang racket/base

(require racket/async-channel
         racket/port
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define text
  (call-with-input-file "example.txt" port->string))

(define ch (make-async-channel))
(define stop
  (serve
   #:dispatch (dispatch/servlet
               (lambda (_req)
                 (response/xexpr
                  `(h1 ,text))))
   #:port 8000
   #:listen-ip "127.0.0.1"
   #:confirmation-channel ch))

(define ready-or-exn (sync ch))
(when (exn:fail? ready-or-exn)
  (raise ready-or-exn))

(with-handlers ([exn:break?
                 (lambda (_)
                   (stop))])
  (sync/enable-break never-evt))
```

If I just take this app, build an executable and then a distribution
then try to run it, I'll run into a problem:

```
$ raco exe -o app app.rkt
$ raco distribute dist app
$ cd dist
$ ./bin/app
open-input-file: cannot open input file
  path: /Users/bogdan/tmp/dist/example.txt
  system error: No such file or directory; errno=2
  context...:
   raise-filesystem-error
   open-input-file
   call-with-input-file
   proc
   call-in-empty-metacontinuation-frame
   call-with-module-prompt
   body of '#%mzc:s
   temp35_0
   run-module-instance!
   perform-require!
   call-in-empty-metacontinuation-frame
   eval-one-top
   eval-compiled-parts
   embedded-load
   proc
   call-in-empty-metacontinuation-frame
```

Had I not `cd`'d into the `dist` directory, this would've worked,
because `example.txt` would've been in the working directory where the
application would have been run from.  The problem is we're passing a
path to `call-with-input-file` that Racket doesn't know anything about
at compile time.

To ship the `example.txt` file along with the application, we have to
use [`define-runtime-path`] to tell Racket that it should embed the
file in the distribution and update the code so that it references the
embedded file's eventual path.

```diff
 #lang racket/base

 (require racket/async-channel
          racket/port
+         racket/runtime-path
          web-server/http
          web-server/servlet-dispatch
          web-server/web-server)
+
+(define-runtime-path example-path "example.txt")

 (define text
-  (call-with-input-file "example.txt" port->string))
+  (call-with-input-file example-path port->string))

 (define ch (make-async-channel))
 (define stop
   (serve
    #:dispatch (dispatch/servlet
                (lambda (_req)
                  (response/xexpr
                   `(h1 ,text))))
    #:port 8000
    #:listen-ip "127.0.0.1"
    #:confirmation-channel ch))

 (define ready-or-exn (sync ch))
 (when (exn:fail? ready-or-exn)
   (raise ready-or-exn))

 (with-handlers ([exn:break?
                  (lambda (_)
                    (stop))])
   (sync/enable-break never-evt))
```

The use of `define-runtime-path` in the above code tells `raco
distribute` to copy `example.txt` into the distribution and makes it
so that the `example-path` binding refers to the path that file will
eventually have.

If I build a distribution now and inspect its contents, I can see that
`example.txt` is copied into it:

```
$ raco exe -o app app.rkt
$ raco distribute dist app
$ tree dist
dist/
├── bin
│   └── app
└── lib
    ├── Racket.framework
    │   └── Versions
    │       └── 7.7.0.9_CS
    │           ├── Racket
    │           └── boot
    │               ├── petite.boot
    │               ├── racket.boot
    │               └── scheme.boot
    └── plt
        └── app
            └── exts
                └── ert
                    ├── r0
                    │   └── example.txt
                    ├── r1
                    │   └── error.css
                    ├── r2
                    │   ├── libcrypto.1.1.dylib
                    │   └── libssl.1.1.dylib
                    └── r3
                        └── bundles
                            ├── es
                            │   └── srfi-19
                            └── srfi-19

16 directories, 11 files
```

If you want more information about how this all works, the links I
gave for [raco exe], [raco distribute] and [`define-runtime-path`]
should have you covered!

[raco exe]: https://docs.racket-lang.org/raco/exe.html
[raco distribute]: https://docs.racket-lang.org/raco/exe-dist.html
[`define-runtime-path`]: https://docs.racket-lang.org/reference/Filesystem.html#%28form._%28%28lib._racket%2Fruntime-path..rkt%29._define-runtime-path%29%29
