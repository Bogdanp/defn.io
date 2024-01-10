#lang punct "../common.rkt"

---
title: One Billion Row Challenge in Racket
date: 2024-01-10T21:51:00+02:00
---

I decided to have some fun tonight and work on a Racket solution to
[the One Billion Row Challenge][gh]. I came up with a (pretty gnarly)
solution that completes in about 45 seconds on my machine, a 2023
12-core Apple M2 Max with 96GB of RAM. This is about on par with the
lower end of the optimized Java solutions shown in the challenge repo's
`README`, when I run them on the same machine.

You can find the solution in this [GitHub Gist][solution]. It works by
splitting the work across several [places][places][^1], where each place
iterates over the input file in full. I initially attempted an approach
where the main place read the whole file into a `shared-bytes` value and
then dispatched work to separate places, but that turned out to have too
much overhead from the places accessing the shared bytes. I had also
tried an approach where the main place sent individual work units (i.e.
lines) to the worker places, but that was killed by the overhead of
`place-channel-put`[^2].

[^1]: You might have noticed I spawned one place for every two CPU
    cores on my machine. This turned out to be more performant than
    trying to use one place per core, presumably because there was
    less synchronization overhead between places.

[^2]: My guess would be the issue here was partly contract checks and
    partly the overhead of copying the bytes between places. It would
    be nice if we had support for some kind of shared immutable bytes
    with less overhead than regular shared bytes. That way one could
    send the shared immutable bytes over to the worker places once and
    subsequently send pairs of start and end indexes representing the
    work units.

On boot, each place is given the path to the input file, the total
number of places (shards), its shard number and a place channel where it
can publish the aggregated data once it's done reading the file. Even
though each place iterates over the full input file, it only processes
those entries that match its shard number, skipping the rest and thereby
reducing the total number of work per place by the total number of
places.

The data gets read in in 10MB chunks, but the difference between buffer
sizes 1MB and over is negligible. The place-local data is stored in a
hash from location names to `state` structs that contain the number of
entries, the lowest temperature, the highest temperature and the sum of
all temperatures at that location, as seen by that particular place. Any
one location's data may be spread across different places, and there is
a final step to combine the data from every place by location and print
out the results.

Originally, I had used a regular Racket hash to store the place-local
data, but I eventually rolled my own [open-addressed] hash table to
avoid the cost of copying location names from the input buffer to
individual bytes values for use with `hash-ref!`. I don't remember
exactly how much time this saved, but I believe it was on the order
of about 10-15 seconds. This is probably less because my hash is any
good (it's not), and more because copying so many little strings gets
expensive fast. The code goes to great lengths to avoid copying as much
as possible and, thankfully, the built-in bytes procedures are set up to
help as much as they can.

A couple more minor, but potentially-interesting, things about the code
are its use of `#%declare` to disable some contract checks, and the
`filtered-in` require to rename imports from `racket/unsafe/ops` to drop
the `unsafe-` prefix.

I'm not completely satisfied with the result, so I may spend some more
time in the coming days trying to come up with ways to make this code
faster. Let me know if you have any ideas!

[gh]: https://github.com/gunnarmorling/1brc?tab=readme-ov-file
[solution]: https://gist.github.com/Bogdanp/b1edba407b5f7ab8794e0cb5ac197d34
[places]: https://docs.racket-lang.org/guide/parallelism.html#%28tech._place%29
[open-addressed]: https://en.wikipedia.org/wiki/Open_addressing
