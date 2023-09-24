#lang punct "../common.rkt"

---
title: Building a PDF API with Django and Dramatiq
date: 2017-11-12T20:12:43+02:00
---

In this post I talk about how you can use [Django][django],
[Dramatiq][dramatiq] and [h2p] to create a simple HTTP API that can turn
any URL into a PDF.

## What is Dramatiq?

Dramatiq is a distributed task processing library for Python 3 that I've
been working on as an alternative to [Celery][celery]. Using Dramatiq,
you can transparently run functions in the background across a large
number of machines. In this post I'm going to use it to offload the work
of generating PDFs from the web server onto a background processing
server.

### Why use a task queue?

Long-running or computationally-intensive tasks in the middle of the
request-response cycle of a web server can severily impact the latency
and throughput of that server. A common pattern to work around this
issue is to use a task queue to offload the parts of the request that
can be done later and in the background off to a different fleet of
servers known as workers. This has other advantages, too: tasks may
easily be retried later in case there's an error and you can run tasks
completely outside of the request-response cycle (eg. using a cron job).

Generating PDFs from web pages is a slow process so we want to take that
out of the request and give the requester a way to poll for the result
of the operation.

## Setup

First things first, we're going to need a message broker. Dramatiq
currently works with [Redis] and [RabbitMQ], but for this post I'm going
to use RabbitMQ. To install it on macOS, you can run:

```bash
$ brew install rabbitmq
```

Run it with `rabbitmq-server`.

Next, we're going to create a new virtual environment and, inside
of that environment, use [pipenv] to install all the prerequisite
libraries:

```bash
$ pipenv install django djangorestframework django_dramatiq "dramatiq[rabbitmq, watch]" h2p
```

•(haml
  (:small
   (:code "django_dramatiq")
   " is a small Django app that makes integrating Dramatiq and Django easy."))

After that's done, we're going to create a Django project called
`pdfapi`:

```bash
$ django-admin.py startproject pdfapi .
```

Finally, we need to configure `django_dramatiq` to use RabbitMQ. In
`pdfapi/settings.py`, add `django_dramatiq` and `rest_framework` to your
`INSTALLED_APPS`:

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'django_dramatiq',
    'rest_framework',
]
```

And configure the broker in the same file:

```python
DRAMATIQ_BROKER = {
    "BROKER": "dramatiq.brokers.rabbitmq.RabbitmqBroker",
    "OPTIONS": {
        "url": "amqp://localhost:5672",
    },
    "MIDDLEWARE": [
        "dramatiq.middleware.Prometheus",
        "dramatiq.middleware.AgeLimit",
        "dramatiq.middleware.TimeLimit",
        "dramatiq.middleware.Retries",
        "django_dramatiq.middleware.AdminMiddleware",
        "django_dramatiq.middleware.DbConnectionsMiddleware",
    ]
}
```

Let's run the migrations and then the server to make sure everything's
working so far:

```bash
$ python manage.py migrate
$ python manage.py runserver
```

If you visit http://127.0.0.1:8000, you should now see the familiar
"Congratulations on your first Django-powered page" view. Kill the
server and create a new app called `pdfs`:

```bash
$ python manage.py startapp pdfs
```

## The API

The API we're going to define is going to be very simple.  It will
accept `POST` requests to `/v1/pdfs` containing the `url` we're
expected to convert into a PDF, these requests will submit a task to
generate the PDF and immediately return a JSON object with an `id` and
a `status` field that the caller can then use to keep track of the
job.

Using the `id` field from the response, the caller will be able to
poll `/v1/pdfs/{id}` to find out what the status of the task is.

### The PDF model

In `pdfs/models.py` declare the following model:

```python
class PDF(models.Model):
    STATUS_PENDING = "pending"
    STATUS_FAILED = "failed"
    STATUS_DONE = "done"
    STATUSES = [
        (STATUS_PENDING, "Pending"),
        (STATUS_FAILED, "Failed"),
        (STATUS_DONE, "Done"),
    ]

    source_url = models.CharField(max_length=512)
    status = models.CharField(
        max_length=10,
        default=STATUS_PENDING,
        choices=STATUSES,
    )

    @property
    def filename(self):
        raise NotImplementedError

    @property
    def pdf_url(self):
        raise NotImplementedError
```

We're going to skip the implementations of the `filename` and
`pdf_url` properties for now.

Build and run the migrations:

```bash
$ python manage.py makemigrations
$ python manage.py migrate
```

Then add a serializer for that model in `pdfs/serializers.py`:

```python
from rest_framework import serializers

from .models import PDF


class PDFSerializer(serializers.ModelSerializer):
    source_url = serializers.URLField(max_length=512)
    pdf_url = serializers.URLField(read_only=True)

    class Meta:
        model = PDF
        fields = ("id", "source_url", "pdf_url", "status")
        read_only_fields = ("status",)
```

We're going to use this serializer to render PDF models as JSON and to
validate incoming requests.

### The Views

In `pdfs/views.py` add the following views:

```python
from django.views.decorators.csrf import csrf_exempt
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response

