#lang punct

---
title: Announcing h2p
date: 2017-11-05T00:00:00+00:00
---

This past week I released [h2p][h2p], a simple python frontend to
[libwkhtmltox][wk] that lets you generate PDF files from web pages
without needing to spawn subprocesses.

You can use pip or pipenv to install it:

    pipenv install h2p

And the API is straightforward:

```python
import h2p

websites = ["https://google.com", "https://example.com", "https://defn.io"]

tasks = []
for i, website in enumerate(websites, 1):
   filename = f"output-{i}.pdf"
   tasks.append(h2p.generate_pdf(filename, website))
   print(f"Enqueued task for {website!r} -> {filename!r}.")

# ... do other stuff while your pdfs are being generated ...

for task in tasks:
   task.result()

print("All tasks are done.")
```

Each call to `generate_pdf` returns an asynchronous task that represents
the action of generating that pdf. Calling `result` on that task will
block until it's done.


[h2p]: https://github.com/Bogdanp/h2p
[wk]: https://wkhtmltopdf.org
