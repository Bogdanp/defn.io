#lang punct

---
title: Racket for e-commerce
date: 2019-08-20T21:00:00+03:00
---

*I had originally shared a version of this post with a small, private
mailing list, but then I figured there'd be no harm in sharing it with
a larger audience so here it is.*

My girlfriend and I recently launched [matchacha.ro][matchacha], a
small e-commerce site selling Japanese green tea here in Romania (the
site defaults to Romanian, but you can change the language by
scrolling to the bottom -- we don't ship outside of Romania, though,
sorry!) and I figured I'd write a little experience report for this
group.

I'll get the obvious stuff out of the way first: building the website
from scratch was *by far* the easiest part.  Finding suppliers,
getting all the documentation right to be able to import the tea from
Japan -- nothing quite like Romanian bureaucracy to make you want to
give up on everything --, finding users and convincing them to buy the
product have all been significantly harder.

That said, as someone who wrote his first line of Racket almost
exactly a year ago, I have to say I found the whole process of
actually building the application delightful and only very rarely
frustrating (I'll get to that!).

My reasoning for building from scratch was threefold:

1. I wanted to avoid being locked in to VC-backed SaaS so that excluded
   most of the large players, like Shopify and BigCommerce,
2. I wanted to avoid anything written in PHP, and
3. I wanted to have some fun.

The app is a server-rendered "classic" web application with minimal JS
and it does most of the things you would expect from an e-commerce
app.  There are products, product variants, collections of products,
shopping carts, invoices that are generated on the fly, user accounts
(hidden right now), blog posts and dynamic pages, promo codes,
affiliate links, credit card payments, and a pretty powerful
administration panel.  It is backed by a Postgres database and it
comes in at a neat ~10k cloc of Racket code (including unit and
end-to-end tests):

    $ cloc matchacha/ matchacha-tests/ migrations/ resources/css/ resources/js/
         295 text files.
         294 unique files.
          88 files ignored.

    github.com/AlDanial/cloc v 1.82  T=0.18 s (1182.1 files/s, 102674.8 lines/s)
    -------------------------------------------------------------------------------
    Language                     files          blank        comment           code
    -------------------------------------------------------------------------------
    Racket                          87           1924            136          10374
    Sass                            35            626              3           2928
    JavaScript                      20            142             29            646
    SQL                             65            145            454            573
    -------------------------------------------------------------------------------
    SUM:                           207           2837            622          14521
    -------------------------------------------------------------------------------

That number does not include all of the supporting libraries that I've
written, which come in at about another ~13k cloc including unit tests.

Speaking of libraries, here are all the ones the application currently
depends on:

* base
* component-lib
* crypto-lib
* db-lib
* deta-lib
* forms-lib
* gregor-lib
* koyo-lib
* koyo-sentry
* marionette-lib
* mobilpay
* net-cookies-lib
* postmark-client
* rackunit-lib
* sql
* srfi-lite-lib
* struct-define
* struct-plus-plus
* threading-lib
* twilio
* web-server-lib

That doesn't include transitive dependencies, because I don't know how
to list them all, but I want to thank everyone who has worked on any
of these and on any of these libraries' own dependencies.

The deployment process is fairly simple.  GitHub Actions picks up all
commits to master, runs their tests, and, on success, for commits that
are tagged a certain way, packages up a distribution then ships it up
to my dedicated server, unzips it, updates a symlink and restarts a
service.  Deployments are *not* zero-downtime at this point and I'm
planning to switch to an AB-style deployment model once the site has
enough traffic to warrant it, but a second of downtime during each
deployment is fine for now.  Rolling back to an earlier version means
updating the aforementioned symlink and restarting the service.

The ability to package up the application so that it can be
distributed easily is one of my favorite things about Racket.  This is
a distinguishing feature that most of the dynamic languages that I
have used either lack entirely or it's not nearly as well integrated
as one would like.  With [koyo], all it takes is

    $ raco koyo dist

and all that really does under the hood is shell out to `raco exe` and
then `raco dist`.

Production runtime errors (of which there has been exactly one so far,
triggered by me, not one of my users) are sent to the SaaS version of
[Sentry].  The low runtime error rate is due to the amount of stuff
that Racket manages to catch at compile time compared to other dynamic
languages and to some fairly extensive automated testing.

I use [rackunit] for all my tests.  It gets the job done, but I find
it's not quite as good as, say, Python's [pytest].  My main complaint
is I like to organize tests in suites, but those aren't run
automatically, so in each of my test modules I have to call
`(run-tests some-suite)` within a `test` submodule, which splits up
the reporting that `raco test` generates.  If I centralize things so
that I have a single `run-all-tests.rkt` file, then I can't leverage
the `-j` parameter to `raco test`, meaning my tests run
*significantly* slower.  Apart from that, I would like to be able to
run a particular test suite or test case from the command line, but I
haven't been able to figure out how to do that yet.  In addition, it
would be nice to be able to tell `raco test` that I want to list the
`top n` slowest tests along with their runtimes, which is something
that pytest can easily do.

For end-to-end and screenshot tests, I use my own library,
[marionette], together with rackunit to control a live Firefox
instance and make assertions.  Some of those assertions generate
screenshots of a web page and compare them with old versions committed
to the repo by shelling out to [ImageMagick].

Error reporting during test runs or when I'm manually testing stuff is
the most frustrating part of working with Racket.  I run the tests as
well as the app (in local development mode) with `errortrace` turned
on, but I still find myself often scratching my head trying to figure
out *where* certain errors originate.  This is an area where Racket
really needs to improve.  It absolutely has to be able to show the
programmer where every error originated and that "where" can't be
"somewhere inside this 20-line-long for-loop in file x.rkt, good
luck!"

[racket-mode] for Emacs is a joy.  I can easily spin up a REPL for any
module that I'm working on and tinker with it, with some pretty good
facilities for cleaning up imports, running tests and a macro stepper.

Continuations are fantastic for rapid development.  I use them for
small things like increasing/decreasing item quantities in the
shopping cart and preserving state between the steps of the checkout
process, but I will eventually be moving off them as the site grows
because, from the user's perspective, it's bad UX to have URLs expire
randomly just because a deployment happened to occur when you were
browsing the site.  At this stage, though, that's not a problem, and
continuation expiration is handled gracefully: the user is redirected
to the original page they were on before clicking the continuation
link (or submitting the form, etc.) and shown a flash message.

If you visited the website (and assuming you live in Europe), you may
have noticed how fast it is.  Part of that is because of how fast
Racket itself is, and part of it is me being judicious about what code
runs on each page.  [koyo] has an instrumenting profiler and, in
development mode, all pages render a little floating widget that I can
expand to show a trace of all the instrumented places (inspired by
[MiniProfiler]).

I didn't find the lack of libraries to be a problem -- I just wrote
whatever it was I needed at the time -- and the documentation for the
stuff that does exist is pretty good.  Documentation for Racket itself
tends to be great, although a bit "stuffy".  That's a challenge for
someone who, like me, tends to skim a lot.  I would like to see more
code examples intended for people in a hurry.

One area where I didn't build my own thing was I18n/L10n.  For that,
the app relies on [SRFI-29].  I would have preferred to use the more
standard tooling, like [gettext], but there's no library for that.
Yet.

The community is welcoming and thoughtful.  Although I don't
participate frequently, I enjoy reading racket-users, racket-dev, the
subreddit and the Slack channel.  I've learned a ton by reading blog
posts by Alexis King, Alex Harsanyi, Greg Hendershott, and others.  I
love it whenever a new issue of [Racket News] comes out.

In terms of development time, this was all spread out across the past
year, but I estimate I only spent about a full "work" month on the
application itself and about another one working on all of those
supporting libraries I mentioned.  I think that's pretty good, given
all the things the application does.

Overall, I'm really happy with my choice to use Racket so far!


[ImageMagick]: https://imagemagick.org/index.php
[Racket News]: https://racket-news.com/
[SRFI-29]: https://srfi.schemers.org/srfi-29/srfi-29.html
[Sentry]: https://sentry.io
[gettext]: https://www.gnu.org/software/gettext/
[koyo]: https://koyo.defn.io
[marionette]: https://docs.racket-lang.org/marionette/index.html?q=marionette
[matchacha]: https://www.matchacha.ro
[pytest]: https://pytest.org/en/latest/
[racket-mode]: https://racket-mode.com
[rackunit]: https://docs.racket-lang.org/rackunit/api.html?q=rackunit
[MiniProfiler]: https://miniprofiler.com/
