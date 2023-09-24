#lang punct "../common.rkt"

---
title: Racketeering Gophers
date: 2020-11-17T12:30:00+02:00
---

•(haml
  (:center
   (img "rocketeering-gopher.svg" "rocketeering gopher")
   (:br)
   (:p (:em "Close enough."))))

I've been working on a [Wasm] implementation [in Racket][racket-wasm]
for the past couple of weeks and have recently reached a neat
milestone.

I can take this Go program,

```go
package main

import (
	"log"
	"net/http"
)

func main() {
	log.Println("GETing https://defn.io...")
	resp, err := http.Get("https://defn.io")
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()
	log.Println(resp.Status)
}
```

compile it to Wasm

    $ env GOARCH=wasm GOOS=js go build -o http.wasm http.go

and end up with a 7MiB Wasm file

    -rwxr-xr-x  1 bogdan  staff   7.1M Nov 17 12:43 http.wasm*

that this Racket program can run:

```racket
#lang racket/base

(require wasm/private/binary
         wasm/private/validation
         wasm/private/vm
         "go-runtime.rkt")

;; Read the module.
(define m (call-with-input-file "http.wasm" read-wasm))

;; Typecheck.
(define-values (valid? error-message)
  (mod-valid? m))
(unless valid? (error error-message))

;; Create an interpreter.
(define v (make-vm m (hash "go" *go*)))

;; Grab the entrypoint and run it.
;; run(argc, argv)
(define run (vm-ref v "run" #f))
(parameterize ([current-vm v])
  (run 0 0))
```

```
$ racket run.rkt
2020/11/17 12:48:19 GETing https://defn.io...
2020/11/17 12:48:19 200 OK
```

Tada!  The compiled Go code requires some runtime support that's
specific to it, which is where the [`go-runtime.rkt`][go-runtime]
module above comes in.  I've only implemented the parts of the Go
runtime support that I needed to get the above program to work and
that code is pretty bad, but it gets the job done as a test for the
Wasm implementation.

There's still a lot to do until this is ready to be used by others
(note the lack of any sort of public API or documentation so far), but
I thought this was a cool little result worth sharing.

[Wasm]: https://webassembly.org/
[racket-wasm]: https://github.com/bogdanp/racket-wasm
[go-runtime]: https://gist.github.com/Bogdanp/c4754c49dad09612a0bc3f84b342644b


•(haml (:hr))

Credit: _Rocketeering Gopher_ by [Egon Elbre on GitHub][gophers].

[gophers]: https://github.com/egonelbre/gophers
