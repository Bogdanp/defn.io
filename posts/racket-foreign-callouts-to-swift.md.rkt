#lang punct

---
title: Safe Foreign Callouts from Racket to Swift
date: 2023-02-04T13:47:00+02:00
---

In anticipation of working on the Windows & Linux versions of [Franz],
I've wanted to move its auto-update implementation from Swift into
Franz' Racket core.  The reason I implemented the auto-update code in
Swift in the first place is because of the way the Swift part normally
communicates with the Racket part: the core Racket code runs in its
own thread and the Swift part communicates with it asynchronously via
pipes.  So, until a couple of days ago, I didn't have an easy way for
Racket code to trigger the execution of Swift code on its own.

All of the code that handles embedding Racket inside Swift, code
generation and the general communication mechanism is open source and
lives in [Noise], so that's where you can find the full implementation
of the approach I describe in this post (specifically, commits
[`0a585be`] and [`2f6c37e`]).

## Low Level Bits

Swift has its own calling convention, but it supports declaring
procedures (but not closures) as using the C calling convention via
the `@convention(c)` attribute.  For example:

```swift
var add1: @convention(c) (Int) -> Int = { x in x + 1 }
```

This attribute makes it so that you can transparently pass such
procedures around in places where you would normally store C function
pointers.  In my case, though, I didn't want to have to write any C
code to support this functionality.  Instead, I needed to be able to
get the raw pointer addresses of the procedures so that I could
serialize them and send them (over the aforementioned pipes) to the
Racket side.  Thankfully, there is a way to do this in Swift, via
`unsafeBitCast`:

```swift
let ptr = unsafeBitCast(add1, Optional<UnsafeRawPointer>.self)
let addr = Int(bitPattern: ptr!)
```

With a raw pointer in hand, all I have to do is make an RPC to the
Racket side to tell it to register a callout at that pointer's
address.  The Racket side can then take that address and construct a
foreign procedure using its FFI facilities:

```racket
(require ffi/unsafe)

(define add1-type
  (_func _int -> _int))       ;; •1
(define add1
  (let ([p (malloc _intptr)]) ;; •2
    (ptr-set! p _intptr addr) ;; •3
    (ptr-ref p add1-type)))   ;; •4
```

There's no direct way to convert an address to a pointer using the FFI
library.  Instead, I have to allocate a bit of memory (•2), write the
address to that memory (•3) and then read the address out as a foreign
procedure (•4).  Additionally, I have to know what the signature of
that procedure is (•1) to be able to call it later. [^1]

Putting these bits together, I came up with a small abstraction on
[the Racket side][callout-box-impl] to wrap the FFI code needed to
turn a raw address into a foreign procedure:

[callout-box-impl]: https://github.com/Bogdanp/Noise/blob/9dc4b05a6e2fbb390f2bc1d47998d02fdc651827/Racket/noise-serde-lib/unsafe/callout.rkt

```racket
(struct callout-box (type [proc #:mutable])
  #:property prop:procedure (λ (b . args)
                              (define proc (callout-box-proc b))
                              (unless proc
                                (error 'callout-box "procedure not installed"))
                              (apply (callout-box-proc b) args)))

(define (make-callout-box type)
  (callout-box type #f))

(define (callout-box-install! b addr)
  (define p (malloc _intptr))
  (ptr-set! p _intptr addr)
  (set-callout-box-proc! b (ptr-ref p (callout-box-type b))))
```

And, on [the Swift side][callout-swift], I devised a little interface
for installing arbitrary callbacks (on the Swift side) as callouts (on
the Racket side) by using a trampoline (some details, such as locking
around `callbacks`, elided for brevity):

[callout-swift]: https://github.com/Bogdanp/Noise/blob/9dc4b05a6e2fbb390f2bc1d47998d02fdc651827/Sources/NoiseBackend/Callout.swift

