#lang punct

---
title: SO_KEEPALIVE Slow on macOS
date: 2025-07-31T08:00:00+03:00
---

[Tested on macOS 14, 15 and 26.]

It turns out that enabling `SO_KEEPALIVE` on a socket on macOS slows
operations through that socket to a crawl.

I noticed this while looking into a performance issue with downloads for
[Podcatcher]. I set up a remote server[^1] to download a 1GB file, and
saw it was much slower than `curl` or even Python's `requests` library.
Then, I minimized the test down to a plain Racket TCP client:

``` racket
#lang racket/base

(require racket/port
         racket/tcp)

(define-values (in out)
  (tcp-connect "<HOST>" 8000))

(fprintf out "GET /1gb.bin HTTP/1.1\r\n")
(fprintf out "Connection: close\r\n")
(fprintf out "\r\n")
(tcp-abandon-port out)
(read-line in)
(time (copy-port in (open-output-nowhere)))
```

Which, to my surprise, was also slow. Eventually, I tested it on a
Linux Docker container, and that was performing as expected. Then, I
tested it on a macOS machine running Racket 8.15, and that was also
performing well.

In version 8.17, Racket enabled `SO_KEEPALIVE` for all TCP sockets by
default, and that turns out to be the culprit. For whatever reason,
only on macOS, if you turn on `SO_KEEPALIVE` on a socket (client or
server), operations on that socket slow down significantly (2x-4x
between machines on the same WiFi network and a lot more when more hops
are involved[^2]).

Here's a minimal C client program that reproduces the problem. To test
it, on a remote server, generate a large file by running `dd`:

    dd if=/dev/zero of=1gb.bin bs=1MB count=1024

Then, serve it using Python:

    python -m http.server --bind 0.0.0.0 8000


On a Mac, compile and execute the following code, replacing the `HOST`
and `PORT` strings with appropriate values for your test:

```c
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

const char *HOST = "<HOST>";
const char *PORT = "<PORT>";

int sendstr(int sock, const char *str) {
  return send(sock, str, strlen(str), 0);
}

int main(void) {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        perror("socket");
        return 1;
    }

    int enable = 0; // Set to 1 to slow to a crawl
    if (setsockopt(sock, IPPROTO_TCP, SO_KEEPALIVE, &enable, sizeof(enable))) {
      perror("setsockopt");
      close(sock);
      return 1;
    }

    struct sockaddr_in server_addr;
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(atoi(PORT));

    if (inet_pton(AF_INET, HOST, &server_addr.sin_addr) <= 0) {
        perror("inet_pton");
        close(sock);
        return 1;
    }

    if (connect(sock, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        perror("connect");
        close(sock);
        return 1;
    }

    sendstr(sock, "GET /1gb.bin HTTP/1.1\r\n");
    sendstr(sock, "Connection: close\r\n");
    sendstr(sock, "\r\n");

    char buf[65536];
    size_t nread, total = 0;
    do {
      nread = recv(sock, buf, sizeof(buf), 0);
      total += nread;
      printf("%ldMiB\r", total/1024/1024);
    } while (nread > 0);
    printf("%ldMiB\n", total/1024/1024);

    close(sock);
    return 0;
}
```

Change the `enabled` flag to `1` and then run it again to see the
difference.

For Racket, the fix is going to be to turn off `SO_KEEPALIVE` on macOS.
I've sent a report to Apple (FB19250856) about this problem. Maybe
they'll have an idea about what's going wrong here.

[^1]: The issue doesn't occur over loopback.
[^2]: In my test with the 1gb file on a remote server, the slowdown
    was between 20x and 40x.

[Podcatcher]: https://podcatcher.net/
