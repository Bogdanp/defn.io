#lang punct "../common.rkt"

---
title: Generators from Scratch
date: 2019-09-05T17:00:00+03:00
---

## Generators in Python

One of the nice things about Python is that it comes with in-built
support for "generators", functions that can suspend themselves and be
resumed in the middle of processing.  Here's a generator that produces
the fibonacci series:

```python
def fib():
    x = 0
    y = 1
    while True:
        y, x = x + y, y
        yield x
```

A generator is instantiated every time you call the `fib` function.
Once you have a generator object, you can run it until the next time
it suspends itself by passing it to the `next` function:

```python
>>> fibber = fib()
>>> next(fibber)
1
>>> next(fibber)
1
>>> next(fibber)
2
>>> next(fibber)
3
>>> next(fibber)
5
>>> next(fibber)
8
>>> next(fibber)
13
```

The very first time we call `next` on `fib`, all of the code within it
runs and gets suspended at the `yield`, returning the first value.
Every time we call `next` on it after that, it resumes execution after
the `yield`, which happens to be in a `while` loop, so execution jumps
to the top of the loop.  `x` and `y` are modified and the function
`yield`s again, suspending itself and returning the new value for `y`.

This can go on and on until the machine runs out of memory.

Another property of generators is that you can send values into them
every time they are resumed.  Here's a generator that computes the sum
of two numbers sent from the outside:

```python
def add():
    x = yield "expecting x"
    y = yield "expecting y"
    return x + y
```

When you run this generator, execution first suspends before `x` is
assigned and then it suspends again before `y` is assigned.

```python
>>> adder = add()
>>> adder.send(None)
'expecting x'
>>> adder.send(1)
'expecting y'
>>> adder.send(2)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
StopIteration: 3
```

Think of the `send` method as a lower level way of resuming a
generator than `next`, with the added benefit that it allows you to
send values into the generator (whereas `next` always sends `None`).

Above, I first call `send` with `None`, which signals to the generator
that it can start executing.  Then I send it the value that should be
assigned to `x`, followed by the value for `y`.  Once it hits the
`return` statement, the generator raises `StopIteration` with the
returned value.


## Generators in Racket

Racket's standard library also comes with built-in support for
generators via the [racket/generator] module.  But what if it didn't?
Could we implement Python-like generators in the language itself?  The
answer, of course, is "yes."

Racket comes with an even more general mechanism for capturing and
resuming computation, called [continuations].  Continuations let you
capture the execution of a program at a particular point as a
function.  When applied, that function will cause the program flow to
jump back to the point it refers to.  Here's an example:

```scheme
(+ 1
   (call/cc
    (lambda (k)
      (displayln "before k is applied")
      (k 2)
      (displayln "after k is applied")))
   3)
```

`call/cc` captures the current continuation and passes it to another
function -- in this case the lambda we created -- and, as mentioned
above, when the continuation, `k`, is applied the program will jump to
the spot that `call/cc` was itself applied at, effectively "return"ing
from it with the value passed into the continuation.

So the above program:

1. evaluates `1`,
2. evaluates the `call/cc`, reaching the line where `k` is applied,
3. jumps back to the point where it started evaluating the `call/cc`,
4. replaces the entire `call/cc` block with the value passed to `k`,
5. evaluates the `3`, and, finally,
6. evaluates `(+ 1 2 3)`.

The `(displayln "after k is applied")` expression is never evaluated
by this program.

Here's another example, where we escape an infinite loop by way of a
continuation:

```scheme
(call/cc
 (lambda (k)
   (define (loop i)
     (when (= i 5)
       (k i))

     (loop (add1 i)))

   (loop 0)))
```

Here we:

1. evaluate the `call/cc` and capture the current continuation, `k`
2. recursively loop until `i` is `5`, when we apply `k` and
3. jump back to the point where `call/cc` was called and replace it
   with the value passed to `k`, which is `5`.

Here's the same program with `k` renamed to `return`:

```scheme
(call/cc
 (lambda (return)
   (define (loop i)
     (when (= i 5)
       (return i))

     (loop (add1 i)))

   (loop 0)))
```

Does that look familiar?


### Delimited Continuations

To implement our generators, we're going to use a more general type of
continuations called "[delimited continuations]."  These types of
continuations allow us to install "prompts", continuation frames
associated with specific prompt tags, and then later on in the
execution of the program, abort to the nearest enclosing prompt with a
particular tag without needing to have a reference to the captured
continuation.

