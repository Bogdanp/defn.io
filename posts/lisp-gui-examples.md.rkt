#lang punct

---
title: LISP GUI Examples
date: 2021-11-16T08:00:00+02:00
---

I recently ran across Matthew D. Miller's ["Survey of the State of
GUI Programming in Lisp"][series] series on implementing a small
GUI application across various LISP implementations. The [first
article][first] in that series uses `racket/gui`, so I figured I'd take
a stab at porting that implementation to [gui-easy]. You can find my
port [here][port].

Porting the code was straightforward, but it uncovered a common problem
with bidirectional [`input`]s: updating the field's value observable
on every change meant that the text (and cursor position) changed
as the user typed because every change would trigger an update (and
thus a re-rendering of the text) to the underlying text field. To
work around those sorts of problems, I introduced the `#:value=?` and
`#:value->text` arguments in commit [`ce190608`]. Input views with a
`#:value=?` function only re-render the text field's contents when the
current value of the input observable is different (according to the
`#:value=?` function) from the previous one. This means that you can use
that argument to control whether or not partial edits end up triggering
a re-rendering of the text, so instead of:

```racket
(define/obs @n 42)
(render
 (window
  #:size '(200 #f)
  (input
   (@n . ~> . number->string)
   (λ (_event text)
     (cond [(string->number text) => (λ:= @n)])))))
```

You can write:

```racket
(define/obs @n 42)
(render
 (window
  #:size '(200 #f)
  (input
   @n
   #:value=? =
   #:value->text number->string
   (λ (_event text)
     (cond [(string->number text) => (λ:= @n)])))))
```

In the first example, typing a `.` after `42` re-renders the text as
`42.0` and places the cursor at the end. In the second, it doesn't
re-render the text at all since `42.0` and `42` are `=`. Still, the
second example isn't perfect since `string->number` parses `42.` to
`42.0` so, if you type `42.5` into the text field and then delete the
`5`, it will re-render the value as `42.0`. You can work around this
problem by avoiding partial updates in the input's action:

```diff
   (λ (_event text)
--   (cond [(string->number text) => (λ:= @n)]))
++   (unless (string-suffix? text ".")
++     (cond [(string->number text) => (λ:= @n)])))
```

Perhaps a better way to handle this would be to make the `#:value->text`
argument smarter and have it pass the current text to the rendering
function when it has an arity of two. That way the rendering function
can decide whether or not it needs to change the text. I'll have to
experiment with that.

[series]: https://blog.matthewdmiller.net/series/survey-of-the-state-of-gui-programming-in-lisp
[first]: https://blog.matthewdmiller.net/learn-racket-by-example-gui-programming
[gui-easy]: https://github.com/Bogdanp/racket-gui-easy
[port]: https://github.com/Bogdanp/lisp-gui-examples/blob/dd61503c00ba384527a737ff35a19f4a40f88dd4/examples/racket/bleep2.rkt
[`input`]: https://docs.racket-lang.org/gui-easy/index.html#%28def._%28%28lib._racket%2Fgui%2Feasy..rkt%29._input%29%29
[`ce190608`]: https://github.com/Bogdanp/racket-gui-easy/commit/ce190608
