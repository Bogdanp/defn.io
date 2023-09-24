#lang punct

---
title: Continuations in Racket's Web Server
date: 2020-05-11T11:55:00+03:00
---

In [The Missing Guide to Racket's Web Server][guide], I said that
`dispatch/servlet` is equivalent to:

```racket
(lambda (start)
  (lambda (conn req)
    (output-response conn (start req))))
```

That was an oversimplification.  It does apply its `start` argument to
incoming requests and it does take care of writing the responses to
the appropriate connections, but it has another important job: to
handle responses returned from continuations and to dispatch incoming
requests to captured continuations.

With a number of details omitted, the essence of `dispatch/servlet` is
actually the following:

```racket
(define servlet-prompt
  (make-continuation-prompt 'servlet))

(define (dispatch/servlet start)
  (define servlet (make-servlet start))
  (lambda (conn req)
    (output-response conn (call-with-continuation-barrier
                           (lambda ()
                             (call-with-continuation-prompt
                              (lambda ()
                                ((servlet-handler servlet) req))
                              servlet-prompt))))))
```

First, it creates a `servlet` value that wraps the request-handling
function that it is given.  The servlet contains some internal state
that maps request URIs to captured continuations.  The servlet's
`handler` field is what decides which code to run when a request comes
in: if the request URI matches a known continuation, then that
continuation is resumed, otherwise the `start` function is applied to
the request.

After creating the servlet, it returns a dispatcher that applies the
servlet's handler to the request and writes the resulting response to
the connection.  Before it applies the servlet handler, however, it
sets up a continuation barrier so that continuations captured within
the servlet cannot be resumed from outside of the request-response
cycle.  This ensures that you can't resume such a continuation outside
of the request-response cycle, when the client isn't prepared to
receive a response.  After installing the continuation barrier, it
installs a continuation prompt so that the various "web interaction"
functions can abort to it.

The simplest of the web interaction functions, `send/back`, looks like
this:

```racket
(define (send/back resp)
  (abort-current-continuation servlet-prompt (lambda () resp)))
```

Knowing that, consider the following request handler:

```racket
(define (hello req)
  (send/back (response/xexpr "sent"))
  (response/xexpr "ignored"))
```

When execution reaches the `send/back` function call, it aborts to the
nearest[^1] `servlet-prompt` handler, which happens to be the one that
`dispatch/servlet` installs with `call-with-continuation-prompt`, so
the execution of the request handler short circuits and the response
passed to `send/back` is immediately sent to the client.

The `send/suspend` function, on the other hand, looks roughly[^2] like
this:

```racket
(define (send/suspend f)
  (call-with-composable-continuation
   (lambda (k)
     (define k-url (store-continuation! k))
     (send/back (f k-url)))
   servlet-prompt))
```

Rather than immediately sending a response back to the client, it
captures the current continuation, associates it with a URL and then
passes that URL to a function, `f`, that generates a response.  The
resulting response is then sent back to the client.

Using `send/suspend`, you can write request handlers that can be
suspended in the middle of execution and then resumed upon subsequent
requests:

```racket
(define (resumable req)
  (define req-2
    (send/suspend
     (lambda (k-url)
       (response/xexpr
        `(a ([href ,k-url]) "Resume")))))
  (response/xexpr "done"))
```

When `resumable` is executed, the first response is generated and
returned to the client and when the client visits the anchor, the
continuation is resumed from where the first request left off, with
the new request bound to `req-2`.

[^1]: If you're wondering whether or not you can install your own
    intermediary `servlet-prompt` handlers, the answer is yes!
[^2]: For clarity, I'm omitting a number of implementation details
    once again.

[guide]: /2020/02/12/racket-web-server-guide/
