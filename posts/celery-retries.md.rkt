#lang punct

---
title: Automatic retries with Celery
date: 2018-02-25T00:00:00+00:00
---

One of the things that I think Celery could be doing better out of the
box is to provide support for automatically retrying tasks on failure
(thereby forcing users to write idempotent tasks by default).

Fortunately, you can achieve this using [signals], specifically the
[task-failure] signal. All you have to do is connect to it and call the
`retry` method on your task:

```python
import logging

from celery import signals


@signals.task_failure.connect
def retry_task_on_exception(*args, **kwargs):
  task = kwargs.get("sender")
  einfo = kwargs.get("einfo")
  logging.warning("Uncaught exception: %r for task: %s", einfo, task)
  task.retry(countdown=3600)
```

The above will retry failing tasks once an hour. The task object also
contains information about how many times it's been retried and you can
use that information in order to retry tasks with exponential backoff
and to make them stop after a while. For example:

```python
@signals.task_failure.connect
def retry_task_on_exception(*args, **kwargs):
  task = kwargs.get("sender")
  einfo = kwargs.get("einfo")
  logging.warning("Uncaught exception: %r for task: %s", einfo, task)

  # Backoffs: 60, 120, 240, 480, 960, 1920, 3600, 3600, ...
  backoff = min(60 * 2 ** task.request.retries, 3600)
  task.retry(countdown=backoff)
```

Not too bad. One caveat with this approach is you might run into issues
if you have a large volume of failing tasks due to Celery's weak support
for delayed tasks.

Check out [dramatiq] if you'd rather not have to worry about this kind
of stuff.


[dramatiq]: https://dramatiq.io
[signals]: http://docs.celeryproject.org/en/latest/userguide/signals.html
[task-failure]: http://docs.celeryproject.org/en/latest/userguide/signals.html#task-failure