```swift
public func installCallback(id: UInt64, proc: @escaping (Data) -> Void) -> Future<String, Void> {
  callbacks[id] = proc
  let ptr = unsafeBitCast(callbackHandler, to: Optional<UnsafeRawPointer>.self)
  let addr = Int(bitPattern: ptr!)
  installCallback(id, addr)  // RPC to Racket
}

fileprivate var callbacks = [UInt64: (Data) -> Void]()
fileprivate let callbackHandler: @convention(c) (UInt64, Int, UnsafePointer<CChar>) -> Void = { id, len, ptr in
  let data = ...  // based on len and ptr
  let proc = callbacks[id]
  proc!(data)
}
```

Whenever `installCallback` is called with a closure, it stores the
closure in a global hash and calls an RPC on the Racket side to
register the `callbackHandler` as the foreign procedure for that
closure.  The callback handler ends up always being the same, which is
a little wasteful, but this keeps the implementation really
straightforward so I'm not too bothered by it.

## Mid Level Bits

You've probably noticed the `id` argument to `installCallback`.  The
Racket and Swift sides need to sync on these ids to know which callout
connects to with callback.  So, on [the Racket side][define-callout]
there is a syntactic form for declaring callouts:

[define-callout]: https://github.com/Bogdanp/Noise/blob/9dc4b05a6e2fbb390f2bc1d47998d02fdc651827/Racket/noise-serde-lib/private/callout.rkt

```racket
(define-callout (hello-cb [name : String] [age : Varint]))
```

The callouts themselves can have arbitrary arguments and the data is
automatically serialized when a callout procedure is executed, which
is why the callback handler's type contains a size and a data pointer
in addition to the callback id.  We'll get to how this works on the
Swift side toward the end of the article.

The [implementation of define-callout][define-callout] is fairly
straightforward.  It starts with the well-known signature for callout
handlers (the prototype of `callbackHandler`):

```racket
(define callout-type
  (_func _int _size _bytes -> _void))
```

Following that, there are some structure definitions to keep track of
the callout metadata at runtime, a global registry for this metadata
(indexed by callout id), and a helper function to perform the
callouts:

```racket
(struct callout-arg (name type))
(struct callout-info ([id #:mutable] name args cbox))
(define callout-infos (make-hasheqv))

(define (do-callout info arg-pairs)
  (define id (callout-info-id info))
  (define cbox (callout-info-cbox info))
  (define bs
    (call-with-output-bytes
     (lambda (out)
       (for ([p (in-list arg-pairs)])
         (write-field (car p) (cdr p) out)))))
  (cbox id (bytes-length bs) bs))
```

The `arg-pairs` argument to `do-callout` is a list of `cons` pairs
that contains the serializable type of each argument and the
argument's runtime value.  It takes those arguments, serializes them
into a byte string and then executes the callout using the callout's
id and the serialized data.

The definition of `define-callout` itself is as follows (with a couple
small details simplified):

```racket
(define-syntax (define-callout stx)
  (syntax-parse stx
    #:literals (:)
    [(_ (name:id [arg-name:id : arg-type:expr] ...+))
     #:fail-unless (valid-name-stx? #'name)
     "callout names may only contain alphanumeric characters, dashes and underscores"
     #'(begin
         (define (name arg-name ...) ;; •1
           (do-callout info (list (cons (->field-type 'Callout arg-type) arg-name) ...)))
         (define args
           (for/list ([n (in-list (list 'arg-name ...))]
                      [t (in-list (list arg-type ...))])
             (callout-arg n (->field-type 'Callout t))))
         (define cbox
           (make-callout-box callout-type))
         (define info ;; •2
           (callout-info #f 'name args cbox))
         (hash-set! callout-infos (next-callout-id!) info) ;; •3
         )]))
```

Every use of `define-callout` expands to a definition of a procedure
with the given name (•1) that delegates to the `do-callout` helper
when it itself is called and a metadata definition for the callout
that is registered with the global registry (•2, •3).

