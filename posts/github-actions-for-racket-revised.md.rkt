#lang punct

---
title: Using GitHub Actions to Test Racket Code (Revised)
date: 2020-05-05T10:00:00+03:00
---

A little over a year ago, I [wrote][old] about how you could use the
GitHub's new-at-the-time Actions feature to test Racket code. A lot
has changed since then, including the release of a completely revamped
version of GitHub Actions and so I thought it was time for an update.

## A Basic Package

Let's say you're working on a Racket package for computing Fibonacci
sequences. Your `main.rkt` module might look something like this:

```racket
#lang racket/base

(require racket/stream)

(provide
 fibs)

(define (fibs)
  (stream*
   1
   1
   (let ([s (fibs)])
     (for/stream ([x (in-stream s)]
                  [y (in-stream (stream-rest s))])
       (+ x y)))))

(module+ test
  (require rackunit)
  (check-equal? (stream->list (stream-take (fibs) 8))
                '(1 1 2 3 5 8 13 21)))
```

You'd like to make it so that every time you push a change to this
package to GitHub the test in this module gets run and you get notified
of any problems that occur. To do that, all you have to do is add a
workflow configuration file under `.github/workflows`. The file can be
called anything you like as long as it ends with the `yml` extension. In
this case you might call it `push.yml`, because its contents will get
run whenever code is pushed to the repository. A basic workflow file
looks like this:

```yml
on:
  - push

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@master
      - name: Install Racket
        uses: Bogdanp/setup-racket@v1.6.1
        with:
          architecture: 'x64'
          distribution: 'full'
          version: '8.2'
      - name: Run Tests
        run: raco test main.rkt
```

This workflow triggers whenever a `push` event occurs within the
repository. When that happens, it'll run through its `jobs` one-by-one.
The `test` job in this workflow sets up a Ubuntu VM where it'll go
through each of its `steps` in order.

The first step uses the [actions/checkout] action to clone the
repository inside the VM. Once checked out, the working directory for
all the subsequent actions will be in the root of the checked-out
repository, unless otherwise specified within a step.

The second step uses my own [Bogdanp/setup-racket] action to install
Racket CS version 8.2 in the VM. This adds the `racket` and `raco`
executables to the `PATH`.

Finally, the last step runs the tests in the `main.rkt` module.


## Installing Dependencies

Say you're not that confident in that one test that you have for the
`fibs` function and you'll like to throw some property-based testing
in the mix.  Your `test` submodule becomes:

```racket
(module+ test
  (require rackcheck
           rackunit)

  (check-property
   (property ([n (gen:integer-in 3 100)])
     (define numbers (stream->list (stream-take (fibs) n)))
     (for ([n (cddr numbers)]
           [y (cdr numbers)]
           [x numbers])
       (check-eqv? (+ x y) n)))))
```

When you push this change, your action will fail because [rackcheck]
won't be installed on the VM.  To work around this, you can update the
`Install Racket` step to tell it to install `rackcheck` for you:

```diff
       - name: Install Racket
         uses: Bogdanp/setup-racket@v1.6.1
         with:
           architecture: 'x64'
           distribution: 'full'
           version: '8.2'
+          packages: 'rackcheck'
       - name: Run Tests
         run: raco test main.rkt
```

A better solution, however, would be to add a `info.rkt` file to your
repository to specify what dependencies your package has:

```racket
#lang info

(define build-deps '("rackcheck" "rackunit-lib"))
```

Then, between the `Install Racket` and the `Run Tests` steps, you can
add another step to install your package into the VM:

```diff
       - name: Install Racket
         uses: Bogdanp/setup-racket@v1.6.1
         with:
           architecture: 'x64'
           distribution: 'full'
           version: '8.2'
+      - name: Install Package and its Dependencies
+        run: raco pkg install --auto --batch
       - name: Run Tests
         run: raco test main.rkt
```

This way, you won't have to worry about updating your workflow every
time you change your dependencies.


## Matrix Testing

At this point you might be fairly confident that your implementation of
`fibs` is correct, but you want to guarantee that it works not only on
Racket CS version 8.2, but also on Racket BC as well. To do this, you
can add a matrix [strategy] to your job, specifying that the job should
be parameterized over the `racket-variant` values:

```diff
 jobs:
   test:
     runs-on: ubuntu-latest
+    strategy:
+      matrix:
+        racket-variant: ['BC', 'CS']
+    name: Test on ${{ matrix.racket-variant }} Racket
     steps:
```

You can then update the install step to be parameterized over the
variant:

```diff
       - name: Install Racket
         uses: Bogdanp/setup-racket@v1.6.1
         with:
           architecture: 'x64'
           distribution: 'full'
+          variant: ${{ matrix.racket-variant }}
           version: '8.2'
```

You can go one step further and also parameterize the versions of Racket
that you want your tests to run on:

```diff
 jobs:
   test:
     runs-on: ubuntu-latest
     strategy:
       matrix:
         racket-variant: ['BC', 'CS']
+        racket-version: ['8.1', '8.2']
     name: Test on ${{ matrix.racket-variant }} Racket
     steps:
```

And then plug that parameter into the install step, as before:

```diff
       - name: Install Racket
         uses: Bogdanp/setup-racket@v1.6.1
         with:
           architecture: 'x64'
           distribution: 'full'
           variant: ${{ matrix.racket-variant }}
+          version: ${{ matrix.racket-version }}
```

Following these steps will make it so that every change you push will
get tested against versions 8.1 and 8.2 of both variants of Racket.

This only scratches the surface of what you can do with GH Actions so,
if you're interested to learn more, I'd recommend reading through the
[docs]. You can find a working example of everything I've mentioned in
this article in [this repo][repo].

[old]: /2019/05/01/github-actions-for-racket
[actions/checkout]: https://github.com/actions/checkout
[Bogdanp/setup-racket]: https://github.com/Bogdanp/setup-racket
[rackcheck]: https://github.com/Bogdanp/rackcheck
[strategy]: https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idstrategy
[docs]: https://help.github.com/en/actions/reference
[repo]: https://github.com/Bogdanp/racket-actions-example
