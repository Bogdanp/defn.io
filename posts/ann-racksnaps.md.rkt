#lang punct

---
title: Announcing racksnaps
date: 2020-05-03T14:00:00+03:00
---

Racket's package manager doesn't currently have the notion of locking
package sets to specific versions[^1] per project so, as someone who
operates a couple production Racket applications, I've been concerned
about the possibility that new deployments could introduce bugs in
production due to changing dependencies.

To solve this problem, over the past weekend I've put together a service
that creates daily snapshots of the official package catalog. You can
find it at [racksnaps.defn.io].

Every day at 12am UTC, the service queries all the packages on
[pkgs.racket-lang.org] for metadata and source locations. It then
creates a source package archive for each package whose sources are
still valid.

Once all the source package archives are created, "built" packages
(packages that contain source code, docs and compiled `.zo` files) are
created from those archives. Each of these is compiled in isolation and
any packages that don't compile cleanly are excluded from the final
snapshot.

Snapshots are never modified once they succeed and a content addressing
scheme is used for the individual packages to avoid using up too much
disk space over time.

I plan to keep snapshots around indefinitely and I may add support
for paid features like custom package sets eventually -- if there is
interest -- to help support the hosting costs.

## An Example

Say you've just started working on a new application. To develop against
the snapshot from May 2nd, 2020 using Racket 7.6, you might run the
following command:

    raco pkg config --set catalogs \
        https://download.racket-lang.org/releases/7.6/catalog/ \
        https://racksnaps.defn.io/snapshots/2020/05/02/catalog/ \
        https://pkgs.racket-lang.org \
        https://planet-compats.racket-lang.org

This will make it so that any packages you install will first look up
the 7.6 release catalog (for packages in the "main distribution", like
`rackunit` and `typed-racket`), then it'll look up packages in the
snapshot and fall back to the package catalog for any packages not in
the snapshot.

When building the application in CI you might limit the catalog list to
just the release catalog (for packages in the main distribution) and the
snapshot:

    raco pkg config --set catalogs \
        https://download.racket-lang.org/releases/7.6/catalog/ \
        https://racksnaps.defn.io/snapshots/2020/05/02/catalog/

To speed up builds, you might layer in the built-snapshot for that day:

    raco pkg config --set catalogs \
        https://download.racket-lang.org/releases/7.6/catalog/ \
        https://racksnaps.defn.io/built-snapshots/2020/05/02/catalog/ \
        https://racksnaps.defn.io/snapshots/2020/05/02/catalog/

Days/weeks/months/years later, when you're ready to deal with upgrading
your dependencies, you can update to a more recent snapshot and repeat
the cycle.

I'm receptive to feedback on how to improve the service so don't
hesitate to reach out if you think of anything!


[^1]: Technically, it does support pinning a specific sha per package
when using git sources, but that is pretty cumbersome and it means
that packages always have to be installed from source, which increases
install times by 2 to 3x.

[racksnaps.defn.io]: https://racksnaps.defn.io
[pkgs.racket-lang.org]: https://pkgs.racket-lang.org
