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

•(define (paper-venue url label [talk-url #f])
   (haml (:span (:a ([:href url]) label))))

•(define FUNARCH23 (paper-venue "https://www.functional-architecture.org/events/funarch-2023/" "FUNARCH 23"))
•(define FUNARCH24 (paper-venue "https://www.functional-architecture.org/events/funarch-2024/" "FUNARCH 24"))

•(table
  '("Title" "Venue")
  `(,(paper-anchor
      "/papers/cont-funarch24.pdf"
      "Continuations: What Have They Ever Done for Us?"
      "Kaufmann and Popa")
    ,FUNARCH24)
  `(,(paper-anchor
      "/papers/fungui-funarch23.pdf"
      "Functional Shell and Reusable Components for Easy GUIs"
      "Knoble and Popa")
    ,FUNARCH23))

## Talks

•(deflink RacketCon "https://con.racket-lang.org")
•(deflink Racketfest "https://racketfest.com")
•(deflink RoPython "https://ropython.ro/")
•(deflink Dramatiq "https://dramatiq.io")

•(struct talk (label year url venue description))

•(define (talk-row t)
   (match-define (talk label year url venue description) t)
   (list
    (haml (:a ([:href url]) label))
    (number->string year)
    venue
    description))

•(define talks
   (list
    (talk
     #;label "Continuations: What Have They Ever Done for Us"
     #;year 2024
     #;url "https://www.youtube.com/watch?v=Pzt3WhUF9bE"
     #;venue FUNARCH24
     #;description "Marc and I presented our paper with the same title.")
    (talk
     #;label "Native Apps with Racket"
     #;year 2023
     #;url (xref "Racketfest 2023 Talk: Native Apps with Racket")
     #;venue Racketfest
     #;description "How to build native desktop applications with Racket.")
    (talk
     #;label "Declarative GUIs in Racket"
     #;year 2021
     #;url (xref "(eleventh RacketCon) talk: Declarative GUIs")
     #;venue RacketCon
     #;description "How to write declarative GUIs in Racket.")
    (talk
     #;label "Racket for the Web"
     #;year 2020
     #;url "https://github.com/Bogdanp/racketfest2020-talk"
     #;venue Racketfest
     #;description "How I built an e-commerce business with Racket.")
    (talk
     #;label "Async Tasks with Dramatiq"
     #;year 2017
     #;url "https://www.youtube.com/watch?v=mrG9ZwLxb0g"
     #;venue RoPython
     #;description (haml (:span "An intro to " Dramatiq ".")))))

•(apply table '("Talk" "Year" "Venue" "Description") (map talk-row talks))

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
