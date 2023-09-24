#lang punct

---
title: Protohackers Challenge in Racket Part 1
date: 2023-03-25T12:23:00+03:00
---

Someone on the Racket Discord recently mentioned the [Protohackers]
project and I figured it'd be fun to write about Racket solutions to the
challenges available on the website.

## 0: Smoke Test

The 0th challenge is a basic echo server.

```racket
#lang racket/base

(require racket/match
         racket/tcp)

(define (handle in out)
  (let loop ()
    (match (read-bytes 4096 in)
      [(? eof-object?)
       (void)]
      [bs
       (write-bytes bs out)
       (loop)])))

(module+ main
  (define listener
    (tcp-listen 8111 512 #t "0.0.0.0"))
  (define server-custodian
    (make-custodian))
  (with-handlers ([exn:break? void])
    (parameterize ([current-custodian server-custodian])
      (let loop ()
        (parameterize-break #f
          (define-values (in out)
            (tcp-accept/enable-break listener))
          (define client-custodian
            (make-custodian))
          (define client-thd
            (parameterize ([current-custodian client-custodian])
              (thread
               (lambda ()
                 (break-enabled #t)
                 (handle in out)))))
          (thread
           (lambda ()
             (sync client-thd)
             (close-output-port out)
             (close-input-port in)
             (custodian-shutdown-all client-custodian))))
        (loop))))
  (custodian-shutdown-all server-custodian)
  (tcp-close listener))
```

All we have to do is start a TCP listener, then accept new connections
in a loop. For every new connection, we open a thread to handle it and
a thread to close the connection and shut down the client custodian
after the handling thread is done. Wrapping every client in a custodian
ensures the handlers cannot leak resources (other threads, ports, etc.)
after they exit. We disable breaks during connection setup so that
an ill-timed break won't leave connections in a half-set-up state.
On break (`SIGINT`, `SIGTERM`, or other signals), we terminate all
running handler threads and their associated resources then close the
TCP listener.

The `handle` procedure reads data in up to 4096 byte chunks and writes
it back to the client. On `EOF`, `read-bytes` returns a special `EOF`
value and, in that case, we simply exit the loop.

One notable thing about this server is we have no limit on the number
of concurrent clients, so it is easy to flood. We also have no limit
on connection duration, though that would be easy to add to the
handler-supervising thread by using `sync/timeout` instead of `sync`.

## 1: Prime Time

This challenge requires us to do some JSON parsing and primality
checking.

```racket
#lang racket/base

(require json
         racket/match
         racket/tcp)

(define (prime? n)
  (let ([n (truncate n)])
    (and (not (negative? n))
         (not (= n 0))
         (not (= n 1))
         (or (= n 2)
             (not
              (for/or ([i (in-range 2 (add1 (sqrt n)))])
                (zero? (modulo n i))))))))

(define (handle in out)
  (with-handlers ([exn:fail?
                   (λ (e)
                     ((error-display-handler) (format "client error: ~a" (exn-message e)) e)
                     (displayln "request malformed" out))])
    (let loop ()
      (define line (read-line in))
      (match (string->jsexpr line)
        [(hash-table
          ['method "isPrime"]
          ['number (? number? n)])
         (write-json (hasheq 'method "isPrime" 'prime (prime? n)) out)
         (newline out)
         (flush-output out)
         (loop)]
        [_
         (displayln "request malformed" out)]))))
```

The TCP listening bits haven't changed from the first challenge, so I've
elided them here. The `handle` proc now reads one line at a time from
the client and attempts to parse it as a JSON value. Any parsing error,
as well as any validation error causes the handler to exit the loop and
close the connection after writing a message to the client. Well-formed
messages are validated in the first match clause and every valid request
is followed by a valid response and a newline.

Note that `read-line` will happily buffer data in memory until it
sees a linefeed character, meaning an adversarial client could easily
crash this server by sending it a very long stream of non-linefeed
characters[^1]. Also note how the error handlers are set up outside the
loop. The body of the `with-handlers` form is not in tail position,
so if we'd have set up the handlers inside the loop, we'd be creating
unnecessary frames on every iteration, increasing memory consumption.

[^1]: Ryan Culpepper pointed out on the Racket Discord that we could
    combine `read-line` with `make-limited-input-port` in order to
    limit the amount of data `read-line` will buffer in memory.

## 2: Means to an End

This challenge requires us to parse a custom binary format and store a
little bit of state for each client.

