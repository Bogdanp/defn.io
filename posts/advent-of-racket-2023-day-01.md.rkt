#lang punct "../common.rkt"

---
title: Advent of Racket 2023 - Day 01 - Trebuchet?!
date: 2023-12-01T10:00:00+02:00
---

The 2023 [Advent of Code] advent calendar has started and I'm doing it
in [Racket] again this year. I'll probably stick with it for a couple
of weeks or until the puzzles start taking me more than 10-15 minutes
to finish. I've also decided to write some short posts about [my
solutions][repo], so here's the first one.

The first part of [today][day01]'s challenge is to take a list of
strings, combine the first and last decimal digit in each string into a
decimal number and sum them all up. The example input looks like:

```
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
```

In Racket, we can open a file as an input port using
•rkt[call-with-input-file] and iterate over its lines using
•rkt[in-lines].

```racket
(call-with-input-file "day01.txt"
 (lambda (in)
   (for/sum ([line (in-lines in)])
     ...)))
```

The •rkt[for/sum] variant of •rkt[for] returns the sum of all
intermediate iteration results. With the above skeleton in place, all
we have to do is extract the first and last digit in every line and
convert them to a number (the so-called "calibration value" in the
problem statement).

We're going to need to convert characters to digits, so let's first
write a helper procedure to do that.

```racket
(define (get-digit s i)
  (define c (string-ref s i))
  (and (char-numeric? c)
       (- (char->integer c)
          (char->integer #\0))))
```

The `get-digit` procedure takes a string and an index into that string,
grabs the character at the given index and converts it into a decimal
digit if it is numeric. We're only interested in the ASCII character set
for this particular problem, so there's no need to worry about other
unicode numerals.

Next, we can define the procedure to extract the calibration value
from a line.

```racket
(define (calibration-value s)
  (define-values (d0 d1)
    (for/fold ([d0 #f]
               [d1 #f])
              ([i (in-range 0 (string-length s))])
      (define digit (get-decimal-digit s i))
      (values (or d0 digit)
              (or digit d1))))
  (+ (* d0 10) d1))
```

It uses the •rkt[for/fold] form to iterate over all the indices in a
given string and keep track of the first and last-seen digits. Finally,
it combines the two digits into a decimal number.

We can plug the two helpers into our skeleton to solve part one:

```racket
(call-with-input-file "day01.txt"
  (lambda (in)
    (for/sum ([line (in-lines in)])
      (calibration-value line))))
```

For part two, we get a new example and the puzzle gets a little bit
harder. We now need to account for digits that are spelled out on each
line. The example input looks like:

```
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen
```

As in the first part, let's first write a helper to extract digits out
of a string.

```racket
(define digit-rxs
  (for/list ([s (in-list '(zero one two three four five six seven eight nine))])
    (regexp (format "^~a" s))))

(define (get-spelled-out-digit s i)
  (or
   (for/first ([(rx n) (in-indexed (in-list digit-rxs))]
               #:when (regexp-match? rx s i))
     n)
   (get-decimal-digit s i)))
```

Like `get-decimal-digit`, the `get-spelled-out-digit` procedure takes
a string and a starting index into that string. It then iterates over
a list of regular expressions to return the index of the first match.
The •rkt[regexp-match?] procedure takes an optional starting index that
tells it where in the given string it should start matching from[^1]. If
none of the regular expressions match, the •rkt[for/first] form produces
`#f` and we fall back to the `get-decimal-digit` procedure.

Now, we can update `calibration-value` to take its digit-extracting
procedure as an argument instead of calling `get-decimal-digit`
directly.

```racket
(define (calibration-value s [get-digit get-decimal-digit])
  (define-values (d0 d1)
    (for/fold ([d0 #f]
               [d1 #f])
              ([i (in-range 0 (string-length s))])
      (define digit (get-digit s i))
      (values (or d0 digit)
              (or digit d1))))
  (+ (* d0 10) d1))
```

Since the `get-digit` argument to `calibration-value` defaults to
`get-decimal-digit`, we don't need to change our solution to part one
to account for this refactoring. The solution to part two is the same
as part one, but we pass the `get-spelled-out-digit` procedure to
`calibration-value`:

```racket
(call-with-input-file "day01.txt"
  (lambda (in)
    (for/sum ([line (in-lines in)])
      (calibration-value line get-spelled-out-digit))))
```

That's it for day one!

[Advent of Code]: https://adventofcode.com
[Racket]: https://racket-lang.org
[repo]: https://github.com/Bogdanp/aoc2023
[day01]: https://adventofcode.com/2023/day/1

[^1]: Why not just pass in a substring? I prefer to avoid copying
    where possible and many Racket built-ins that work on sequences
    support this pattern of passing in beginning and end indices.
