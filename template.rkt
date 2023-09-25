#lang racket/base

(require punct/doc
         racket/format
         racket/file
         racket/list
         racket/match
         racket/string
         threading
         (only-in xml write-xexpr)
         "common.rkt"
         "document.rkt")

(provide
 render*
 render
 ->html*
 ->html)

(define render*
  (make-keyword-procedure
   (lambda (kws kw-args dir doc)
     (make-directory* dir)
     (call-with-output-file
       (build-path dir "index.html")
       (lambda (out)
         (keyword-apply render kws kw-args doc out null))))))

(define (render doc [out (current-output-port)])
  (match-define (document metas body footnotes) doc)
  (define title (hash-ref metas 'title))
  (define the-date
    (and~> (hash-ref metas 'date #f)
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
       ([:href "/css/screen.css"]
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
          ([:class (class* "document-title" (and the-date "document-title-dated"))]
           [:data-date (if the-date (format-date the-date) "")])
          title))
        ,@(->html* body)
        (unless (null? footnotes)
          (haml
           (:ol.footnotes
            ,@(->html* footnotes))))))
      (.footer))))
   out))

(define (class* . names)
  (string-join (filter values names) " "))

(define (->html* xexprs)
  (filter-map ->html xexprs))

(define (->html xexpr)
  (match xexpr
    [`(blockquote . ,content)
     `(blockquote . ,(->html* content))]
    [`(bold . ,content)
     `(strong . ,(->html* content))]
    [`(code . ,content)
     `(code . ,content)]
    [`(code-block ([info ,_]) ,code)
     `(pre ,code)]
    [`(footnote-definition ([label ,label]
                            [ref-count ,ref-count])
                           ,content)
     `(li
       ([class "footnote"]
        [id ,(~footnote-id label)])
       ,(->html
         (append content
                 (list " ")
                 (for/list ([def (in-range 1 (add1 (string->number ref-count)))])
                   (haml
                    (:sup
                     (:a
                      ([:href (~#footnote-ref-id label def)])
                      (~a def))))))))]
    [`(footnote-reference ([label ,label]
                           [defn-num ,_]
                           [ref-num ,ref]))
     `(sup
       (a ([id ,(~footnote-ref-id label ref)]
           [href ,(~#footnote-id label)])
          ,label))]
    [`(heading ([level ,level]) . ,content)
     (list*
      (case level
        [("1") 'h1]
        [("2") 'h2]
        [("3") 'h3]
        [("4") 'h4]
        [("5") 'h5]
        [("6") 'h6]
        [else (error '->html "invalid heading level: ~e" level)])
      (->html* content))]
    [`(html-block . ,_)
     (error '->html "html-block: ~s" xexpr)]
    [`(image ([src ,src]
              [title ,title]
              [desc ,description]))
     `(img ([src ,src]
            [alt ,description]
            [title ,title]))]
    [`(italic . ,content)
     `(em . ,(->html* content))]
    [`(item . ,content)
     `(li . ,(->html* content))]
    [`(itemization ([style ,_]
                    [start ,start])
                   . ,content)
     (if (equal? start "")
         `(ul . ,(->html* content))
         `(ol ([start ,start]) . ,(->html* content)))]
    [`(link ([dest ,dest]
             [title ,title])
            . ,content)
     `(a ([href ,dest]
          [title ,title])
         . ,(->html* content))]
    [`(paragraph . ,content)
     (let ([content (->html* content)])
       (and (not (null? content))
            `(p . ,content)))]
    [e e]))

(define (menu-item target label)
  (haml
   (:li.menu__item
    (:a ([:href target]) label))))

(define (~footnote-id label)
  (format "footnote-~a" label))

(define (~footnote-ref-id label num)
  (format "footnote-ref-~a-~a" label num))

(define (~#footnote-id label)
  (string-append "#" (~footnote-id label)))

(define (~#footnote-ref-id label num)
  (string-append "#" (~footnote-ref-id label num)))
