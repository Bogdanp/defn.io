#lang punct "../common.rkt"

---
title: Advent of Racket 2023/07 - Camel Cards
date: 2023-12-07T10:00:00+02:00
---

Quite a fun one [today]. The example input looks like this:

```
32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483
```

The first column represents a poker hand and the second a bid. We're
to sort the hands, multiply the bid and the hand's rank (its position
after sorting), then sum up the results.

We can read the data as a vector of `(hand . bid)` pairs:


```racket
(define hands
  (call-with-input-file "day07.txt"
    (lambda (in)
      (for/vector ([line (in-lines in)])
        (match-define (regexp #rx"([^ ]+) (.+)"
                              (list _ hand (app string->number bid)))
          line)
        (cons hand bid)))))
```

To compute the type of hand we have, we can count the kinds of cards in
a hand, sort the results and pattern match on them, since each hand is
guaranteed to be of exactly one type:

```racket
(define (hand-counts h)
  (for/fold ([counts (hasheqv)])
            ([c (in-string h)])
    (hash-update counts c add1 0)))

(define (hand-type h)
  (define counts
    (sort
     (hash->list
      (hand-counts h))
     #:key cdr >))
  (match counts
    [`(,_) 'five-of-a-kind]
    [`((,_ . 4) ,_) 'four-of-a-kind]
    [`((,_ . 3) ,_) 'full-house]
    [`((,_ . 3) ,_ ,_) 'three-of-a-kind]
    [`((,_ . 2) (,_ . 2) ,_) 'two-pair]
    [`((,_ . 2) ,_ ,_ ,_) 'one-pair]
    [`(,_ ,_ ,_ ,_ ,_) 'high-card]))
```

Next, let's define a sort order for each type of hand:

```racket
(define (hand-type-numeric h)
  (case (hand-type h)
    [(five-of-a-kind) 6]
    [(four-of-a-kind) 5]
    [(full-house) 4]
    [(three-of-a-kind) 3]
    [(two-pair) 2]
    [(one-pair) 1]
    [(high-card) 0]))
```

In order to break ties, we're going to have to compare individual
cards in a hand, left-to-right. Higher cards beat lower cards. So, we
can define a procedure to get a card's score:

```racket
(define (card-score c)
  (match c
    [#\2 2]
    [#\3 3]
    [#\4 4]
    [#\5 5]
    [#\6 6]
    [#\7 7]
    [#\8 8]
    [#\9 9]
    [#\T 10]
    [#\J 11]
    [#\Q 12]
    [#\K 13]
    [#\A 14]))
```

Finally, we can define a procedure for sorting hands:

```racket
(define (hand> a b)
  (define an (hand-type-numeric a))
  (define bn (hand-type-numeric b))
  (if (= an bn)
      (for/fold ([ok? #t])
                ([ca (in-string a)]
                 [cb (in-string b)])
        (define cas (card-score ca))
        (define cbs (card-score cb))
        #:break (or (> cas cbs)
                    (not ok?))
        (and ok? (= cas cbs)))
      (> an bn)))
```

When there's a tie, we fall back to comparing the cards in both hands
positionally using `card-score`. Otherwise, the better hand wins.

To compute the solution for part one, we can sort the hands then sum
up the winnings for each hand:

```racket
(define (compute-winnings hands [hand> hand>])
  (let ([hands (vector-copy hands)])
    (vector-sort! hands hand> #:key car)
    (for/sum ([(h idx) (in-indexed (in-vector hands))])
      (define rank (- (vector-length hands) idx))
      (* (cdr h) rank))))

(compute-winnings hands)
```

For part two, we need to reinterpret joker cards such that whenever we
compute the hand type for a hand that contains jokers, we have to
replace the jokers in that hand with whatever cards would make it the
best hand it can be. When comparing individual cards, jokers are now
the weakest card type.

Given any hand that contains jokers, we can find the best hand it can
be by iterating through all the possible replacements of non-joker
cards:

```racket
(define (find-strongest h)
  (define counts
    (hand-counts h))
  (cond
    [(hash-has-key? counts #\J)
     (define non-jokers
       (remv #\J (hash-keys counts)))
     ;; When
     ;;  non-jokers = '(#\Q #\2)
     ;; Then
     ;;  replacementss = '((#\Q #\Q) (#\Q #\2) (#\2 #\2))
     (define replacementss
       (remove-duplicates
        (map (λ (cards) (sort cards char>?))
             (apply cartesian-product (make-list (hash-ref counts #\J) non-jokers)))))
     (for/fold ([res #f] #:result (or res h))
               ([replacements (in-list replacementss)])
       (define replacement-hand
         (for/fold ([chars null]
                    [replacements replacements]
                    #:result (apply string (reverse chars)))
                   ([c (in-string h)])
           (if (char=? c #\J)
               (values (cons (car replacements) chars) (cdr replacements))
               (values (cons c chars) replacements))))
       (if (or (not res)
               (> (hand-type-numeric replacement-hand)
                  (hand-type-numeric res)))
           replacement-hand
           res))]
    [else h]))
```

Next, we can update `card-score` to take an optional argument
representing the score for joker cards:

```racket
(define (card-score c [j-score 11])
  (match c
    [#\2 2]
    [#\3 3]
    [#\4 4]
    [#\5 5]
    [#\6 6]
    [#\7 7]
    [#\8 8]
    [#\9 9]
    [#\T 10]
    [#\J j-score]
    [#\Q 12]
    [#\K 13]
    [#\A 14]))
```

And we can update the signature for `hand>` to make it possible for
the caller to pass in custom procedures for computing hand types and
card scores:

```racket
(define (hand> a b
               #:hand-type-numeric-proc [hand-type-numeric hand-type-numeric]
               #:card-score-proc [card-score card-score])
  ...)
```

Its body remains unchanged. With these changes in place, we can solve
part two by passing in a custom sort procedure to `compute-winnings`:

```racket
(compute-winnings
 hands
 (lambda (a b)
   (hand>
    #:hand-type-numeric-proc (compose1 hand-type-numeric find-strongest)
    #:card-score-proc (λ (c) (card-score c 1))
    a b)))
```

This will be my last post in this series, but I'll probably keep solving
puzzles for another week or so. Check out [my solutions repo] if you
want to follow along!

[today]: https://adventofcode.com/2023/day/7
[my solutions repo]: https://github.com/bogdanp/aoc2023
