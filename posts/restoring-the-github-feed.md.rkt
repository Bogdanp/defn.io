#lang punct

---
title: Restoring the Old Dashboard Feed on GitHub
date: 2023-09-23T13:00:00+03:00
---

A couple weeks ago, GitHub changed its Dashboard feed implementation and
this new version has a lot less relevant information with respect to the
repositories I follow compared to the old one. Fortunately, the old feed
is still available at `/dashboard-feed`. So, for now, you can restore
the old functionality using this quick and dirty user script:

```javascript
document.addEventListener("DOMContentLoaded", () => {
  const $news = document.querySelector("#dashboard .news");
  if (!$news) return;
  let node = $news.firstChild;
  while (node !== null) {
    $news.removeChild(node);
    node = $news.firstChild;
  }

  const req = new XMLHttpRequest();
  req.open("GET", "/dashboard-feed", true);
  req.addEventListener("load", (e) => {
    let $frame = document.createElement("iframe");
    $frame.style.display = "none";
    $frame.onload = () => {
      $news.appendChild($frame.contentDocument.querySelector(".application-main"));
    };
    $frame.srcdoc = req.responseText;
    $news.appendChild($frame);
  });
  req.send(null);
})
```

In [Arc], you can enable this script by going to github.com, creating
a new boost and placing the script in the boost's code section.  In
Firefox, you should be able to use a plugin like Tampermonkey to
achieve the same thing.

Hopefully, they'll keep the old feed around for a while, or bring the
new feed's functionality up to par with the old one in future.

[Arc]: https://arc.net/
