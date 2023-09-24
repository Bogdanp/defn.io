#lang punct "../common.rkt"

---
title: (eleventh RacketCon) talk: Declarative GUIs
date: 2021-11-07T16:00:00+02:00
---

Yesterday, I gave a talk about [gui-easy] at the eleventh RacketCon!
You can find a recording of the talk on [YouTube][talk] and a
transcript below.  Day two of the conference is starting in a little
under a couple of hours so [join us][con] if you like!

## Transcript

### Declarative GUIs

•(define (slide n)
   (define (pad n)
     (if (< n 10)
         (format "0~a" n)
         (format "~a" n)))
   (img (format "racketcon2021-slides/slide-~a.jpg" (pad n))
        (format "Slide ~a." n)))

•(slide 1)

My name is Bogdan Popa, and today I will be talking about `gui-easy`,
a library for declaratively building graphical user interfaces in
Racket.

### racket/gui

•(slide 2)

Racket comes with `racket/gui` as part of its main distribution. The
`racket/gui` library is a toolkit for building cross-platform
graphical user interfaces.  It's powerful and flexible, having been
used to implement the DrRacket IDE.  One of the reasons for that
flexibility is that it's built on top of the `racket/class` library.
The downside of that is that it exposes an imperative API.
Additionally, it is agnostic concerning state management, which means
it's up to you to decide how you're going to keep track of state
within your application and how you're going to keep the GUI and the
application's state in sync.

### gui-easy

•(slide 3)

`gui-easy` is my attempt at adding a declarative layer on top of
`racket/gui`.  It achieves this in two ways.  Firstly, by hiding the
details of the class system from the user so that regular function
calls form the view hierarchy.  Secondly, by providing an abstraction
for managing state and automatically propagating state changes to
views.  These two properties make it less flexible than `racket/gui`.
In particular, you cannot opt out of its state management abstraction.

### Counter

•(slide 4)

Here is an example application built with `racket/gui` on the left and
`gui-easy` on the right. I can run both, and both produce roughly the
same result.

The `racket/gui` version constructs the UI hierarchy incrementally by
instantiating each widget individually and passing them around as
parents of other widgets.  The frame holds the panel, and the panel
contains the two buttons and the message.  In contrast, the `gui-easy`
version has a closer correspondence between the final structure of the
UI and the structure of the code.  The window holds the panel, which
holds the other three views.

The application state is managed in the `racket/gui` version using a
mutable variable and a function that mutates that variable.  In
addition to changing the counter's value, the `update-count!` function
is in charge of updating the message to reflect the change.

In the `gui-easy` version, an observable wraps the counter, and the
library takes care of propagating changes to the relevant views (in
this case, the text view).

### Views

•(slide 5)

Views are regular Racket functions that combine to form the GUI
hierarchy.  They know how to respond to Observable changes in ways
that make sense for the respective widgets they represent.  For
example, text views change their text when their input changes.
Choice views change their current choice when their selection changes,
and canvas views call their draw functions when their data changes.

### Observables

•(slide 6)

An observable is like a box that can broadcast changes to its contents
to observer functions.  We can define an observable value, then
subscribe a couple of functions to it.  When we push a change to the
observable, the two observers trigger.  In this case, both print the
new value of the observable to standard out.

•(slide 7)

The `obs-map` function produces derived observables by applying a
function to the contents of an existing observable.  Just like regular
observables, we can observe derived ones.  If we push a change to the
original `@count` now, we can see both its observers trigger and the
observer we added to the derived one.

•(slide 8)

While you can observe mapped observables, you cannot update
them.  Doing so results in a contract error.

### Custom Views

•(slide 9)

Sometimes you may need to implement custom views. Doing this is
straightforward.  Views in `gui-easy` implement the `view<%>`
interface.  The interface is just four methods.  Every `view<%>` must
be able to list its dependencies.  Its `create` method must instantiate
the underlying `racket/gui` widget.  It needs to know how to respond to
changes in its dependencies and alter the underlying `racket/gui`
widget.  When it's no longer needed, it can perform any teardown
actions it needs to in its `destroy` method.

•(slide 10)

Here is a custom text view.  It depends on an observable message.  To
create the underlying widget, it instantiates a `message%`.  When the
`@msg` observable changes, it updates the label on the `message%`
widget, and it doesn't need to perform any teardown actions, so its
`destroy` method is a no-op.  Once we have the view implementation, we
can declare a constructor function to hide away the class details from
users, and then we can use the new view just like we would any of the
views built into `gui-easy`.

## Demo

•(slide 11)

Next, I will live-code a small GUI to give you a feel for what it's
like to use the library in practice.

•(haml
  (:center
   (:p
    (:em
     "[No transcript for the "
     (:a
      ([:href "https://www.youtube.com/watch?v=7uGJJmjcxzY#t=8m7s"])
      "demo portion")
     ", sorry!]"))))

## Thanks

•(slide 12)

Thank you for attending my talk.  The [library][pkg] and its
[documentation][docs] are available on the package server, and you can
find the source code on my website at [defn.io].  Alongside the source
code, you will find several [example][examples] applications, so I
encourage you to check those out if `gui-easy` appeals to you.
Thanks!


[con]: https://con.racket-lang.org/
[gui-easy]: https://github.com/Bogdanp/racket-gui-easy
[talk]: https://www.youtube.com/watch?v=7uGJJmjcxzY
[pkg]: https://pkgd.racket-lang.org/pkgn/package/gui-easy
[docs]: https://docs.racket-lang.org/gui-easy/index.html
[examples]: https://github.com/Bogdanp/racket-gui-easy/tree/master/examples
[defn.io]: https://defn.io
