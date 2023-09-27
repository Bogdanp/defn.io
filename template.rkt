#lang racket/base

(require punct/render/html
         racket/file
         racket/string
         threading
         (only-in xml write-xexpr)
         "common.rkt"
         "document.rkt")

(provide
 render*
 render)

(define render*
  (make-keyword-procedure
   (lambda (kws kw-args dir doc)
     (make-directory* dir)
     (call-with-output-file
       (build-path dir "index.html")
       (lambda (out)
         (keyword-apply render kws kw-args doc out null))))))

(define (render doc [out (current-output-port)])
  (define title
    (get-meta doc 'title))
  (define the-date
    (and~> (get-meta doc 'date #f)
           (parse-date)))
  (fprintf out "<!DOCTYPE html>")
  (write-xexpr
   (haml
    (:html
     ([:lang "en-US"])
     (:head
      (:meta ([:charset "utf-8"]))
      (:meta ([:name "viewport"]
              [:content "width=device-width, initial-scale=1.0, viewport-fit=cover"]))
      (:title title " " &mdash " defn.io")
      (:link
       ([:href "/index.xml"]
        [:rel "alternate"]
        [:type "application/atom+xml"]))
      (:link
       ([:href "/css/valkyrie.css"]
        [:rel "stylesheet"]
        [:type "text/css"]))
      (:link
       ([:href (format "/css/screen.css?~a" (current-seconds))]
        [:rel "stylesheet"]
        [:type "text/css"])))
     (:body
      (.header
       (.container
        (:nav
         (.logo
          (:a ([:href "/"]) "defn.io"))
         (:ul.menu
          (menu-item "/" "Posts")
          (menu-item "/page/projects" "Projects")
          (menu-item "/page/talks" "Talks")
          (menu-item "/page/about" "About")))))
      (.document
       (.container
        (haml
         (:h1
          ([:class (classnames "document-title" (and the-date "document-title-dated"))]
           [:data-date (if the-date (format-date the-date) "")])
          title))
        (doc->html-xexpr doc)))
      (.footer))))
   out))

(define (classnames . names)
  (string-join (filter values names) " "))

(define (menu-item target label)
  (haml
   (:li.menu__item
    (:a ([:href target]) label))))
