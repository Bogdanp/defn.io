#lang punct

---
title: Prometheus metrics and API Star
date: 2017-11-25T00:00:00+00:00
---

This past week I started playing with [API Star] and I'm kind of in
love with it right now. Being a new project, its docs are a bit lacking
-- its source code, however, is high quality and easy to understand --
so it took me a little time to figure out a way to automatically track
request and response metrics using Prometheus.

## The Goal

My goal was to globally track request durations, request counts and the
number of requests in progress at any given time. AFAICT, there are two
major ways to do this with API Star: either write a WSGI middleware and
wrap the API star `App` object or leverage a [component] along with
`BEFORE_REQUEST` and `AFTER_REQUEST` hooks. I ended up going with the
latter.

## The Component

First I defined a `Prometheus` component. In the app's lifecycle this is
a singleton (`preload=True`) object that can be injected in the before
and after response hooks. It is used to keep track of some thread-local
state (like the start time of each request) and to update the prom
metrics.

```python
import time

from apistar import http
from http import HTTPStatus
from prometheus_client import Counter, Gauge, Histogram
from threading import local

REQUEST_DURATION = Histogram(
    "http_request_duration_seconds",
    "Time spent processing a request.",
    ["method", "handler"],
)
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Request count by method, handler and response code.",
    ["method", "handler", "code"],
)
REQUESTS_INPROGRESS = Gauge(
    "http_requests_inprogress",
    "Requests in progress by method and handler",
    ["method", "handler"],
)


class Prometheus:
    def __init__(self):
        self.data = local()

    def track_request_start(self, method, handler):
        self.data.start_time = time.monotonic()

        handler_name = f"{handler.__module__}.{handler.__name__}"
        REQUESTS_INPROGRESS.labels(method, handler_name).inc()

    def track_request_end(self, method, handler, ret):
        status = 200
        if isinstance(ret, http.Response):
            status = HTTPStatus(ret.status).value

        handler_name = "<builtin>"
        if handler is not None:
            handler_name = f"{handler.__module__}.{handler.__name__}"
            duration = time.monotonic() - self.data.start_time
            del self.data.start_time
            REQUEST_DURATION.labels(method, handler_name).observe(duration)

        REQUEST_COUNT.labels(method, handler_name, status).inc()
        REQUESTS_INPROGRESS.labels(method, handler_name).dec()
```

Thread-local data is stored in the `data` property of the singleton and
the `track_request_start` and `track_request_end` methods are meant to
be called at the beginning and end of each request, respectively.

## The Hooks

The hooks request the `Prometheus` component along with information
about the current request method and handler. All they do is pass that
information along to `track_request_start` and `track_request_end`.

```python
def before_request(prometheus: Prometheus,
                   method: http.Method,
                   handler: Handler):
    prometheus.track_request_start(method, handler)


def after_request(prometheus: Prometheus,
                  method: http.Method,
                  handler: Handler,
                  ret: ReturnValue):
    prometheus.track_request_end(method, handler, ret)
    return ret
```

One odd thing I ran into was the fact that for builtin request handlers,
such as the 404 handler, the `before_request` hook doesn't get called.
This is why `track_request_end` checks whether or not the `handler` is
`None` before trying to compute the time spent running it. In those
cases, `self.data.start_time` is never set because `track_request_start`
was never called.

## The Exposition Handler

One problem I ran into while trying to expose the metrics was the fact
that API Star doesn't seem to provide a plaintext renderer. Defining my
own was straightforward enough:

```python
from apistar import http
from apistar.renderers import Renderer


class PlaintextRenderer(Renderer):
    def render(self, data: http.ResponseData) -> bytes:
        return data
```

Finally, the exposition handler just calls the prom client's
`generate_latest` function and renders it using the `PlaintextRenderer`.

```python
from apistar import Response, annotate
from prometheus_client import CONTENT_TYPE_LATEST


@annotate(renderers=[PlaintextRenderer()])
def expose_metrics():
    return Response(generate_latest(), headers={
        "content-type": CONTENT_TYPE_LATEST,
    })
```

## The App

To hook it all up, I added all the bits I defined previously to
the appropriate spots in the `WSGIApp`'s config, making sure the
`before_request` and `after_request` hooks were the first and last ones
to be added to the configuration, respectively.

```python
import prometheus_component

from apistar import Component, Route, hooks
from apistar.frameworks.wsgi import WSGIApp as App

components = [
    Component(prometheus_component.Prometheus, preload=True),
]

routes = [
    Route("/metrics", "GET", prometheus_component.expose_metrics),
]

settings = {
    "BEFORE_REQUEST": [
        prometheus_component.before_request,
        hooks.check_permissions,
    ],
    "AFTER_REQUEST": [
        hooks.render_response,
        prometheus_component.after_request,
    ],
}

app = App(
    components=components,
    routes=routes,
    settings=settings,
)
```

## Epilogue

In the end I packed all of this up in a library so I could reuse the
functionality across apps. You can find it [here][lib].

Like I said at the beginning, API Star has been a joy to use so far and
I can't wait to play around with it some more. I'm likely going to put
it into production soon so expect more content to come about it.


[API Star]: https://github.com/encode/apistar/
[component]: https://github.com/encode/apistar/#components
[lib]: https://github.com/Bogdanp/apistar_prometheus
