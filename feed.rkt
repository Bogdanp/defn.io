#lang racket/base

(require punct/doc
         racket/date
         racket/match
         (only-in xml write-xml/content xexpr->string xexpr->xml)
         (only-in "document.rkt" in-documents posts post-date post-url)
         (only-in "template.rkt" ->html*))

(provide
 render-feed*
 render-feed)

(define (~datetime d)
  (parameterize ([date-display-format 'rfc2822])
    (date->string d #t)))

(define (render-feed* root)
  (call-with-output-file
    (build-path root "index.xml")
    (lambda (out)
      (render-feed out))))

(define (render-feed [out (current-output-port)])
  (define sorted-posts
    (sort
     (for/list ([(_p slug doc) (in-documents posts)])
       (list slug doc (post-date doc)))
     #:key (compose1 date->seconds caddr) >))
  (define items
    (for/list ([post (in-list sorted-posts)])
      (match-define (list slug (and (document metas body footnotes) doc) the-date) post)
      (define url (format "https://defn.io~a" (post-url doc slug)))
      `(item
        (title ,(hash-ref metas 'title))
        (link ,url)
        (guid ,(format "~a/index.html" url))
        (pubDate ,(~datetime the-date))
        (description
         ,(xexpr->string
           `(div
             ,@(->html* body)
             ,@(if (null? footnotes)
                   '()
                   `((hr)
                     (ol ,@(->html* footnotes))))))))))
  (define feed
    `(rss
      ([xmlns:atom "http://www.w3.org/2005/Atom"]
       [version "2.0"])
      (channel
       (title "defn.io")
       (link "https://defn.io")
       (description "Bogdan Popa's website.")
       (language "en-US")
       (lastBuildDate ,(~datetime (seconds->date (current-seconds))))
       (atom:link
        ([rel "self"]
         [href "https://defn.io/index.xml"]
         [type "application/rss+xml"]))
       ,@items)))
  (write-xml/content (xexpr->xml feed) out))
