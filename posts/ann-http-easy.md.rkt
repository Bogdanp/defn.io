#lang punct

---
title: Announcing http-easy
date: 2020-06-14T18:00:00+03:00
---

Yesterday I released [http-easy], a high-level HTTP client for Racket.
I started working on it after getting annoyed at some of the code in
my [racket-sentry][example] package. The same day I wrote that code,
someone started a mailing list [thread][thd] asking for a "practical"
HTTP client so that served as additional motivation to spend some time
on this problem.

Here's a basic example:

```racket
(require net/http-easy)
(response-xexpr (get "https://example.com"))
```

It might not seem like much, but even just that gets you automatic
connection pooling. Want to stream response bodies instead of reading
them up front? Just pass in `#t` for the `#:stream?` argument:

```racket
(define inp
  (response-output
   (get "https://example.com" #:stream? #t)))
(read-bytes 10 inp)
```

Want to `POST` some `JSON` somewhere? Use the `#:json` keyword argument:

```racket
(post
 #:json (hasheq 'hello "world")
 "https://example.com")
```

Need to upload a file? It's got you covered:

```racket
(post
 #:data (multipart-payload
         (file-part "f" (open-input-file "example-1.txt"))
         (file-part "f" (open-input-file "example-2.txt")))
 "https://example.com")
```

You can find these examples and more in the [documentation]. The only
big feature that's currently missing is proxy support, but I plan to add
that soon. The library is pre-1.0 so, if you do start using it, keep in
mind that its API might change before it stabilizes.

[http-easy]: https://github.com/bogdanp/racket-http-easy
[example]: https://github.com/Bogdanp/racket-sentry/blob/9794b2da9c4f3ca8c8094d6bc78d5ca8bf9b133b/sentry-lib/sentry.rkt#L102-L147
[thd]: https://groups.google.com/g/racket-users/c/sMZtC4G0bHw/m/RW_CN5EeAQAJ
[documentation]: https://docs.racket-lang.org/http-easy/index.html
