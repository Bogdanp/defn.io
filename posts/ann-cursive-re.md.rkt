#lang punct

---
title: Announcing cursive_re
date: 2018-10-22T12:04:55+03:00
---

I released [cursive_re] today. It's a *tiny* Python library made up of
combinators that help you write regular expressions you can read and
modify six months down the line.

Here's what it looks like:

```python
>>> from cursive_re import *
>>> domain_name = one_or_more(any_of(in_range("a", "z") + in_range("0", "9") + text("-")))
>>> domain = domain_name + zero_or_more(text(".") + domain_name)
>>> path_segment = zero_or_more(none_of("/"))
>>> path = zero_or_more(text("/") + path_segment)
>>> url = (
...     group(one_or_more(any_of(in_range("a", "z"))), name="scheme") + text("://") +
...     group(domain, name="domain") +
...     group(path, name="path")
... )
>>> str(url)
"(?P<scheme>[a-z]+)://(?P<domain>[a-z0-9\-]+(?:\.[a-z0-9\-]+)*)(?P<path>(?:/[^/]*)*)"
```

[cursive_re]: https://github.com/Bogdanp/cursive_re
