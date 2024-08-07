#lang punct "../common.rkt"

---
title: Using Units
date: 2024-08-07T16:00:00+03:00
---

I had a use case for [unit]s, a rarely-used feature of Racket, this
week. I ran into units •(@ "Parallelizing the Racket Web Server"
"before") when hacking on the web server, so I knew what they were and
how they worked, but I had never had occasion to write my own unit
before, except to implement the `tcp@` signature.

Basically, units let you write code that depends on bindings whose
concrete implementations are filled in at a later point in time. To
specify the inputs and outputs of a unit, we use signatures:

```racket
(define-signature x^
  (x))
```

The example above declares a signature containing one binding, `x`.
Depending on how the signature is used, `x` may be an import to a unit,
or an export of a unit. We can define a unit, `printer@` that takes the
`x^` signature as input and exports a procedure to print the value of
`x` as follows:

``` racket
(define-signature printer^
  (print-x))

(define-unit printer@
  (import x^)
  (export printer^)
  (define (print-x)
    (println x)))
```

What this is saying is that once the unit `printer@` is invoked, it will
provide a procedure named `print-x` that refers to whatever binding of
`x` is available in scope at invocation time. To invoke the unit, we
can use `define-values/invoke-unit`:

```racket
(define x 42) ;; provide a definition for `x` to be used by the unit

(define-values/invoke-unit printer@
  (import x^)
  (export doer^))

(print-x) ;; prints 42
```

In [Congame], we have a DSL for building studies called `#lang
conscript` which provides some syntactic conveniences on top of
`racket/base`. To run a Conscript study, you need a Congame server,
which can be a pain to set up, especially for students. So, we have
another language called `#lang conscript/local`, which re-provides the
bindings from `#lang conscript`, replacing some of them so that the
whole thing works using a stand-alone web server that doesn't require a
running Postgres database. My use case for units was to write [a generic
implentation of matchmaking][matchmaking] that is reusable between the
two languages.

The process was straightforward. I wrote a signature for the things that
a Conscript-like language provides:

```racket
(define-signature conscript^
  (get-var put-var undefined? call-with-study-transaction)) ;; among others
```

Then, I wrote the signature for the matchmaking implementation:

```racket
(define-signature matchmaking^
  (get-ready-groups get-current-group matchmake))
```

Then, I implemented the unit:

```racket
(define-unit matchmaking@
  (import conscript^)
  (export matchmaking^)
  (define (get-ready-groups) ...)
  (define (get-current-group) ...)
  (define (matchmake group-size) ...))
```

Finally, I instantiated it once using the bindings provided by `#lang
conscript`:

```racket
#lang conscript

(require "matchmaking-sig.rkt"
         "matchmaking-unit.rkt")

(provide (all-defined-out))

(define-values/invoke-unit matchmaking@
  (import conscript^)
  (export matchmaking^))
```

And then I did the same for the `conscript/local` version in a different
module. The only difference between the two modules is the `#lang`
line. The end result is that users of the two languages can import the
respective matchmaking module for their `#lang` and get implementations
that work for their environment, and I get to maintain a single generic
implementation between the two languages.

[unit]: https://docs.racket-lang.org/guide/units.html#%28tech._unit%29
[koyo]: https://docs.racket-lang.org/koyo/index.html
[generics]: https://docs.racket-lang.org/reference/struct-generics.html
[Congame]: https://github.com/marckaufmann/congame
[matchmaking]: https://github.com/MarcKaufmann/congame/pull/152
