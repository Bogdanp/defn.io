#lang punct "../common.rkt"

---
title: Advent of Racket 2023/05 - Fertilizer
date: 2023-12-05T10:00:00+02:00
---

The example input for [day five] looks like this:

```
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4
```

The `seeds` line contains the set of inputs we're supposed to pass
through the given maps and each map feeds into the next. The entries in
a map represent the ranges of values that can be converted by the map.
Values outside the given ranges are passed through unchanged. After
feeding every seed value through all the maps, we need to report the
minimum value that comes out the other end.

I decided to make a struct to represent the individual ranges in a map:

```racket
(struct mapping (dst src len)
  #:transparent)

(define (parse-mapping str)
  (apply mapping (map string->number (string-split str))))
```

```racket
> (parse-mapping "50 98 2")
(mapping 50 98 2)
```

To read a map, we ignore the empty line before its definition, ignore
the line that names the map and then read the ranges until we see an
empty line or reach the end of file:

```racket
(define (read-map in)
  (void (read-line in))
  (void (read-line in))
  (let loop ([mappings null])
    (define c (peek-char in))
    (cond
      [(or (eof-object? c)
           (eqv? c #\newline))
       (reverse mappings)]
      [else
       (loop
        (cons
         (parse-mapping (read-line in))
         mappings))])))
```

We read the initial seeds and then the seven maps. Since the maps feed
into each other, there's no need to keep track of which map is which,
so a list of maps is enough.

```racket
(define-values (seeds maps)
  (call-with-input-file "day05.txt"
    (lambda (in)
      (define seeds
        (map
         string->number
         (string-split
          (substring (read-line in) 6))))
      (values
       seeds
       (for/list ([_ (in-range 7)])
         (read-map in))))))
```

Every map is just a list of `mapping` struct instances and for any given
mapping, we can map a value by checking if it's within the specified
range and adding to it the delta between the `dst` and `src` values:

```racket
(define (mapping-map m v)
  (match-define (mapping dst src len) m)
  (and (>= v src)
       (<= v (+ src len))
       (+  v (- dst src))))
```

Given a set of `mapping`s (i.e. a map), we can write a lookup procedure
that returns the mapped value for any given value:

```racket
(define (look-up mappings v)
  (or
   (for*/first ([m (in-list mappings)]
                [mapped-v (in-value (mapping-map m v))]
                #:when mapped-v)
     mapped-v)
   v))
```

With that, we can write a procedure to run a seed through all the maps:

```racket
(define (find-seed-location maps seed)
  (for/fold ([value seed])
            ([mappings (in-list maps)])
    (look-up mappings value)))
```

And, finally, go through all the seeds and find the minimum location:

```racket
(for/fold ([res +inf.0])
          ([s (in-list seeds)])
  (define loc
    (find-seed-location maps s))
  (if (< loc res) loc res))
```

For part two, we're asked to reinterpret the initial list of seeds as
pairwise ranges of seeds instead of individual seed numbers. So `79 14`
in our initial example now represents the seeds from `79` to `93`. The
actual input is large enough that brute forcing a solution would take
a while.

Instead of iterating over all the seeds in every range, we can split
our ranges against all the mappings in a map, then map the values of
the split ranges and then feed the mapped ranges into the subsequent
maps.

First, let's collect the ranges into a list of pairs:

```racket
(define ranges
  (let loop ([pairs null]
             [seeds seeds])
    (cond
      [(null? seeds)
       (reverse pairs)]
      [else
       (loop
        (cons
         (cons (car seeds)
               (+ (car seeds)
                  (cadr seeds)))
         pairs)
        (cddr seeds))])))
```

```racket
> (car ranges)
(79 . 93)
```

Next, let's write a procedure to split a range for any given mapping:

```racket
(define (mapping-split-range m r)
  (match-define (mapping _dst src len) m)
  (match-define (cons lo hi) r)
  (define src-lo src)
  (define src-hi (+ src len))
  (cond
    [(and (< lo src-lo)
          (< hi src-lo))
     (list r)]
    [(and (> lo src-hi)
          (> hi src-hi))
     (list r)]
    [(and (< lo src-lo)
          (> hi src-hi))
     (list
      (cons lo (sub1 src-lo))
      (cons src-lo src-hi)
      (cons (add1 src-hi) hi))]
    [(< lo src-lo)
     (list
      (cons lo (sub1 src-lo))
      (cons src-lo hi))]
    [(> hi src-hi)
     (list
      (cons lo src-hi)
      (cons (add1 src-hi) hi))]
    [else
     (list
      (cons lo hi))]))
```

And a procedure to map a range for a mapping:

```racket
(define (mapping-map-range m r)
  (define m-lo (mapping-map m (car r)))
  (define m-hi (mapping-map m (cdr r)))
  (and m-lo m-hi (cons m-lo m-hi)))
```

Let's write a procedure to map the ranges for a given set of mappings:

``` racket
(define (map-ranges mappings ranges)
  ;; Split the ranges against all the mappings.
  (define split-ranges
    (let loop ([ranges ranges]
               [mappings mappings])
      (if (null? mappings)
          ranges
          (loop
           (apply append
                  (for/list ([r (in-list ranges)])
                    (mapping-split-range (car mappings) r)))
           (cdr mappings)))))
  ;; Then map the split ranges.
  (for/list ([r (in-list split-ranges)])
    (or
     (for*/first ([m (in-list mappings)]
                  [m-r (in-value (mapping-map-range m r))]
                  #:when m-r)
       m-r)
     r)))
```

And a procedure to feed the ranges through all the maps:

```racket
(define (find-location-ranges maps ranges)
  (for/fold ([ranges ranges])
            ([mappings (in-list maps)])
    (map-ranges mappings ranges)))
```

Finally, we can compute the result for part two by keeping track of the
smallest start value of every funneled range:

```racket
(for*/fold ([res +inf.0])
           ([r (in-list (find-location-ranges maps ranges))])
  (define loc (car r))
  (if (< loc res) loc res))
```

An alternative, and probably less finicky, but less efficient, way to
solve part two would've been to iterate up from 0 and pass the numbers
backwards through the funnel, stopping on the first number that fit in
one of the seed ranges. In my case that approach would've found the
solution in a little under ten million iterations.

[day five]: https://adventofcode.com/2023/day/5
