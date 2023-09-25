#lang racket/base

(require (for-syntax racket/base
                     syntax/parse)
         koyo/haml
         punct/doc
         "document.rkt")

(provide
 (all-from-out koyo/haml))


;; links ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 deflink)

(define-syntax (deflink stx)
  (syntax-parse stx
    [(_ id:id url:expr {~optional label:expr})
     #'(define id
         (haml (:a ([:href url]) {~? label (symbol->string 'id)})))]))


;; cross references ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 @ xref)

(define (@ title [label title])
  (haml (:a ([:href (xref title)]) label)))

(define (xref title)
  (or
   (for/first ([(_p slug doc) (in-documents posts)]
               #:when (equal? (hash-ref (document-metas doc) 'title) title))
     (post-url doc slug))
   (error 'xref "post not found: ~s" title)))


;; elements ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 img
 table
 youtube-embed)

(define (img path [alt ""])
  (unless (file-exists? (build-path static "img" path))
    (error 'img "image ~s does not exist" path))
  (haml
   (:img
    ([:alt alt]
     [:src (string-append "/" (path->string (build-path "img" path)))]))))

(define (table columns . rows)
  (haml
   (:table
    (:thead
     (:tr
      ,@(for/list ([col (in-list columns)])
          (haml (:th col)))))
    (:tbody
     ,@(for/list ([row (in-list rows)])
         (haml (:tr ,@(for/list ([col (in-list row)])
                        (haml (:td col))))))))))

(define (youtube-embed id)
  (haml
   (:center
    (:iframe
     ([:width "560"]
      [:height "315"]
      [:src (format "https://www.youtube-nocookie.com/embed/~a" id)]
      [:title "YouTube video player"]
      [:frameborder "0"]
      [:allow "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"]
      [:allowfullscreen ""])))))
