#lang racket/base

(require punct/doc
         racket/file
         racket/match
         racket/path
         racket/runtime-path
         racket/system
         "document.rkt"
         "feed.rkt"
         "template.rkt")

(define-runtime-path here ".")

(define (build)
  (delete-directory/files public #:must-exist? #f)
  (copy-directory/files static public)
  (for ([(_path slug doc) (in-documents pages)])
    (render* (build-path public "page" slug) doc))
  (for ([(_path slug doc) (in-documents posts)])
    (match-define (document _metas _body _footnotes) doc)
    (render* (post-path doc slug) doc))
  (define index-doc
    (get-doc (build-path here "index.md.rkt")))
  (render* public index-doc)
  (render-feed* public))

(define (watch)
  (define here* (simplify-path here))
  (define root-re
    (byte-regexp (regexp-quote (path->bytes here*))))
  (define racket
    (find-executable-path
     (find-system-path 'exec-file)))
  (define (build* [reason #f])
    (define-values (_ _cpu-time real-time _gc-time)
      (time-apply
       (lambda ()
         (if reason
             (eprintf "Building (~a)...~n" reason)
             (eprintf "Building...~n"))
         (unless (zero? (system*/exit-code racket (build-path here* "main.rkt")))
           (eprintf "Build failed.~n")))
       null))
    (eprintf "Build took ~sms.~n" real-time))
  (build*)
  (with-handlers ([exn:break? void])
    (let loop ()
      (define paths
        (for/list ([path (in-directory here*)]
                   #:when (member
                           (path-get-extension path)
                           '(#".css" #".rkt"))
                   #:unless (regexp-match? #"\\.#" path))
          path))
      (define evts
        (map filesystem-change-evt paths))
      (define changed-path
        (apply
         sync/enable-break
         (for/list ([path (in-list paths)]
                    [evt (in-list evts)])
           (handle-evt evt (λ (_) path)))))
      (for-each filesystem-change-evt-cancel evts)
      (build* (format "~a changed" (regexp-replace root-re (path->bytes changed-path) #"")))
      (loop))))

(module+ main
  (require racket/cmdline)

  (define watch? #f)
  (command-line
   #:once-each
   [("-w" "--watch")
    "rebuild whenever any source files change"
    (set! watch? #t)])

  (if watch?
      (watch)
      (build)))
