#lang punct "../common.rkt"

---
title: Web application from scratch, Part III
date: 2018-03-20T00:00:00+00:00
---

This is the third post in my web app from scratch series.  If you
haven't read them yet, you can find the [first part here] and the
[second part here].  You'll want to read them first.

[first part here]: •(xref "Web application from scratch, Part I")
[second part here]: •(xref "Web application from scratch, Part II")

This part is going to be short and sweet.  We're going to cover
request handlers and middleware.  [Here's] the source for part 2 so
you can follow along.  Let's get to it!

[Here's]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-02


## Handlers

Last time we implemented all our request handling logic inside the
`HTTPWorker` class.  That's not an appropriate place for application
logic to live in so we need to update that code to run arbitrary
application code that it knows nothing about.  To do this, we're going
to introduce the concept of a request handler.  In our case a request
handler is going to be a function that takes in a `Request` object and
returns a `Response` object.  Expressed as a type, that looks like
this:

```python
HandlerT = Callable[[Request], Response]
```

Let's modify our `HTTPServer` so that it stores a set of request
handlers, each one assigned to a particular path prefix so that we can
host different applications at different paths.  In `HTTPServer`'s
constructor, let's assign an empty list to the `handlers` instance
variable.

```python
class HTTPServer:
    def __init__(self, host="127.0.0.1", port=9000, worker_count=16) -> None:
        self.handlers = []
        ...
```

Next, let's add a method that we can use to add handlers to the
handler list.  Call it `mount`.

```python
    def mount(self, path_prefix: str, handler: HandlerT) -> None:
        """Mount a request handler at a particular path.  Handler
        prefixes are tested in the order that they are added so the
        first match "wins".
        """
        self.handlers.append((path_prefix, handler))
```

Now we need to update the `HTTPWorker` class to take advantage of
these handlers.  We need to make the workers' constructor take the
handlers list as a parameter.

```python
class HTTPWorker(Thread):
    def __init__(self, connection_queue: Queue, handlers: List[Tuple[str, HandlerT]]) -> None:
        super().__init__(daemon=True)

        self.connection_queue = connection_queue
        self.handlers = handlers
        self.running = False
```

And then we need to update the `handle_client` method to delegate
request handling to the handler functions.  If none of the handlers
match the current path, then we'll return a 404 and if one of the
handlers raises an exception then we'll return a 500 error to the
client.

```python
    def handle_client(self, client_sock: socket.socket, client_addr: typing.Tuple[str, int]) -> None:
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
            except Exception:
                LOGGER.warning("Failed to parse request.", exc_info=True)
                response = Response(status="400 Bad Request", content="Bad Request")
                response.send(client_sock)
                return

            # Force clients to send their request bodies on every
            # request rather than making the handlers deal with this.
            if "100-continue" in request.headers.get("expect", ""):
                response = Response(status="100 Continue")
                response.send(client_sock)

            for path_prefix, handler in self.handlers:
                if request.path.startswith(path_prefix):
                    try:
                        request = request._replace(path=request.path[len(path_prefix):])
                        response = handler(request)
                        response.send(client_sock)
                    except Exception as e:
                        LOGGER.exception("Unexpected error from handler %r.", handler)
                        response = Response(status="500 Internal Server Error", content="Internal Error")
                        response.send(client_sock)
                    finally:
                        break
            else:
                response = Response(status="404 Not Found", content="Not Found")
                response.send(client_sock)
```

Lastly, we have to make sure we pass the handler list to the
`HTTPWorker`s when we instantiate them in `serve_forever`.

```python
    def serve_forever(self) -> None:
        workers = []
        for _ in range(self.worker_count):
            worker = HTTPWorker(self.connection_queue, self.handlers)
            worker.start()
            workers.append(worker)

        ...
```

Now, whenever an `HTTPWorker` receives a new connection, it'll parse
the request and try to find a request handler to process it with.
Before the request is passed to a request handler, we remove the
prefix from its path property so that request handlers don't have to
be aware of what prefix they're running under.  This'll come in handy
when we write a handler that serves static files.

Since we haven't mounted any request handlers yet, our server will
reply with a 404 to any incoming request.

```
~> curl -v 127.0.0.1:9000
* Rebuilt URL to: 127.0.0.1:9000/
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to 127.0.0.1 (127.0.0.1) port 9000 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1:9000
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 404 Not Found
< content-length: 9
<
* Connection #0 to host 127.0.0.1 left intact
Not Found
```

Let's mount a request handler that always returns the same response.

```python
def app(request: Request) -> Response:
  return Response(status="200 OK", content="Hello!")


server = HTTPServer()
server.mount("", app)
server.serve_forever()
```

Whatever path we visit now, we'll get the same `Hello!` response.
Let's mount another handler to serve static files from a local folder.
To do this, we're going to update our old `serve_file` function and
turn it into a function that takes the path to some folder on disk and
returns a request handler that can serve files from that folder.

```python
def serve_static(server_root: str) -> HandlerT:
    """Generate a request handler that serves file off of disk
    relative to server_root.
    """

    def handler(request: Request) -> Response:
        path = request.path
        if request.path == "/":
            path = "/index.html"

        abspath = os.path.normpath(os.path.join(server_root, path.lstrip("/")))
        if not abspath.startswith(server_root):
            return Response(status="404 Not Found", content="Not Found")

        try:
            content_type, encoding = mimetypes.guess_type(abspath)
            if content_type is None:
                content_type = "application/octet-stream"

            if encoding is not None:
                content_type += f"; charset={encoding}"

            body_file = open(abspath, "rb")
            response = Response(status="200 OK", body=body_file)
            response.headers.add("content-type", content_type)
            return response
        except FileNotFoundError:
            return Response(status="404 Not Found", content="Not Found")

    return handler
```

Finally, we're going to call serve static and mount the result under
"/static" before we mount our application handler.

```python
server = HTTPServer()
server.mount("/static", serve_static("www")),
server.mount("", app)
server.serve_forever()
```

All requests that begin with `"/static"` will now be handled by the
generated static file handler and everything else will be handled by
the app handler.


## Middleware

Given that our request handlers are plain functions that take a
request and return a response, writing middleware -- arbitrary
functionality that can run before or after every request -- is pretty
straightforward: any function that takes a request handler as input
and itself generates a request handler is a middleware.

Here's how we might write a middleware that ensures that all incoming
requests have a valid `Authorization` header:

```python
def wrap_auth(handler: HandlerT) -> HandlerT:
    def auth_handler(request: Request) -> Response:
        authorization = request.headers.get("authorization", "")
        if authorization.startswith("Bearer ") and authorization[len("Bearer "):] == "opensesame":
            return handler(request)
        return Response(status="403 Forbidden", content="Forbidden!")
    return auth_handler
```

To use it, we just pass it the app handler and mount the result.

```python
server = HTTPServer()
server.mount("/static", serve_static("www")),
server.mount("", wrap_auth(app))
server.serve_forever()
```

Now all requests to the root handler will have to contain an
authorization header with our super secret hard-coded value, otherwise
they'll get back a 403 response.


## Winding down

That's it for part 3.  In part 4 we're going to cover extracting an
`Application` abstraction and implementing request routing.  If you'd
like to check out the full source code and follow along, you can find
it [here][source].

See ya next time!

P.S.: CodeCrafters have an interactive course where you can put what
you learned in this article into practice. Use my [referral link] to
try their service for free and get a 40% discount if you ever decide
to upgrade.

[referral link]: https://app.codecrafters.io/join?via=Bogdanp

[source]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-03
