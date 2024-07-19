#lang punct "../common.rkt" racket/match

---
title: Talks
---

## Publications

•(define (paper-anchor url label authors)
   (haml
    (:span
     (:a ([:href url]) label)
     (:br)
     authors)))

•(define (paper-venue url label)
   (haml (:span (:a ([:href url]) label))))

•(table
  '("Title" "Venue")
  `(,(paper-anchor
      "/papers/cont-funarch24.pdf"
      "Continuations: What Have They Ever Done for Us?"
      "Kaufmann and Popa")
    ,(paper-venue
      "https://www.functional-architecture.org/events/funarch-2024/"
      "FUNARCH 24"))
  `(,(paper-anchor
      "/papers/fungui-funarch23.pdf"
      "Functional Shell and Reusable Components for Easy GUIs"
      "Knoble and Popa")
    ,(paper-venue
      "https://www.functional-architecture.org/events/funarch-2023/"
      "FUNARCH 23")))

## Talks

•(deflink RacketCon "https://con.racket-lang.org")
•(deflink Racketfest "https://racketfest.com")
•(deflink Dramatiq "https://dramatiq.io")

•(struct talk (label year url description))

•(define (talk-row t)
   (match-define (talk label year url description) t)
   (list
    (haml (:a ([:href url]) label))
    (number->string year)
    description))

•(define talks
   (list
    (talk
     "Native Apps with Racket" 2023
     (xref "Racketfest 2023 Talk: Native Apps with Racket")
     (haml (:span "A talk I gave at " Racketfest " 2023 about building native desktop applications with Racket.")))
    (talk
     "Declarative GUIs in Racket" 2021
     (xref "(eleventh RacketCon) talk: Declarative GUIs")
     (haml (:span "A talk I gave at the eleventh " RacketCon " about a system for building native GUIs in Racket in a declarative way.")))
    (talk
     "Racket for the Web" 2020
     "https://github.com/Bogdanp/racketfest2020-talk"
     (haml (:span "A talk I gave at " Racketfest " 2020 about building an e-commerce business with Racket.")))
    (talk
     "Async Tasks with Dramatiq" 2017
     "https://www.youtube.com/watch?v=mrG9ZwLxb0g"
     (haml (:span "An intro talk to " Dramatiq ", my task processing library for Python.")))))

•(apply table '("Talk" "Year" "Description") (map talk-row talks))

## Screencasts

•(struct screencast (label year url description))

•(define (screencast-row s)
   (match-define (screencast label year url description) s)
   (list
    (haml (:a ([:href url]) label))
    (number->string year)
    description))

•(deflink Noise "https://github.com/Bogdanp/Noise")
•(define screencasts
   (list
    (screencast
     "SwiftUI + Racket" 2022
     (xref "Screencast: SwiftUI + Racket")
     (haml (:span "Showing off a very early version of " Noise " and how it can be used to embed Racket inside a native macOS application.")))
    (screencast
     "Resource Pool for Racket" 2021
     (xref "Screencast: Writing a Resource Pool Library for Racket")
     "Live coding a generic resource pooling library for Racket.")
    (screencast
     "Improvements in Koyo 0.9" 2021
     (xref "Improvements in koyo 0.9")
     "Showing off some improvements made in the 0.9 release of Koyo.")
    (screencast
     "Redis Session Store for Koyo" 2021
     (xref "Screencast: Building a Redis Session Store for Koyo")
     "Live coding a Redis-backed session store for Koyo.")))

•(apply table '("Title" "Year" "Description") (map screencast-row screencasts))