```racket
#lang racket/base

(require racket/match
         racket/math
         racket/port
         racket/tcp
         "002.bnf")

(define (get-avg-price prices min-time max-time)
  (for/fold ([n 0] [s 0] #:result (if (zero? n) 0 (exact-round (/ s n))))
            ([(timestamp price) (in-hash prices)]
             #:when (and (>= timestamp min-time)
                         (<= timestamp max-time)))
    (values (add1 n) (+ s price))))

(define (handle in out)
  (let loop ([prices (hasheqv)])
    (define data (read-bytes 9 in))
    (unless (eof-object? data)
      (match (call-with-input-bytes data Message)
        [`((char_1 . #\I)
           (Timestamp_1 . ,timestamp)
           (Price_1 . ,price))
         (loop (hash-set prices timestamp price))]
        [`((char_1 . #\Q)
           (MinTime_1 . ,min-time)
           (MaxTime_1 . ,max-time))
         (un-Price (get-avg-price prices min-time max-time) out)
         (flush-output out)
         (loop prices)]))))
```

Just like with challenge 1, the listener bits have not changed. However,
I did decide to overengineer this solution a little by using [binfmt] to
parse the binary format. The contents of "0002.bnf" are:

```
#lang binfmt

Message = Insert | Query;

Insert = 'I' Timestamp Price;
Timestamp = i32be;
Price = i32be;

Query = 'Q' MinTime MaxTime;
MinTime = i32be;
MaxTime = i32be;
```

The `handler` proc reads 9 bytes from the client at a time and tries to
parse a `Message` out of them. When it receives an insert message, it
updates the price slot for that timestamp and when it receives a query
message, it computes an average price and responds to the client.

Like the previous challange, this server is susceptible to an attack
where an adversarial client could send it enough prices to exhaust
available memory and cause it to crash.

## 3: Budget Chat

This challenge requires us to implement a chat room.

```racket
#lang racket/base

(require racket/match
         racket/string
         racket/tcp)

(define room-ch (make-channel))
(define room-thd
  (thread/suspend-to-kill
   (lambda ()
     (let loop ([users (hasheq)]
                [reqs null])
       (apply
        sync
        (handle-evt
         room-ch
         (lambda (msg)
           (match msg
             [`(join ,name ,out ,res-ch ,nack)
              (cond
                [(hash-has-key? users name)
                 (define req `((fail "username-taken") ,res-ch ,nack))
                 (loop users (cons req reqs))]
                [else
                 (define req `((ok ,(hash-keys users)) ,res-ch ,nack))
                 (broadcast users (format "* ~a has joined the room~n" name))
                 (loop (hash-set users name out) (cons req reqs))])]
             [`(broadcast ,name ,message ,res-ch ,nack)
              (define req `((ok) ,res-ch ,nack))
              (broadcast (hash-remove users name) (format "[~a] ~a~n" name message))
              (loop users (cons req reqs))]
             [`(leave ,name ,res-ch ,nack)
              (define req `((ok) ,res-ch ,nack))
              (define remaining-users (hash-remove users name))
              (broadcast remaining-users (format "* ~a has left the room~n" name))
              (loop remaining-users (cons req reqs))]
             [_
              (log-warning "malformed message: ~s" msg)
              (loop users reqs)])))
        (append
         (for/list ([req (in-list reqs)])
           (match-define `(,res ,res-ch ,_) req)
           (handle-evt
            (channel-put-evt res-ch res)
            (λ (_) (loop users (remq req reqs)))))
         (for/list ([req (in-list reqs)])
           (match-define `(,_ ,_ ,nack) req)
           (handle-evt nack (λ (_) (loop users (remq req reqs)))))))))))

(define (make-room-evt command . args)
  (define res-ch (make-channel))
  (nack-guard-evt
   (lambda (nack)
     (begin0 res-ch
       (thread-resume room-thd (current-thread))
       (channel-put room-ch `(,command ,@args ,res-ch ,nack))))))

(define (handle in out)
  (fprintf* out "Welcome to budgetchat! What shall I call you?~n")
  (match (read-line in 'any)
    [(regexp #px"^[a-zA-Z0-9]{1,16}$" (list (app string->symbol name)))
     (match (sync (make-room-evt 'join name out))
       [`(fail ,message)
        (fprintf out "error: ~a~n" message)]
       [`(ok ,names)
        (fprintf* out "* The room contains: ~a~n" (string-join (map symbol->string (sort names symbol<?))))
        (with-handlers ([exn:fail? (λ (e) ((error-display-handler) (format "client error: ~a" (exn-message e)) e))])
          (let loop ()
            (define data
              (read-line in 'any))
            (unless (eof-object? data)
              (sync (make-room-evt 'broadcast name data))
              (loop))))
        (sync (make-room-evt 'leave name))])]
    [_
     (fprintf* out "error: invalid name~n")]))

(define (broadcast users message)
  (for ([out (in-hash-values users)])
    (with-handlers ([exn:fail? void])
      (fprintf* out message))))

(define (fprintf* out msg . args)
  (apply fprintf out msg args)
  (flush-output out))
```

The implementation for this challenge is more complex since it involves
keeping track of shared state and broadcasting messages to multiple
clients. I opted to make a shared thread to keep track of user sessions.
The contents of the loop inside `room-thd` is a common pattern I
use when implementing stateful actors in Racket, stolen from [this
paper][kill safe].

The room is itself a sort of server. It receives messages via the
`room-ch` where each message is expected to have a channel on which
responses can be sent, and a negative acknowledgement `evt`. For
every message it receives, it updates its internal state and responds
to whatever requests it can, or removes any requests whose negative
acknowledgement event is ready for synchronization (i.e. requests
that have been abandoned ). The `make-room-evt` procedure generates a
synchronizable event that sends a request to the room and receives a
response when synchronized.

The handler follows the initialization sequence by asking the client for
a nickname, validating it and then entering the messaging loop. When a
client joins the room, it sends its nick along with its output port to
the room. The room then writes to the client's output port whenever new
information is broadcast.

This server is susceptible to the same attacks as the ones before
it: it uses `read-line` to read messages and it doesn't limit the
number of concurrent users. The former we can fix by writing a custom
`read-line*` function that rejects lines longer than 1024 bytes (eg, by
using `peek-bytes`) and the latter we can fix by making the room reject
`join` requests when the number of users exceeds some limit.

That's all for today. You can find these servers in full on [GitHub].

[Protohackers]: https://protohackers.com/
[binfmt]: https://docs.racket-lang.org/binfmt-manual/index.html
[kill safe]: https://www-old.cs.utah.edu/plt/publications/pldi04-ff.pdf
[GitHub]: https://github.com/Bogdanp/racket-protohackers
