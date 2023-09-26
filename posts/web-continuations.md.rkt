#lang punct "../common.rkt"

---
title: Continuations for Web Development
date: 2019-04-07T17:00:00+03:00
---

One of the distinguishing features of Racket's built-in [web-server]
is that it supports the use of [continuation]s in a web context.  This
is a feature I've only ever seen in Smalltalk's [Seaside] before,
though Racket's version is more powerful.

I've been leveraging continuations in an e-commerce application I've
been building these past couple of months and I wanted to write down
my thoughts.  Let's dive right in.

## First, an Example

```scheme
#lang web-server/insta

(define (render-counter counter)
  (send/suspend/dispatch
   (lambda (embed/url)
     (response/xexpr
      `(div
        (h1 "Current count: " ,(number->string counter))
        (a ((href ,(embed/url (lambda (req)
                                (render-counter (+ counter 1))))))
           "Increment"))))))

(define (start req)
  (render-counter 0))
```

*Note: I'm using "#lang web-server/insta" here, which I realize may be
off-putting to some readers (I know it rubbed me the wrong way when I
was first reading about web development in Racket).  There are more
familiar (less magical) ways to implement web servers in Racket than
this, but this is the most succinct.*

The entry point for this server (the `start` function) calls
`render-counter` with a starting value of `0` for every new request
that comes in.  `render-counter` then demarcates the start of the
continuation with the call to [send/suspend/dispatch] and, finally, it
renders some HTML that displays the current value of the counter as
well as a link that, when clicked, will recursively `render-counter`
with an incremented `counter` value.

Notice how naturally this code flows and the fact that the
continuation (the anonymous function that is passed to `embed/url`) is
able to reference bindings in the scope of its parent.

Here's what that short piece of code gets you:

•(video "https://media.defn.io/continuations-demo.mp4")

I think this is cool as hell.  In essence, continuations let you write
code that manipulates objects (a counter, a shopping a cart, [a form],
etc.)  local to the current web page without having to do duplicate
work -- image a shopping cart where you only retrieve a product from
the database when you render the product page, but you close over the
product when adding it to the cart -- and without having to give said
code an explicit route.  The latter is both a strength and a weakness,
as I argue below.

## Then, the Bad

As with most things, continuations on the web come with a set of
trade-offs.

Continuations are local to a Racket process, meaning that any web
server that leverages them is *stateful*.  That's not inherently a bad
thing, but it does mean that you have to be careful when it comes to
load balancing and deploying new versions of your application: all new
deployments invalidate all existing continuations and you have to rely
on session affinity (cookie each user and use that to determine which
server they connect to) to tie individual users to particular
instances of the web server.

Racket's particular implementation of continuations stores the
continuation id as a parameter in the URI, meaning that if someone
guesses the id of your continuation then they can effectively steal
your session.  This is fairly easy to work around by leveraging
[dynamic binding][parameterize] in racket:

1. for each request, read the continuation security token from the user
   agent; if it doesn't exist then generate a large unique value and
   store that in a cookie on the user agent,
1. [dynamically bind][parameterize] the current continuation security
   token for the request,
1. before executing each continuation, ensure that the value of the
   user's continuation security token cookie is the same as the value
   of the current continuation security token parameter; if the value
   is different then return a 403 Forbidden or similar response.

Because of how the continuation machinery works, each continuation
will "remember" the continuation security token of the request that
created it, ensuring that each continuation is tied to the browser
session that it was created by.  You can find an implementation of
this pattern in my [racket-webapp-template] project.  All in all, it
takes less than a hundred lines of code to implement.

Because of the session-stealing issue and the fact that continuation
URLs are fairly ugly, they're not a good match for URLs that should be
shareable between users (or for SEO, for that matter).  I tend to
limit my use of continuations to "actions" that a user may perform on
an object local to the current page (eg. adding an item to the
shopping cart, or increasing the quantity of said item in the cart,
etc.).

Finally, because continuations close over local scope, any objects
captured are going to live for the duration that the continuation
exists.  So if you're not careful, then you may end up leaking memory.
To combat this and to prevent servers' memory usage from growing
indefinitely, the `web-server` library has a robust implementation of
an LRU continuation manager that expires continuations quicker the
more memory pressure there is.  In addition, you can write your own
manager implementation to suit your application if the built-in ones
don't cut it.


## And a Conclusion

That may seem like a lot of "bad", but all of those points are
straightforward tradeoffs that I believe are worth it in the long run
given the ergonomics that continuations on the web buy you.  Plus,
writing code in this way is just so. much. fun!


[Seaside]: https://github.com/SeasideSt/Seaside
[a form]: https://github.com/Bogdanp/racket-forms/blob/master/examples/blog-continuations.rkt#L161-L183
[continuation]: https://en.wikipedia.org/wiki/Continuation
[parameterize]: https://docs.racket-lang.org/guide/parameterize.html
[racket-webapp-template]: https://github.com/Bogdanp/racket-webapp-template/blob/master/app-name-here/components/continuation.rkt#L1-L85
[send/suspend/dispatch]: https://docs.racket-lang.org/web-server/servlet.html#%28def._%28%28lib._web-server%2Fservlet%2Fweb..rkt%29._send%2Fsuspend%2Fdispatch%29%29
[web-server]: https://docs.racket-lang.org/web-server/
