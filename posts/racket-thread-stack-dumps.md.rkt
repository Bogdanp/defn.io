#lang punct "../common.rkt"

---
title: What is Racket DOING???
date: 2025-05-30T07:35:00+03:00
---

A neat feature of the JVM is that, out of the box, you can send
a running JVM process a `SIGQUIT` signal and it'll dump stack
traces for all running threads to `stdout`. The output looks like
[this][threaddump]. It's can be really handy when you're trying to debug
a live system.

Racket doesn't have this feature, but you can build something like it
yourself by combining some of the introspection tools the runtime system
provides to you. Given a Racket thread, you can get its [continuation
marks], using the [`continuation-marks`] procedure:

``` racket
> (continuation-marks (thread void))
#<continuation-mark-set>
```

With a set of marks in hand, you can get an approximate stack trace by
calling [`continuation-mark-set->context`]:

``` racket
> (continuation-mark-set->context
   (let ([thd (thread (λ () (let loop () (sleep 5) (loop))))])
     ;; Give the thread a chance to activate.
     (sync (system-idle-evt))
     (continuation-marks thd)))
(list (cons #f (srcloc 'string 2 20 53 42)))
```

The result is a list of pairs of procedure names (or `#f` if a procedure
name is not available, as above) and source locations. Converting that
list to a textual stack trace is straightforward.

The next step is to get a list of all running threads.  All threads in
Racket are managed by a [custodian]. If you have access to a custodian
and its parent, you can ask for all of the objects managed by that
custodian by calling [`custodian-managed-list`].

``` racket
> (define root (current-custodian))
> (current-custodian (make-custodian root))
> (define thd (thread (lambda () (let loop () (sleep 5) (loop)))))
> (custodian-managed-list (current-custodian) root)
'(#<thread>)
```

The result may include custodians subordinate to the custodian you're
querying:

``` racket
;; ... continued from above
> (define child (make-custodian))
> (define thd-of-child
    (parameterize ([current-custodian child])
      (thread (lambda () (let loop () (sleep 5) (loop))))))
> (custodian-managed-list (current-custodian) root)
'(#<thread> #<custodian>)
```

So, you have to collect the list of threads recursively by dispatching
on the list types of the values in the list:

``` racket
;; ...continued from above
> (define thds
    (let loop ([v (current-custodian)])
      (cond
        [(thread? v) (list v)]
        [(custodian? v) (loop (custodian-managed-list v root))]
        [(list? v) (apply append (map loop v))]
        [else null])))
> thds
'(#<thread> #<thread>)
```

With that, you can print stack traces for all threads reachable from
the topmost custodian your program or library has access to.

This is now a [a built-in feature][src] of [dbg]. The client has a
new [`dump-threads`] procedure that returns a string representing the
stack traces of all the threads accessible by the debugging server in
a process[^1] and the GUI displays that same information under a new
"Threads" tab.

[^1]: More specifically, in a [place], since each place has its own custodian tree.

[threaddump]: https://gist.github.com/Bogdanp/9d4a2c6d9a36243ff8acf81ac9a99696
[continuation marks]: https://docs.racket-lang.org/reference/contmarks.html
[`continuation-marks`]: https://docs.racket-lang.org/reference/contmarks.html#%28def._%28%28quote._~23~25kernel%29._continuation-marks%29%29
[`continuation-mark-set->context`]: https://docs.racket-lang.org/reference/contmarks.html#%28def._%28%28quote._~23~25kernel%29._continuation-mark-set-~3econtext%29%29
[custodian]: https://docs.racket-lang.org/reference/eval-model.html#%28tech._custodian%29
[`custodian-managed-list`]: https://docs.racket-lang.org/reference/custodians.html#%28def._%28%28quote._~23~25kernel%29._custodian-managed-list%29%29
[dbg]: https://docs.racket-lang.org/dbg-manual/index.html
[src]: https://github.com/Bogdanp/racket-dbg/blob/f1f91f74b440b795bf858fa5d596d80db25072c5/dbg/private/stackdump.rkt
[`dump-threads`]: https://docs.racket-lang.org/dbg-manual/index.html#%28def._%28%28lib._debugging%2Fclient..rkt%29._dump-threads%29%29
[place]: https://docs.racket-lang.org/reference/places.html
