#lang punct "../common.rkt"

---
title: Web application from scratch, Part II
date: 2018-03-04T00:00:00+00:00
---

This is the second post in my web app from scratch series. If you
haven't read it yet, you can find the [first part here]. You'll want to
read that one first.

[first part here]: •(xref "Web application from scratch, Part I")

In this part we're going to cover improvements to the `Request` data
structure, adding `Response` and `Server` abstractions and making the
server able to serve concurrent requests.

## Requests

The `Request` class we wrote last time was able to store the request
`method`, its `path` and its `headers`.  Let's first improve it by
making it possible to store multiple values for a single header.  To
do that, we're going to define a class called `Headers` that acts as a
mapping from case-insensitive header names to lists of header values.

```python
from collections import defaultdict


class Headers:
    def __init__(self) -> None:
        self._headers = defaultdict(list)

    def add(self, name: str, value: str) -> None:
        self._headers[name.lower()].append(value)

    def get_all(self, name: str) -> typing.List[str]:
        return self._headers[name.lower()]

    def get(self, name: str, default: typing.Optional[str] = None) -> typing.Optional[str]:
        try:
            return self.get_all(name)[-1]
        except IndexError:
            return default
```

Pretty straightforward: each instance of the class has an underlying
dict whose keys are lower-cased header names and whose values are
lists of header values.  If we plug `Headers` into our `Request` class
now, it should look something like this:

```python
class Request(typing.NamedTuple):
    method: str
    path: str
    headers: Headers

    @classmethod
    def from_socket(cls, sock: socket.socket) -> "Request":
        """Read and parse the request from a socket object.

        Raises:
          ValueError: When the request cannot be parsed.
        """
        lines = iter_lines(sock)

        try:
            request_line = next(lines).decode("ascii")
        except StopIteration:
            raise ValueError("Request line missing.")

        try:
            method, path, _ = request_line.split(" ")
        except ValueError:
            raise ValueError(f"Malformed request line {request_line!r}.")

        headers = Headers()
        for line in lines:
            try:
                name, _, value = line.decode("ascii").partition(":")
                headers.add(name, value.lstrip())
            except ValueError:
                raise ValueError(f"Malformed header line {line!r}.")

        return cls(method=method.upper(), path=path, headers=headers)
```

Next up, let's make it possible to read request bodies using our
request class.  Since reading the full request body on every request
is potentially wasteful (and an attack vector!), we're going to define
a `BodyReader` class that will behave as a read-only file object so
that users of the `Request` class can decide when and how much data
they want to read from the request body.

```python
class BodyReader(io.IOBase):
    def __init__(self, sock: socket.socket, *, buff: bytes = b"", bufsize: int = 16_384) -> None:
        self._sock = sock
        self._buff = buff
        self._bufsize = bufsize

    def readable(self) -> bool:
        return True

    def read(self, n: int) -> bytes:
        """Read up to n number of bytes from the request body.
        """
        while len(self._buff) < n:
            data = self._sock.recv(self._bufsize)
            if not data:
                break

            self._buff += data

        res, self._buff = self._buff[:n], self._buff[n:]
        return res
```

The `BodyReader` wraps a socket and reads data in `bufsize` chunks
into an in-memory buffer.  To understand why its buffer can be
pre-filled (the `buff` parameter in the constructor), lets take
another look at the `iter_lines` function we defined last time:

```python
def iter_lines(sock: socket.socket, bufsize: int = 16_384) -> typing.Generator[bytes, None, bytes]:
    """Given a socket, read all the individual CRLF-separated lines
    and yield each one until an empty one is found.  Returns the
    remainder after the empty line.
    """
    buff = b""
    while True:
        data = sock.recv(bufsize)
        if not data:
            return b""

        buff += data
        while True:
            try:
                i = buff.index(b"\r\n")
                line, buff = buff[:i], buff[i + 2:]
                if not line:
                    return buff

                yield line
            except IndexError:
                break
```

You can see that once it finds the marker for the end of the request
headers (`if not line:`), it *returns* any additional data that it may
have read.  To give a concrete example, say a request contains 4KiB of
header data and 100KiB of body data, since `iter_lines` reads data in
chunks of 16KiB by default, it might read all the header data *plus*
an additional 12KiB of body data in one call.  The 4KiB of header data
will be split into lines and yielded by the generator and the
additional data that was read past the request headers will be
returned from the generator.  We'll use the returned data to
pre-populate the `RequestReader`'s internal buffer.

