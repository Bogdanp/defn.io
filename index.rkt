#lang racket/base

(require koyo/haml
         punct/doc
         racket/date
         "document.rkt")

(provide
 index)

(define (index)
  (define items+seconds
    (for/list ([(_p slug doc) (in-documents posts)])
      (define the-date (post-date doc))
      (define item
        (haml
         (:li.post-index__post
          ([:data-date (format-date the-date)])
          (:a
           ([:href (post-url doc slug)])
           (hash-ref (document-metas doc) 'title)))))
      (cons item (date->seconds the-date #f))))
  (haml
   (:ul.post-index
    ,@(for/list ([item+seconds (in-list (sort items+seconds #:key cdr >))])
        (car item+seconds)))))
