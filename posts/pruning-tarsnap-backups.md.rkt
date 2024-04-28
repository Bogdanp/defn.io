#lang punct

---
title: Pruning Tarsnap Backups
date: 2024-04-28T16:00:00+03:00
---

I use [Tarnsap] to back up my data and I like it a lot, but it gets
fairly expensive once you accumulate a lot of backups.

At some point, I found [prunef] and started using it to prune my
backups. It's a backup tool-agnostic utility that takes an unsorted list
of backup filenames with timestamps in their name, a set of rotation
rules, specified via command line flags, and it returns a set of backups
to delete.

To use it with tarsnap, I just pipe the output of `tarsnap
--list-archives` to `prunef` and save the result to a file called
`todo`:

```bash
tarsnap --list-archives | \
  prunef \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    'mbp_%Y-%m-%d_%H-%M-%S' | \
  tee todo
```

Then, I iterate over the entries in the `todo` files and delete each
one individually:

```bash
while IFS='' read -r archive; do
  tarsnap -d -f "$archive"
done < <(sort todo)
```

[Tarnsap]: https://www.tarsnap.com/
[prunef]: https://git.sr.ht/~apreiml/prunef/
