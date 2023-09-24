#lang punct

---
title: Parallelizing the Racket Web Server
date: 2021-12-30T13:45:00+02:00
---

Racket provides support for concurrency via lightweight threads, which
the [web server] leverages to handle requests, spawning one such
thread per incoming request. At the runtime level, these threads run
concurrently but not in parallel (i.e., only one thread is active at any
one time). Parallelism is available in Racket via [Places]: distinct
instances of the Racket runtime running in separate OS threads that
communicate via message passing.

The web server doesn't do anything with places, so, by default, all
Racket web servers run in a single OS thread. That isn't a big deal
since you can run one web server process per core and place a reverse
proxy like Nginx in front to load balance between the processes. But
what if you don't want to do that? Is there a way to use the web server
in conjunction with places despite the web server lacking explicit
support for them?

The answer is "yes." Otherwise, I wouldn't be writing this post!
Doing so can lead to a decent reduction in memory usage over the
multi-process approach since some resources (such as code, shared
libraries, allocation segments, etc.) are shared between places.

One approach to solving this problem might be to spawn multiple places,
each running a web server bound to the same port. Unfortunately, it's
not possible in Racket to re-use TCP ports (primarily because not
all platforms have an equivalent of Linux's `SO_REUSEPORT` flag).
Thankfully, the web server's `serve` function takes an optional `tcp@`
argument. We can leverage that argument to provide the server with a
custom implementation of the [`tcp^` signature]. So, our main place can
spawn one place for every parallel web server that we want to run, then
run a TCP server of its own, accept new connections on that server, and
send each connection to the web server places one by one.

Take this minimal application -- saved on my machine as `app.rkt` -- for
example:

```racket
#lang racket/base

(require web-server/dispatch
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(provide
 start)

(define-values (app _)
  (dispatch-rules
   [("")
    (λ (_req)
      (response/output
       (λ (out)
         (displayln "hello, world" out))))]
   [else
    (λ (_req)
      (response/output
       #:code 404
       (λ (out)
         (displayln "not found" out))))]))

(define (start host port)
  (serve
   #:dispatch (dispatch/servlet app)
   #:listen-ip host
   #:port port))

(module+ main
  (define stop (start "127.0.0.1" 8000))
  (with-handlers ([exn:break? (λ (_)
                                (stop))])
    (sync never-evt)))
```

Without modifying `app.rkt`, we can create a second module, called
`main.rkt`, that spawns multiple instances of the server, each bound to
different ports:

```racket
#lang racket/base

(require racket/match
         racket/place
         "app.rkt")

(define (start-place)
  (place ch
    (let loop ([stop void])
      (match (sync ch)
        [`(init ,host ,port)
         (loop (start host port))]
        [`(stop)
         (stop)]))))

(module+ main
  (define places
    (for/list ([idx (in-range 4)])
      (define pch (start-place))
      (begin0 pch
        (place-channel-put pch `(init "127.0.0.1" ,(+ 8000 idx))))))

  (with-handlers ([exn:break? (λ (_)
                                (for ([pch (in-list places)])
                                  (place-channel-put pch '(stop)))
                                (for-each place-wait places))])
    (sync never-evt)))
```

Next, we can define our custom `tcp@` unit in `main.rkt`:

```diff
  #lang racket/base

- (require racket/match
+ (require net/tcp-sig
+          racket/match
           racket/place
+          (prefix-in tcp: racket/tcp)
+          racket/unit
           "app.rkt")

+ (struct place-tcp-listener ())
+
+ (define (make-place-tcp@ accept-ch)
+   (unit
+     (import)
+     (export tcp^)
+
+     (define (tcp-addresses _p [port-numbers? #f])
+       (if port-numbers?
+           (values "127.0.0.1" 1 "127.0.0.1" 0)
+           (values "127.0.0.1" "127.0.0.1")))
+
+     (define (tcp-connect _hostname
+                          _port-no
+                          [_local-hostname #f]
+                          [_local-port-no #f])
+       (error 'tcp-connect "not supported"))
+
+     (define (tcp-connect/enable-break _hostname
+                                       _port-no
+                                       [_local-hostname #f]
+                                       [_local-port-no #f])
+       (error 'tcp-connect/enable-break "not supported"))
+
+     (define (tcp-abandon-port p)
+       (tcp:tcp-abandon-port p))
+
+     (define (tcp-listen _port-no
+                         [_backlog 4]
+                         [_reuse? #f]
+                         [_hostname #f])
+       (place-tcp-listener))
+
+     (define (tcp-listener? l)
+       (place-tcp-listener? l))
+
+     (define (tcp-close _l)
+       (void))
+
+     (define (tcp-accept _l)
+       (apply values (channel-get accept-ch)))
+
+     (define (tcp-accept/enable-break _l)
+       (apply values (sync/enable-break accept-ch)))
+
+     (define (tcp-accept-ready? _l)
+       (error 'tcp-accept-ready? "not supported"))))

  (define (start-place)
    (place ch
      (let loop ([stop void])
        (match (place-channel-get ch)
          [`(init ,host ,port)
           (loop (start host port))]
          [`(stop)
           (stop)]))))

  (module+ main
    (define places
      (for/list ([idx (in-range 4)])
        (define pch (start-place))
        (begin0 pch
          (place-channel-put pch `(init "127.0.0.1" ,(+ 8000 idx))))))

    (with-handlers ([exn:break? (λ (_)
                                  (for ([pch (in-list places)])
                                    (place-channel-put pch '(stop)))
                                  (for-each place-wait places))])
      (sync never-evt)))
```

It may look daunting at first glance, but `make-place-tcp@` is
straightforward: it takes a channel of TCP connections as input and
produces an instance of a [unit] that implements the `tcp^` signature
that accepts new connections off of that channel. The web server doesn't
use the client-specific functions, so we don't need to bother with
their implementation. The `tcp-listen` function returns new instances
of a stub struct, and `tcp-accept` synchronizes on the input channel
to receive new connections (each a list of an input port and an output
port).

Next, let's change `start-place` to instantiate the unit for each web
server place and to pass that unit along to the app:

```diff
  (define (start-place)
    (place ch
+     (define connections-ch (make-channel))
+     (define tcp@ (make-place-tcp@ connections-ch))
      (let loop ([stop void])
        (match (sync ch)
          [`(init ,host ,port)
-          (loop (start host port))]
+          (loop (start host port tcp@))]
          [`(stop)
           (stop)]))))
```

Now we need to change `app.rkt`'s `start` function to take the `tcp@`
argument and pass it to `serve`:

```diff
- (define (start host port)
+ (define (start host port tcp@)
    (serve
     #:dispatch (dispatch/servlet app)
     #:listen-ip host
-    #:port port))
+    #:port port
+    #:tcp@ tcp@))
```

Next, we can change `start-place` to accept new connections on its place
channel:

```diff
  (define (start-place)
    (place ch
      (define connections-ch (make-channel))
      (define tcp@ (make-place-tcp@ connections-ch))
      (let loop ([stop void])
        (match (sync ch)
          [`(init ,host ,port)
           (loop (start host port tcp@))]
+         [`(accept ,in ,out)
+          (channel-put connections-ch (list in out))
+          (loop stop)]
          [`(stop)
           (stop)]))))
```

Finally, we have to change the main place to make it spawn a TCP server
to accept new connections and dispatch them to the server places:

```diff
  (module+ main
+   (require racket/tcp)
+
+   (define num-places 4)
    (define places
-     (for/list ([idx (in-range 4)])
+     (for/list ([_ (in-range num-places)])
        (define pch (start-place))
        (begin0 pch
-         (place-channel-put pch `(init "127.0.0.1" ,(+ 8000 idx))))))
+         (place-channel-put pch `(init "127.0.0.1" 8000)))))

+   (define listener
+     (tcp-listen 8000 4096 #t "127.0.0.1"))
+   (with-handlers ([exn:break? (λ (_)
+                                 (for ([pch (in-list places)])
+                                   (place-channel-put pch '(stop)))
-                                 (for-each place-wait places))])
+                                 (for-each place-wait places)
+                                 (tcp-close listener))])
-     (sync never-evt)))
+     (let loop ([idx 0])
+       (define pch (list-ref places idx))
+       (define-values (in out)
+         (tcp-accept listener))
+       (place-channel-put pch `(accept ,in ,out))
+       (tcp-abandon-port out)
+       (tcp-abandon-port in)
+       (loop (modulo (add1 idx) num-places))))
```

Now the main place spawns four other places, each running a web server
that accepts new connections via the custom TCP unit, then it launches
a TCP server on port 8000 and dispatches incoming connections to the
server places in round-robin order. I used this approach earlier
this week to improve the implementation of the [Racket TechEmpower
benchmark][pr].

You can find the final version of the code in this post [here][gist].

[web server]: https://docs.racket-lang.org/web-server/index.html
[Places]: https://docs.racket-lang.org/guide/parallelism.html#%28part._effective-places%29
[`tcp^` signature]: https://docs.racket-lang.org/net/tcp.html#%28form._%28%28lib._net%2Ftcp-sig..rkt%29._tcp~5e%29%29
[unit]: https://docs.racket-lang.org/guide/units.html#%28tech._unit%29
[pr]: https://github.com/TechEmpower/FrameworkBenchmarks/pull/7003
[gist]: https://gist.github.com/Bogdanp/730ee19345d4f89d97c8be73739b7659