We're going to have to change our header parsing logic to use a while
loop instead of a for loop so that we can capture the return value of
the generator.  Once we have the return value, we can construct a body
reader and pass that to the `Request` constructor.

```python
class Request(typing.NamedTuple):
    method: str
    path: str
    headers: Headers
    body: BodyReader

    @classmethod
    def from_socket(cls, sock: socket.socket) -> "Request":
        """Read and parse the request from a socket object.

        Raises:
          ValueError: When the request cannot be parsed.
        """
        lines = iter_lines(sock)

        try:
            request_line = next(lines).decode("ascii")
        except StopIteration:
            raise ValueError("Request line missing.")

        try:
            method, path, _ = request_line.split(" ")
        except ValueError:
            raise ValueError(f"Malformed request line {request_line!r}.")

        headers = Headers()
        buff = b""
        while True:
            try:
                line = next(lines)
            except StopIteration as e:
                # StopIteration.value contains the return value of the generator.
                buff = e.value
                break

            try:
                name, _, value = line.decode("ascii").partition(":")
                headers.add(name, value.lstrip())
            except ValueError:
                raise ValueError(f"Malformed header line {line!r}.")

        body = BodyReader(sock, buff=buff)
        return cls(method=method.upper(), path=path, headers=headers, body=body)
```

Now that we have a body reader, we can update our main server loop to
read and print out incoming request bodies:

```python
    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"Received connection from {client_addr}...")
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    client_sock.sendall(METHOD_NOT_ALLOWED_RESPONSE)
                    continue

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                client_sock.sendall(BAD_REQUEST_RESPONSE)
```

If you send the server some body data now, you should see it print the
whole thing to standard out.  Cool!

We're done with the `Request` data structure for now.  We'll come back
to it later when we add query string parameter parsing but, for now,
let's move it, `BodyReader` and `iter_lines` into a module called
`request.py`.  We'll also move `Headers` into its own module called
`headers.py` since the `Response` class is also going to use the
`Headers` data structure.

`headers.py`:

```python
import typing

from collections import defaultdict


class Headers:
    def __init__(self) -> None:
        self._headers = defaultdict(list)

    def add(self, name: str, value: str) -> None:
        self._headers[name.lower()].append(value)

    def get_all(self, name: str) -> typing.List[str]:
        return self._headers[name.lower()]

    def get(self, name: str, default: typing.Optional[str] = None) -> typing.Optional[str]:
        try:
            return self.get_all(name)[-1]
        except IndexError:
            return default
```

`request.py`:

```python
import io
import socket
import typing

from collections import defaultdict
from headers import Headers


class BodyReader(io.IOBase):
    def __init__(self, sock: socket.socket, *, buff: bytes = b"", bufsize: int = 16_384) -> None:
        self._sock = sock
        self._buff = buff
        self._bufsize = bufsize

    def readable(self) -> bool:
        return True

    def read(self, n: int) -> bytes:
        """Read up to n number of bytes from the request body.
        """
        while len(self._buff) < n:
            data = self._sock.recv(self._bufsize)
            if not data:
                break

            self._buff += data

        res, self._buff = self._buff[:n], self._buff[n:]
        return res


class Request(typing.NamedTuple):
    method: str
    path: str
    headers: Headers
    body: BodyReader

    @classmethod
    def from_socket(cls, sock: socket.socket) -> "Request":
        """Read and parse the request from a socket object.

        Raises:
          ValueError: When the request cannot be parsed.
        """
        lines = iter_lines(sock)

        try:
            request_line = next(lines).decode("ascii")
        except StopIteration:
            raise ValueError("Request line missing.")

        try:
            method, path, _ = request_line.split(" ")
        except ValueError:
            raise ValueError(f"Malformed request line {request_line!r}.")

        headers = Headers()
        buff = b""
        while True:
            try:
                line = next(lines)
            except StopIteration as e:
                buff = e.value
                break

            try:
                name, _, value = line.decode("ascii").partition(":")
                headers.add(name, value.lstrip())
            except ValueError:
                raise ValueError(f"Malformed header line {line!r}.")

        body = BodyReader(sock, buff=buff)
        return cls(method=method.upper(), path=path, headers=headers, body=body)


def iter_lines(sock: socket.socket, bufsize: int = 16_384) -> typing.Generator[bytes, None, bytes]:
    """Given a socket, read all the individual CRLF-separated lines
    and yield each one until an empty one is found.  Returns the
    remainder after the empty line.
    """
    buff = b""
    while True:
        data = sock.recv(bufsize)
        if not data:
            return b""

        buff += data
        while True:
            try:
                i = buff.index(b"\r\n")
                line, buff = buff[:i], buff[i + 2:]
                if not line:
                    return buff

                yield line
            except IndexError:
                break
```

