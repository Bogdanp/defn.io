#lang punct

---
title: Bye, Bye, Google
date: 2019-02-04T09:00:00+02:00
---

I spent this past weekend de-Google-ifying my life and, despite my
expectations, it wasn't *too hard* to do.

I started by moving all of my websites off of Google App Engine and
onto a dedicated box that I had already owned. That was straightforward
enough. Next, I removed any Google Analytics snippets from each of them
and replaced those with my own analytics server that I had built a while
back (it doesn't store any PII, only aggregate information (and very
little of that, too)). Afterwards, I replaced any Google Fonts that I
had been using with system fonts and, finally, I moved the screencasts
for [Dramatiq] and [molten] from YouTube to [peertube].

Next, it was time for e-mail. I had already been using [isync] to
download all my mail so it was easy for me to switch my `@defn.io`
and `@cleartype.io` e-mail addresses over to [FastMail] \(who really
deserve their name!). I created my accounts, updated my `.mbsyncrc`,
ran a sync and successfully imported all my mail into the new accounts.
So far so good! The problem was my `@gmail.com` account that I had
been using since 2005. Most of my internet accounts were tied to that
e-mail address. Thankfully, [1Password] lets you filter your accounts by
username and so I did that and, one by one, I updated all of my internet
accounts to use my `@defn.io` e-mail address (and deleted a number of
accounts in the process -- some companies make this process really
annoying (I shit you not, one in particular made me go through about
20 dialogs before it finally let me delete the account)). That was a
time-consuming, but satisfying, process; sorta like spring cleaning. In
the end, I was able to switch about 130 internet accounts to use my new
e-mail address after a few hours of work. There were only 5 instances
where I could neither change my e-mail address or delete the account so,
for all of those, I e-mailed support and I'm currently waiting to hear
back.

I've debated deleting the `@gmail.com` e-mail address, but I think it's
wiser to keep it and essentially squat the username lest someone else
take it over and cause me trouble down the line. I've made it forward
and delete any new mail it gets to `@defn.io`. As time goes on, the
amount of incoming email to that address should tend toward 0.

Why go through all this trouble? I've grown increasingly concerned
this past year with how much access Google has to our lives. They are
the world's biggest advertising company and they have access to most
of our web browsing via Google Chrome (62.5% market share -- although
given the amount of broken websites (some explicitly Chrome-only!) I've
found since switching to Firefox, I believe this number may actually
be higher), all our website visitors via Google Analytics and Google
Fonts. Much of our communication via GMail and Google Apps and much of
the content we consume every day via YouTube. I'm not even going to get
into all the information they gather from people who use Android phones.
While I don't believe that folks working at Google are actively trying
to do harm, I believe that, due to the sheer size of the company, no
one is truly at the helm and this massive organism will tend toward
maximizing profits at whatever expense so I've decided to do my best to
support the smaller alternatives that are out there.

P.S. Here's a funny response I got to an account close e-mail from
[Kraken] just as I was writing this post! They're offering me the
privilege to keep my user account and receive their news.

> We can offer you to keep your account with us instead of closing
> it. You'll get the newest updates about us/our services that you
> might be interested in.

Aren't I lucky?


[Dramatiq]: https://dramatiq.io
[molten]: https://moltenframework.com
[peertube]: https://peertube.social/accounts/bogdan/videos
[isync]: http://isync.sourceforge.net/
[FastMail]: https://www.fastmail.com/
[1Password]: https://1password.com/
[Kraken]: https://www.kraken.com/
