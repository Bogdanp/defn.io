#lang punct "../common.rkt"

---
title: #lang lua
date: 2022-11-12T20:00:00+02:00
---

I'm currently working on [a macOS app][app] that's built with Racket and
allows the user to write small scripts to process and filter some data.
While Racket is definitely _my_ preferred language and I could easily
use it for these scripts, my target audience for this app would probably
appreciate a more familiar language. I decided to use [Lua]. So, last
weekend I was faced with a choice[^1] between writing FFI bindings for
Lua or implementing a [#lang] in Racket. Of course, I picked the harder
option. Partly because it seemed like the more fun option, and partly
because this way I don't have to worry about making two (three? did I
mention Swift's also in the mix?) very different runtimes cooperate.

It's pretty far along at this point, though some Lua standard library
functionality is still missing and a couple things are still missing
lexer support (long brackets, scientific notation for numbers). If you
want to play around with it, you can get it from the package server
by installing `lua-lang` or `lua-lib` if you don't want the docs.
You can find the code [on GitHub][code] and the docs [on the package
server][docs].

•(img "racket-lua.png" "DrRacket Displaying a Lua Module")

[^1]: Before I started working on the #lang, I had checked the
documentation server to see if there was already an implementation.
I didn't find anything. Unfortunately, I forgot to check the package
server until I was ready to upload my own library. Long story short,
there are now (at least) two[^2] independent implementations of Lua as a
#lang for Racket. Whoops.

[^2]: The other one you can find [here][lure].

[Lua]: https://lua.org
[#lang]: https://docs.racket-lang.org/guide/Module_Syntax.html#%28part._hash-lang%29
[code]: https://github.com/Bogdanp/racket-lua
[docs]: https://docs.racket-lang.org/lua-manual@lua-lang/index.html
[lure]: https://github.com/ShawSumma/lure
[app]: /2022/11/20/ann-franz
