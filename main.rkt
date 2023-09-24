#lang racket/base

(require punct/doc
         racket/file
         racket/match
         "document.rkt"
         "feed.rkt"
         "template.rkt")

(define (main)
  (delete-directory/files public)
  (copy-directory/files static public)
  (for-each-document
   (λ (_path slug doc)
     (render* (build-path public "page" slug) doc))
   pages)
  (for-each-document
   (λ (_path slug doc)
     (match-define (document _metas _body _footnotes) doc)
     (define dir (post-path doc slug))
     (render* dir doc))
   posts)
  (define index-doc
    (dynamic-require "index.md.rkt" 'doc))
  (render* public index-doc)
  (render-feed* public))

(module+ main
  (main))
