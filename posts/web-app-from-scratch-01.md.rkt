#lang punct

---
title: Web application from scratch, Part I
date: 2018-02-25T01:00:00+00:00
---

This is the first in a series of posts in which I'm going to go
through the process of building a web application (and its web server)
from scratch in Python.  For the purposes of this series, I'm going to
solely rely on the Python standard library and I'm going to ignore the
WSGI standard.

Without further ado, let's get to it!

## The web server

To begin with, we're going to write the HTTP server that will power
our web app.  But first, we need to spend a little time looking into
how the HTTP protocol works.


### How HTTP works

Simply put, HTTP clients connect to HTTP servers over the network and
send them a string of data representing the request.  The server then
interprets that request and sends the client back a response.  The
entire protocol and the formats of those requests and responses are
described in [RFC2616], but I'm going to informally describe them
below so you don't have to read the whole thing.

#### Request format

Requests are represented by a series of `\r\n`-separated lines, the
first of which is called the "request line".  The request line is made
up of an HTTP method, followed by a space, followed by the path of the
file being requested, followed by another space, followed by the HTTP
protocol version the client speaks and, finally, followed by a
carriage return (`\r`) and a line feed (`\n`) character:

```http
GET /some-path HTTP/1.1\r\n
```

After the request line come zero or more header lines.  Each header
line is made up of the header name, followed by a colon, followed by
an optional value, followed by `\r\n`:

```http
Host: example.com\r\n
Accept: text/html\r\n
```

The end of the headers section is signaled by an empty line:

```http
\r\n
```

Finally, the request may contain a "body" -- an arbitrary payload that
is sent to the server with the request.

Putting it all together, here's a simple `GET` request:

```http
GET / HTTP/1.1\r\n
Host: example.com\r\n
Accept: text/html\r\n
\r\n
```

and here's a simple `POST` request with a body:

```http
POST / HTTP/1.1\r\n
Host: example.com\r\n
Accept: application/json\r\n
Content-type: application/json\r\n
Content-length: 2\r\n
\r\n
{}
```

#### Response format

Responses, like requests, are made up of a series of `\r\n`-separated
lines.  The first line in the response is called the "status line" and
it is made up of the HTTP protocol version, followed by a space,
followed by the response status code, followed by another space, then
the status code reason, followed by `\r\n`:

```http
HTTP/1.1 200 OK\r\n
```

After the status line come the response headers, then an empty line
and then an optional response body:

```http
HTTP/1.1 200 OK\r\n
Content-type: text/html\r\n
Content-length: 15\r\n
\r\n
<h1>Hello!</h1>
```


### A simple server

Based on what we know so far about the protocol, let's write a server
that sends the same response regardless of the incoming request.

To start out, we need to create a socket, bind it to an address and
then start listening for connections.

```python
import socket

HOST = "127.0.0.1"
PORT = 9000

# By default, socket.socket creates TCP sockets.
with socket.socket() as server_sock:
    # This tells the kernel to reuse sockets that are in `TIME_WAIT` state.
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    # This tells the socket what address to bind to.
    server_sock.bind((HOST, PORT))

    # 0 is the number of pending connections the socket may have before
    # new connections are refused.  Since this server is going to process
    # one connection at a time, we want to refuse any additional connections.
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")
```

If you try to run this code now, it'll print to standard out that it's
listening on `127.0.0.1:9000` and then exit.  In order to actually
process incoming connections we need to call the `accept` method on
our socket.  Doing so will block the process until a client connects
to our server.

```python
with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    client_sock, client_addr = server_sock.accept()
    print(f"New connection from {client_addr}.")
```

Once we have a socket connection to the client, we can start to
communicate with it.  Using the `sendall` method, let's send the
connecting client an example response:

```python
RESPONSE = b"""\
HTTP/1.1 200 OK
Content-type: text/html
Content-length: 15

<h1>Hello!</h1>""".replace(b"\n", b"\r\n")

with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    client_sock, client_addr = server_sock.accept()
    print(f"New connection from {client_addr}.")
    with client_sock:
        client_sock.sendall(RESPONSE)
```

If you run the code now and then visit http://127.0.0.1:9000 in your
favourite browser, it should render the string "Hello!".  Unfortunately,
the server will exit after it sends the response so refreshing the
page will fail.  Let's fix that:

