#lang racket/base

(require racket/match
         "../common.rkt")

(provide
 projects-table)

(struct project (label url description))

(define (project-row p)
  (match-define (project label url description) p)
  (haml
   (:a ([:href url]) label)
   description))

(define (projects-table ps)
  (apply table '("Project" "Description") (map project-row ps)))


;; the projects ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide
 app-projects
 archived-projects
 lib-projects
 website-projects)

(deflink Postmark "https://postmarkapp.com")
(deflink Sentry "https://sentry.io")
(deflink Twilio "https://twilio.com")

(define app-projects
  (list
   (project
    "Franz" "https://franz.defn.io"
    "A desktop client for Apache Kafka.")
   (project
    "neko.app" "https://github.com/Bogdanp/neko"
    "A tiny kitten follows your mouse cursor on macOS.")
   (project
    "Podcatcher" "https://apps.apple.com/us/app/podcatcher-podcast-player/id6736467324"
    "A podcast player for iOS.")
   (project
    "Remember" "https://remember.defn.io"
    "A keyboard-driven application for stashing away distractions for later.")))

(define archived-projects
  (list
   (project
    "PyREPL" "https://github.com/Bogdanp/pyrepl.vim"
    "Run a Python interpreter inside Vim.")
   (project
    "RbREPL" "https://github.com/Bogdanp/rbrepl.vim"
    "Run a Ruby interpreter inside Vim.")
   (project
    "anom-go" "https://github.com/Bogdanp/anom"
    "An object mapper for the AppEngine Datastore in Go.")
   (project
    "anom" "https://anom.defn.io"
    "An object mapper for Cloud Datastore for Python 3.")
   (project
    "apistar_cors" "https://github.com/Bogdanp/apistar_cors"
    "CORS support for API Star apps.")
   (project
    "apistar_dramatiq" "https://github.com/Bogdanp/apistar_dramatiq"
    "Dramatiq support for API Star apps.")
   (project
    "apistar_prometheus" "https://github.com/Bogdanp/apistar_prometheus"
    "Prometheus metrics for API Star apps.")
   (project
    "apistar_request_id" "https://github.com/Bogdanp/apistar_request_id"
    "Request id generation and propagation for API Star.")
   (project
    "apistar_sentry" "https://github.com/Bogdanp/apistar_sentry"
    "Sentry support for API Star apps.")
   (project
    "apistar_settings" "https://github.com/Bogdanp/apistar_settings"
    "A settings component for API Star apps.")
   (project
    "browser-connect" "https://github.com/Bogdanp/browser-connect.vim"
    "Live browser interaction for Vim.")
   (project
    "cedar-mode" "https://github.com/Bogdanp/cedar-mode"
    "Emacs mode for cedar.")
   (project
    "cedar" "https://github.com/Bogdanp/cedar"
    "A web service definition format and code generator.")
   (project
    "crontab" "https://github.com/Bogdanp/racket-crontab"
    "A crontab spec parser for Scala.")
   (project
    "elm-ast" "https://github.com/Bogdanp/elm-ast"
    "A parser for Elm in Elm.")
   (project
    "elm-combine" "https://github.com/Bogdanp/elm-combine"
    "Parser combinators for Elm.")
   (project
    "elm-cookiecutter" "https://github.com/Bogdanp/elm-cookiecutter"
    "A cookiecutter template for Elm apps.")
   (project
    "elm-datepicker" "https://github.com/Bogdanp/elm-datepicker"
    "A reusable datepicker for Elm.")
   (project
    "elm-generate" "https://github.com/Bogdanp/elm-generate"
    "Generators for Elm.")
   (project
    "elm-mode" "https://github.com/jcollard/elm-mode"
    "An Elm mode for EMACS.")
   (project
    "elm-querystring" "https://github.com/Bogdanp/elm-querystring"
    "A library for working with querystrings in Elm.")
   (project
    "elm-route" "https://github.com/Bogdanp/elm-route"
    "A type-safe routing library for Elm.")
   (project
    "elm-time" "https://github.com/Bogdanp/elm-time"
    "A pure Elm date and time library.")
   (project
    "falcon_sugar" "https://github.com/Bogdanp/falcon_sugar"
    "A little sugar for Falcon applications.")
   (project
    "fargate_scraper" "https://github.com/Bogdanp/fargate_scraper"
    "A CLI tool that scrapes Fargate tasks to find Prometheus targets.")
   (project
    "ff" "https://github.com/Bogdanp/ff"
    "A fuzzy-finder for the terminal.")
   (project
    "firechannel" "https://github.com/LeadPages/firechannel"
    "An almost-dropin replacement for the GAE channels API using Firebase.")
   (project
    "h2p" "https://github.com/Bogdanp/h2p"
    "A Python interface to libwkhtmltox.")
   (project
    "heater" "https://github.com/Bogdanp/heater"
    "A Python heatmapping library.")
   (project
    "hugs" "https://github.com/Bogdanp/hugs"
    "A library that maps SQL expressions to Python fuctions.")
   (project
    "ido-clever-match" "https://github.com/Bogdanp/ido-clever-match"
    "An alternative matcher for Emacs ido-mode.")
   (project
    "markii" "https://github.com/Bogdanp/markii"
    "A development-mode error handler for Python web apps.")
   (project
    "modviz" "https://github.com/Bogdanp/modviz"
    "A module dependency graph visualizer for Python.")
   (project
    "mold" "https://github.com/Bogdanp/mold"
    "A fast templating engine for Python.")
   (project
    "multiprom" "https://github.com/Bogdanp/multiprom"
    "A multiprocess-friendly Prometheus client for Python.")
   (project
    "pico" "https://github.com/Bogdanp/pico"
    "A minimal lisp interpreter written in Python.")
   (project
    "quicksilver" "https://github.com/Bogdanp/quicksilver.vim"
    "A fast file finder for VIM.")
   (project
    "tcopy" "https://github.com/Bogdanp/tcopy"
    "A tail-call optimizing decorator for Python.")
   (project
    "threadop" "https://github.com/Bogdanp/threadop"
    "Adds a threading operator to Python.")
   (project
    "trio-redis" "https://github.com/Bogdanp/trio-redis"
    "A trio-based Redis client for Python.")
   (project
    "yes.py" "https://github.com/Bogdanp/yes.py"
    "A fast implementation of `yes` in Python.")
   (project
    "zed" "https://github.com/Bogdanp/zed"
    "A toy text editor.")))

(define lib-projects
  (list
   (project
    "actor" "https://github.com/Bogdanp/racket-actor"
    "Kill-Safe actors for Racket.")
   (project
    "avro" "https://github.com/Bogdanp/racket-avro"
    "A Racket implementation of the Apache Avro serialization format.")
   (project
    "binfmt" "https://github.com/Bogdanp/racket-binfmt"
    "A binary format parser-generator.")
   (project
    "chief" "https://github.com/Bogdanp/racket-chief"
    "A Procfile runner for Racket.")
   (project
    "component" "https://github.com/Bogdanp/racket-component"
    "Dependency injection for Racket.")
   (project
    "crontab" "https://github.com/Bogdanp/racket-crontab"
    "Cron-like scheduling for Racket.")
   (project
    "cursive_re" "https://github.com/Bogdanp/cursive_re"
    "Readable regular expressions for Python 3.")
   (project
    "dbg" "https://github.com/Bogdanp/racket-dbg"
    "A remote debugging/monitoring tool for Racket programs.")
   (project
    "define-query" "https://github.com/Bogdanp/racket-define-query"
    "Turn .sql files into virtual-statements in Racket.")
   (project
    "deta" "https://github.com/Bogdanp/deta"
    "A functional database mapper for Racket.")
   (project
    "dramatiq" "https://dramatiq.io"
    "A distributed task processing library for Python 3.")
   (project
    "dramatiq_dashboard" "https://github.com/Bogdanp/dramatiq_dashboard"
    "A monitoring UI for Dramatiq.")
   (project
    "dramatiq_sqs" "https://github.com/Bogdanp/dramatiq_sqs"
    "An Amazon SQS broker for Dramatiq.")
   (project
    "forms" "https://github.com/Bogdanp/racket-forms"
    "A web form validation library for Racket.")
   (project
    "geoip" "https://github.com/Bogdanp/racket-geoip"
    "Geolocation for Racket based on MaxMind's GeoIP databases.")
   (project
    "gui-easy" "https://github.com/Bogdanp/racket-gui-easy"
    "A declarative GUI library for Racket.")
   (project
    "http-easy" "https://github.com/Bogdanp/racket-http-easy"
    "A high-level HTTP client for Racket.")
   (project
    "koyo" "https://github.com/Bogdanp/koyo"
    "A web development toolkit for Racket.")
   (project
    "lz4" "https://github.com/Bogdanp/racket-lz4"
    "A pure-Racket decompressor for LZ4 data.")
   (project
    "marionette" "https://github.com/Bogdanp/marionette"
    "A Racket library that lets you control Firefox via the Marionette Protocol.")
   (project
    "messagepack" "https://github.com/Bogdanp/racket-messagepack"
    "An implementation of the MessagePack serialization format for Racket.")
   (project
    "molten" "https://moltenframework.com"
    "A modern API framework for Python 3.")
   (project
    "monocle" "https://github.com/Bogdanp/racket-monocle"
    "Lenses for Racket.")
   (project
    "monotonic" "https://github.com/Bogdanp/racket-monotonic"
    "Monotonic time for Racket.")
   (project
    "nemea" "https://github.com/Bogdanp/nemea"
    "A little Racket web application for tracking website analytics.")
   (project
    "net-ip" "https://github.com/Bogdanp/racket-net-ip"
    "Utilities for working with IP addresses and networks in Racket.")
   (project
    "noise" "https://github.com/Bogdanp/Noise"
    "A Swift Package for embedding Racket inside applications.")
   (project
    "north" "https://github.com/Bogdanp/racket-north"
    "A database schema migration tool written in Racket.")
   (project
    "place-tcp-listener" "https://github.com/Bogdanp/racket-place-tcp-listener"
    "A TCP listener that dispatches new connections to places.")
   (project
    "postmark" "https://github.com/Bogdanp/racket-postmark"
    (haml (:span "A " Postmark " client written in Racket.")))
   (project
    "py-test.el" "https://github.com/Bogdanp/py-test.el"
    "A Python test runner for Emacs.")
   (project
    "rackcheck" "https://github.com/Bogdanp/rackcheck/"
    "A property-based testing library for Racket with support for shrinking.")
   (project
    "racket-kafka" "https://github.com/Bogdanp/racket-kafka/"
    "A Racket client for Apache Kafka.")
   (project
    "racket-lua" "https://github.com/Bogdanp/racket-lua/"
    (haml (:span "A Racket " (:code "#lang") " implementation of Lua.")))
   (project
    "racket-protocol-buffers" "https://github.com/Bogdanp/racket-protocol-buffers/"
    "A Protocol Buffers implementation for Racket.")
   (project
    "racket-redis" "https://github.com/Bogdanp/racket-redis/"
    "Fast, idiomatic bindings to Redis for Racket.")
   (project
    "resource-pool" "https://github.com/Bogdanp/racket-resource-pool/"
    "A generic resource pool for Racket.")
   (project
    "resource_pool" "https://github.com/Bogdanp/resource_pool"
    "A generic resource pool for Python.")
   (project
    "review" "https://github.com/Bogdanp/racket-review/"
    "A linter for Racket.")
   (project
    "sass" "https://github.com/Bogdanp/racket-sass/"
    "Bindings to libsass for Racket.")
   (project
    "sentry" "https://github.com/Bogdanp/racket-sentry/"
    (haml (:span "A " Sentry " SDK for Racket.")))
   (project
    "setup-racket" "https://github.com/marketplace/actions/setup-racket-environment"
    "A GitHub Action for installing Racket.")
   (project
    "smtp-server" "https://github.com/Bogdanp/racket-smtp-server"
    "An SMTP server implementation for Racket.")
   (project
    "twilio" "https://github.com/Bogdanp/racket-twilio/"
    (haml (:span "A " Twilio " client for Racket.")))
   (project
    "wasm" "https://github.com/Bogdanp/racket-wasm/"
    "A WASM VM written in Racket.")
   (project
    "watchdog_gevent" "https://github.com/Bogdanp/watchdog_gevent"
    "A gevent-based observer for watchdog.")
   (project
    "web-app-from-scratch" "https://github.com/Bogdanp/web-app-from-scratch"
    "Supporting material for my \"Web App From Scratch\" blog series.")))

(define website-projects
  (list
   (project
    "Racksnaps" "https://racksnaps.defn.io"
    "Daily snapshots of the official Racket package catalog.")
   (project
    "Task Queues" "https://taskqueues.com"
    "A list of message brokers and task queues across many programming languages and implementations.")))
