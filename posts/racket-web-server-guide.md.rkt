#lang punct

---
title: The Missing Guide to Racket's Web Server
date: 2020-02-12T12:00:00+02:00
---

Racket's built-in [web-server] package is great, but parts of it are
low-level enough that it can be confusing to people who are new to the
language.  In this post, I'm going to try to clear up some of that
confusion by providing some definitions and examples for things
beginners might wonder about.

## Servlets

A servlet is a function from a [`request`] to a [`response`].  It has
the contract:

``` racket
(-> request? can-be-response?)
```

Here's a servlet that replies with "Hello, world!" regardless of what
the request looks like:

```racket
#lang racket/base

(require web-server/http)

(define (hello req)
  (response/output
   (lambda (out)
     (displayln "Hello, world!" out))))
```

And here's one that dynamically constructs a response based on the
request's query parameters:

```racket
#lang racket/base

(require racket/match
         web-server/http)

(define (age req)
  (define binds (request-bindings/raw req))
  (define message
    (match (list (bindings-assq #"name" binds)
                 (bindings-assq #"age" binds))
      [(list #f #f)
       "Anonymous is unknown years old."]

      [(list #f (binding:form _ age))
       (format "Anonymous is ~a years old." age)]

      [(list (binding:form _ name) #f)
       (format "~a is unknown years old." name)]

      [(list (binding:form _ name)
             (binding:form _ age))
       (format "~a is ~a years old." name age)]))
  (response/output
   (lambda (out)
     (displayln message out))))
```

[`serve/servlet`] is a convenience function that configures a server
to run whatever servlet you give it.

Here's how you'd run the `age` servlet using `serve/servlet`:

```racket
#lang racket/base

(define age ...)

(serve/servlet
 age
 #:listen-ip "127.0.0.1"
 #:port 8000
 #:command-line? #t
 #:servlet-path ""
 #:servlet-regexp #rx"")
```

While very convenient for quick things, it obscures a lot of what's
going on under the hood from the caller.  An invocation of the
lower-level [`serve`] function that achieves the same result would
look like:

```racket
#lang racket/base

(require racket/match
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define age ...)

(define stop
  (serve
   #:dispatch (dispatch/servlet age)
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

This sets up a web server with a single dispatcher that runs a single
servlet, running in a background thread.  The return value of the
`serve` function is a function that can be used to stop the server
and, since the server runs in a background thread, I need to do
something on the main thread to prevent it from terminating.  I've
chosen to wait on an event that never terminates and to capture breaks
(such as the `SIGINT` and `SIGTERM` signals (the former is sent when
you press Ctrl+C on a running process)).  When such a break is
received, the `stop` function gets called and the server terminates
gracefully.

## Dispatchers

You may have noticed that, unlike with `serve/servlet`, I couldn't
just pass my `age` servlet directly to `serve`.  I had to turn it into
a dispatcher by calling `dispatch/servlet`.  This is because a
dispatcher, not a servlet, sits at the root of every server.

A dispatcher is a function that takes a [`connection`] object and a
[`request`] and either services that request or calls
[`next-dispatcher`].  Its contract is:

```racket
(-> connection? request? any)
```

Dispatchers' return values *are ignored*.  They operate directly on
the connection objects that they are given.  If I wanted to make my
own dispatcher to run the `age` servlet instead of using
`dispatch/servlet`, it'd look something like this:

```racket
#lang racket/base

(require web-server/http/response)

(define (age-dispatcher conn req)
  (output-response conn (age req)))
```

`output-response` takes a [`connection`] and a [`response`] and
serializes the response over the connection to the client end.

This is equivalent[^1] to:

``` racket
(define age-dispatcher (dispatch/servlet age))
```

There are a number of built-in dispatchers that you'd normally make
use of in a real world project.  The most important of which are:

* [`web-server/dispatchers/dispatch-sequencer`]
* [`web-server/dispatchers/dispatch-filter`]
* [`web-server/dispatchers/dispatch-files`]

### `dispatch-sequencer`

This dispatcher takes a list of dispatchers and runs through them in
order on every request, until it reaches the first one that doesn't
call `next-dispatcher`.

```racket
#lang racket/base

(require net/url
         racket/string
         web-server/dispatchers/dispatch
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/http
         web-server/http/response
         web-server/web-server)

