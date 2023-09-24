#lang punct

---
title: Google Groups Without Google Accounts
date: 2019-02-05T20:00:00+02:00
---

It turns out that when you [delete your Google accounts], Google
unsubscribes you from any (public and private) Google Groups you're
a member of. I found out about this only because my inbox traffic
these past couple of days felt unusually light so I went and looked at
[racket-users] and, lo and behold, there were a bunch of new posts I
hadn't received.

I get it. They want to avoid sending emails to an address that, from
their perspective, no longer exists. Makes sense, although they could
certainly tell you that you're gonna be unsubscribed when you cancel,
maybe even throw in a list of all the groups you're currently subscribed
to for good measure.

What annoys me, though, is how hard they make it for someone who
doesn't have a Google account to join a Google Group. If you visit a
group and you're not logged in, there's no way for you to join via
the UI. This makes it seem like you can't join unless you create
an account, but that's not the case! You can still join groups by
sending an e-mail to `group-name+subscribe@googlegroups.com`. For
example, to join the `racket-users` group, you would send an e-mail to
`racket-users+subscribe@googlegroups.com`. If the group you want to join
has spaces in its name, replace the spaces with dashes in the e-mail
address.

If you were wondering about how to join a group without a Google
account, now you know! And if you're considering starting a new mailing
list, I urge you to take this factor into consideration and maybe use
something like [groups.io] or [lists.sr.ht] instead.


[delete your Google accounts]: /2019/02/04/bye-bye-google/
[racket-users]: https://groups.google.com/forum/#!forum/racket-users
[groups.io]: https://groups.io/
[lists.sr.ht]: https://lists.sr.ht/
