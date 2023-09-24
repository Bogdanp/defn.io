#lang punct

---
title: ido-mode
date: 2015-10-12T00:00:00+00:00
---

Ido mode is one of those Emacs packages that you can't imagine living
without once you embed it into your workflow. It stands for "interactive
do" and in this post I'm going to talk about what it does, some of the
configuration options that come bundled with it and how you can enhance
it further.

## What it does

Ido extends the built-in `find-file` and `switch-to-buffer`
commands with interactive completion. It displays all the items
that are available to you based on the current selection, narrowing
down to the most relevant ones as you type to expand said
selection. You can find a brief demonstration of this functionality
[here](https://asciinema.org/a/27740).

Turn it on by calling `ido-mode`.

```emacs-lisp
(require 'ido)
(ido-mode)
```

Calling `ido-everywhere` will ensure that ido is used for all buffer and
file selections in Emacs.

```emacs-lisp
(ido-everywhere)
```

If, for some reason, you'd prefer to only apply ido to one of those
commands but not the other you can do so by calling `ido-mode` with a
`​'buffer` or `​'file` argument to limit ido to buffer switching and
finding files respectively.

### Completion

As you type, ido narrows the result set based on which items your
selection is a substring of. You can select the first result by pressing
`RET` and you can cycle through the result set at any point with `C-s`
and `C-r`. This can pose a problem if, for example, you want to create
a new file whose name is a substring of another file in the current
directory. You can use `C-j` to tell ido to use whatever you typed
verbatim.

Ido limits the list of visible completions to a few at a time, but if
you want to view the full list of available completions you can hit `?`.
Doing so will display all of the available completions in a separate
buffer.

#### Prefix matching

Toggle prefix matching inside an ido buffer by hitting `C-p`. This is
similar to the standard Emacs completion method in that it will only
display results that start with your selection.

You can make prefix matching the default behavior by setting
`ido-enable-prefix` to a truthy value.

```emacs-lisp
(setq ido-enable-prefix t)
```

#### Flexible matching

Ido's flexible matching makes it so that any items containing all of the
selection's characters in order will appear in the result set.

Turn it on by setting `ido-enable-flex-matching` to a truthy value.

```emacs-lisp
(setq ido-enable-flex-matching t)
```

### Finding files

`ido-find-file` comes with a few file-specific bindings. Find more
information about this command with `C-h f ido-find-file RET`.

I most commonly use `C-d` to open the current matching directory in
dired and `C-k` to delete the current matching file.

To ignore certain file extensions when finding files set
`ido-ignore-extensions` to a truthy value and add the extension to the
`completion-ignored-extensions` list.

```emacs-lisp
(setq ido-ignore-extensions t)
(add-to-list 'completion-ignored-extensions ".pyc")
```

Sometimes it is convenient to use the filename under the cursor as a
starting point for ido completion, `ido-use-filename-at-point` tells ido
to do just that.

```emacs-lisp
(setq ido-use-filename-at-point 'guess)
```

By default, ido will ask for confirmation every time you attempt to
create a new buffer. This can become annoying if you like to create many
buffers. Turn it off with:

```emacs-lisp
(setq ido-create-new-buffer 'always)
```

### Switching buffers

As with finding files, switching buffers using ido comes with a number
of commands you can run on the current selection. Find out more about
this command with `C-h f ido-switch-buffer RET`.

I most commonly use `C-k` to kill the current matching buffer. If you
find that the buffer you meant to switch to isn't open, you can switch
to `find-file` by hitting `C-f`.

You can use `ido-switch-buffer` to switch to recently-used buffers by
enabling `ido-use-virtual-buffers`. Doing so will turn `recentf` mode
on which means you will be able to open a file in Emacs, close it then
start it back up and switch to that file's buffer as if it were already
open.

```emacs-lisp
(setq ido-use-virtual-buffers t)
```

## Extensions
### smex

[smex][smex] is an ido-based replacement for `M-x`. In addition to
bringing ido completion to `M-x`, `smex` maintains a list of your
most-used commands so that it can order results by frequency.

You can grab it off of [MELPA][melpa] and bind it to your preferred key.

```emacs-lisp
(require 'smex)
(smex-initialize)

;; My personal preference is C-;
(global-set-key (kbd "C-;") #'smex)
;; but you can also override M-x
(global-set-key (kbd "M-x") #'smex)
```

Smex comes with command completion for the current major mode. You can
use this by binding `smex-major-mode-commands` to a key.

```emacs-lisp
(global-set-key (kbd "M-X") #'smex-major-mode-commands)
```

[smex]: https://github.com/nonsequitur/smex
[melpa]: http://melpa.org/

### ido-ubiquitous

Like the name implies, [ido-ubiquitous][ido-ubiquitous] is a package
that attempts to weave in ido completion wherever it can. With this
package, most functions that use `completing-read` will automatically
start using ido for completion.

The package is available on MELPA and you can turn it on by calling
`ido-ubiquitous-mode`.

```emacs-lisp
(require 'ido-ubiquitous)
(ido-ubiquitous-mode)
```

If you run into any issues because of `ido-ubiquitous`, view
the documentation for `ido-ubiquitous-command-overrides` and
`ido-ubiquitous-function-overrides` by calling `describe-variable`
(bound to `C-h v` by default). You can use those variables to turn ido
off for specific functions or commands.

Note that `ido-ubiquitous` does not turn ido completion on for packages
that come with built in ido support (even if it is not turned on by
default) like Magit and Org mode. I have included a section below on how
you can turn ido on for both of those modes.

[ido-ubiquitous]: https://github.com/DarwinAwardWinner/ido-ubiquitous

### ido-vertical-mode

[ido-vertical-mode][ido-vertical-mode] modifies the ido completion
buffer so that it displays vertically rather than horizontally, making
it so that the most relevant completions are displayed at the top.

`ido-vertical-mode` is available on MELPA.

```emacs-lisp
(require 'ido-vertical-mode)
(ido-vertical-mode)
```

[ido-vertical-mode]: https://github.com/creichert/ido-vertical-mode.el

### ido-clever-match

Finally, [ido-clever-match][ido-clever-match] is a simple package I
wrote that wraps the built-in ido matching function in order to try to
provide predictable prefix, substring and flex matching. You can find
more information about how it works on its Github page but the gist of
it is it ranks matches based on class (`exact`, `prefix`, `substring` or
`flex`) and then some sub-metric within that class. The package ensures
that `prefix` matches always come before `substring` which always come
before `flex` matches.

It is available on MELPA and you can enable it with:

```emacs-lisp
(require 'ido-clever-match)
(ido-clever-match-enable)
```

If you find that you prefer ido's standard matching behavior and would
like to go back simply call `ido-clever-match-disable`.

[ido-clever-match]: https://github.com/Bogdanp/ido-clever-match

## Other packages

I've found that the following packages work particularly well when
paired with ido.

### Magit

[Magit][magit] comes with its own completion function which you can
replace with ido by setting `magit-completing-read-function` to
`magit-ido-completing-read`.

```emacs-lisp
(setq magit-completing-read-function #'magit-ido-completing-read)
```

[magit]: https://github.com/magit/magit

### Org mode

Like Magit, [Org mode][org-mode] comes with its own completion function
which you can replace with ido by setting `org-completion-use-ido` to a
truthy value.

The documentation recommends that you turn off
`org-outline-complete-in-steps` if you switch to ido completion.

```emacs-lisp
(setq org-completion-use-ido t
      org-outline-path-complete-in-steps nil)
```

[org-mode]: http://orgmode.org/

### Projectile

Ido is [Projectile's][projectile] default completion method. The
maintainers recommend you install [flx-ido][flx] for its flexible
matching but you can also use Projectile with ido-clever-match.

[projectile]: https://github.com/bbatsov/projectile
[flx]: https://github.com/lewang/flx

## Wrapping up

In closing, ido-mode is an extremely versatile package that can
massively enhance one's workflow when using Emacs.

I highly recommend you try it out!