(define (request-path-has-prefix? req p)
  (string-prefix? (path->string (url->path (request-uri req))) p))

(define (a-dispatcher conn req)
  (if (request-path-has-prefix? req "/a/")
      (output-response conn (response/output
                             (lambda (out)
                               (displayln "hello from a" out))))
      (next-dispatcher)))

(define (b-dispatcher conn req)
  (output-response conn
                   (response/output
                    (lambda (out)
                      (displayln "hello from b" out)))))

(define stop
  (serve
   #:dispatch (sequencer:make a-dispatcher
                              b-dispatcher)
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

The above server runs the `a-dispatcher` on every request.  If the
request path doesn't start with `"/a/"`, then it moves on to the
`b-dispatcher`.

### `dispatch-filter`

Filtering the request path like I did in the previous snippet is
pretty cumbersome so the web-server provides the filtering dispatcher
for this exact purpose.  The above code could be rewritten as:

```racket
#lang racket/base

(require (prefix-in filter: web-server/dispatchers/dispatch-filter)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/http
         web-server/http/response
         web-server/web-server)

(define (a-dispatcher conn req)
  (output-response conn
                   (response/output
                    (lambda (out)
                      (displayln "hello from a" out)))))

(define (b-dispatcher conn req)
  (output-response conn
                   (response/output
                    (lambda (out)
                      (displayln "hello from b" out)))))

(define stop
  (serve
   #:dispatch (sequencer:make (filter:make #rx"^/a/" a-dispatcher)
                              b-dispatcher)
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

### `dispatch-files`

This dispatcher can be used to serve files off of the filesystem.  You
can combine it with the other dispatchers to generate a server that
can either serve files off of the filesystem or fall back to a
servlet:

```racket
#lang racket/base

(require net/url
         (prefix-in files: web-server/dispatchers/dispatch-files)
         (prefix-in filter: web-server/dispatchers/dispatch-filter)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/dispatchers/filesystem-map
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define (homepage req)
  (response/xexpr
   '(html
     (head
      (link ([href "/static/screen.css"] [rel "stylesheet"])))
     (body
      (h1 "Hello!")))))

(define url->path/static
  (make-url->path "static"))

(define static-dispatcher
  (files:make #:url->path (lambda (u)
                            (url->path/static
                             (struct-copy url u [path (cdr (url-path u))])))))

(define stop
  (serve
   #:dispatch (sequencer:make
               (filter:make #rx"^/static/" static-dispatcher)
               (dispatch/servlet homepage))
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

This dispatcher needs to know how to map the current request URL to a
path on the filesystem.

First, I create a function that maps URLs to file paths within the
`static` directory (a relative path from where the server happens to
be run (the current working directory)).  This function automatically
removes things like `..` from the paths it is given, ensuring that no
request paths can "escape" out of the static directory.

Then, I pass `files:make` a function that maps URLs to file paths.
Since I'm going to serve all static files from URLs that start with
`/static/`, I need to drop that prefix from the URL before I pass it
to the `url->path/static` function because it expects a file path
relative to the `static` directory.

Finally, I sequence the static dispatcher along with a servlet
dispatcher that serves the home page and the end result is a web
server that can serve static files from a directory and run dynamic
Racket code!

## Routing

You could route requests by sequencing together multiple
`dispatch-filter` dispatchers, but that wouldn't be very ergonomic.
The web server provides the [`dispatch-rules`] macro as a convenient
way to declare *servlets* -- not dispatchers! the overloading of terms
here can be a bit confusing -- that perform different actions based on
the request method and path.

```racket
#lang racket/base

(require net/url
         web-server/dispatch
         (prefix-in files: web-server/dispatchers/dispatch-files)
         (prefix-in filter: web-server/dispatchers/dispatch-filter)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/dispatchers/filesystem-map
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define (response/template . content)
  (response/xexpr
   `(html
     (head
      (link ([href "/static/screen.css"] [rel "stylesheet"])))
     (body
      ,@content))))

