#lang racket/base

(require (for-syntax racket/base
                     syntax/parse)
         koyo/haml
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

(define (@ title-or-slug [label title-or-slug])
  (haml (:a ([:href (xref title-or-slug)]) label)))

(define (xref title-or-slug)
  (or
   (for/first ([(_p slug doc) (in-documents posts)]
               #:when (or (string-ci=? slug title-or-slug)
                          (string-ci=? (get-meta doc 'title) title-or-slug)))
     (post-url doc slug))
   (error 'xref "post not found: ~s" title-or-slug)))


;; elements ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 rkt
 fig
 img
 table
 video
 youtube-embed)

(define-syntax (rkt stx)
  (syntax-parse stx
    [(_ id:id)
     #:with id-str (datum->syntax #'id (symbol->string (syntax->datum #'id)))
     #'(haml
        (:a
         ([:href (format "https://docs.racket-lang.org/search/index.html?q=~a" id-str)])
         (:code id-str)))]))

(define (fig path caption #:alt [alt ""])
  (haml
   (:figure
    (img path alt)
    (:figcaption caption))))

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

(define (video src)
  (haml
   (:video
    ([:src src]
     [:controls ""]
     [:width "100%"]))))

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
