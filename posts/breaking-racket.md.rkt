#lang punct "../common.rkt"

---
title: Breaking Racket
date: 2023-03-31T15:00:00+03:00
---

If you've looked at some of the concurrency and networking procedures
available in Racket, you might've noticed a bunch that follow the
naming pattern `<name>/enable-break` and it might not have been
immediately obvious why or when you would use these variants of these
procedures over the regular ones.  Let's look at a snippet from the
documentation of `tcp-accept/enable-break`:

>  If breaking is disabled when `tcp-accept/enable-break` is called,
>  then either ports are returned or the `exn:break` exception is
>  raised, but not both.

So, the procedure guarantees that either it will accept a connection
and return a pair of ports, or it will raise a break exception, if
breaking is disabled when it is called.  Sounds straightforward
enough, but it still might not be clear where this would come in
handy.  The part of the quote about "if breaking is disabled" is an
important hint.  Consider this simplified piece of code based on my
previous post re. the protohackers challenge:

•(define (bullet n)
   (format "•~a" n))

```racket
(define listener (tcp-listen 8000))
(with-handlers ([exn:break? void])
  (let loop ()
    (parameterize-break #f
      (define-values (in out)
        (tcp-accept listener))                     ;; •(bullet 1)
      (define conn-thd
        (thread (make-connection-handler in out))) ;; •(bullet 2)
      (thread (make-supervisor conn-thd in out)))  ;; •(bullet 3)
    (loop)))
(tcp-close listener)
```

We set up a listener, then enter a loop to start accepting new
connections and spawn threads to handle every connection.  For every
connection-handling thread, we spawn a supervising thread to clean up
resources once the handling thread is done.

We want to ensure that a handling thread gets spawned for every accepted
connection, so we want to guarantee that no breaks can be received
between •(bullet 1) and •(bullet 2). Likewise, we want to guarantee
that every handler thread has an associated supervision thread, so no
breaks should be allowed between •(bullet 2) and •(bullet 3) either.
So, we've wrapped •(bullet 1), •(bullet 2), and •(bullet 3) in the
`parameterize-break` form to disable breaks. However, accepting a
new connection will block the thread until a client actually tries
connecting to the server. This means that we can only stop this server
if we happen to send it a break at exactly the time after •(bullet 3)
returns, or by killing the process.

By replacing the call to `tcp-accept` with `tcp-accept/enable-break`,
we can preserve the same guarantees as before while also allowing
breaks to be raised before new connections are accepted.
