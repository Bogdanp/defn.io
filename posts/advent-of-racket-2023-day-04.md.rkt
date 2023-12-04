#lang punct "../common.rkt"

---
title: Advent of Racket 2023/04 - Scratchcards
date: 2023-12-04T10:00:00+02:00
---

[Day four] starts out very simple. We're given an input where we have
two lists of numbers per line. Per line (or "card"), we get one point
for the first number in the second list that is also found in the first,
and the score doubles for every subsequent match. The example input
looks like this:

```
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
```

Since part one seemed a little too easy, I decided to parse the input
into a struct, in anticipation of a harder part two.

```racket
;; id : int
;; winning : listof int
;; have : listof int
(struct card (id winning have)
  #:transparent)
```

Parsing the cards is straightforward enough, though I did spend a
minute scratching my head because I forgot to escape the `|`
character:

```
(define cards
  (call-with-input-file "day04.txt"
    (lambda (in)
      (for/vector ([line (in-lines in)])
        (match-define (regexp #rx"Card +([0-9]+): ([^|]+) \\| (.+)"
                              (list _ (app string->number id) winning-str have-str))
          line)
        (card
         id
         (map string->number (string-split winning-str))
         (map string->number (string-split have-str)))))))
```

I had originally stored the set of cards as a list, but changed it to a
vector for part two. We'll see why in a bit. In the mean time, computing
part one is just a matter of determining the number of matches in each
card:

```racket
(define (card-matches c)
  (for/sum ([n (in-list (card-have c))]
            #:when (memv n (card-winning c)))
    1))
```

And computing the score per card:

```racket
(define (card-score c)
  (define matches
    (card-matches c))
  (cond
    [(zero? matches) 0]
    [else (expt 2 (sub1 matches))]))
```

Putting those functions together, we get:

```racket
(define part1
  (for/sum ([c (in-vector cards)])
    (card-score c)))
```

For part two, the problem goes exponential. For every card, the number
of matches that we find represents subsequent cards that we have to
check for matches. We have to recursively add up all the cards we see.

We need a function that returns the won cards for any given card:

```racket
(define (card-wins c)
  (match-define (card id _winning _have) c)
  (for/list ([i (in-range 0 (card-matches c))])
    (vector-ref cards (+ id i))))
```

This function is the reason why I stored the cards as a vector earlier
on. With this function in hand, we can now write a function to compute
the number of cards seen when starting from any given card:

```racket
(define (add-counts cs)
  (apply hash-union cs #:combine +))

(define (card-counts c)
  (add-counts
   (list*
    (hasheqv (card-id c) 1)
    (map card-counts (card-wins c)))))
```

Running `card-counts` on the first card in the example input yields:

```racket
> (card-counts (vector-ref cards 0))
'#hasheqv((1 . 1) (2 . 1) (3 . 2) (4 . 4) (5 . 7))
```

To compute the result for part two we just have to add up all the
counts for all the cards we have:

```racket
(apply + (hash-values
          (add-counts
           (for/list ([c (in-vector cards)])
             (card-counts c)))))
```

This works fine for the example input, but the real input is much larger
and requires many more iterations. The trick to notice here is that
calling `card-counts` on an individual card will always return the same
result, so we can simply memoize the result for every card and greatly
reduce the number of iterations required to compute the solution.

All we have to do is change `card-counts` to:

```racket
(define card-counts
  (let ([memo (make-hasheqv)])
    (lambda (c)
      (hash-ref!
       memo (card-id c)
       (lambda ()
         (add-counts
          (list*
           (hasheqv (card-id c) 1)
           (map card-counts (card-wins c)))))))))
```

The `memo` hash keeps a mapping of card ids to the number of cards
seen when starting from that card. If a card's id is already in the
hash, we return its associated value, otherwise we compute the result
and store it in the hash for subsequent lookups.

That's it for day four!

[Day four]: https://adventofcode.com/2023/day/4