### 100 Continue

If you use cURL to send more than 1KiB of data to the server you might
notice it hangs for about a second before it reads all the data.
That's because cURL uses the `100 Continue` status code to figure out
if and when it should send large request bodies to the server.

When you make a cURL request with a payload larger than 1KiB, it
automatically sends the server an `Expect: 100-continue` header and
waits until either

1. it receives a `HTTP/1.1 100 Continue` response status line from the
   server, at which point it sends the request body to the server, or
2. it receives some other response status line from the server, in
   which case it doesn't send the request body to the server at all, or
3. its 1 second timeout lapses with the server having not sent it any
   data, at which point it sends the request body to the server.

This mechanism lets clients pause the request until the server
determines whether or not it wants to process it.  Our server will
accept all requests for now so we'll just make it send the client a
`100 Continue` status every time it gets such an `Expect` header:

```python
    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"Received connection from {client_addr}...")
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                if "100-continue" in request.headers.get("expect", ""):
                    client_sock.sendall(b"HTTP/1.1 100 Continue\r\n\r\n")

                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    client_sock.sendall(METHOD_NOT_ALLOWED_RESPONSE)
                    continue

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                client_sock.sendall(BAD_REQUEST_RESPONSE)
```

Send the server more than 1KiB of data using cURL now.  It should be
much faster than it was before.


## Responses

So far all the responses we've returned have been "hand-written".
It's time for us to write a `Response` abstraction to make that side
of things a little more manageable.

Back in `server.py`, let's define our `Response` class:

```python
class Response:
    """An HTTP response.

    Parameters:
      status: The resposne status line (eg. "200 OK").
      headers: The response headers.
      body: A file containing the response body.
      content: A string representing the response body.  If this is
        provided, then body is ignored.
      encoding: An encoding for the content, if provided.
    """

    def __init__(
            self,
            status: str,
            headers: typing.Optional[Headers] = None,
            body: typing.Optional[typing.IO] = None,
            content: typing.Optional[str] = None,
            encoding: str = "utf-8"
    ) -> None:

        self.status = status.encode()
        self.headers = headers or Headers()

        if content is not None:
            self.body = io.BytesIO(content.encode(encoding))
        elif body is None:
            self.body = io.BytesIO()
        else:
            self.body = body

    def send(self, sock: socket.socket) -> None:
        """Write this response to a socket.
        """
        raise NotImplementedError
```

We'll keep it relatively simple for now: a response is just a class
that holds the response `status`, `headers` and a file representing
the response body.  In addition to that, it knows how to write itself
to a socket (rather, it will know, since we haven't implemented that
part yet).  We can use this to rewrite `serve_file` and our main loop.

```python
def serve_file(sock: socket.socket, path: str) -> None:
    """Given a socket and the relative path to a file (relative to
    SERVER_ROOT), send that file to the socket if it exists.  If the
    file doesn't exist, send a "404 Not Found" response.
    """
    if path == "/":
        path = "/index.html"

    abspath = os.path.normpath(os.path.join(SERVER_ROOT, path.lstrip("/")))
    if not abspath.startswith(SERVER_ROOT):
        response = Response(status="404 Not Found", content="Not Found")
        response.send(sock)
        return

    try:
        with open(abspath, "rb") as f:
            content_type, encoding = mimetypes.guess_type(abspath)
            if content_type is None:
                content_type = "application/octet-stream"

            if encoding is not None:
                content_type += f"; charset={encoding}"

            response = Response(status="200 OK", body=f)
            response.headers.add("content-type", content_type)
            response.send(sock)
            return
    except FileNotFoundError:
        response = Response(status="404 Not Found", content="Not Found")
        response.send(sock)
        return


with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"Received connection from {client_addr}...")
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                if "100-continue" in request.headers.get("expect", ""):
                    response = Response(status="100 Continue")
                    response.send(client_sock)

                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    response = Response(status="405 Method Not Allowed", content="Method Not Allowed")
                    response.send(client_sock)
                    continue

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                response = Response(status="400 Bad Request", content="Bad Request")
                response.send(client_sock)
```