Here's an example where I install a prompt and then abort to it:

```scheme
(define the-tag
  (make-continuation-prompt-tag))

(+ 1
   (call-with-continuation-prompt
    (lambda ()
      (displayln "before abort")
      (abort-current-continuation the-tag 2)
      (displayln "after abort"))
    the-tag
    (lambda (x)
      (displayln "received x")
      x))
   3)
```

When `abort-current-continuation` is applied, execution jumps to the
abort handler (the third argument to `call-with-continuation-prompt`)
and then returns from the point where `call-with-continuation-prompt`
is applied.  So the above program prints

```
before abort
received x
6
```

That shared prompt tag is how the abort function knows which
continuation prompt it should jump to.

With this in mind, we can define a prompt tag for our continuations:

```scheme
(define yield-tag
  (make-continuation-prompt-tag))
```

Followed by the `yield` function:

```scheme
(define current-yielder
  (make-parameter
   (lambda _
     (error 'yield "may only be called within a generator"))))

(define (yield . args)
  (apply (current-yielder) args))
```

`yield` looks up the value of the current yielder and then applies its
arguments to that function.  The default value of `current-yielder`
raises an error so that `yield` will fail if applied outside of a
generator.

Next, we implement the `generator` function itself:

```scheme
(define (generator proc)
  (lambda _
    (define cont proc)

    (define (next . args)
      (call-with-continuation-prompt
       (lambda _
         (parameterize ([current-yielder yield])
           (begin0 (apply cont args)
             (set! cont (lambda _
                          (error 'generator "exhausted"))))))
       yield-tag))

    (define (yield . args)
      (call-with-current-continuation
       (lambda (k)
         (set! cont k)
         (abort-current-continuation yield-tag (lambda _
                                                 (apply values args))))
       yield-tag))

    next))
```

This function takes another function, `proc`, as an argument and
returns a function that will create a generator "instance" (really,
it's just another function!) when applied.

Let's break down what happens inside the generator "factory" that is
created.  First, the original function is assigned to `cont`.  Next,
an inner function called `next` is defined.

When applied, `next` installs a new continuation prompt with the
`yield-tag`.  Inside the extent of the prompt, `next` then sets
the current yielder to `yield`, which we'll talk about in a second,
and returns the value of applying `cont` to its arguments.

Next, the `yield` function that `next` references is defined.  When
applied, it captures its own continuation (the continuation of the
place that it itself was applied at), it then updates `cont` to point
to that continuation and, finally, it aborts to the nearest prompt
with the `yield-tag` (i.e. the place where the `next` function was
applied), passing a function that returns `yield`'s arguments to the
continuation prompt handler that `call-with-continuation-prompt`
installed.  Because we didn't pass a handler function to
`call-with-continuation-prompt`, the default handler, which applies
whatever argument it's given, is used.

Finally, the `next` function is returned from the "factory."

And that's it!  That's pretty much all you need to do to get a working
implementation of generators.

Here's the definition of our `fib` generator built using this function:

```scheme
(define fib
  (generator
   (lambda ()
     (let loop ([x 1]
                [y 1])
       (yield x)
       (loop y (+ x y))))))
```

and here it is in use:

```scheme
> (define fibber (fib))
> (fibber)
1
> (fibber)
1
> (fibber)
2
> (fibber)
3
> (fibber)
5
> (fibber)
8
> (fibber)
13
```

And here's the `add` generator:

```scheme
(define add
  (generator
   (lambda ()
     (+ (yield "expecting x")
        (yield "expecting y")))))
```

in action:

```scheme
> (define adder (add))
> (adder)
"expecting x"
> (adder 1)
"expecting y"
> (adder 2)
3
```

Pretty cool, eh?

Here's a video of me stepping through the `fib` example with a debugger:

•(haml
  (:center
   (:video
    ([:src "https://media.defn.io/generators-screencast.mp4"]
     [:controls ""]
     [:width "720px"]))))

P.S. This is actually pretty close to how the generator implementation
in Racket itself works.  Feel free to [check that out][racket-core-impl],
the main differences between the two stem from some additional error
handling that the core implementation does.

[continuations]: https://en.wikipedia.org/wiki/Continuation
[delimited continuations]: https://en.wikipedia.org/wiki/Delimited_continuation
[racket/generator]: https://docs.racket-lang.org/reference/Generators.html
[racket-core-impl]: https://github.com/racket/racket/blob/master/racket/collects/racket/generator.rkt