```python
RESPONSE = b"""\
HTTP/1.1 200 OK
Content-type: text/html
Content-length: 15

<h1>Hello!</h1>""".replace(b"\n", b"\r\n")

with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"New connection from {client_addr}.")
        with client_sock:
            client_sock.sendall(RESPONSE)
```

At this point we have a web server that can serve a simple HTML web
page on every request, all in about 25 lines of code.  That's not too
bad!


### A file server

Let's extend the HTTP server so that it can serve files off of disk.

#### Request abstraction

Before we can do that, we have to be able to read and parse incoming
request data from the client.  Since we know that request data is
represented by a series of lines, each separated by `\r\n` characters,
let's write a generator function that reads data from a socket and
yields each individual line:

```python
import typing


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

This may look a bit daunting, but essentially what it does is it reads
as much data as it can from the socket (in `bufsize` chunks), joins
that data together in a buffer (`buff`) and continually splits the
buffer into individual lines, yielding one at a time.  Once it finds
an empty line, it returns the extra data that it read.

Using `iter_lines`, we can begin printing the requests we get from our
clients:

```python
with socket.socket() as server_sock:
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind((HOST, PORT))
    server_sock.listen(0)
    print(f"Listening on {HOST}:{PORT}...")

    while True:
        client_sock, client_addr = server_sock.accept()
        print(f"New connection from {client_addr}.")
        with client_sock:
            for request_line in iter_lines(client_sock):
                print(request_line)

            client_sock.sendall(RESPONSE)
```

If you run the server now and visit http://127.0.0.1:9000, you should
see something like this in your console:

```
Received connection from ('127.0.0.1', 62086)...
b'GET / HTTP/1.1'
b'Host: localhost:9000'
b'Connection: keep-alive'
b'Cache-Control: max-age=0'
b'Upgrade-Insecure-Requests: 1'
b'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.167 Safari/537.36'
b'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8'
b'Accept-Encoding: gzip, deflate, br'
b'Accept-Language: en-US,en;q=0.9,ro;q=0.8'
```

Pretty neat!  Let's abstract over that data by defining a ``Request`` class:

```python
import typing


class Request(typing.NamedTuple):
    method: str
    path: str
    headers: typing.Mapping[str, str]
```

For now, the request class is only going to know about methods, paths
and request headers.  We'll leave parsing query string parameters and
reading request bodies for later.

To encapsulate the logic needed to build up a request, we'll add a
class method to `Request` called `from_socket`:

```python
class Request(typing.NamedTuple):
    method: str
    path: str
    headers: typing.Mapping[str, str]

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

        headers = {}
        for line in lines:
            try:
                name, _, value = line.decode("ascii").partition(":")
                headers[name.lower()] = value.lstrip()
            except ValueError:
                raise ValueError(f"Malformed header line {line!r}.")

        return cls(method=method.upper(), path=path, headers=headers)
```

It uses the `iter_lines` function we defined earlier to read the
request line.  That's where it gets the `method` and the `path`, then
it reads each individual header line and parses those.  Finally, it
builds the `Request` object and returns it.  If we plug that into our
server loop, it should look something like this:

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
            request = Request.from_socket(client_sock)
            print(request)
            client_sock.sendall(RESPONSE)
```

If you connect to the server now, you should see lines like this one
get printed out:

```python
Request(method='GET', path='/', headers={'host': 'localhost:9000', 'user-agent': 'curl/7.54.0', 'accept': '*/*'})
```

Because `from_socket` can raise an exception under certain
circumstances, the server might crash if given an invalid request
right now.  To simulate this, you can use telnet to connect to the
server and send it some bogus data:

```
~> telnet 127.0.0.1 9000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
hello
Connection closed by foreign host.
```

Sure enough, the server crashed:

```
Received connection from ('127.0.0.1', 62404)...
Traceback (most recent call last):
  File "server.py", line 53, in parse
    request_line = next(lines).decode("ascii")
ValueError: not enough values to unpack (expected 3, got 1)

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "server.py", line 82, in <module>
    with client_sock:
  File "server.py", line 55, in parse
    raise ValueError("Request line missing.")
ValueError: Malformed request line 'hello'.
```

To handle these kinds of issues a little more gracefully, let's wrap
the call to `from_socket` in a try-except block and send the client a
"400 Bad Request" response when we get a malformed request:

