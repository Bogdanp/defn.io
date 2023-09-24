#lang punct

---
title: Deploying Racket Web Apps With Docker
date: 2023-05-19T07:00:00+03:00
---

Since there was [a question about deploying Racket code using
Docker][reddit] on the Racket Reddit this morning, I figured I'd write a
quick follow-up to my post about [Deploying Racket Web Apps][old-post].
My preference is still to avoid using Docker and just use the method
described in that post by default. But, if I have to use Docker for
some reason, then I'll typically use a two-stage build to build a
distribution in the first stage and then copy that distribution into the
second stage in order to get a minimal Docker image that I can easily
ship around.

Given the following app, saved as `app.rkt`:

```racket
#lang racket/base

(require racket/async-channel
         web-server/http
         web-server/servlet-dispatch
         web-server/web-server)

(define ch (make-async-channel))
(define stop
  (serve
   #:dispatch (dispatch/servlet
               (lambda (_req)
                 (response/xexpr
                  '(h1 "Hello!"))))
   #:port 8000
   #:listen-ip "0.0.0.0"
   #:confirmation-channel ch))

(define ready-or-exn (sync ch))
(when (exn:fail? ready-or-exn)
  (raise ready-or-exn))

(with-handlers ([exn:break? void])
  (sync/enable-break never-evt))

(stop)
```

I would write the following `Dockerfile`:

```Dockerfile
FROM racket/racket:8.9-full AS build

COPY app.rkt /code/
WORKDIR /code
RUN raco exe -o app app.rkt
RUN raco dist dist app

FROM debian:bullseye-slim AS final

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends dumb-init && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /code/dist /app
CMD ["dumb-init", "/app/bin/app"]
```

When this image gets built, the `build` stage creates a distribution
of the app that gets copied into the `final` stage. At the end, the
build stage is discarded and the end result is a roughly 150MB Docker
image with just my code in it and a minimal Debian system. Not quite
as minimal as you can get out of using a similar method with Go, but
Racket distributions have a high baseline, so a real app wouldn't be
much bigger than this.

[reddit]: https://www.reddit.com/r/Racket/comments/13lft3d/how_do_you_deploy_your_racket_code_to_a_server/
[old-post]: /2020/06/28/racket-deployment/
