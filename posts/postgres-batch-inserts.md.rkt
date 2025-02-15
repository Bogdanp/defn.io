#lang punct

---
title: Batch Inserts in PostgreSQL
date: 2025-02-15T11:40:00+02:00
---

I recently added [support for batch inserts] to [koyo] and thought
I'd make a quick post about it. Here's what it looks like to use this
feature:

``` racket
(define ib
  (make-insert-batcher
   #:on-conflict '(do-nothing (ticker))
   'tickers
   '([isin "TEXT"]
     [ticker "TEXT"]
     [added_at "TIMESTAMPTZ"])))
(with-database-connection [conn db]
  (for ([(isin ticker added-at) (in-sequence datasource)])
    (ib-push! ib conn isin ticker added-at))
  (ib-flush! ib conn))
```

You create a batcher, tell it what table to insert the data into and
what columns to insert, then push data into it and flush it at the
end. Pushing may trigger a flush when too many rows have accumulated,
according to an optional `#:batch-size` argument.

In the past, when I built a batcher like this, I did it by accumulating
the row data into an array and, on flush, generating an `INSERT`
statement with a row-wise set of placeholder parameters. Like this:

``` sql
INSERT INTO tickers(
  isin, ticker, added_at
) VALUES
  ($1, $2, $3),
  ($4, $5, $6),
  ...
  ($(n*3+1), $(n*3+2), $(n*3+3))
```

This works fine for the most part, but it has a couple of problems.
First, the maximum number of parameters to an insert statement in
Postgres is 65536, so at most `65k/n-columns` rows may be batched in
memory before a flush is required. Second, this has the obvious problem
that every flush requires sending a new, long query to the database,
so this approach can't easily leverage prepared statements. The latter
doesn't seem to have a huge impact, but it's still some unnecessary
inefficiency.

This time around, I decided to buffer the values in column-wise arrays.
On flush, those arrays are passed to the insert statement directly and
I use `UNNEST` to turn them into a virtual table to insert from. That
looks like this:

``` sql
INSERT INTO tickers(
  isin, ticker, added_at
) SELECT * FROM UNNEST(
  $1::TEXT[],
  $2::TEXT[],
  $3::TIMESTAMPTZ[]
) AS t(isin, ticker, added_at)
```

So, the end result is a much shorter query that can be prepared ahead of
time and reused between flushes. It also means we can buffer more rows
in memory before flushing. The only disadvantage is that the batcher
needs to know what the individual column types are ahead of time, hence
the last positional argument to `make-insert-batcher`.

[support for batch inserts]: https://docs.racket-lang.org/koyo/database.html#%28part._database-batch%29
[koyo]: https://docs.racket-lang.org/koyo/
