#lang punct "../common.rkt"

---
title: Advent of Racket 2023/06 - Wait For It
date: 2023-12-06T10:00:00+02:00
---

A really quick one [today]. The example input looks like this:

```
Time:      7  15   30
Distance:  9  40  200
```

Every pair of rows represents a race, where the distance is the record
distance so far. By pausing at the beginning of the race we gain one
distance unit per time unit paused, but lose that time unit in the
process. We're to determine the distinct durations we could have paused
for during every race in order to beat the record distance, then
multiply the results.

We can read the races as a list of pairs:

```racket
(define (read-integers in start)
  (map string->number
       (string-split
        (substring (read-line in) start))))

(define races
  (call-with-input-file "day06.txt"
    (lambda (in)
      (define times (read-integers in (string-length "Time:")))
      (define distances (read-integers in (string-length "Distance:")))
      (map cons times distances))))
```

And write a procedure to determine whether or not a given hold time
would beat the record distance:

```racket
(define (win? r hold-time)
  (match-define (cons race-time distance) r)
  (define travel-time
    (- race-time hold-time))
  (> (* hold-time travel-time) distance))
```

Then all we have to do is count the number of times a race could be
won within its allotted time:

```racket
(define (winning-hold-times r)
  (for/sum ([i (in-range (add1 (car r)))]
            #:when (win? r i))
    1))
```

And multiply those counds for every race together:

```racket
(for/fold ([res 1])
          ([r (in-list races)])
  (* res (winning-hold-times r)))
```

For part two, we need to append all the race times and durations
together into one long race. So, instead of interpreting our example
input as three separate races, we need to interpret it as if it were
written without any spaces:

```
Time:      71530
Distance:  940200
```

Let's append the races together into our input for part two:

``` racket
(define one-race
  (let ([m (λ (n) (expt 10 (exact-ceiling (log n 10))))])
    (for/fold ([t 0] [d 0] #:result (cons t d))
              ([r (in-list races)])
      (match-define (cons r-t r-d) r)
      (values (+ (* t (m r-t)) r-t)
              (+ (* d (m r-d)) r-d)))))
```

Finally, we can just call our `winning-hold-times` procedure on the
`one-race` value to find the solution for part two. The input is small
enough to brute force in a couple hundred milliseconds.

If the input for part two were larger, we could use a closed form
solution. We've already expressed a race's solution as:

    x(t - x) > d

Where `x` is the hold time required to beat the record `d`. We can
expand that expression to:

    -x^2 + tx - d > 0

And we can solve for `x` using the [quadratic formula] and get all
possible values of `x` for any given distance:

```racket
(define (winning-hold-times* r)
  (match-define (cons t d) r)
  (define discriminant (sqrt (- (* t t) (* 4 d))))
  (define hi (exact-ceiling (/ (+ t discriminant) 2)))
  (define lo (exact-floor (/ (- t discriminant) 2)))
  (- hi lo 1))
```


[today]: https://adventofcode.com/2023/day/6
[quadratic formula]: https://en.wikipedia.org/wiki/Quadratic_formula