```python
BAD_REQUEST_RESPONSE = b"""\
HTTP/1.1 400 Bad Request
Content-type: text/plain
Content-length: 11

Bad Request""".replace(b"\n", b"\r\n")

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
                print(request)
                client_sock.sendall(RESPONSE)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                client_sock.sendall(BAD_REQUEST_RESPONSE)
```

If we try to break it now, our client will get a response back and the
server will stay up:

```
~> telnet 127.0.0.1 9000
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
hello
HTTP/1.1 400 Bad Request
Content-type: text/plain
Content-length: 11

Bad RequestConnection closed by foreign host.
```

At this point we're ready to start implementing the file serving part,
but first let's make our default response a "404 Not Found" response:

```python
NOT_FOUND_RESPONSE = b"""\
HTTP/1.1 404 Not Found
Content-type: text/plain
Content-length: 9

Not Found""".replace(b"\n", b"\r\n")

#...

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
                print(request)
                client_sock.sendall(NOT_FOUND_RESPONSE)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                client_sock.sendall(BAD_REQUEST_RESPONSE)
```

Additionally, let's add a "405 Method Not Allowed" response.  We're
going to need it for when we get anything other than a `GET` request.

```python
METHOD_NOT_ALLOWED_RESPONSE = b"""\
HTTP/1.1 405 Method Not Allowed
Content-type: text/plain
Content-length: 17

Method Not Allowed""".replace(b"\n", b"\r\n")
```

Let's define a `SERVER_ROOT` constant to represent where the server
should serve files from and a `serve_file` function.

```python
import mimetypes
import os
import socket
import typing

SERVER_ROOT = os.path.abspath("www")

FILE_RESPONSE_TEMPLATE = """\
HTTP/1.1 200 OK
Content-type: {content_type}
Content-length: {content_length}

""".replace("\n", "\r\n")


def serve_file(sock: socket.socket, path: str) -> None:
    """Given a socket and the relative path to a file (relative to
    SERVER_SOCK), send that file to the socket if it exists.  If the
    file doesn't exist, send a "404 Not Found" response.
    """
    if path == "/":
        path = "/index.html"

    abspath = os.path.normpath(os.path.join(SERVER_ROOT, path.lstrip("/")))
    if not abspath.startswith(SERVER_ROOT):
        sock.sendall(NOT_FOUND_RESPONSE)
        return

    try:
        with open(abspath, "rb") as f:
            stat = os.fstat(f.fileno())
            content_type, encoding = mimetypes.guess_type(abspath)
            if content_type is None:
                content_type = "application/octet-stream"

            if encoding is not None:
                content_type += f"; charset={encoding}"

            response_headers = FILE_RESPONSE_TEMPLATE.format(
                content_type=content_type,
                content_length=stat.st_size,
            ).encode("ascii")

            sock.sendall(response_headers)
            sock.sendfile(f)
    except FileNotFoundError:
        sock.sendall(NOT_FOUND_RESPONSE)
        return
```

`serve_file` takes the client socket and a path to a file.  It then
tries to resolve that path to a real file inside of the `SERVER_ROOT`,
returning a "not found" response if the file resolves outside of the
server root.  Then it tries to open the file and figure out its mime
type and size (using `os.fstat`), then it constructs the response
headers and uses the `sendfile` system call to write the file to the
socket.  If it can't find the file on disk, then it sends a "not
found" response.

If we add `serve_file` into the mix, our server loop should now look
like this:

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
                if request.method != "GET":
                    client_sock.sendall(METHOD_NOT_ALLOWED_RESPONSE)
                    continue

                serve_file(client_sock, request.path)
            except Exception as e:
                print(f"Failed to parse request: {e}")
                client_sock.sendall(BAD_REQUEST_RESPONSE)
```

If you add a file called `www/index.html` next to your `server.py`
file and visit http://localhost:9000 you should see the contents
of that file.  Cool, eh?


### Winding down

That's it for part 1.  In part 2 we're going to cover extracting
`Server` and `Response` abstractions as well as making the server
handle multiple concurrent connections.  If you'd like to check out
the full source code and follow along, you can find it [here][source].

See ya next time!

P.S.: CodeCrafters have an interactive course where you can put what
you learned in this article into practice. Use my [referral link] to
try their service for free and get a 40% discount if you ever decide
to upgrade.

[referral link]: https://app.codecrafters.io/join?via=Bogdanp



[RFC2616]: https://tools.ietf.org/html/rfc2616
[source]: https://github.com/Bogdanp/web-app-from-scratch/tree/part-01