from .models import PDF
from .serializers import PDFSerializer


@csrf_exempt
@api_view(["POST"])
def create_pdf(request):
    serializer = PDFSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(["GET"])
def view_pdf(request, pk):
    try:
        pdf = PDF.objects.get(pk=pk)
        serializer = PDFSerializer(pdf)
        return Response(serializer.data)
    except PDF.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)
```

And then hook them up in `pdfs/urls.py`:

```python
from django.conf.urls import url

from . import views

app_name = "pdfs"
urlpatterns = [
    url(r"^$", views.create_pdf, name="create_pdf"),
    url(r"^(?P<pk>\d+)$", views.view_pdf, name="view_pdf"),
]
```

Add the `pdfs` app to `pdfapi/settings.py`:

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'django_dramatiq',
    'rest_framework',

    'pdfs',
]
```

Finally, include the `pdfs` urls in `pdfapi/urls.py`:

```python
from django.conf.urls import url, include
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^v1/pdfs/', include("pdfs.urls")),
]
```

At this point if you run the development server and visit `/v1/pdfs`
you should be able to interact with the API.

## The Task

So far we've declared the model and an API that lets us interact with
it, but we haven't done anything to actually generate PDFs so every
PDF we create using the API is going to be in a perpetual `pending`
state.  Let's fix that.

In `pdfs/tasks.py` add the following task:

```python
import dramatiq
import h2p

from .models import PDF


@dramatiq.actor
def generate_pdf(pk):
    pdf = PDF.objects.get(pk=pk)

    try:
        h2p.generate_pdf(
            pdf.filename,
            source_uri=pdf.source_url,
        ).result()

        pdf.status = PDF.STATUS_DONE
    except h2p.ConversionError:
        pdf.status = PDF.STATUS_FAILED

    pdf.save()
```

Let's break this down a little bit.  `generate_pdf` is just a normal
Python function that we've decorated with `@dramatiq.actor`.  This
makes it possible to run the function asynchronously.

`generate_pdf` takes a `pk` parameter representing the id of a `PDF`,
this is important because tasks are distributed and we wouldn't want
to send entire `PDF` objects over the network.  It delegates the work
of actually creating the PDF to `h2p` and updates the `PDF` object's
status based on the result of that operation.

We're passing the `filename` property of `PDF` to `h2p.generate_pdf`
but we haven't implemented it yet so let's fill it and `pdf_url` in on
the `PDF` model in `pdfs/models.py`:

```python
    @property
    def filename(self):
        return f"{settings.MEDIA_ROOT}{self.pk}.pdf"

    @property
    def pdf_url(self):
        return f"{settings.MEDIA_URL}{self.pk}.pdf"
```

Don't forget to add `MEDIA_ROOT` and `MEDIA_URL` to
`pdfapi/settings.py`:

```python
MEDIA_ROOT = os.path.join(BASE_DIR, "files/")
MEDIA_URL = "/media"
```

Create the `files` folder and then add a static handler to
`pdfapi/urls.py`:

```python
from django.conf import settings
from django.conf.urls import url, include
from django.conf.urls.static import static
from django.contrib import admin

urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url(r'^v1/pdfs/', include("pdfs.urls")),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

# Hooking 'em up

At this point we've created a task that can generate PDF files and an
API that can submit and keep track of that work.  Let's hook them up!

In the `create_pdf` view from `pdfs/views.py` change the
`serializer.save()` call to:

```python
    if serializer.is_valid():
        pdf = serializer.save()
        generate_pdf.send(pdf.pk)
        return Response(serializer.data)
```

Now every time someone creates a `PDF` object using the API, we'll
enqueue a `generate_pdf` task.  Spin up the API server and some
Dramatiq workers and test it out.

```bash
$ python manage.py runserver
$ python manage.py rundramatiq  # in a separate terminal window
```

To test it out, send a create request using curl:

```bash
$ curl -d"source_url=http://example.com" http://127.0.0.1:8000/v1/pdfs/
{"id":1,"source_url":"http://example.com","pdf_url":"/media/1.pdf","status":"pending"}
```

Then poll using GET requests until it's ready:

```bash
$ curl http://127.0.0.1:8000/v1/pdfs/1
{"id":1,"source_url":"http://example.com","pdf_url":"/media/1.pdf","status":"done"}
```

Finally, visit http://127.0.0.1:8000/media/1.pdf to view the generated PDF.

# Next Steps

You can find the full code on [GitHub][source]. If you want to
learn more about Dramatiq (and hopefully you do!) head on to the
[docs][dramatiq]. I've put a lot of work into making them as accessible
as possible.

Happy coding!


[RabbitMQ]: https://www.rabbitmq.com/
[Redis]: https://redis.io
[celery]: http://www.celeryproject.org
[django]: http://djangoproject.com
[django_dramatiq]: https://github.com/Bogdanp/django_dramatiq
[dramatiq]: https://dramatiq.io
[h2p]: https://github.com/Bogdanp/h2p
[pipenv]: https://docs.pipenv.org
[source]: https://github.com/Bogdanp/django_dramatiq_pdfapi_example
