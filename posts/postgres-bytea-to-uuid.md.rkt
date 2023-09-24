#lang punct

---
title: Converting byte arrays to UUIDs in Postgres
date: 2020-04-05T19:00:00+03:00
---

For a project that I'm working on, I have a custom flake id [spec] that
allows me to generate unique, sortable identifiers across computers
without any sort of synchronization. The ids themselves can be encoded
down to 16 bytes and I wanted to store them in Postgres. A good way
to do that is to leverage Postgres' `UUID` data type, which lets you
efficiently store any 16 byte quantity in a way that can be indexed
reasonably well.

The problem I ran into was that my [DB library of choice][db-lib] only
supports inserting UUID values that follow the standard UUID format, so
queries like

```sql
INSERT INTO the_table(uuid_column) VALUES ($1)
```

would get rejected at runtime unless `$1` actually looked like a UUID.

I considered converting the ids into the standard UUID format within
my application code but that didn't feel like the right thing to do.
Instead, I found that Postgres has a standard function called [`encode`]
that is able to take any byte array and encode it into a hex string so
all I had to do was change my query into

```sql
INSERT INTO the_table(uuid_column) VALUES (CAST(ENCODE($1, 'hex') AS UUID))
```

and that worked great!

[spec]: https://github.com/Bogdanp/racket-buid/blob/5806054cbea5e69fae66a0b6d622752ace690afd/README.md#spec
[db-lib]: https://github.com/racket/db/blob/3ce8e6b073cedc485011130d0d0c54475800c2a2/db-lib/db/util/postgresql.rkt#L110
[`encode`]: https://www.postgresql.org/docs/12/functions-binarystring.html
