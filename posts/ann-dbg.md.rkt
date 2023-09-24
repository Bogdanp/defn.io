#lang punct "../common.rkt"

---
title: Announcing dbg
date: 2021-10-04T09:10:00+03:00
---

I recently started working on a remote debugging/monitoring tool for
Racket programs. It comes with a TCP server for exposing debugging
information, a client implementation, and a GUI that builds upon
those two things. You run the server as part of your application and
then connect to it via the UI to debug things. Currently, it provides
insights into GC pauses, current memory usage by data type, and a way to
run and visualize performance profiles.

Below, you can see a short demo of dbg in action. The library is
available on the package server and you can find the source code on
[GitHub][dbg].

•(youtube-embed "KqRq1t9Ey8k")

[dbg]: https://github.com/Bogdanp/racket-dbg