Finally, the RPC to install these callbacks that I mentioned at the
end of the first section looks like this:

```racket
(define-rpc (install-callback [internalWithId id : UVarint]
                              [andAddr addr : Varint])
  (define cbox (callout-info-cbox (hash-ref callout-infos id)))
  (callout-box-install! cbox addr))
```

When applied, it looks up the runtime info for the callout with the
given id, extracts its box and installs the procedure at that address
into the box.

## High Level Bits

You might be wondering why the `callout-info` needs to remember the
argument types for the callout, since we never used them again above.
This leads us to the final piece of this system, namely the code
generation part.

Noise generates Swift code to handle data type serialization and
deserialization, RPCs and, now, callouts.  To do this, it uses that
same runtime callout metadata described above.

When generating the `Backend` class for a project, it produces methods
for all the RPCs and then it turns to callouts, the code for which
looks like this:

```racket
(define sorted-callout-ids (sort (hash-keys callout-infos) <))
(for ([id (in-list sorted-callout-ids)])
  (match-define (callout-info _ name args _cbox)
    (hash-ref callout-infos id))
  (define proc-name (~name name))
  (define proc-type
    (format "@escaping (~a) -> Void"
            (string-join
             (map (compose1 swift-type callout-arg-type) args)
             ", ")))
  (fprintf out "~n")
  (fprintf out "  public func installCallback(~a proc: ~a) -> Future<String, Void> {~n" proc-name proc-type)
  (fprintf out "    return NoiseBackend.installCallback(id: ~a, rpc: self.installCallback(internalWithId:andAddr:)) { inp in~n" id)
  (fprintf out "      var buf = Data(count: 8*1024)~n")
  (fprintf out "      proc(~n")
  (define last-idx (sub1 (length args)))
  (for ([(arg idx) (in-indexed (in-list args))])
    (match-define (callout-arg _name type) arg)
    (define maybe-comma (if (= idx last-idx) "" ","))
    (fprintf out "        ~a.read(from: inp, using: &buf)~a~n" (swift-type type) maybe-comma))
  (fprintf out "      )~n")
  (fprintf out "    }~n")
  (fprintf out "  }~n"))
```

That is, for every known callout, it generates a Swift method named
`installCallback(calloutName:)`.  To give a concrete example, here is
what the installer for the `hello-cb` example from earlier in this
article would look like:

```swift
public func installCallback(helloCb proc: @escaping (String, Varint) -> Void) -> Future<String, Void> {
  return NoiseBackend.installCallback(id: 0, rpc: self.installCallback(internalWithId:andAddr:)) { inp in
    var buf = Data(count: 8*1024)
    proc(
      String.read(from: inp, using: &buf),
      Varint.read(from: inp, using: &buf)
    )
  }
}
```

Which you would use from the Swift side like so:

```swift
Backend.shared.installCallback(helloCb: { name, age in
  print("hello \(name), I hear you're \(age) years old!")
})
```

And you would call from the Racket side like so:

```racket
(hello-cb "Bogdan" 30)
```

And you wouldn't need to worry about most of the details I've written
about above.

[Franz]: https://franz.defn.io
[Noise]: https://github.com/Bogdanp/noise
[`0a585be`]: https://github.com/Bogdanp/Noise/commit/0a585be4f7816144f4943a996b58fd27ab5e2d2e
[`2f6c37e`]: https://github.com/Bogdanp/Noise/commit/2f6c37e0d26d13f84e1e68650c4bca76cae0bfae

[^1]: [Sam Phillips] pointed out on the Racket Discord that there is
    actually a helper for this in `ffi-lib`, namely [`cast`].  So this
    `let` can be replaced with `(cast addr _intptr add1-type)`.

[Sam Phillips]: https://github.com/samdphillips
[`cast`]: https://docs.racket-lang.org/foreign/Miscellaneous_Support.html#%28def._%28%28lib._ffi%2Funsafe..rkt%29._cast%29%29
