#lang punct

---
title: Protohackers Challenge in Racket Part 2
date: 2023-03-26T07:15:00+03:00
---

I'm currently stuck waiting for a flight, so I figured I'd pick up
where I left off [yesterday] [^1] and implement a couple more of the
[Protohackers] challenges.

[yesterday]: /2023/03/25/protohackers-part-1/

[^1]: I wrote this post last Sunday, but only published it today
    (Wednesday, March 26) after tweaking the post and solutions a bit.

## `run-server`

Since the accept loop was common between all the challenges so far, I
decided to extract and reuse it:

```racket
(define (run-server host port handle
                    #:backlog [backlog 511]
                    #:reuse? [reuse? #t]
                    #:timeout-evt-proc [make-timeout-evt values]
                    #:listen-proc [listen tcp-listen]
                    #:accept-proc [accept tcp-accept/enable-break]
                    #:close-proc [close tcp-close])
  (define listener
    (listen port backlog reuse? host))
  (define server-custodian
    (make-custodian))
  (define server-thd
    (parameterize ([current-custodian server-custodian])
      (thread
       (lambda ()
         (with-handlers ([exn:break? void])
           (let loop ()
             (parameterize-break #f
               (define-values (in out)
                 (accept listener))
               (define client-custodian
                 (make-custodian))
               (define client-thd
                 (thread
                  (lambda ()
                    (break-enabled #t)
                    (parameterize ([current-custodian client-custodian])
                      (handle in out)))))
               (thread
                (lambda ()
                  (sync (make-timeout-evt client-thd))
                  (close-output-port out)
                  (close-input-port in)
                  (custodian-shutdown-all client-custodian))))
             (loop)))
         (close listener)))))
  (lambda ()
    (break-thread server-thd)
    (thread-wait server-thd)
    (custodian-shutdown-all server-custodian)))
```

This version abstracts over the TCP procedures (you'll see why in a
bit), runs the accept loop in a thread and returns a procedure that
can be used to stop the server.  For convenience, I also wrote a
version that blocks the calling thread until a break is received:

```racket
(define run-server*
  (make-keyword-procedure
   (lambda (kws kw-args . args)
     (define stop (keyword-apply run-server kws kw-args args))
     (with-handlers ([exn:break? void])
       (sync never-evt))
     (stop))))
```

With this in place, the 0th challenge from yesterday now looks like
this:

```racket
#lang racket/base

(require racket/match)

(define (handle in out)
  (let loop ()
    (match (read-bytes 4096 in)
      [(? eof-object?)
       (void)]
      [bs
       (write-bytes bs out)
       (loop)])))

(module+ main
  (require "common.rkt")
  (run-server* "0.0.0.0" 8111 handle))
```

## 4: Unusual Database Program

This challenge switches things up and uses UDP instead of TCP.

```racket
#lang racket/base

(require racket/match
         racket/port)

(define db
  (make-hash `(("version" . "Ken's Key-Value Store 1.0"))))