(define (homepage req)
  (response/template '(h1 "Home")))

(define (blog req)
  (response/template '(h1 "Blog")))

(define-values (app reverse-uri)
  (dispatch-rules
   [("") homepage]
   [("blog") blog]))

(define url->path/static (make-url->path "static"))

(define static-dispatcher
  (files:make #:url->path (lambda (u)
                            (url->path/static
                             (struct-copy url u [path (cdr (url-path u))])))))

(define stop
  (serve
   #:dispatch (sequencer:make
               (filter:make #rx"^/static/" static-dispatcher)
               (dispatch/servlet app))
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

Using `dispatch-rules` as I've done above produces two values: a
servlet that maps requests made to `/` to the `homepage` servlet and
requests made to `/blog` to the `blog` servlet, and a function that
can produce reverse URIs when given either of those functions.

Plugging that in via `dispatch/servlet` into the main servlet sequence
gets you a server that can serve files off of disk and also
dynamically dispatch requests to multiple servlets.

One final tweak we might want to make here is to plug another servlet
after the app servlet into the sequencer to handle requests to paths
that don't exist:

```racket
#lang racket/base

(require net/url
         web-server/dispatch
         (prefix-in files: web-server/dispatchers/dispatch-files)
         (prefix-in filter: web-server/dispatchers/dispatch-filter)
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         web-server/dispatchers/filesystem-map
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define (response/template . content)
  (response/xexpr
   `(html
     (head
      (link ([href "/static/screen.css"] [rel "stylesheet"])))
     (body
      ,@content))))

(define (homepage req)
  (response/template '(h1 "Home")))

(define (blog req)
  (response/template '(h1 "Blog")))

(define (not-found req)
  (response/template '(h1 "Not Found")))

(define-values (app reverse-uri)
  (dispatch-rules
   [("") homepage]
   [("blog") blog]))

(define url->path/static (make-url->path "static"))

(define static-dispatcher
  (files:make #:url->path (lambda (u)
                            (url->path/static
                             (struct-copy url u [path (cdr (url-path u))])))))

(define stop
  (serve
   #:dispatch (sequencer:make
               (filter:make #rx"^/static/" static-dispatcher)
               (dispatch/servlet app)
               (dispatch/servlet not-found))
   #:listen-ip "127.0.0.1"
   #:port 8000))

(with-handlers ([exn:break? (lambda (e)
                              (stop))])
  (sync/enable-break never-evt))
```

[^1]: I am simplifying things here for the purposes of this guide.
    The `dispatch/servlet` function does some additional work to
    support continuations.  See [Continuations in Racket's Web
    Server][conts] for details.

[web-server]: https://docs.racket-lang.org/web-server/index.html?q=web-server
[`request`]: https://docs.racket-lang.org/web-server/http.html?q=request#%28def._%28%28lib._web-server%2Fhttp%2Frequest-structs..rkt%29._request%29%29
[`response`]: https://docs.racket-lang.org/web-server/http.html?q=request#%28def._%28%28lib._web-server%2Fhttp%2Fresponse-structs..rkt%29._response%29%29
[`serve/servlet`]: https://docs.racket-lang.org/web-server/run.html?q=serve%2Fservlet#%28def._%28%28lib._web-server%2Fservlet-env..rkt%29._serve%2Fservlet%29%29
[`serve`]: https://docs.racket-lang.org/web-server-internal/web-server.html?q=serve#%28def._%28%28lib._web-server%2Fweb-server..rkt%29._serve%29%29
[`connection`]: https://docs.racket-lang.org/web-server-internal/connection-manager.html?q=connection%3F#%28def._%28%28lib._web-server%2Fprivate%2Fconnection-manager..rkt%29._connection~3f%29%29
[`next-dispatcher`]: https://docs.racket-lang.org/web-server-internal/dispatch.html?q=next-dispatcher#%28def._%28%28lib._web-server%2Fdispatchers%2Fdispatch..rkt%29._next-dispatcher%29%29
[`web-server/dispatchers/dispatch-files`]: https://docs.racket-lang.org/web-server-internal/dispatch-files.html?q=dispatchers%2Ffile
[`web-server/dispatchers/dispatch-filter`]:  https://docs.racket-lang.org/web-server-internal/dispatch-filter.html?q=dispatchers%2Ffile
[`web-server/dispatchers/dispatch-sequencer`]: https://docs.racket-lang.org/web-server-internal/dispatch-sequencer.html?q=dispatchers%2Ffile
[`dispatch-rules`]: https://docs.racket-lang.org/web-server/dispatch.html?q=dispatch-rules#%28form._%28%28lib._web-server%2Fdispatch..rkt%29._dispatch-rules%29%29
[conts]: /2020/05/11/racket-web-server-internals/
