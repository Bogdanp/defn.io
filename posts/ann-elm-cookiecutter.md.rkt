#lang punct

---
title: Announcing elm-cookiecutter
date: 2016-06-24T00:00:00+00:00
---

Since most of my Elm apps tend to follow a similar structure, I've
decided to create and open source a [cookiecutter][cc] template that
deals with all of the boilerplate required to set up one of these apps
the way I like it. The repository is available [here][repo].

## Quickstart

To get started immediately:

1. `pip install cookiecutter`
1. `cookiecutter gh:Bogdanp/elm-cookiecutter`

You will be prompted for a project name and description.  Once you've
completed the process, `cd` into `$PROJECT_NAME` and run:

1. `npm install`
1. `make serve`

The latter will build your sources, start up a web server and open the
app in a web browser.  Once you've made changes to any of the sources,
run `make` again to rebuild or run `make watch` in a separate terminal
to have it automatically rebuild the app when any of the sources
change.

To produce a production build, run `env NPM_ENV=prod make`.

## Structure

Some of the more interesting files are described below.

```
.
├── Makefile               # Rules for building the app. See `make help`
├── README.md              # The app's README
├── bin
│   └── server.js          # The development server. Points all nonexistent paths to `index.html`
├── build
│   ├── index.html
│   └── js                 # The final product ends up in js/app.js. This includes styles
├── css
│   ├── app.scss           # The entrypoint for styles
│   └── normalize.scss     # A slightly modified Normalize.css
├── elm
│   ├── Main.elm           # The entrypoint for Elm code
│   ├── Model.elm          # Definitions for Flags, the Model and the root Msg. Referenced by Update and View
│   ├── Pages
│   │   └── Dashboard.elm
│   ├── Routes.elm
│   ├── Update.elm
│   ├── Util.elm
│   └── View.elm
├── elm-package.json
├── js
│   └── app.js             # Sets up the Elm app and deals with flags, subscriptions and ports
├── package.json
└── webpack.config.js

7 directories, 17 files
```


[cc]: https://github.com/audreyr/cookiecutter
[repo]: https://github.com/Bogdanp/elm-cookiecutter