(define (handle in out)
  (match (port->string in)
    [(regexp #rx"^([^=]*)=(.*)$" (list _ key value))
     (unless (equal? key "version")
       (hash-set! db key value))]
    [key
     (define value (hash-ref db key #f))
     (display key out)
     (when value
       (display "=" out)
       (display value out))]))

(module+ main
  (require racket/udp
           "common.rkt")

  (define (udp-listen port _backlog reuse? host)
    (define socket (udp-open-socket))
    (begin0 socket
      (udp-bind! socket host port reuse?)))

  (define (udp-accept listener)
    (define buf (make-bytes 65536))
    (parameterize-break #f
      (define-values (len hostname port)
        (udp-receive!/enable-break listener buf))
      (define client-in (open-input-bytes (subbytes buf 0 len)))
      (define-values (pipe-in client-out)
        (make-pipe))
      (thread
       (lambda ()
         (let loop ()
           (define len (read-bytes! buf pipe-in))
           (unless (eof-object? len)
             (udp-send-to listener hostname port buf 0 len)
             (loop)))))
      (values client-in client-out)))

  (run-server* "0.0.0.0" 8111 handle
               #:listen-proc udp-listen
               #:accept-proc udp-accept
               #:close-proc udp-close))
```

Since `run-server` now abstracts over the `listen`, `accept`, and
`close` procedures, we can massage the UDP API to fit into the
`run-server` model.  To listen, we bind a socket to the given host and
port.  To accept, we receive a packet, wrap the data into an input
port and use a pipe to pump responses back to the client through the
same UDP socket.

The `handle` procedure is straightforward: it uses a shared hash to
store and retrieve the entries.  Hashes are thread-safe so it's fine
to share the same hash between clients given that we don't have to
worry about data races for this particular problem.

## 5: Mob in the Middle

Back to TCP, this time implementing a MITM attack.

```racket
#lang racket/base

(require racket/tcp)

(define (handle in out)
  (define-values (proxied-in proxied-out)
    (tcp-connect "chat.protohackers.com" 16963))
  (thread
   (lambda ()
     (pump proxied-in out)))
  (pump in proxied-out))

(define (pump in out)
  (define buf (make-bytes 4096))
  (let loop ([data #""])
    (define len
      (read-bytes-avail! buf in))
    (cond
      [(eof-object? len)
       (write-bytes (rewrite data) out)
       (flush-output out)]
      [else
       (loop (drain (bytes-append data (subbytes buf 0 len)) out))])))

(define (drain data out)
  (let loop ([data data])
    (cond
      [(bytes-index-of data 10)
       => (λ (idx)
            (write-bytes (rewrite (subbytes data 0 idx)) out)
            (write-byte 10 out)
            (flush-output out)
            (loop (subbytes data (add1 idx))))]
      [else data])))

(define (rewrite data)
  (regexp-replace*
   #px#"(.?)(7[a-zA-Z0-9]{25,34})(.?)" data
   (λ (bs pre _addr post)
     (cond
       [(and (member pre '(#"" #" "))
             (member post '(#"" #" ")))
        (bytes-append pre #"7YWHMfk9JZe0LM0g1ZauHuiSxhI" post)]
       [else bs]))))

(define (bytes-index-of bs b)
  (for/first ([o (in-bytes bs)]
              [i (in-naturals)]
              #:when (= o b))
    i))

(module+ main
  (require "common.rkt")
  (run-server* "0.0.0.0" 8111 handle))
```

This is the first challenge where we act as a TCP client.  For every
connection, we make our own connection to the upstream chat server.
Then, we pipe all output from the chat server to the client, rewriting
any lines containing cryptocurrency addresses.  We do the same for
input from the client to the chat server.

The tricky part about this challenge is that we can't just use
`read-line` because the client might terminate the connection in the
middle of writing a line and `read-line` makes no distinction between
the end of input and the end of a line.  So, we pump input from one
side to the other in 4k chunks, searching for newlines after every
chunk and rewriting complete lines.

## 6: Speed Daemon

This challenge cranks up the difficulty, so I'll split the solution
into sections below.

### Common Bits

The imports and a logger are shared between the three sections.

``` racket
#lang racket/base

(require (for-syntax racket/base
                     racket/syntax
                     syntax/parse)
         racket/match
         racket/math
         racket/random
         threading
         (prefix-in proto: "006.bnf"))

(define-logger protohackers)
```

### Message Parsing

Once again, I've opted to use [binfmt] to handle the message parsing,
but this time around I've decided to parse the data into actual
structs.

``` racket
(define *message-readers*
  (make-hasheqv))

(define-values (prop:message-writer _prop:message-writer? message-writer)
  (make-struct-type-property 'message-writer))

(define-syntax (define-message stx)
  (syntax-parse stx
    [(_ message-id:id
        ([field-id:id field-sym:id] ...)
        #:tag tag-number:expr
        {~alt
         {~optional {~seq #:parser parser-proc}}
         {~optional {~seq #:unparser unparser-proc}}} ...)
     #:with (field-accessor-id ...) (for/list ([field-id-stx (in-list (syntax-e #'(field-id ...)))])
                                      (format-id field-id-stx "~a-~a" #'message-id field-id-stx))
     #:with read-message-id (format-id #'message-id "read-~a" #'message-id)
     #:with write-message-id (format-id #'message-id "write-~a" #'message-id)
     #:with default-parser-id (format-id #'message-id "proto:~a" #'message-id)
     #:with default-unparser-id (format-id #'message-id "proto:un-~a" #'message-id)
     #'(begin
         (struct message-id (field-id ...)
           #:transparent
           #:property prop:message-writer
           (λ () write-message-id))
         (define (read-message-id in)
           (define data ({~? parser-proc default-parser-id} in))
           (define msg (message-id (and~> (assq 'field-sym data) cdr) ...))
           (begin0 msg
             (log-protohackers-debug "read ~s" msg)))
         (define (write-message-id m out)
           (log-protohackers-debug "write ~s" m)
           (define msg `((num_1 . ,tag-number) (field-sym . ,(field-accessor-id m)) ...))
           ({~? unparser-proc default-unparser-id} msg out)
           (flush-output out))
         (hash-set! *message-readers* tag-number read-message-id))]))

(define-message Error
  ([message Str_1])
  #:tag #x10)

(define-message Plate
  ([plate PlateStr_1]
   [timestamp Timestamp_1])
  #:tag #x20)

(define-message Ticket
  ([plate PlateStr_1]
   [road Road_1]
   [mile1 Mile_1]
   [timestamp1 Timestamp_1]
   [mile2 Mile_2]
   [timestamp2 Timestamp_2]
   [speed Speed_1])
  #:tag #x21)

(define-message WantHeartbeat
  ([interval Interval_1])
  #:tag #x40)

(define-message Heartbeat ()
  #:tag #x41
  #:unparser (λ (_ out)
               (write-byte #x41 out)
               (flush-output out)))

(define-message Camera
  ([road Road_1]
   [mile Mile_1]
   [limit Limit_1])
  #:tag #x80
  #:parser proto:IAmCamera
  #:unparser proto:un-IAmCamera)

(define-message Dispatcher
  ([roads Road_1])
  #:tag #x81
  #:parser proto:IAmDispatcher
  #:unparser proto:un-IAmDispatcher)

(define (read-message in)
  (match (peek-byte in)
    [(? eof-object?) eof]
    [tag-number
     (with-handlers ([exn:fail?
                      (λ (e)
                        (begin0 #f
                          (log-protohackers-error "failed to read message with tag ~s: ~a" tag-number (exn-message e))))])
       ((hash-ref *message-readers* tag-number) in))]))

(define (write-message m out)
  (((message-writer m)) m out))

(define (write-message* m out)
  (with-handlers ([exn:fail?
                   (λ (e)
                     (log-protohackers-warning "failed to write message: ~s~n  error: ~a" m (exn-message e)))])
    (write-message m out)))

(define (write-error msg out)
  (write-message* (Error (string->bytes/utf-8 msg)) out))
```

The `define-message` form generates a struct with the given fields, a
reader procedure that parses data off of a port and destructures it
onto a struct instance and a writer procedure that does the reverse.
It then registers the reader procedure with the global read registry
by tag and associates the write procedure with the struct using a
custom struct type property.

The `read-message` and `write-message` procedures use the
aforementioned registry and struct type property to generically read
and write messages.

### Dispatcher

Similar to challenge 3, we keep track of shared state using an actor
implemented with a thread and a channel.

``` racket
(struct dispatcher (ch thd))

(define (make-dispatcher)
  (define ch (make-channel))
  (define thd
    (thread
     (lambda ()
       (let loop ([st (make-state)])
         (let-values ([(tickets ticketed-st) (get-tickets st)])
           (cond
             [(null? tickets)
              (apply
               sync
               (handle-evt
                ch
                (lambda (msg)
                  (log-protohackers-debug "handling dispatcher message: ~s" msg)
                  (match msg
                    [`(add-port ,out ,res-ch ,nack)
                     (define-values (id next-st)
                       (add-port st out))
                     (loop (add-request next-st `(,id ,res-ch ,nack)))]
                    [`(add-dispatcher ,id ,roads ,res-ch ,nack)
                     (loop (~> (add-dispatcher st id roads)
                               (add-request `(ok ,res-ch ,nack))))]
                    [`(remove-port ,id ,res-ch ,nack)
                     (loop (~> (remove-port st id)
                               (add-request `(ok ,res-ch ,nack))))]
                    [`(update-heartbeat ,id ,interval ,res-ch ,nack)
                     (loop (~> (update-heartbeat st id interval)
                               (add-request `(ok ,res-ch ,nack))))]
                    [`(snap ,plate-number ,road ,mile ,limit ,timestamp ,res-ch ,nack)
                     (loop (~> (track-plate st plate-number road mile limit timestamp)
                               (add-request `(ok ,res-ch ,nack))))]
                    [_
                     (log-protohackers-error "unexpected dispatcher message: ~s~n" msg)])))
               (handle-evt
                (heartbeat-evt st)
                (lambda (id interval)
                  (define out (ref-port st id))
                  (write-message* (Heartbeat) out)
                  (loop (update-heartbeat st id interval))))
               (append
                (for/list ([req (in-list (state-requests st))])
                  (match-define `(,res ,res-ch ,_) req)
                  (handle-evt
                   (channel-put-evt res-ch res)
                   (lambda (_)
                     (loop (remove-request st req)))))
                (for/list ([req (in-list (state-requests st))])
                  (match-define `(,_ ,_ ,nack) req)
                  (handle-evt nack (λ () (loop (remove-request st req)))))))]
             [else
              (for ([ticket (in-list tickets)])
                (define road (Ticket-road ticket))
                (define id (random-ref (hash-ref (state-dispatchers st) road)))
                (define out (ref-port st id))
                (write-message* ticket out))
              (loop ticketed-st)]))))))
  (dispatcher ch thd))

(define (make-dispatcher-evt d command . args)
  (match-define (dispatcher ch thd) d)
  (define res-ch (make-channel))
  (nack-guard-evt
   (lambda (nack)
     (begin0 res-ch
       (thread-resume thd (current-thread))
       (channel-put ch `(,command ,@args ,res-ch ,nack))))))
```

The actor receives messages on a channel and updates its internal
state accordingly, checking to see if it has to dispatch any tickets
after every update.  When it has tickets to dispatch, it first writes
them all out to their destination dispatchers and then resumes
handling messages.

The actor's state is implemented using a set of structs and several
functions that operate on them:

``` racket
(struct heartbeat (deadline interval))
(struct observation (mile limit timestamp) #:transparent)
(struct plate (observations-by-road ticket-days) #:transparent)
(struct state
  (id-seq      ;; nonnegative-integer
   ports       ;; id -> output-port
   heartbeats  ;; id -> heartbeat
   dispatchers ;; road -> listof id
   plates      ;; plate-number -> listof plate
   requests    ;; listof (res res-ch nack)
   )
  #:transparent)

(define (make-plate)
  (plate (hasheqv) ;; observations-by-road
         (hasheqv) ;; ticket-days
         ))

(define (add-observation p road obs)
  (match-define (plate roads _) p)
  (define next-roads
    (hash-update
     roads road
     (λ (obss)
       (cons obs obss))
     null))
  (struct-copy plate p [observations-by-road next-roads]))

(define (add-ticket-days p timestamp1 timestamp2)
  (define ticket-days
    (for/fold ([ticket-days (plate-ticket-days p)])
              ([d (in-range (->day timestamp1)
                            (add1 (->day timestamp2)))])
      (hash-set ticket-days d #t)))
  (struct-copy plate p [ticket-days ticket-days]))

(define (ticketed-on? p timestamp)
  (hash-has-key?
   (plate-ticket-days p)
   (->day timestamp)))

(define (make-state)
  (state 0         ;; id-seq
         (hasheqv) ;; ports
         (hasheqv) ;; heartbeats
         (hasheqv) ;; dispatchers
         (hash)    ;; plates
         null      ;; requests
         ))

(define (add-port st out)
  (define id (state-id-seq st))
  (values id (struct-copy state st
                          [id-seq (add1 id)]
                          [ports (hash-set (state-ports st) id out)])))

(define (ref-port st id)
  (hash-ref (state-ports st) id))

(define (remove-port st id)
  (struct-copy state st
               [ports (hash-remove (state-ports st) id)]
               [heartbeats (hash-remove (state-heartbeats st) id)]
               [dispatchers (for/hash ([(road ids) (in-hash (state-dispatchers st))])
                              (values road (remq id ids)))]))

(define (update-heartbeat st id interval)
  (cond
    [(zero? interval)
     (struct-copy state st [heartbeats (hash-remove (state-heartbeats st) id)])]
    [else
     (define beat (heartbeat (+ (current-inexact-monotonic-milliseconds) interval) interval))
     (struct-copy state st [heartbeats (hash-set (state-heartbeats st) id beat)])]))

(define (heartbeat-evt st)
  (define heartbeats
    (state-heartbeats st))
  (cond
    [(hash-empty? heartbeats)
     never-evt]
    [else
     (match-define (cons id (heartbeat deadline interval))
       (car (sort (hash->list (state-heartbeats st)) #:key (compose1 heartbeat-deadline cdr) <)))
     (handle-evt
      (alarm-evt deadline #t)
      (lambda (_)
        (values id interval)))]))

(define (add-dispatcher st id roads)
  (define next-dispatchers
    (for/fold ([dispatchers (state-dispatchers st)])
              ([road (in-list roads)])
      (hash-update dispatchers road (λ (ids) (cons id ids)) null)))
  (struct-copy state st [dispatchers next-dispatchers]))

(define (track-plate st plate-number road mile limit timestamp)
  (define obs (observation mile limit timestamp))
  (define next-plates
    (hash-update
     (state-plates st) plate-number
     (λ (p) (add-observation p road obs))
     make-plate))
  (struct-copy state st [plates next-plates]))

(define (get-tickets st)
  (define dispatchers (state-dispatchers st))
  (define-values (tickets plates)
    (for*/fold ([tickets null]
                [plates (state-plates st)])
               ([(plate-number p) (in-hash (state-plates st))]
                [(road observations) (in-hash (plate-observations-by-road p))]
                #:unless (null? (hash-ref dispatchers road null)))
      (define sorted-observations
        (sort observations #:key observation-timestamp >))
      (define-values (next-tickets next-plate)
        (for/fold ([tickets tickets] [p p])
                  ([obs2 (in-list sorted-observations)]
                   [obs1 (in-list (cdr sorted-observations))]
                   #:unless (ticketed-on? p (observation-timestamp obs2))
                   #:unless (ticketed-on? p (observation-timestamp obs1))
                   #:unless (= (observation-timestamp obs2)
                               (observation-timestamp obs1)))
          (match-define (observation mile1 limit timestamp1) obs1)
          (match-define (observation mile2 _     timestamp2) obs2)
          (define speed
            (/ (abs (- mile2 mile1))
               (/ (- timestamp2 timestamp1) 3600)))
          (cond
            [(<= speed limit)
             (values tickets p)]
            [else
             (define ticket
               (Ticket plate-number road mile1 timestamp1 mile2 timestamp2 (exact-round (* speed 100))))
             (values
              (cons ticket tickets)
              (add-ticket-days p timestamp1 timestamp2))])))
      (values next-tickets (hash-set plates plate-number next-plate))))
  (values tickets (struct-copy state st [plates plates])))

(define (add-request st req)
  (struct-copy state st [requests (cons req (state-requests st))]))

(define (remove-request st req)
  (struct-copy state st [requests (remq req (state-requests st))]))

(define (->day ts)
  (quotient ts 86400))
```

This makes it easy to test the state and ticketing implementation in
isolation:

``` racket
(module+ test
  (require racket/port
           rackunit)
  (define (get-tickets* st)
    (define-values (tickets _)
      (get-tickets st))
    tickets)
  (check-equal?
   (get-tickets* (make-state))
   null)
  (check-equal?
   (~> (make-state)
       (track-plate "ABC" 1 0 80 0)
       (track-plate "ABC" 1 80 80 3600)
       (get-tickets*))
   null
   "within limit")
  (check-equal?
   (~> (make-state)
       (track-plate "ABC" 1 0 80 0)
       (track-plate "ABC" 1 80 80 1800)
       (get-tickets*))
   null
   "speed exceeded but no dispatcher")
  (check-equal?
   (let*-values ([(st) (make-state)]
                 [(id st) (add-port st (open-output-nowhere))])
     (~> (add-dispatcher st id '(1))
         (track-plate "ABC" 1 0 80 0)
         (track-plate "ABC" 1 80 80 1800)
         (get-tickets*)))
   (list (Ticket "ABC" 1 0 0 80 1800 16000))
   "speed exceeded with dispatcher")
  (check-equal?
   (let*-values ([(st) (make-state)]
                 [(id st) (add-port st (open-output-nowhere))]
                 [(_tickets st)
                  (~> (add-dispatcher st id '(1))
                      (track-plate "ABC" 1 0 80 0)
                      (track-plate "ABC" 1 80 80 1800)
                      (get-tickets))]
                 [(tickets _st)
                  (~> (track-plate st "ABC" 1 160 80 3600)
                      (get-tickets))])
     tickets)
   null
   "speed exceeded twice in same day")
  (check-equal?
   (let*-values ([(st) (make-state)]
                 [(id st) (add-port st (open-output-nowhere))]
                 [(_tickets st)
                  (~> (add-dispatcher st id '(1))
                      (track-plate "ABC" 1 0 80 0)
                      (track-plate "ABC" 1 80 80 1800)
                      (get-tickets))]
                 [(tickets _st)
                  (~> (track-plate st "ABC" 1 16000 80 86400)
                      (track-plate "ABC" 1 32000 80 (* 2 86400))
                      (get-tickets))])
     tickets)
   (list (Ticket "ABC" 1 16000 86400 32000 172800 66667))
   "speed exceeded next day"))
```

I'm using functional updates to alter the state between actor ticks.
This is fine for the purposes of this challenge, but if performance
were to become an issue, I'd probably switch to a mutable
implementation.

The challenge is unclear on what should happen should an observation
arrive arbitrarily late, so we keep all observations around
perpetually.  In a real system, we'd want to expire these.

### Server

The server implementation simply accepts connections and sends
messages to the dispatcher on their behalf.

``` racket
(define-syntax-rule (send d command . args)
  (sync (make-dispatcher-evt d 'command . args)))

(define ((make-handler d) in out)
  (define id (send d add-port out))
  (dynamic-wind
    void
    (lambda ()
      (let loop ([ob #f])
        (match (read-message in)
          [(? eof-object?)
           (void)]
          [(? Camera? camera)
           #:when (not ob)
           (loop camera)]
          [(and (Dispatcher roads) dispatcher)
           #:when (not ob)
           (send d add-dispatcher id roads)
           (loop dispatcher)]
          [(WantHeartbeat interval)
           (send d update-heartbeat id (* (/ interval 10.0) 1000))
           (loop ob)]
          [(Plate plate-number timestamp)
           #:when (Camera? ob)
           (match-define (Camera road mile limit) ob)
           (send d snap plate-number road mile limit timestamp)
           (loop ob)]
          [_
           (write-error "unexpected message" out)])))
    (lambda ()
      (send d remove-port id))))

(module+ main
  (require "common.rkt")
  (run-server* "0.0.0.0" 8111 (make-handler (make-dispatcher))))
```

Every new client is registered with the dispatcher and receives a
unique id.  We use `dynamic-wind` to ensure that each client is
deregistered on failure or on connection close.

That's all I have for this post.  As before, you can find these
solutions in full on [GitHub].

[Protohackers]: https://protohackers.com/
[binfmt]: https://docs.racket-lang.org/binfmt-manual/index.html
[GitHub]: https://github.com/Bogdanp/racket-protohackers
