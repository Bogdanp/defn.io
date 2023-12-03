#lang punct "../common.rkt"

---
title: Advent of Racket 2023/03 - Gear Ratios
date: 2023-12-03T10:00:00+02:00
---

Let's get right into [day three]. The first part of the puzzle today
is to find any numbers adjacent to a non-numeric, non-period symbol in
a table and add them all up. The example input looks like this:

```
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..
```

The first thing I did was count the number of columns and rows. I
noticed the example input was a square, so I took a peek at my own input
and it, too, was square. So, I decided to read the whole input into a
unidimensional vector:

```racket
(define table
  (call-with-input-file "day03.txt"
    (lambda (in)
      (for*/vector ([line (in-lines in)]
                    [char (in-string line)])
        char))))
```

Since we're going to be looking for adjacent positions, we need to
know what the table's stride is. Since the input table is square,
that's easy:

```racket
(define s (sqrt (vector-length table)))
(define -s (- s))
```

Next, we can define a function to match special symbols:

```racket
(define (engine-symbol? c)
  (and (not (eqv? c #\.))
       (not (char-numeric? c))))
```

And a function to determine if a position has any adjacent special
symbols:

```racket
(define (has-adjacent? t pos [ok? engine-symbol?])
  (for*/first ([d (in-list (list (- -s 1) -s (+ -s 1)
                                      -1           1
                                 (-  s 1)  s (+  s 1)))]
               [idx (in-value (+ pos d))]
               #:when (and (>= idx 0)
                           (<  idx (vector-length t))
                           (ok? (vector-ref t idx))))
    idx))
```

For any given index into the table, `has-adjacent?` checks its 8
adjacent indexes for a position for which `ok?` returns `#t`,
returning the first match or `#f` if no matches are found.

To compute part one, all we have to do is iterate over the table,
piece any run of digits into a number and add any number for which
we've found an adjacent symbol to the total:

```racket
(for/fold ([num 0]
           [ok? #f]
           [total 0]
           #:result (if ok? (+ num total) total))
          ([(c idx) (in-indexed (in-vector table))])
  (if (char-numeric? c)
      (values (+ (* num 10) (char->decimal c))
              (or ok? (has-adjacent? table idx))
              total)
      (values 0 #f (if ok? (+ num total) total))))
```

The one edge case to watch out for here is that a table may end in a
number, so we need to make sure the final result accounts for that and
add the last-collected number to the total if necessary. That case is
covered by the `#:result` clause above.

As in day two, the second part of today's puzzle flips the problem on
its head and asks us to instead find any two numbers that are adjacent
to a `*` symbol, multiply them together and sum them up.

To solve part two, we can just iterate over the table and whenever
we see a `*` symbol, check if it has any adjacent numbers. If it has
exactly two of them, we can multiply them together and add them to the
total. It would be nice if we had a variant of `has-adjacent?` that
returns the indexes of adjacent symbols, so let's go ahead and write
that function:

```racket
(define-syntax-rule (define-finder id for*-id)
  (define (id t pos [ok? engine-symbol?])
    (for*-id ([d (in-list (list (- -s 1) -s (+ -s 1)
                                     -1           1
                                (-  s 1)  s (+  s 1)))]
              [idx (in-value (+ pos d))]
              #:when (and (>= idx 0)
                          (<  idx (vector-length t))
                          (ok? (vector-ref t idx))))
      idx)))

(define-finder find-adjacent for*/list)
(define-finder has-adjacent? for*/first)
```

I wanted to preserve the short-circuiting behavior of `has-adjacent?`,
so I decided to abstract over its implementation using a macro. In this
case, the `define-finder` macro lets us plug in different for loop
behaviors into the same implementation. So, `find-adjacent` works the
same way as `has-adjacent?`, but it returns all the adjacent positions
for which `ok?` is true instead of just the first one.

One problem to consider, though, is that a symbol may be adjacent to
multiple digits belonging to the same number. For example:

```
123
.*.
456
```

Given the above example, the `find-adjacent` procedure would return the
position of every digit surrounding the `*` symbol. So, we need a way
get the numbers at a given set of positions that is aware of this issue
and skips redundant positions.

```racket
; invariant: indexes always start out as valid digit positions in the table
(define (get-numbers t is)
  (let loop ([is is]
             [nums null])
    (cond
      [(null? is) nums]
      [else
       (define-values (num rem-is)
         (let get-number ([i (car is)])
           (if (or (< i 0)
                   (not (char-numeric? (vector-ref t i))))
               (for/fold ([n 0] [rem-is is])
                         ([(c idx) (in-indexed (in-vector t (add1 i)))])
                 #:break (not (char-numeric? c))
                 (values
                  (+ (* n 10) (char->decimal c))
                  (remq (+ (add1 i) idx) rem-is)))
               (get-number (sub1 i)))))
       (loop rem-is (cons num nums))])))
```

The `get-numbers` procedure takes a table and a list of indexes into
that table. It then tries the indexes in order and walks backwards from
each index to find the start of a number, then it reads the number
forwards, removing any indexes that it sees along the way from the
pending list of indexes, and collecting the numbers into a list.

```
> (define t
    (vector #\1 #\2 #\.
            #\3 #\4 #\.))
> (get-numbers t '())
'()
> (get-numbers t '(0))
'(12)
> (get-numbers t '(1))
'(12)
> (get-numbers t '(0 1))
'(12)
> (get-numbers t '(0 1 3))
'(34 12)
> (get-numbers t '(0 1 3 4))
'(34 12)
```

With `find-adjacent` and `get-numbers` in hand, we can just iterate
over the table and compute the result:

```racket
(for/fold ([total 0])
          ([(c idx) (in-indexed (in-vector table))]
           #:when (eqv? c #\*))
  (define adjacent-numbers
    (get-numbers table (find-adjacent table idx char-numeric?)))
  (if (= (length adjacent-numbers) 2)
      (+ total (apply * adjacent-numbers))
      total))
```

Any time we see a `*`, we find all the adjacent numeric positions and
get the numbers at those positions. If we have exactly two adjacent
numbers, then we multiply them together and add them to the sum. Easy
peasy.

[day three]: https://adventofcode.com/2023/day/3
