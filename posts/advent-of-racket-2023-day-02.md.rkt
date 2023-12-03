#lang punct "../common.rkt"

---
title: Advent of Racket 2023/02 - Cube Conondrum
date: 2023-12-02T10:00:00+02:00
---

[Today's puzzle] was quick and easy. For the first part, we're to take
a list of "games" as input where each game has an id and a set of
semicolon-separated sets of plays and report the sum of the game ids
where the sets match a certain condition. The example input looks like:

```
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
```

I decided to make a struct to represent each game:

```racket
(struct game (id sets)
  #:transparent)
```

And to parse each set into a hash from colors to the number of blocks:

```racket
(define (parse-set set-str)
  (for/hasheq ([reveal-str (in-list (string-split set-str ","))])
    (match-define (regexp #rx"([0-9]+) ([a-z]+)"
                          (list _
                                (app string->number blocks)
                                (app string->symbol color)))
      reveal-str)
    (values color blocks)))
```

The `parse-set` procedure splits the input on commas and extracts the
block count and color of each reveal using a regular expression. The
•rkt[for/hasheq] form then collects the results of each iteration into a
hash. The •rkt[match] form's `app` syntax comes in handy when you want
to transform a matched value before binding it.

```racket
> (parse-set "")
'#hasheq()
> (parse-set "10 red, 3 blue")
'#hasheq((blue . 3) (red . 10))
> (parse-set "10 red, 3 blue, 5 green")
'#hasheq((blue . 3) (green . 5) (red . 10))
```

To parse a game, we do a similar kind of pattern matching to extract
the game id and the set of reveals to pass to `parse-set`:

```racket
(define (parse-game line)
  (match-define (regexp #rx"Game ([^:]+): (.+)"
                        (list _ (app string->number id) sets-str))
    line)
  (define sets
    (map parse-set (string-split sets-str ";")))
  (game id sets))
```

With the id and parsed sets in hand, we construct an instance of the
game struct.

```racket
> (parse-game "Game 5: 10 red, 3 blue; 10 green, 5 red")
(game 5 '(#hasheq((blue . 3) (red . 10))
          #hasheq((green . 10) (red . 5))))
```

The goal of part one is to sum up the game ids where the games would be
valid. A valid game is defined as any game where every set of reveals
had fewer than 12 red cubes, 13 green cubes and 14 blue cubes. So, I
defined a generic procedure for determining if a game was valid:

```racket
(define (game-ok? g proc)
  (for/and ([s (in-list (game-sets g))])
    (proc s)))
```

The •rkt[for/and] form returns `#t` when all of the iterations are
truthy and `#f` otherwise. Next, we define a procedure representing the
valid condition for part 1:

```racket
(define (part1-ok? s)
  (and
   (<= (hash-ref s 'red 0) 12)
   (<= (hash-ref s 'green 0) 13)
   (<= (hash-ref s 'blue 0) 14)))
```

And, with that, we can put everything together:

```racket
(call-with-input-file "day02.txt"
  (lambda (in)
    (for*/sum ([line (in-lines in)]
               [game (in-value (parse-game line))]
               #:when (game-ok? game part1-ok?))
      (game-id game))))
```

We use the `sum` variant of •rkt[for*] to sum up the valid game ids. The
•rkt[in-value] form generates a sequence of one element representing
each game for each line and the body of the loop is skipped whenever
`game-ok?` is false.

In part two, the problem is flipped on its head and we're asked to
find the minimum constraint that would make each game valid. That's
just a matter of iterating over every set in each game and keeping
track of the _maximum_ number of blocks of each color:

```racket
(define (game-minimums g)
  (for*/fold ([minimums (hasheq 'red 0 'green 0 'blue 0)])
             ([s (in-list (game-sets g))]
              [c (in-list '(red green blue))])
    (hash-update minimums c (λ (blocks) (max blocks (hash-ref s c 0))))))
```

For example:

```racket
> (game-minimums (parse-game "Game 5: 10 red, 3 blue; 10 green, 5 red"))
'#hasheq((blue . 3) (green . 10) (red . 10))
```

To compute the puzzle solution, we have to sum up the result of
multiplying the number of colors in every game (its "power"). So, we
define a procedure to compute a game's power:

```racket
(define (game-power g)
  (apply * (hash-values (game-minimums g))))
```

Put it all together:

```racket
(call-with-input-file "day02.txt"
  (lambda (in)
    (for*/sum ([line (in-lines in)]
               [game (in-value (parse-game line))])
      (game-power game))))
```

And that's it for day two!

[Today's puzzle]: https://adventofcode.com/2023/day/2
