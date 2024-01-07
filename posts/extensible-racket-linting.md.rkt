#lang punct "../common.rkt"

---
title: Extensible Linting for Racket
date: 2024-01-07T18:37:00+02:00
---

Several years ago, I released [review], a little linter for Racket.
Recently, I added support for extending the linter from arbitrary Racket
packages.

Review analyzes code by pattern-matching on input programs'
surface-level syntax, rather than by analyzing their fully-expanded
forms. This is a nice property because it means that it can provide
advice about _how_ to use certain syntactic forms before those forms
are expanded to core Racket forms. It is, however, a double-edged sword
because it means that the linter has to have a rule for every syntactic
form it wants to lint, including ones that it can't possibly have any
knowledge of (eg. because they're user-defined). By default, review
simply ignores such unknown forms and does its best to analyze the rest
of the program. This works reasonably well, but may cause it to return
false-positive results or miss certain issues altogether.

I had had it in the back of my mind to make review user-extensible for
a while but never got around to it until this winter break. It turned
out to be much easier than I expected!

When review is run, it looks for installed Racket [packages] that have a
`review-exts` entry in any of their `info.rkt` files. Every entry must
be a list of 3-element lists of this form:

    [module-path should-review?-proc-id review-ext-proc-id]

On boot, it dynamically requires the `should-review?-proc-id` and
the `review-ext-proc-id` from each `module-path` of each entry it
discovers. For every expression in the input program, it applies each
`should-review?-proc` against the expression's syntax object. If any
of the `should-review?` procedures returns `#t`, that procedure's
associated `review-ext-proc` is then called on that syntax object. The
first match wins and, if there are no matches, then review falls back to
its own analysis of the expression.

Review extension procedures can use the bindings provided by the
`review/ext` module to track any errors or warnings they find or to
manage scopes and bindings.

## A Concrete Example

The above description probably makes things sound more complicated than
they really are. So, let's try to write a custom linter. Say we have a
custom form for defining records:

```racket
(define-record RECORD-ID
  (FIELD ...))

Where:

  FIELD
    = [FIELD-ID : TYPE-ID]

  TYPE-ID
    = Int
    | Str
```

The form can be used as follows:

``` racket
(define-record Person
 ([name : Str]
  [age : Int]))
```

For every record, the above definition generates a constructor
procedure (`make-Person`), a predicate (`Person?`), accessors for every
field (`Person-name` and `Person-age`), and setters for every field
(`set-Person-name` and `set-Person-age`).

We can start by adding a module called `review.rkt` to the root of
our collection. In it, we'll have to define our `should-review?` and
`review-syntax` procedures:

``` racket
#lang racket/base

(require review/ext
         syntax/parse)

(provide
 should-review?
 review-syntax)

(define (should-review? stx)
  (syntax-parse stx
    #:datum-literals (define-record)
    [(define-record . _rest) #t]
    [_ #f]))

(define (review-syntax stx)
  stx)
```

The `should-review?` procedure returns `#t` whenever it is given a list
whose first item is the literal symbol `define-record` and `#f` in every
other case. For now, the `review-syntax` procedure is just a stub that
does nothing. With this module in hand, we can now update our `info.rkt`
file to add a `review-exts` entry:

``` racket
#lang info

...

;; Assuming our collection is named "example".
(define review-exts
  '([example/review should-review? review-syntax]))
```

As soon as we do this, running `raco review` against a program should
defer to the `review-syntax` procedure above any time it encounters a
`(define-record ...)` form. So, let's extend it to perform some checks:

``` racket
#lang racket/base

#|review: ignore|#

(require review/ext
         syntax/parse/pre)

(provide
 should-review?
 review-syntax)

(define (should-review? stx)
  (syntax-parse stx
    #:datum-literals (define-record)
    [(define-record . _rest) #t]
    [_ #f]))

(define-syntax-class field-definition
  #:datum-literals (: Int Str)
  (pattern [id:id : {~or Int Str}])
  (pattern [id:id : type] #:do [(track-error #'type "invalid type")])
  (pattern e
           #:attr id #'stub
           #:do [(track-error this-syntax "invalid field definition")]))

(define-syntax-class record-definition
  (pattern (define-record record-id:id
             (record-field:field-definition ...))))

(define (review-syntax stx)
  (syntax-parse stx
    [d:record-definition #'d]
    [_ (begin0 stx
         (track-error stx "invalid record definition"))]))
```

Above, we define syntax classes to pattern match on record and field
definitions. Match failures, including using invalid types for field
definitions, are reported as errors. This already gets us a useful
little linter that checks that our uses of `define-record` are
syntactically valid. With a little more work, we can extend our
`record-definition` class to track the bindings generated by
`define-record`:

``` racket
(define-syntax-class record-definition
  (pattern (define-record record-id:id
             (record-field:field-definition ...))
           #:do [(track-binding #'record-id "make-~a")
                 (track-binding #'record-id "~a?")
                 (define record-id-sym (syntax->datum #'record-id))
                 (for ([field-id-stx (in-list (syntax-e #'(record-field.id ...)))])
                   (track-binding field-id-stx (format "~a-~~a" record-id-sym))
                   (track-binding field-id-stx (format "set-~a-~~a" record-id-sym)))]))
```

Now, our linter will complain if we have any unused fields. You can
find the full example on [GitHub][example]. For a slightly more complex
example, check out the custom linter for deta on [GitHub][deta-example].

## Limitations

This approach has some obvious limitations. The binding tracking is
approximate and done as a side-channel to the way Racket actually does
things. Syntactic forms are recognized symbolically rather than by
binding, so linters have no way of recognizing renamed imports, nor
do they have a way of distinguishing the same names across different
libraries.

Despite all that, I get valuable support from review in the 80% [^1] of
cases where it does work well, and I expect to get more out of it as I
wrote more extensions for bits of custom syntax that I have here and
there. Maybe you will too!

[^1]: A made-up number.

[review]: https://github.com/Bogdanp/racket-review
[packages]: https://docs.racket-lang.org/guide/module-basics.html#%28tech._package%29
[example]: https://github.com/Bogdanp/racket-review-ext-example
[deta-example]: https://github.com/Bogdanp/deta/tree/3b2d819f52e79e253b6b97e668c3f65a0cab032d/deta-lint-lib