Before we can implement `Response.send`, we have to add a method to
`Headers` that'll let us iterate over all the headers.

```python
HeadersDict = typing.Dict[str, typing.List[str]]
HeadersGenerator = typing.Generator[typing.Tuple[str, str], None, None]


class Headers:
    def __init__(self) -> None:
        self._headers = defaultdict(list)

    def add(self, name: str, value: str) -> None:
        self._headers[name.lower()].append(value)

    def get_all(self, name: str) -> typing.List[str]:
        return self._headers[name.lower()]

    def get(self, name: str, default: typing.Optional[str] = None) -> typing.Optional[str]:
        try:
            return self.get_all(name)[-1]
        except IndexError:
            return default

    def __iter__(self) -> HeadersGenerator:
        for name, values in self._headers.items():
            for value in values:
                yield name, value
```

With this in place, we can now write `Response.send`:

```python
    def send(self, sock: socket.socket) -> None:
        """Write this response to a socket.
        """
        content_length = self.headers.get("content-length")
        if content_length is None:
            try:
                body_stat = os.fstat(self.body.fileno())
                content_length = body_stat.st_size
            except OSError:
                self.body.seek(0, os.SEEK_END)
                content_length = self.body.tell()
                self.body.seek(0, os.SEEK_SET)

            if content_length > 0:
                self.headers.add("content-length", content_length)

        headers = b"HTTP/1.1 " + self.status + b"\r\n"
        for header_name, header_value in self.headers:
            headers += f"{header_name}: {header_value}\r\n".encode()

        sock.sendall(headers + b"\r\n")
        if content_length > 0:
            sock.sendfile(self.body)
```

`send` tries to figure out what the size of the request body is, then
it joins up the status line with the headers and sends them over the
socket.  Finally, it writes the body file to the socket if there is at
least one byte in it.

Python's `socket.sendfile` has the nice property that it figures out
if its parameter is just a regular file or not.  If it is, then it
uses the high-performance `sendfile` system call to write the file to
the socket and if it isn't then it falls back to regular `send` calls.

We're done with `Response` for the time being so let's move it into its
own module, called `response.py`.

## Server

At this point, our server loop in `server.py` is pretty short and sweet:

```python
with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"Received connection from {client_addr}...")
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                if "100-continue" in request.headers.get("expect", ""):
                    response = Response(status="100 Continue")
                    response.send(client_sock)

                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    response = Response(status="405 Method Not Allowed", content="Method Not Allowed")
                    response.send(client_sock)
                    continue

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                response = Response(status="400 Bad Request", content="Bad Request")
                response.send(client_sock)
```

Let's wrap it in a class called `HTTPServer`:

```python
class HTTPServer:
    def __init__(self, host="127.0.0.1", port=9000) -> None:
        self.host = host
        self.port = port

    def serve_forever(self) -> None:
        with socket.socket() as server_sock:
            server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            server_sock.bind((self.host, self.port))
            server_sock.listen(0)
            print(f"Listening on {self.host}:{self.port}...")

            while True:
                client_sock, client_addr = server_sock.accept()
                self.handle_client(client_sock, client_addr)

    def handle_client(self, client_sock: socket.socket, client_addr: typing.Tuple[str, int]) -> None:
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                if "100-continue" in request.headers.get("expect", ""):
                    response = Response(status="100 Continue")
                    response.send(client_sock)

                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    response = Response(status="405 Method Not Allowed", content="Method Not Allowed")
                    response.send(client_sock)
                    return

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                response = Response(status="400 Bad Request", content="Bad Request")
                response.send(client_sock)


server = HTTPServer()
server.serve_forever()
```

This is still the exact same logic, but now it's a little more
reusable.  `serve_forever` sets up the server socket and accepts new
connections on a loop, it then sends those connections over to
`handle_client` which processes the request and sends a response over
the socket.

Next, let's throw a little bit of concurrency into the mix by defining
an `HTTPWorker` class.

