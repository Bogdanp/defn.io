#lang punct "../common.rkt"

---
title: Web application from scratch, Part IV
date: 2018-05-12T00:00:00+00:00
---

This is the fourth post in my web app from scratch series. If you
haven't read them yet, you should check out parts 1 through 3 first!

In this part we're going to cover building an `Application`
abstraction.  If you're following along at home, you can find the
source code for part 3 [here].  Let's get to it!

[here]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-03


## Housekeeping

### Type checking

So far we've used type annotations mostly as documentation and haven't
worried about type checking our code.  In commit [6fa54c4], I
introduced [mypy] as a dev dependency and started type-checking the
code using it.  I won't describe the changes I had to make here
because the process was mostly mechanical:

1. run `mypy server.py`,
2. make necessary changes,
3. repeat.

[6fa54c4]: https://github.com/Bogdanp/web-app-from-scratch/commit/6fa54c489ae34b95466d40e63f7fb7adc635ea0e
[mypy]: https://mypy.readthedocs.io

### Unit testing

In commit [4455e04], I moved the modules from the repo root into a package
called `scratch` and added a `tests` package at the top level.

[4455e04]: https://github.com/Bogdanp/web-app-from-scratch/commit/4455e04


## The Application

Last time, we added support for mounting request handlers to specific
paths and today we're going to build upon that work by writing an
abstraction that can hold multiple request handlers and route to them
based on the request path.

In `scratch/application.py` add the following:

```python
from .request import Request
from .response import Response


class Application:
    def __call__(self, request: Request) -> Response:
        return Response("501 Not Implemented", content="Not Implemented")
```

If you remember from last time, we defined request handlers as
functions that take a `Request` and return a `Response`.  This means
that our `Application`s are themselves going to be request handlers.

Let's remove the old server instantiation code from
`scratch/server.py` -- delete everything from `wrap_auth` onward --
and create a new CLI entrypoint for our package in `__main__.py`:

```python
import sys

from .application import Application
from .server import HTTPServer


def main() -> int:
    application = Application()

    server = HTTPServer()
    server.mount(application)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

We can now run our server from the repo root with `python -m scratch`
and if we try to visit `http://127.0.0.1:9000`, we should get a 501
response back.

### The Router

Each application is going to contain an instance of a `Router`.  The
router's responsibility will be to map incoming request method, path
pairs like `POST /users` or `GET /users/{user_id}` to request
handlers.  Here's what it looks like (in `scratch/application.py`):

```python
import re
from collections import OrderedDict, defaultdict
from functools import partial
from typing import Callable, Dict, Optional, Pattern, Set, Tuple

from .request import Request
from .response import Response
from .server import HandlerT

RouteT = Tuple[Pattern[str], HandlerT]
RoutesT = Dict[str, Dict[str, RouteT]]
RouteHandlerT = Callable[..., Response]


class Router:
    def __init__(self) -> None:
        self.routes_by_method: RoutesT = defaultdict(OrderedDict)
        self.route_names: Set[str] = set()

    def add_route(self, name: str, method: str, path: str, handler: RouteHandlerT) -> None:
        assert path.startswith("/"), "paths must start with '/'"
        if name in self.route_names:
            raise ValueError(f"A route named {name} already exists.")

        route_template = ""
        for segment in path.split("/")[1:]:
            if segment.startswith("{") and segment.endswith("}"):
                segment_name = segment[1:-1]
                route_template += f"/(?P<{segment_name}>[^/]+)"
            else:
                route_template += f"/{segment}"

        route_re = re.compile(f"^{route_template}$")
        self.routes_by_method[method][name] = route_re, handler
        self.route_names.add(name)

    def lookup(self, method: str, path: str) -> Optional[HandlerT]:
        for route_re, handler in self.routes_by_method[method].values():
            match = route_re.match(path)
            if match is not None:
                params = match.groupdict()
                return partial(handler, **params)
        return None
```

Its `add_route` method iterates over all the parts of the path it's
given and generates a regular expression in the process, replacing all
dynamic path segments with named capture groups in the regex
(`"/users/{user_id}"` becomes `"^/users/(?P<user_id>[^/]+)$"`).

When a path is looked up via its `lookup` method, it iterates over all
of the available routes for that method and checks the path against
the regex for matches.  When it finds a match, it partially applies
the dynamic capture groups (if any) to the handler function and then
returns that value.

Hooking the router into our application class is pretty
straightforward.  We instantiate a router on application init, add a
method to proxy adding routes and update our `__call__` method to look
up and execute handlers when a request comes in:

```python
class Application:
    def __init__(self) -> None:
        self.router = Router()

    def add_route(self, method: str, path: str, handler: RouteHandlerT, name: Optional[str] = None) -> None:
        self.router.add_route(method, path, handler, name or handler.__name__)

    def __call__(self, request: Request) -> Response:
        handler = self.router.lookup(request.method, request.path)
        if handler is None:
            return Response("404 Not Found", content="Not Found")
        return handler(request)
```

As an added bit of sugar, we're also going to define a `route`
decorator on the `Application` class:

```python
    def route(
            self,
            path: str,
            method: str = "GET",
            name: Optional[str] = None,
    ) -> Callable[[RouteHandlerT], RouteHandlerT]:
        def decorator(handler: RouteHandlerT) -> RouteHandlerT:
            self.add_route(method, path, handler, name)
            return handler
        return decorator
```

With that all in place, we can go ahead and update our code in
`__main__` to register handlers for various routes.

```python
import functools
import json
import sys
from typing import Callable, Tuple, Union

from .application import Application
from .request import Request
from .response import Response
from .server import HTTPServer

USERS = [
    {"id": 1, "name": "Jim"},
    {"id": 2, "name": "Bruce"},
    {"id": 3, "name": "Dick"},
]


def jsonresponse(handler: Callable[..., Union[dict, Tuple[str, dict]]]) -> Callable[..., Response]:
    @functools.wraps(handler)
    def wrapper(*args, **kwargs):
        result = handler(*args, **kwargs)
        if isinstance(result, tuple):
            status, result = result
        else:
            status, result = "200 OK", result

        response = Response(status=status)
        response.headers.add("content-type", "application/json")
        response.body.write(json.dumps(result).encode())
        return response
    return wrapper


app = Application()


@app.route("/users")
@jsonresponse
def get_users(request: Request) -> dict:
    return {"users": USERS}


@app.route("/users/{user_id}")
@jsonresponse
def get_user(request: Request, user_id: str) -> Union[dict, Tuple[str, dict]]:
    try:
        return {"user": USERS[int(user_id)]}
    except (IndexError, ValueError):
        return "404 Not Found", {"error": "Not found"}


def main() -> int:
    server = HTTPServer()
    server.mount("", app)
    server.serve_forever()
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

`jsonresponse` is a little helper decorator that converts handler
results to JSON responses.  Other than that, everything is pretty
straightforward: we create an application instance, register a couple
route handlers and then mount that application inside our server.  And,
with that, we have a little JSON API for listing users.


## Winding down

That's it for part 4.  Next time we're going to cover extending the
`Request` object to parse query strings and cookies as well as to be
able to hold user-defined data per request.  If you'd like to check
out the full source code and follow along, you can find it
[here][source].

See ya next time!

P.S.: CodeCrafters have an interactive course where you can put what
you learned in this article into practice. Use my [referral link] to
try their service for free and get a 40% discount if you ever decide
to upgrade.

[referral link]: https://app.codecrafters.io/join?via=Bogdanp

[source]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-04
