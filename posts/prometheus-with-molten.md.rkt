#lang punct

---
title: Prometheus with Molten
date: 2018-10-21T00:00:00+00:00
---

[molten] has built-in support for exporting the following [Prometheus]
metrics:

* `http_request_duration_seconds{method,path}` -- a histogram of the
  request duration percentiles by request method and path,
* `http_requests_total{method,path,status}` -- a counter of the total
  number of requests by method, path and status,
* and `http_requests_inprogress{method,path}` -- a gauge of the number of
  requests in progress by method and path.

Let's say that you have a basic molten app.  Something like this:

``` python
from molten import App, Route


def index():
    return {}

app = App(
    routes=[
        Route("/", index),
    ],
)
```

To start tracking metrics, add `prometheus_middleware` to your app's
`middlewares` list:

``` python
from molten import App, ResponseRendererMiddleware, Route
from molten.contrib.prometheus import prometheus_middleware


def index():
    return {}

app = App(
    middleware=[
        prometheus_middleware,
        ResponseRendererMiddleware()
    ],
    routes=[
        Route("/", index),
    ],
)
```

The app will then begin keeping track of metrics in memory, but won't
expose them anywhere.  Prometheus uses a pull-based model to gather
metrics from servers, which means you have tell it where (i.e. which
servers/ports) to look for metrics and your server needs to be able to
expose those metrics in a way that Prometheus can understand.

To start exposing metrics, add `expose_metrics` to your routes:

``` python
from molten import App, ResponseRendererMiddleware, Route
from molten.contrib.prometheus import expose_metrics, prometheus_middleware


def index():
    return {}

app = App(
    middleware=[
        prometheus_middleware,
        ResponseRendererMiddleware()
    ],
    routes=[
        Route("/", index),
        Route("/metrics", expose_metrics),
    ],
)
```

If you run your app now and visit the index handler a couple of times
and then visit `/metrics`, you should see all the metrics that were
gathered up until that point.

One caveat related to `expose_metrics` is it should only be used in
single-process configurations.  If your application uses multiple
processes to server requests (for example, multiple `gunicorn`
workers) then you should use `expose_metrics_multiprocess` instead.

Assuming you're running the app on `localhost:8000`, you can then use
a [scrape config] such as this one to let Prometheus know where to
look for metrics:

``` yaml
scrape_configs:
  - job_name: 'a-molten-app'
    scrape_interval: 15s
    static_configs:
      - targets: ['localhost:8000']
```

Save that to a file called `prometheus.yml`, run prometheus and then
visit http://localhost:9090 and you should be able to start querying
the metrics I mentioned above.  Check out Prometheus' [querying]
documentation to find out how to construct queries.

While Prometheus' dashboard is nice for inspecting metrics, it's not
meant for long-lived graphs and dashboards.  For that, you should take
a look at [Grafana].

[molten]: https://moltenframework.com
[Prometheus]: https://prometheus.io/
[scrape config]: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#%3Cscrape_config%3E
[querying]: https://prometheus.io/docs/prometheus/latest/querying/basics/
[Grafana]: https://prometheus.io/docs/visualization/grafana/