```python
class HTTPWorker(Thread):
    def __init__(self, connection_queue: Queue) -> None:
        super().__init__(daemon=True)

        self.connection_queue = connection_queue
        self.running = False

    def stop(self) -> None:
        self.running = False

    def run(self) -> None:
        self.running = True
        while self.running:
            try:
                client_sock, client_addr = self.connection_queue.get(timeout=1)
            except Empty:
                continue

            try:
                self.handle_client(client_sock, client_addr)
            except Exception:
                print(f"Unhandled error: {e}")
                continue
            finally:
                self.connection_queue.task_done()

    def handle_client(self, client_sock: socket.socket, client_addr: typing.Tuple[str, int]) -> None:
        with client_sock:
            try:
                request = Request.from_socket(client_sock)
                if "100-continue" in request.headers.get("expect", ""):
                    response = Response(status="100 Continue")
                    response.send(client_sock)

                try:
                    content_length = int(request.headers.get("content-length", "0"))
                except ValueError:
                    content_length = 0

                if content_length:
                    body = request.body.read(content_length)
                    print("Request body", body)

                if request.method != "GET":
                    response = Response(status="405 Method Not Allowed", content="Method Not Allowed")
                    response.send(client_sock)
                    return

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                response = Response(status="400 Bad Request", content="Bad Request")
                response.send(client_sock)
```

HTTP workers are OS threads that wait for new connections to pop up on
a queue and then act on them.  Let's plug workers into `HTTPServer`:

```python
class HTTPServer:
    def __init__(self, host="127.0.0.1", port=9000, worker_count=16) -> None:
        self.host = host
        self.port = port
        self.worker_count = worker_count
        self.worker_backlog = worker_count * 8
        self.connection_queue = Queue(self.worker_backlog)

    def serve_forever(self) -> None:
        workers = []
        for _ in range(self.worker_count):
            worker = HTTPWorker(self.connection_queue)
            worker.start()
            workers.append(worker)

        with socket.socket() as server_sock:
            server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            server_sock.bind((self.host, self.port))
            server_sock.listen(self.worker_backlog)
            print(f"Listening on {self.host}:{self.port}...")

            while True:
                try:
                    self.connection_queue.put(server_sock.accept())
                except KeyboardInterrupt:
                    break

        for worker in workers:
            worker.stop()

        for worker in workers:
            worker.join(timeout=30)
```

Now all the HTTP server class does is it spins up some number of
worker threads, then it sets up the server socket and starts accepting
new connections.  It pushes connections onto the shared connection
queue so that the workers can pick them up and handle them.

Just for fun, here's what running Apache Bench on the server yields
on my machine:

```
$ ab -n 10000 -c 32 http://127.0.0.1:9000/
This is ApacheBench, Version 2.3 <$Revision: 1807734 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking 127.0.0.1 (be patient)
Completed 1000 requests
Completed 2000 requests
Completed 3000 requests
Completed 4000 requests
Completed 5000 requests
Completed 6000 requests
Completed 7000 requests
Completed 8000 requests
Completed 9000 requests
Completed 10000 requests
Finished 10000 requests


Server Software:
Server Hostname:        127.0.0.1
Server Port:            9000

Document Path:          /
Document Length:        15 bytes

Concurrency Level:      32
Time taken for tests:   3.320 seconds
Complete requests:      10000
Failed requests:        0
Total transferred:      790000 bytes
HTML transferred:       150000 bytes
Requests per second:    3011.73 [#/sec] (mean)
Time per request:       10.625 [ms] (mean)
Time per request:       0.332 [ms] (mean, across all concurrent requests)
Transfer rate:          232.35 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       2
Processing:     2   11   5.1     10      73
Waiting:        1    9   4.6      8      72
Total:          3   11   5.1     10      73

Percentage of the requests served within a certain time (ms)
  50%     10
  66%     11
  75%     11
  80%     11
  90%     12
  95%     12
  98%     14
  99%     17
 100%     73 (longest request)
```

3k requests per second.  Not bad considering this is a threaded web
server implemented in pure Python!


## Winding down

Whew!  That was a lot of stuff to cover in one post.  I didn't think
you'd make it, but here you are!  That's it for part 2.  In part 3
we're going to cover request handlers and middleware.  If you'd like
to check out the full source code and follow along, you can find it
[here][source].

See ya next time!

P.S.: CodeCrafters have an interactive course where you can put what
you learned in this article into practice. Use my [referral link] to
try their service for free and get a 40% discount if you ever decide
to upgrade.

[referral link]: https://app.codecrafters.io/join?via=Bogdanp

[source]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-02
