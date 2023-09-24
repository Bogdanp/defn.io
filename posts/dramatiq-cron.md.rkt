#lang punct

---
title: Dramatiq cron with APScheduler
date: 2018-01-11T00:00:00+00:00
---

Here's a quick way you can combine [Dramatiq] and [APScheduler] to
automatically schedule tasks to execute at certain times.

Install Dramatiq and APScheduler using [pipenv]:

    pipenv install dramatiq apscheduler

Next, declare a task and decorate it with `@cron`. We'll define the cron
function afterwards. In a module called `tasks.py`, add the following
code:

```python
import dramatiq

from cron import cron
from datetime import datetime


@cron("* * * * *")  # Run once a minute
@dramatiq.actor
def print_current_datetime():
    print(datetime.now())
```

Then define the decorator in `cron.py`:

```python
import importlib

from apscheduler.triggers.cron import CronTrigger

JOBS = []


def cron(crontab):
    """Wrap a Dramatiq actor in a cron schedule.
    """
    trigger = CronTrigger.from_crontab(crontab)

    def decorator(actor):
        module_path = actor.fn.__module__
        func_name = actor.fn.__name__
        JOBS.append((trigger, module_path, func_name))
        return actor

    return decorator
```

`JOBS` is where the job definitions are stored. When we run the
scheduler from the command line, we'll iterate over this list and
register jobs based on entries made here.

`cron` just builds a cron trigger and adds a job definition to `JOBS`.

Now that we have all the components in place, we just need a way to run
a scheduler from the command line. In a file called `run_cron.py` add
the following:

``` python
import cron
import logging
import signal
import sys
import tasks  # imported for its side-effects

from apscheduler.schedulers.blocking import BlockingScheduler

logging.basicConfig(
    format="[%(asctime)s] [PID %(process)d] [%(threadName)s] [%(name)s] [%(levelname)s] %(message)s",
    level=logging.DEBUG,
)

# Pika is a bit noisy w/ Debug logging so we have to up its level.
logging.getLogger("pika").setLevel(logging.WARNING)


def main():
    scheduler = BlockingScheduler()
    for trigger, module_path, func_name in cron.JOBS:
        job_path = f"{module_path}:{func_name}.send"
        job_name = f"{module_path}.{func_name}"
        scheduler.add_job(job_path, trigger=trigger, name=job_name)

    def shutdown(signum, frame):
        scheduler.shutdown()

    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    scheduler.start()
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

Here we set up logging, instantiate a blocking scheduler and register
all the jobs that were declared in `tasks.py` -- which is why we import
it in the first place, if we didn't, then the code that registers the
jobs would never run. Finally, we add a signal handler to shut down the
scheduler whenever the process receives a `SIGINT` or a `SIGTERM`.

Run `rabbitmq-server` then `python run_cron.py` and `dramatiq tasks` in
a separate terminal and you're done! You should see your workers print
the current time once a minute.


[Dramatiq]: https://dramatiq.io/
[APScheduler]: https://apscheduler.readthedocs.io/en/latest/
[pipenv]: http://pipenv.org/
