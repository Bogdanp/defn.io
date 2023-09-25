#lang racket/base

(require punct/doc
         racket/date
         racket/file
         racket/match
         racket/path
         racket/runtime-path
         racket/string)

(provide
 pages
 posts
 public
 static
 in-documents
 for-each-document
 document-title
 post-date
 post-path
 post-url
 parse-date
 format-date)

(define-runtime-path pages "pages")
(define-runtime-path posts "posts")
(define-runtime-path public "public")
(define-runtime-path static "static")

(define (for-each-document proc root)
  (for ([(p slug doc) (in-documents root)])
    (proc p slug doc)))

(define find-documents
  (let ([memo (make-hash)])
    (lambda (root)
      (hash-ref!
       memo root
       (λ ()
         (list->vector
          (find-files (λ (p) (path-has-extension? p #".md.rkt")) root)))))))

(define (in-documents root)
  (define paths
    (find-documents root))
  (make-do-sequence
   (lambda ()
     (values
      (lambda (idx)
        (define p (vector-ref paths idx))
        (define-values (_dir filename _must-be-dir?)
          (split-path p))
        (match-define (and (document metas _body _footnotes) doc)
          (dynamic-require p 'doc))
        (define slug
          (hash-ref metas 'slug (λ () (string-replace (path->string filename) ".md.rkt" ""))))
        (values p slug doc))
      (λ (idx) (add1 idx)) ;pos->element
      0 ;next-pos
      (λ (idx) (< idx (vector-length paths))) ;continue-with-pos?
      #f ;continue-with-val?
      #f ;continue-after-pos+val?
      ))))

(define (document-title doc)
  (hash-ref (document-metas doc) 'title))

(define (post-date doc)
  (parse-date (hash-ref (document-metas doc) 'date)))

(define (post-path doc slug [full? #t])
  (define d (post-date doc))
  (define args
    (list
     (~pad (date-year d))
     (~pad (date-month d))
     (~pad (date-day d))
     slug))
  (apply build-path (if full? (cons public args) args)))

(define (post-url doc slug [full? #f])
  (define path (path->string (post-path doc slug #f)))
  (string-append (if full? "https://defn.io/" "/") path))

(define (parse-date s)
  (match-define (list year month day hour minute second offset-hours offset-minutes)
    (map string->number (cdr (regexp-match #rx"(....)-(..)-(..)T(..):(..):(..)(...):(..)" s))))
  (define offset-seconds
    (+ (* offset-hours 3600)
       (* (* (if (< offset-hours 0) -1 1) offset-minutes) 60)))
  (seconds->date (- (find-seconds second minute hour day month year #f) offset-seconds)))

(define (format-date d)
  (string-append
   (~pad (date-year d))
   "-"
   (~pad (date-month d))
   "-"
   (~pad (date-day d))))

(define (~pad n)
  (if (< n 10)
      (string-append "0" (number->string n))
      (number->string n)))
