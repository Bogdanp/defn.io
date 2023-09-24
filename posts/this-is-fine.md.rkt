#lang punct

---
title: This is Fine
date: 2022-12-18T15:25:00+02:00
---

*This post is a dumb rant, but I needed to vent.*

As I often do when I'm bored or procrastinating, I decided to update
some of the software on my machine today.  As usual, this was a
mistake.

I ran the following command:

```
$ sudo port upgrade yubikey-manager ykpers
```

And its output was:

```
--->  Computing dependencies for py310-semantic_version
--->  Fetching archive for py310-semantic_version
--->  Attempting to fetch py310-semantic_version-2.10.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-semantic_version
--->  Attempting to fetch py310-semantic_version-2.10.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-semantic_version
--->  Installing py310-semantic_version @2.10.0_0
--->  Activating py310-semantic_version @2.10.0_0
--->  Cleaning py310-semantic_version
--->  Computing dependencies for py310-typing_extensions
--->  Fetching archive for py310-typing_extensions
--->  Attempting to fetch py310-typing_extensions-4.4.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-typing_extensions
--->  Attempting to fetch py310-typing_extensions-4.4.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-typing_extensions
--->  Installing py310-typing_extensions @4.4.0_0
--->  Activating py310-typing_extensions @4.4.0_0
--->  Cleaning py310-typing_extensions
--->  Computing dependencies for jemalloc
--->  Fetching archive for jemalloc
--->  Attempting to fetch jemalloc-5.3.0_2.darwin_22.arm64.tbz2 from https://packages.macports.org/jemalloc
--->  Attempting to fetch jemalloc-5.3.0_2.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/jemalloc
--->  Attempting to fetch jemalloc-5.3.0_2.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/jemalloc
--->  Fetching distfiles for jemalloc
--->  Attempting to fetch jemalloc-5.3.0.tar.bz2 from https://distfiles.macports.org/jemalloc
--->  Verifying checksums for jemalloc
--->  Extracting jemalloc
--->  Applying patches to jemalloc
--->  Configuring jemalloc
--->  Building jemalloc
--->  Staging jemalloc into destroot
--->  Installing jemalloc @5.3.0_2
--->  Activating jemalloc @5.3.0_2
--->  Cleaning jemalloc
--->  Computing dependencies for libssh2
--->  Fetching archive for libssh2
--->  Attempting to fetch libssh2-1.10.0_0.darwin_22.arm64.tbz2 from https://packages.macports.org/libssh2
--->  Attempting to fetch libssh2-1.10.0_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/libssh2
--->  Attempting to fetch libssh2-1.10.0_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/libssh2
--->  Fetching distfiles for libssh2
--->  Attempting to fetch libssh2-1.10.0.tar.gz from https://distfiles.macports.org/libssh2
--->  Verifying checksums for libssh2
--->  Extracting libssh2
--->  Configuring libssh2
Warning: Configuration logfiles contain indications of -Wimplicit-function-declaration; check that features were not accidentally disabled:
  strchr: found in libssh2-1.10.0/config.log
--->  Building libssh2
--->  Staging libssh2 into destroot
--->  Installing libssh2 @1.10.0_0
--->  Activating libssh2 @1.10.0_0
--->  Cleaning libssh2
--->  Computing dependencies for libgit2
--->  Fetching archive for libgit2
--->  Attempting to fetch libgit2-1.5.0_0+threadsafe.darwin_22.arm64.tbz2 from https://packages.macports.org/libgit2
--->  Attempting to fetch libgit2-1.5.0_0+threadsafe.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/libgit2
--->  Attempting to fetch libgit2-1.5.0_0+threadsafe.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/libgit2
--->  Fetching distfiles for libgit2
--->  Attempting to fetch libgit2-1.5.0.tar.gz from https://distfiles.macports.org/libgit2
--->  Verifying checksums for libgit2
--->  Extracting libgit2
--->  Applying patches to libgit2
--->  Configuring libgit2
--->  Building libgit2
--->  Staging libgit2 into destroot
--->  Installing libgit2 @1.5.0_0+threadsafe
--->  Activating libgit2 @1.5.0_0+threadsafe
--->  Cleaning libgit2
```

That's more stuff than I'd expect, but whatever.  So far so good...

```
--->  Computing dependencies for rust
--->  Fetching archive for rust
--->  Attempting to fetch rust-1.61.0_2.darwin_22.arm64.tbz2 from https://packages.macports.org/rust
--->  Attempting to fetch rust-1.61.0_2.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/rust
--->  Attempting to fetch rust-1.61.0_2.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/rust
--->  Fetching distfiles for rust
--->  Attempting to fetch rustc-1.61.0-src.tar.gz from https://static.rust-lang.org/dist
--->  Attempting to fetch rust-std-1.60.0-aarch64-apple-darwin.tar.gz from https://static.rust-lang.org/dist
--->  Attempting to fetch rustc-1.60.0-aarch64-apple-darwin.tar.gz from https://static.rust-lang.org/dist
--->  Attempting to fetch cargo-1.60.0-aarch64-apple-darwin.tar.gz from https://static.rust-lang.org/dist
--->  Attempting to fetch addr2line-0.16.0.crate from https://crates.io/api/v1/crates/addr2line/0.16.0/download?dummy=
--->  Attempting to fetch adler-0.2.3.crate from https://crates.io/api/v1/crates/adler/0.2.3/download?dummy=
--->  Attempting to fetch ahash-0.7.4.crate from https://crates.io/api/v1/crates/ahash/0.7.4/download?dummy=
--->  Attempting to fetch aho-corasick-0.7.18.crate from https://crates.io/api/v1/crates/aho-corasick/0.7.18/download?dummy=
--->  Attempting to fetch ammonia-3.1.3.crate from https://crates.io/api/v1/crates/ammonia/3.1.3/download?dummy=
--->  Attempting to fetch annotate-snippets-0.8.0.crate from https://crates.io/api/v1/crates/annotate-snippets/0.8.0/download?dummy=
--->  Attempting to fetch ansi_term-0.12.1.crate from https://crates.io/api/v1/crates/ansi_term/0.12.1/download?dummy=
--->  Attempting to fetch anyhow-1.0.51.crate from https://crates.io/api/v1/crates/anyhow/1.0.51/download?dummy=
--->  Attempting to fetch array_tool-1.0.3.crate from https://crates.io/api/v1/crates/array_tool/1.0.3/download?dummy=
--->  Attempting to fetch arrayvec-0.7.0.crate from https://crates.io/api/v1/crates/arrayvec/0.7.0/download?dummy=
--->  Attempting to fetch askama-0.11.0.crate from https://crates.io/api/v1/crates/askama/0.11.0/download?dummy=
--->  Attempting to fetch askama_derive-0.11.0.crate from https://crates.io/api/v1/crates/askama_derive/0.11.0/download?dummy=
--->  Attempting to fetch askama_escape-0.10.2.crate from https://crates.io/api/v1/crates/askama_escape/0.10.2/download?dummy=
--->  Attempting to fetch askama_shared-0.12.0.crate from https://crates.io/api/v1/crates/askama_shared/0.12.0/download?dummy=
--->  Attempting to fetch atty-0.2.14.crate from https://crates.io/api/v1/crates/atty/0.2.14/download?dummy=
--->  Attempting to fetch autocfg-1.1.0.crate from https://crates.io/api/v1/crates/autocfg/1.1.0/download?dummy=
--->  Attempting to fetch bitflags-1.2.1.crate from https://crates.io/api/v1/crates/bitflags/1.2.1/download?dummy=
--->  Attempting to fetch bitmaps-2.1.0.crate from https://crates.io/api/v1/crates/bitmaps/2.1.0/download?dummy=
--->  Attempting to fetch block-buffer-0.7.3.crate from https://crates.io/api/v1/crates/block-buffer/0.7.3/download?dummy=
--->  Attempting to fetch block-buffer-0.10.2.crate from https://crates.io/api/v1/crates/block-buffer/0.10.2/download?dummy=
--->  Attempting to fetch block-padding-0.1.5.crate from https://crates.io/api/v1/crates/block-padding/0.1.5/download?dummy=
--->  Attempting to fetch bstr-0.2.13.crate from https://crates.io/api/v1/crates/bstr/0.2.13/download?dummy=
--->  Attempting to fetch byte-tools-0.3.1.crate from https://crates.io/api/v1/crates/byte-tools/0.3.1/download?dummy=
--->  Attempting to fetch bytecount-0.6.2.crate from https://crates.io/api/v1/crates/bytecount/0.6.2/download?dummy=
--->  Attempting to fetch byteorder-1.3.4.crate from https://crates.io/api/v1/crates/byteorder/1.3.4/download?dummy=
--->  Attempting to fetch bytes-1.0.1.crate from https://crates.io/api/v1/crates/bytes/1.0.1/download?dummy=
--->  Attempting to fetch bytesize-1.0.1.crate from https://crates.io/api/v1/crates/bytesize/1.0.1/download?dummy=
--->  Attempting to fetch camino-1.0.5.crate from https://crates.io/api/v1/crates/camino/1.0.5/download?dummy=
--->  Attempting to fetch cargo-platform-0.1.2.crate from https://crates.io/api/v1/crates/cargo-platform/0.1.2/download?dummy=
--->  Attempting to fetch cargo_metadata-0.14.0.crate from https://crates.io/api/v1/crates/cargo_metadata/0.14.0/download?dummy=
--->  Attempting to fetch cc-1.0.69.crate from https://crates.io/api/v1/crates/cc/1.0.69/download?dummy=
--->  Attempting to fetch cfg-if-0.1.10.crate from https://crates.io/api/v1/crates/cfg-if/0.1.10/download?dummy=
--->  Attempting to fetch cfg-if-1.0.0.crate from https://crates.io/api/v1/crates/cfg-if/1.0.0/download?dummy=
--->  Attempting to fetch chalk-derive-0.80.0.crate from https://crates.io/api/v1/crates/chalk-derive/0.80.0/download?dummy=
--->  Attempting to fetch chalk-engine-0.80.0.crate from https://crates.io/api/v1/crates/chalk-engine/0.80.0/download?dummy=
--->  Attempting to fetch chalk-ir-0.80.0.crate from https://crates.io/api/v1/crates/chalk-ir/0.80.0/download?dummy=
--->  Attempting to fetch chalk-solve-0.80.0.crate from https://crates.io/api/v1/crates/chalk-solve/0.80.0/download?dummy=
--->  Attempting to fetch chrono-0.4.19.crate from https://crates.io/api/v1/crates/chrono/0.4.19/download?dummy=
--->  Attempting to fetch clap-2.34.0.crate from https://crates.io/api/v1/crates/clap/2.34.0/download?dummy=
--->  Attempting to fetch clap-3.1.1.crate from https://crates.io/api/v1/crates/clap/3.1.1/download?dummy=
--->  Attempting to fetch cmake-0.1.44.crate from https://crates.io/api/v1/crates/cmake/0.1.44/download?dummy=
--->  Attempting to fetch colored-2.0.0.crate from https://crates.io/api/v1/crates/colored/2.0.0/download?dummy=
--->  Attempting to fetch combine-4.6.3.crate from https://crates.io/api/v1/crates/combine/4.6.3/download?dummy=
--->  Attempting to fetch commoncrypto-0.2.0.crate from https://crates.io/api/v1/crates/commoncrypto/0.2.0/download?dummy=
--->  Attempting to fetch commoncrypto-sys-0.2.0.crate from https://crates.io/api/v1/crates/commoncrypto-sys/0.2.0/download?dummy=
--->  Attempting to fetch compiler_builtins-0.1.70.crate from https://crates.io/api/v1/crates/compiler_builtins/0.1.70/download?dummy=
--->  Attempting to fetch compiletest_rs-0.7.1.crate from https://crates.io/api/v1/crates/compiletest_rs/0.7.1/download?dummy=
--->  Attempting to fetch core-foundation-0.9.0.crate from https://crates.io/api/v1/crates/core-foundation/0.9.0/download?dummy=
--->  Attempting to fetch core-foundation-sys-0.8.0.crate from https://crates.io/api/v1/crates/core-foundation-sys/0.8.0/download?dummy=
--->  Attempting to fetch cpufeatures-0.2.1.crate from https://crates.io/api/v1/crates/cpufeatures/0.2.1/download?dummy=
--->  Attempting to fetch crc32fast-1.2.0.crate from https://crates.io/api/v1/crates/crc32fast/1.2.0/download?dummy=
--->  Attempting to fetch crossbeam-channel-0.5.2.crate from https://crates.io/api/v1/crates/crossbeam-channel/0.5.2/download?dummy=
--->  Attempting to fetch crossbeam-deque-0.8.1.crate from https://crates.io/api/v1/crates/crossbeam-deque/0.8.1/download?dummy=
--->  Attempting to fetch crossbeam-epoch-0.9.6.crate from https://crates.io/api/v1/crates/crossbeam-epoch/0.9.6/download?dummy=
--->  Attempting to fetch crossbeam-utils-0.8.6.crate from https://crates.io/api/v1/crates/crossbeam-utils/0.8.6/download?dummy=
--->  Attempting to fetch crypto-common-0.1.2.crate from https://crates.io/api/v1/crates/crypto-common/0.1.2/download?dummy=
--->  Attempting to fetch crypto-hash-0.3.4.crate from https://crates.io/api/v1/crates/crypto-hash/0.3.4/download?dummy=
--->  Attempting to fetch cstr-0.2.8.crate from https://crates.io/api/v1/crates/cstr/0.2.8/download?dummy=
--->  Attempting to fetch ctor-0.1.15.crate from https://crates.io/api/v1/crates/ctor/0.1.15/download?dummy=
--->  Attempting to fetch curl-0.4.41.crate from https://crates.io/api/v1/crates/curl/0.4.41/download?dummy=
--->  Attempting to fetch curl-sys-0.4.51+curl-7.80.0.crate from https://crates.io/api/v1/crates/curl-sys/0.4.51+curl-7.80.0/download?dummy=
--->  Attempting to fetch datafrog-2.0.1.crate from https://crates.io/api/v1/crates/datafrog/2.0.1/download?dummy=
--->  Attempting to fetch derive-new-0.5.8.crate from https://crates.io/api/v1/crates/derive-new/0.5.8/download?dummy=
--->  Attempting to fetch derive_more-0.99.9.crate from https://crates.io/api/v1/crates/derive_more/0.99.9/download?dummy=
--->  Attempting to fetch diff-0.1.12.crate from https://crates.io/api/v1/crates/diff/0.1.12/download?dummy=
--->  Attempting to fetch difference-2.0.0.crate from https://crates.io/api/v1/crates/difference/2.0.0/download?dummy=
--->  Attempting to fetch digest-0.8.1.crate from https://crates.io/api/v1/crates/digest/0.8.1/download?dummy=
--->  Attempting to fetch digest-0.10.2.crate from https://crates.io/api/v1/crates/digest/0.10.2/download?dummy=
--->  Attempting to fetch directories-3.0.2.crate from https://crates.io/api/v1/crates/directories/3.0.2/download?dummy=
--->  Attempting to fetch dirs-2.0.2.crate from https://crates.io/api/v1/crates/dirs/2.0.2/download?dummy=
--->  Attempting to fetch dirs-next-2.0.0.crate from https://crates.io/api/v1/crates/dirs-next/2.0.0/download?dummy=
--->  Attempting to fetch dirs-sys-0.3.6.crate from https://crates.io/api/v1/crates/dirs-sys/0.3.6/download?dummy=
--->  Attempting to fetch dirs-sys-next-0.1.2.crate from https://crates.io/api/v1/crates/dirs-sys-next/0.1.2/download?dummy=
--->  Attempting to fetch dlmalloc-0.2.3.crate from https://crates.io/api/v1/crates/dlmalloc/0.2.3/download?dummy=
--->  Attempting to fetch either-1.6.0.crate from https://crates.io/api/v1/crates/either/1.6.0/download?dummy=
--->  Attempting to fetch elasticlunr-rs-2.3.9.crate from https://crates.io/api/v1/crates/elasticlunr-rs/2.3.9/download?dummy=
--->  Attempting to fetch ena-0.14.0.crate from https://crates.io/api/v1/crates/ena/0.14.0/download?dummy=
--->  Attempting to fetch enum-iterator-0.6.0.crate from https://crates.io/api/v1/crates/enum-iterator/0.6.0/download?dummy=
--->  Attempting to fetch enum-iterator-derive-0.6.0.crate from https://crates.io/api/v1/crates/enum-iterator-derive/0.6.0/download?dummy=
--->  Attempting to fetch env_logger-0.7.1.crate from https://crates.io/api/v1/crates/env_logger/0.7.1/download?dummy=
--->  Attempting to fetch env_logger-0.8.4.crate from https://crates.io/api/v1/crates/env_logger/0.8.4/download?dummy=
--->  Attempting to fetch env_logger-0.9.0.crate from https://crates.io/api/v1/crates/env_logger/0.9.0/download?dummy=
--->  Attempting to fetch expect-test-1.0.1.crate from https://crates.io/api/v1/crates/expect-test/1.0.1/download?dummy=
--->  Attempting to fetch fake-simd-0.1.2.crate from https://crates.io/api/v1/crates/fake-simd/0.1.2/download?dummy=
--->  Attempting to fetch fallible-iterator-0.2.0.crate from https://crates.io/api/v1/crates/fallible-iterator/0.2.0/download?dummy=
--->  Attempting to fetch filetime-0.2.14.crate from https://crates.io/api/v1/crates/filetime/0.2.14/download?dummy=
--->  Attempting to fetch fixedbitset-0.2.0.crate from https://crates.io/api/v1/crates/fixedbitset/0.2.0/download?dummy=
--->  Attempting to fetch flate2-1.0.16.crate from https://crates.io/api/v1/crates/flate2/1.0.16/download?dummy=
--->  Attempting to fetch fnv-1.0.7.crate from https://crates.io/api/v1/crates/fnv/1.0.7/download?dummy=
--->  Attempting to fetch foreign-types-0.3.2.crate from https://crates.io/api/v1/crates/foreign-types/0.3.2/download?dummy=
--->  Attempting to fetch foreign-types-shared-0.1.1.crate from https://crates.io/api/v1/crates/foreign-types-shared/0.1.1/download?dummy=
--->  Attempting to fetch form_urlencoded-1.0.1.crate from https://crates.io/api/v1/crates/form_urlencoded/1.0.1/download?dummy=
--->  Attempting to fetch fortanix-sgx-abi-0.3.3.crate from https://crates.io/api/v1/crates/fortanix-sgx-abi/0.3.3/download?dummy=
--->  Attempting to fetch fs-err-2.5.0.crate from https://crates.io/api/v1/crates/fs-err/2.5.0/download?dummy=
--->  Attempting to fetch fs_extra-1.1.0.crate from https://crates.io/api/v1/crates/fs_extra/1.1.0/download?dummy=
--->  Attempting to fetch fst-0.4.5.crate from https://crates.io/api/v1/crates/fst/0.4.5/download?dummy=
--->  Attempting to fetch futf-0.1.4.crate from https://crates.io/api/v1/crates/futf/0.1.4/download?dummy=
--->  Attempting to fetch futures-0.1.31.crate from https://crates.io/api/v1/crates/futures/0.1.31/download?dummy=
--->  Attempting to fetch futures-0.3.19.crate from https://crates.io/api/v1/crates/futures/0.3.19/download?dummy=
--->  Attempting to fetch futures-channel-0.3.19.crate from https://crates.io/api/v1/crates/futures-channel/0.3.19/download?dummy=
--->  Attempting to fetch futures-core-0.3.19.crate from https://crates.io/api/v1/crates/futures-core/0.3.19/download?dummy=
--->  Attempting to fetch futures-executor-0.3.19.crate from https://crates.io/api/v1/crates/futures-executor/0.3.19/download?dummy=
--->  Attempting to fetch futures-io-0.3.19.crate from https://crates.io/api/v1/crates/futures-io/0.3.19/download?dummy=
--->  Attempting to fetch futures-macro-0.3.19.crate from https://crates.io/api/v1/crates/futures-macro/0.3.19/download?dummy=
--->  Attempting to fetch futures-sink-0.3.19.crate from https://crates.io/api/v1/crates/futures-sink/0.3.19/download?dummy=
--->  Attempting to fetch futures-task-0.3.19.crate from https://crates.io/api/v1/crates/futures-task/0.3.19/download?dummy=
--->  Attempting to fetch futures-util-0.3.19.crate from https://crates.io/api/v1/crates/futures-util/0.3.19/download?dummy=
--->  Attempting to fetch fwdansi-1.1.0.crate from https://crates.io/api/v1/crates/fwdansi/1.1.0/download?dummy=
--->  Attempting to fetch generic-array-0.12.4.crate from https://crates.io/api/v1/crates/generic-array/0.12.4/download?dummy=
--->  Attempting to fetch generic-array-0.14.4.crate from https://crates.io/api/v1/crates/generic-array/0.14.4/download?dummy=
--->  Attempting to fetch getopts-0.2.21.crate from https://crates.io/api/v1/crates/getopts/0.2.21/download?dummy=
--->  Attempting to fetch getrandom-0.1.14.crate from https://crates.io/api/v1/crates/getrandom/0.1.14/download?dummy=
--->  Attempting to fetch getrandom-0.2.0.crate from https://crates.io/api/v1/crates/getrandom/0.2.0/download?dummy=
--->  Attempting to fetch getset-0.1.1.crate from https://crates.io/api/v1/crates/getset/0.1.1/download?dummy=
--->  Attempting to fetch gimli-0.25.0.crate from https://crates.io/api/v1/crates/gimli/0.25.0/download?dummy=
--->  Attempting to fetch gimli-0.26.1.crate from https://crates.io/api/v1/crates/gimli/0.26.1/download?dummy=
--->  Attempting to fetch git2-0.14.2.crate from https://crates.io/api/v1/crates/git2/0.14.2/download?dummy=
--->  Attempting to fetch git2-curl-0.15.0.crate from https://crates.io/api/v1/crates/git2-curl/0.15.0/download?dummy=
--->  Attempting to fetch glob-0.3.0.crate from https://crates.io/api/v1/crates/glob/0.3.0/download?dummy=
--->  Attempting to fetch globset-0.4.5.crate from https://crates.io/api/v1/crates/globset/0.4.5/download?dummy=
--->  Attempting to fetch gsgdt-0.1.2.crate from https://crates.io/api/v1/crates/gsgdt/0.1.2/download?dummy=
--->  Attempting to fetch handlebars-4.1.0.crate from https://crates.io/api/v1/crates/handlebars/4.1.0/download?dummy=
--->  Attempting to fetch hashbrown-0.11.2.crate from https://crates.io/api/v1/crates/hashbrown/0.11.2/download?dummy=
--->  Attempting to fetch hashbrown-0.12.0.crate from https://crates.io/api/v1/crates/hashbrown/0.12.0/download?dummy=
--->  Attempting to fetch heck-0.3.1.crate from https://crates.io/api/v1/crates/heck/0.3.1/download?dummy=
--->  Attempting to fetch hermit-abi-0.1.19.crate from https://crates.io/api/v1/crates/hermit-abi/0.1.19/download?dummy=
--->  Attempting to fetch hermit-abi-0.2.0.crate from https://crates.io/api/v1/crates/hermit-abi/0.2.0/download?dummy=
--->  Attempting to fetch hex-0.3.2.crate from https://crates.io/api/v1/crates/hex/0.3.2/download?dummy=
--->  Attempting to fetch hex-0.4.2.crate from https://crates.io/api/v1/crates/hex/0.4.2/download?dummy=
--->  Attempting to fetch home-0.5.3.crate from https://crates.io/api/v1/crates/home/0.5.3/download?dummy=
--->  Attempting to fetch html5ever-0.25.1.crate from https://crates.io/api/v1/crates/html5ever/0.25.1/download?dummy=
--->  Attempting to fetch humantime-1.3.0.crate from https://crates.io/api/v1/crates/humantime/1.3.0/download?dummy=
--->  Attempting to fetch humantime-2.0.1.crate from https://crates.io/api/v1/crates/humantime/2.0.1/download?dummy=
--->  Attempting to fetch idna-0.1.5.crate from https://crates.io/api/v1/crates/idna/0.1.5/download?dummy=
--->  Attempting to fetch idna-0.2.0.crate from https://crates.io/api/v1/crates/idna/0.2.0/download?dummy=
--->  Attempting to fetch if_chain-1.0.0.crate from https://crates.io/api/v1/crates/if_chain/1.0.0/download?dummy=
--->  Attempting to fetch ignore-0.4.17.crate from https://crates.io/api/v1/crates/ignore/0.4.17/download?dummy=
--->  Attempting to fetch im-rc-15.0.0.crate from https://crates.io/api/v1/crates/im-rc/15.0.0/download?dummy=
--->  Attempting to fetch indexmap-1.8.0.crate from https://crates.io/api/v1/crates/indexmap/1.8.0/download?dummy=
--->  Attempting to fetch indoc-1.0.3.crate from https://crates.io/api/v1/crates/indoc/1.0.3/download?dummy=
--->  Attempting to fetch instant-0.1.12.crate from https://crates.io/api/v1/crates/instant/0.1.12/download?dummy=
--->  Attempting to fetch itertools-0.10.1.crate from https://crates.io/api/v1/crates/itertools/0.10.1/download?dummy=
--->  Attempting to fetch itoa-0.4.6.crate from https://crates.io/api/v1/crates/itoa/0.4.6/download?dummy=
--->  Attempting to fetch jobserver-0.1.24.crate from https://crates.io/api/v1/crates/jobserver/0.1.24/download?dummy=
--->  Attempting to fetch json-0.12.4.crate from https://crates.io/api/v1/crates/json/0.12.4/download?dummy=
--->  Attempting to fetch jsonpath_lib-0.2.6.crate from https://crates.io/api/v1/crates/jsonpath_lib/0.2.6/download?dummy=
--->  Attempting to fetch jsonrpc-client-transports-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-client-transports/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-core-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-core/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-core-client-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-core-client/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-derive-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-derive/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-ipc-server-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-ipc-server/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-pubsub-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-pubsub/18.0.0/download?dummy=
--->  Attempting to fetch jsonrpc-server-utils-18.0.0.crate from https://crates.io/api/v1/crates/jsonrpc-server-utils/18.0.0/download?dummy=
--->  Attempting to fetch kstring-1.0.6.crate from https://crates.io/api/v1/crates/kstring/1.0.6/download?dummy=
--->  Attempting to fetch lazy_static-1.4.0.crate from https://crates.io/api/v1/crates/lazy_static/1.4.0/download?dummy=
--->  Attempting to fetch lazycell-1.3.0.crate from https://crates.io/api/v1/crates/lazycell/1.3.0/download?dummy=
--->  Attempting to fetch libc-0.2.116.crate from https://crates.io/api/v1/crates/libc/0.2.116/download?dummy=
--->  Attempting to fetch libgit2-sys-0.13.2+1.4.2.crate from https://crates.io/api/v1/crates/libgit2-sys/0.13.2+1.4.2/download?dummy=
--->  Attempting to fetch libloading-0.7.1.crate from https://crates.io/api/v1/crates/libloading/0.7.1/download?dummy=
--->  Attempting to fetch libm-0.1.4.crate from https://crates.io/api/v1/crates/libm/0.1.4/download?dummy=
--->  Attempting to fetch libnghttp2-sys-0.1.4+1.41.0.crate from https://crates.io/api/v1/crates/libnghttp2-sys/0.1.4+1.41.0/download?dummy=
--->  Attempting to fetch libssh2-sys-0.2.23.crate from https://crates.io/api/v1/crates/libssh2-sys/0.2.23/download?dummy=
--->  Attempting to fetch libz-sys-1.1.3.crate from https://crates.io/api/v1/crates/libz-sys/1.1.3/download?dummy=
--->  Attempting to fetch linked-hash-map-0.5.4.crate from https://crates.io/api/v1/crates/linked-hash-map/0.5.4/download?dummy=
--->  Attempting to fetch lock_api-0.4.5.crate from https://crates.io/api/v1/crates/lock_api/0.4.5/download?dummy=
--->  Attempting to fetch log-0.4.14.crate from https://crates.io/api/v1/crates/log/0.4.14/download?dummy=
--->  Attempting to fetch lsp-codec-0.3.0.crate from https://crates.io/api/v1/crates/lsp-codec/0.3.0/download?dummy=
--->  Attempting to fetch lsp-types-0.60.0.crate from https://crates.io/api/v1/crates/lsp-types/0.60.0/download?dummy=
--->  Attempting to fetch lzma-sys-0.1.16.crate from https://crates.io/api/v1/crates/lzma-sys/0.1.16/download?dummy=
--->  Attempting to fetch mac-0.1.1.crate from https://crates.io/api/v1/crates/mac/0.1.1/download?dummy=
--->  Attempting to fetch macro-utils-0.1.3.crate from https://crates.io/api/v1/crates/macro-utils/0.1.3/download?dummy=
--->  Attempting to fetch maplit-1.0.2.crate from https://crates.io/api/v1/crates/maplit/1.0.2/download?dummy=
--->  Attempting to fetch markup5ever-0.10.1.crate from https://crates.io/api/v1/crates/markup5ever/0.10.1/download?dummy=
--->  Attempting to fetch markup5ever_rcdom-0.1.0.crate from https://crates.io/api/v1/crates/markup5ever_rcdom/0.1.0/download?dummy=
--->  Attempting to fetch matchers-0.1.0.crate from https://crates.io/api/v1/crates/matchers/0.1.0/download?dummy=
--->  Attempting to fetch matches-0.1.8.crate from https://crates.io/api/v1/crates/matches/0.1.8/download?dummy=
--->  Attempting to fetch md-5-0.10.0.crate from https://crates.io/api/v1/crates/md-5/0.10.0/download?dummy=
--->  Attempting to fetch mdbook-0.4.15.crate from https://crates.io/api/v1/crates/mdbook/0.4.15/download?dummy=
--->  Attempting to fetch measureme-9.1.2.crate from https://crates.io/api/v1/crates/measureme/9.1.2/download?dummy=
--->  Attempting to fetch measureme-10.0.0.crate from https://crates.io/api/v1/crates/measureme/10.0.0/download?dummy=
--->  Attempting to fetch memchr-2.4.1.crate from https://crates.io/api/v1/crates/memchr/2.4.1/download?dummy=
--->  Attempting to fetch memmap2-0.2.1.crate from https://crates.io/api/v1/crates/memmap2/0.2.1/download?dummy=
--->  Attempting to fetch memoffset-0.6.5.crate from https://crates.io/api/v1/crates/memoffset/0.6.5/download?dummy=
--->  Attempting to fetch minifier-0.0.43.crate from https://crates.io/api/v1/crates/minifier/0.0.43/download?dummy=
--->  Attempting to fetch minimal-lexical-0.2.1.crate from https://crates.io/api/v1/crates/minimal-lexical/0.2.1/download?dummy=
--->  Attempting to fetch miniz_oxide-0.4.0.crate from https://crates.io/api/v1/crates/miniz_oxide/0.4.0/download?dummy=
--->  Attempting to fetch mio-0.7.14.crate from https://crates.io/api/v1/crates/mio/0.7.14/download?dummy=
--->  Attempting to fetch miow-0.3.7.crate from https://crates.io/api/v1/crates/miow/0.3.7/download?dummy=
--->  Attempting to fetch new_debug_unreachable-1.0.4.crate from https://crates.io/api/v1/crates/new_debug_unreachable/1.0.4/download?dummy=
--->  Attempting to fetch nom-7.1.0.crate from https://crates.io/api/v1/crates/nom/7.1.0/download?dummy=
--->  Attempting to fetch ntapi-0.3.6.crate from https://crates.io/api/v1/crates/ntapi/0.3.6/download?dummy=
--->  Attempting to fetch num-integer-0.1.43.crate from https://crates.io/api/v1/crates/num-integer/0.1.43/download?dummy=
--->  Attempting to fetch num-traits-0.2.12.crate from https://crates.io/api/v1/crates/num-traits/0.2.12/download?dummy=
--->  Attempting to fetch num_cpus-1.13.1.crate from https://crates.io/api/v1/crates/num_cpus/1.13.1/download?dummy=
--->  Attempting to fetch object-0.26.2.crate from https://crates.io/api/v1/crates/object/0.26.2/download?dummy=
--->  Attempting to fetch object-0.28.1.crate from https://crates.io/api/v1/crates/object/0.28.1/download?dummy=
--->  Attempting to fetch odht-0.3.1.crate from https://crates.io/api/v1/crates/odht/0.3.1/download?dummy=
--->  Attempting to fetch once_cell-1.7.2.crate from https://crates.io/api/v1/crates/once_cell/1.7.2/download?dummy=
--->  Attempting to fetch opaque-debug-0.2.3.crate from https://crates.io/api/v1/crates/opaque-debug/0.2.3/download?dummy=
--->  Attempting to fetch opener-0.5.0.crate from https://crates.io/api/v1/crates/opener/0.5.0/download?dummy=
--->  Attempting to fetch openssl-0.10.35.crate from https://crates.io/api/v1/crates/openssl/0.10.35/download?dummy=
--->  Attempting to fetch openssl-probe-0.1.2.crate from https://crates.io/api/v1/crates/openssl-probe/0.1.2/download?dummy=
--->  Attempting to fetch openssl-src-111.17.0+1.1.1m.crate from https://crates.io/api/v1/crates/openssl-src/111.17.0+1.1.1m/download?dummy=
--->  Attempting to fetch openssl-sys-0.9.65.crate from https://crates.io/api/v1/crates/openssl-sys/0.9.65/download?dummy=
--->  Attempting to fetch ordslice-0.3.0.crate from https://crates.io/api/v1/crates/ordslice/0.3.0/download?dummy=
--->  Attempting to fetch os_info-3.0.7.crate from https://crates.io/api/v1/crates/os_info/3.0.7/download?dummy=
--->  Attempting to fetch os_str_bytes-6.0.0.crate from https://crates.io/api/v1/crates/os_str_bytes/6.0.0/download?dummy=
--->  Attempting to fetch output_vt100-0.1.2.crate from https://crates.io/api/v1/crates/output_vt100/0.1.2/download?dummy=
--->  Attempting to fetch packed_simd_2-0.3.4.crate from https://crates.io/api/v1/crates/packed_simd_2/0.3.4/download?dummy=
--->  Attempting to fetch parity-tokio-ipc-0.9.0.crate from https://crates.io/api/v1/crates/parity-tokio-ipc/0.9.0/download?dummy=
--->  Attempting to fetch parking_lot-0.11.2.crate from https://crates.io/api/v1/crates/parking_lot/0.11.2/download?dummy=
--->  Attempting to fetch parking_lot_core-0.8.5.crate from https://crates.io/api/v1/crates/parking_lot_core/0.8.5/download?dummy=
--->  Attempting to fetch pathdiff-0.2.0.crate from https://crates.io/api/v1/crates/pathdiff/0.2.0/download?dummy=
--->  Attempting to fetch percent-encoding-1.0.1.crate from https://crates.io/api/v1/crates/percent-encoding/1.0.1/download?dummy=
--->  Attempting to fetch percent-encoding-2.1.0.crate from https://crates.io/api/v1/crates/percent-encoding/2.1.0/download?dummy=
--->  Attempting to fetch perf-event-open-sys-1.0.1.crate from https://crates.io/api/v1/crates/perf-event-open-sys/1.0.1/download?dummy=
--->  Attempting to fetch pest-2.1.3.crate from https://crates.io/api/v1/crates/pest/2.1.3/download?dummy=
--->  Attempting to fetch pest_derive-2.1.0.crate from https://crates.io/api/v1/crates/pest_derive/2.1.0/download?dummy=
--->  Attempting to fetch pest_generator-2.1.3.crate from https://crates.io/api/v1/crates/pest_generator/2.1.3/download?dummy=
--->  Attempting to fetch pest_meta-2.1.3.crate from https://crates.io/api/v1/crates/pest_meta/2.1.3/download?dummy=
--->  Attempting to fetch petgraph-0.5.1.crate from https://crates.io/api/v1/crates/petgraph/0.5.1/download?dummy=
--->  Attempting to fetch phf-0.8.0.crate from https://crates.io/api/v1/crates/phf/0.8.0/download?dummy=
--->  Attempting to fetch phf_codegen-0.8.0.crate from https://crates.io/api/v1/crates/phf_codegen/0.8.0/download?dummy=
--->  Attempting to fetch phf_generator-0.8.0.crate from https://crates.io/api/v1/crates/phf_generator/0.8.0/download?dummy=
--->  Attempting to fetch phf_shared-0.8.0.crate from https://crates.io/api/v1/crates/phf_shared/0.8.0/download?dummy=
--->  Attempting to fetch pin-project-lite-0.2.8.crate from https://crates.io/api/v1/crates/pin-project-lite/0.2.8/download?dummy=
--->  Attempting to fetch pin-utils-0.1.0.crate from https://crates.io/api/v1/crates/pin-utils/0.1.0/download?dummy=
--->  Attempting to fetch pkg-config-0.3.18.crate from https://crates.io/api/v1/crates/pkg-config/0.3.18/download?dummy=
--->  Attempting to fetch polonius-engine-0.13.0.crate from https://crates.io/api/v1/crates/polonius-engine/0.13.0/download?dummy=
--->  Attempting to fetch ppv-lite86-0.2.8.crate from https://crates.io/api/v1/crates/ppv-lite86/0.2.8/download?dummy=
--->  Attempting to fetch precomputed-hash-0.1.1.crate from https://crates.io/api/v1/crates/precomputed-hash/0.1.1/download?dummy=
--->  Attempting to fetch pretty_assertions-0.7.2.crate from https://crates.io/api/v1/crates/pretty_assertions/0.7.2/download?dummy=
--->  Attempting to fetch pretty_env_logger-0.4.0.crate from https://crates.io/api/v1/crates/pretty_env_logger/0.4.0/download?dummy=
--->  Attempting to fetch proc-macro-crate-0.1.5.crate from https://crates.io/api/v1/crates/proc-macro-crate/0.1.5/download?dummy=
--->  Attempting to fetch proc-macro-error-1.0.4.crate from https://crates.io/api/v1/crates/proc-macro-error/1.0.4/download?dummy=
--->  Attempting to fetch proc-macro-error-attr-1.0.4.crate from https://crates.io/api/v1/crates/proc-macro-error-attr/1.0.4/download?dummy=
--->  Attempting to fetch proc-macro2-1.0.30.crate from https://crates.io/api/v1/crates/proc-macro2/1.0.30/download?dummy=
--->  Attempting to fetch psm-0.1.16.crate from https://crates.io/api/v1/crates/psm/0.1.16/download?dummy=
--->  Attempting to fetch pulldown-cmark-0.9.1.crate from https://crates.io/api/v1/crates/pulldown-cmark/0.9.1/download?dummy=
--->  Attempting to fetch punycode-0.4.1.crate from https://crates.io/api/v1/crates/punycode/0.4.1/download?dummy=
--->  Attempting to fetch quick-error-1.2.3.crate from https://crates.io/api/v1/crates/quick-error/1.2.3/download?dummy=
--->  Attempting to fetch quick-error-2.0.0.crate from https://crates.io/api/v1/crates/quick-error/2.0.0/download?dummy=
--->  Attempting to fetch quine-mc_cluskey-0.2.4.crate from https://crates.io/api/v1/crates/quine-mc_cluskey/0.2.4/download?dummy=
--->  Attempting to fetch quote-1.0.7.crate from https://crates.io/api/v1/crates/quote/1.0.7/download?dummy=
--->  Attempting to fetch racer-2.2.1.crate from https://crates.io/api/v1/crates/racer/2.2.1/download?dummy=
--->  Attempting to fetch rand-0.7.3.crate from https://crates.io/api/v1/crates/rand/0.7.3/download?dummy=
--->  Attempting to fetch rand-0.8.4.crate from https://crates.io/api/v1/crates/rand/0.8.4/download?dummy=
--->  Attempting to fetch rand_chacha-0.2.2.crate from https://crates.io/api/v1/crates/rand_chacha/0.2.2/download?dummy=
--->  Attempting to fetch rand_chacha-0.3.0.crate from https://crates.io/api/v1/crates/rand_chacha/0.3.0/download?dummy=
--->  Attempting to fetch rand_core-0.5.1.crate from https://crates.io/api/v1/crates/rand_core/0.5.1/download?dummy=
--->  Attempting to fetch rand_core-0.6.2.crate from https://crates.io/api/v1/crates/rand_core/0.6.2/download?dummy=
--->  Attempting to fetch rand_hc-0.2.0.crate from https://crates.io/api/v1/crates/rand_hc/0.2.0/download?dummy=
--->  Attempting to fetch rand_hc-0.3.0.crate from https://crates.io/api/v1/crates/rand_hc/0.3.0/download?dummy=
--->  Attempting to fetch rand_pcg-0.2.1.crate from https://crates.io/api/v1/crates/rand_pcg/0.2.1/download?dummy=
--->  Attempting to fetch rand_xorshift-0.2.0.crate from https://crates.io/api/v1/crates/rand_xorshift/0.2.0/download?dummy=
--->  Attempting to fetch rand_xoshiro-0.4.0.crate from https://crates.io/api/v1/crates/rand_xoshiro/0.4.0/download?dummy=
--->  Attempting to fetch rand_xoshiro-0.6.0.crate from https://crates.io/api/v1/crates/rand_xoshiro/0.6.0/download?dummy=
--->  Attempting to fetch rayon-1.5.1.crate from https://crates.io/api/v1/crates/rayon/1.5.1/download?dummy=
--->  Attempting to fetch rayon-core-1.9.1.crate from https://crates.io/api/v1/crates/rayon-core/1.9.1/download?dummy=
--->  Attempting to fetch redox_syscall-0.2.10.crate from https://crates.io/api/v1/crates/redox_syscall/0.2.10/download?dummy=
--->  Attempting to fetch redox_users-0.4.0.crate from https://crates.io/api/v1/crates/redox_users/0.4.0/download?dummy=
--->  Attempting to fetch regex-1.5.4.crate from https://crates.io/api/v1/crates/regex/1.5.4/download?dummy=
--->  Attempting to fetch regex-automata-0.1.10.crate from https://crates.io/api/v1/crates/regex-automata/0.1.10/download?dummy=
--->  Attempting to fetch regex-syntax-0.6.25.crate from https://crates.io/api/v1/crates/regex-syntax/0.6.25/download?dummy=
--->  Attempting to fetch remove_dir_all-0.5.3.crate from https://crates.io/api/v1/crates/remove_dir_all/0.5.3/download?dummy=
--->  Attempting to fetch rls-data-0.19.1.crate from https://crates.io/api/v1/crates/rls-data/0.19.1/download?dummy=
--->  Attempting to fetch rls-span-0.5.3.crate from https://crates.io/api/v1/crates/rls-span/0.5.3/download?dummy=
--->  Attempting to fetch rls-vfs-0.8.0.crate from https://crates.io/api/v1/crates/rls-vfs/0.8.0/download?dummy=
--->  Attempting to fetch rustc-demangle-0.1.21.crate from https://crates.io/api/v1/crates/rustc-demangle/0.1.21/download?dummy=
--->  Attempting to fetch rustc-hash-1.1.0.crate from https://crates.io/api/v1/crates/rustc-hash/1.1.0/download?dummy=
--->  Attempting to fetch rustc-rayon-0.3.2.crate from https://crates.io/api/v1/crates/rustc-rayon/0.3.2/download?dummy=
--->  Attempting to fetch rustc-rayon-core-0.3.2.crate from https://crates.io/api/v1/crates/rustc-rayon-core/0.3.2/download?dummy=
--->  Attempting to fetch rustc-semver-1.1.0.crate from https://crates.io/api/v1/crates/rustc-semver/1.1.0/download?dummy=
--->  Attempting to fetch rustc_tools_util-0.2.0.crate from https://crates.io/api/v1/crates/rustc_tools_util/0.2.0/download?dummy=
--->  Attempting to fetch rustc_version-0.4.0.crate from https://crates.io/api/v1/crates/rustc_version/0.4.0/download?dummy=
--->  Attempting to fetch rustfix-0.5.1.crate from https://crates.io/api/v1/crates/rustfix/0.5.1/download?dummy=
--->  Attempting to fetch rustfix-0.6.0.crate from https://crates.io/api/v1/crates/rustfix/0.6.0/download?dummy=
--->  Attempting to fetch rustversion-1.0.5.crate from https://crates.io/api/v1/crates/rustversion/1.0.5/download?dummy=
--->  Attempting to fetch ryu-1.0.5.crate from https://crates.io/api/v1/crates/ryu/1.0.5/download?dummy=
--->  Attempting to fetch same-file-1.0.6.crate from https://crates.io/api/v1/crates/same-file/1.0.6/download?dummy=
--->  Attempting to fetch schannel-0.1.19.crate from https://crates.io/api/v1/crates/schannel/0.1.19/download?dummy=
--->  Attempting to fetch scoped-tls-1.0.0.crate from https://crates.io/api/v1/crates/scoped-tls/1.0.0/download?dummy=
--->  Attempting to fetch scopeguard-1.1.0.crate from https://crates.io/api/v1/crates/scopeguard/1.1.0/download?dummy=
--->  Attempting to fetch security-framework-2.0.0.crate from https://crates.io/api/v1/crates/security-framework/2.0.0/download?dummy=
--->  Attempting to fetch security-framework-sys-2.0.0.crate from https://crates.io/api/v1/crates/security-framework-sys/2.0.0/download?dummy=
--->  Attempting to fetch semver-1.0.3.crate from https://crates.io/api/v1/crates/semver/1.0.3/download?dummy=
--->  Attempting to fetch serde-1.0.125.crate from https://crates.io/api/v1/crates/serde/1.0.125/download?dummy=
--->  Attempting to fetch serde_derive-1.0.125.crate from https://crates.io/api/v1/crates/serde_derive/1.0.125/download?dummy=
--->  Attempting to fetch serde_ignored-0.1.2.crate from https://crates.io/api/v1/crates/serde_ignored/0.1.2/download?dummy=
--->  Attempting to fetch serde_json-1.0.59.crate from https://crates.io/api/v1/crates/serde_json/1.0.59/download?dummy=
--->  Attempting to fetch serde_repr-0.1.6.crate from https://crates.io/api/v1/crates/serde_repr/0.1.6/download?dummy=
--->  Attempting to fetch sha-1-0.8.2.crate from https://crates.io/api/v1/crates/sha-1/0.8.2/download?dummy=
--->  Attempting to fetch sha-1-0.10.0.crate from https://crates.io/api/v1/crates/sha-1/0.10.0/download?dummy=
--->  Attempting to fetch sha2-0.10.1.crate from https://crates.io/api/v1/crates/sha2/0.10.1/download?dummy=
--->  Attempting to fetch sharded-slab-0.1.1.crate from https://crates.io/api/v1/crates/sharded-slab/0.1.1/download?dummy=
--->  Attempting to fetch shell-escape-0.1.5.crate from https://crates.io/api/v1/crates/shell-escape/0.1.5/download?dummy=
--->  Attempting to fetch shlex-1.0.0.crate from https://crates.io/api/v1/crates/shlex/1.0.0/download?dummy=
--->  Attempting to fetch signal-hook-registry-1.2.2.crate from https://crates.io/api/v1/crates/signal-hook-registry/1.2.2/download?dummy=
--->  Attempting to fetch siphasher-0.3.3.crate from https://crates.io/api/v1/crates/siphasher/0.3.3/download?dummy=
--->  Attempting to fetch sized-chunks-0.6.4.crate from https://crates.io/api/v1/crates/sized-chunks/0.6.4/download?dummy=
--->  Attempting to fetch slab-0.4.2.crate from https://crates.io/api/v1/crates/slab/0.4.2/download?dummy=
--->  Attempting to fetch smallvec-1.7.0.crate from https://crates.io/api/v1/crates/smallvec/1.7.0/download?dummy=
--->  Attempting to fetch snap-1.0.1.crate from https://crates.io/api/v1/crates/snap/1.0.1/download?dummy=
--->  Attempting to fetch socket2-0.4.1.crate from https://crates.io/api/v1/crates/socket2/0.4.1/download?dummy=
--->  Attempting to fetch stable_deref_trait-1.2.0.crate from https://crates.io/api/v1/crates/stable_deref_trait/1.2.0/download?dummy=
--->  Attempting to fetch stacker-0.1.14.crate from https://crates.io/api/v1/crates/stacker/0.1.14/download?dummy=
--->  Attempting to fetch string_cache-0.8.0.crate from https://crates.io/api/v1/crates/string_cache/0.8.0/download?dummy=
--->  Attempting to fetch string_cache_codegen-0.5.1.crate from https://crates.io/api/v1/crates/string_cache_codegen/0.5.1/download?dummy=
--->  Attempting to fetch strip-ansi-escapes-0.1.0.crate from https://crates.io/api/v1/crates/strip-ansi-escapes/0.1.0/download?dummy=
--->  Attempting to fetch strsim-0.8.0.crate from https://crates.io/api/v1/crates/strsim/0.8.0/download?dummy=
--->  Attempting to fetch strsim-0.10.0.crate from https://crates.io/api/v1/crates/strsim/0.10.0/download?dummy=
--->  Attempting to fetch structopt-0.3.25.crate from https://crates.io/api/v1/crates/structopt/0.3.25/download?dummy=
--->  Attempting to fetch structopt-derive-0.4.18.crate from https://crates.io/api/v1/crates/structopt-derive/0.4.18/download?dummy=
--->  Attempting to fetch strum-0.18.0.crate from https://crates.io/api/v1/crates/strum/0.18.0/download?dummy=
--->  Attempting to fetch strum_macros-0.18.0.crate from https://crates.io/api/v1/crates/strum_macros/0.18.0/download?dummy=
--->  Attempting to fetch syn-1.0.80.crate from https://crates.io/api/v1/crates/syn/1.0.80/download?dummy=
--->  Attempting to fetch synstructure-0.12.6.crate from https://crates.io/api/v1/crates/synstructure/0.12.6/download?dummy=
--->  Attempting to fetch tar-0.4.37.crate from https://crates.io/api/v1/crates/tar/0.4.37/download?dummy=
--->  Attempting to fetch tempfile-3.2.0.crate from https://crates.io/api/v1/crates/tempfile/3.2.0/download?dummy=
--->  Attempting to fetch tendril-0.4.1.crate from https://crates.io/api/v1/crates/tendril/0.4.1/download?dummy=
--->  Attempting to fetch term-0.6.1.crate from https://crates.io/api/v1/crates/term/0.6.1/download?dummy=
--->  Attempting to fetch term-0.7.0.crate from https://crates.io/api/v1/crates/term/0.7.0/download?dummy=
--->  Attempting to fetch termcolor-1.1.2.crate from https://crates.io/api/v1/crates/termcolor/1.1.2/download?dummy=
--->  Attempting to fetch termize-0.1.1.crate from https://crates.io/api/v1/crates/termize/0.1.1/download?dummy=
--->  Attempting to fetch tester-0.9.0.crate from https://crates.io/api/v1/crates/tester/0.9.0/download?dummy=
--->  Attempting to fetch textwrap-0.11.0.crate from https://crates.io/api/v1/crates/textwrap/0.11.0/download?dummy=
--->  Attempting to fetch textwrap-0.14.2.crate from https://crates.io/api/v1/crates/textwrap/0.14.2/download?dummy=
--->  Attempting to fetch thiserror-1.0.30.crate from https://crates.io/api/v1/crates/thiserror/1.0.30/download?dummy=
--->  Attempting to fetch thiserror-impl-1.0.30.crate from https://crates.io/api/v1/crates/thiserror-impl/1.0.30/download?dummy=
--->  Attempting to fetch thorin-dwp-0.2.0.crate from https://crates.io/api/v1/crates/thorin-dwp/0.2.0/download?dummy=
--->  Attempting to fetch thread_local-1.1.4.crate from https://crates.io/api/v1/crates/thread_local/1.1.4/download?dummy=
--->  Attempting to fetch tikv-jemalloc-sys-0.4.1+5.2.1-patched.crate from https://crates.io/api/v1/crates/tikv-jemalloc-sys/0.4.1+5.2.1-patched/download?dummy=
--->  Attempting to fetch time-0.1.43.crate from https://crates.io/api/v1/crates/time/0.1.43/download?dummy=
--->  Attempting to fetch tinyvec-0.3.4.crate from https://crates.io/api/v1/crates/tinyvec/0.3.4/download?dummy=
--->  Attempting to fetch tokio-1.8.4.crate from https://crates.io/api/v1/crates/tokio/1.8.4/download?dummy=
--->  Attempting to fetch tokio-stream-0.1.7.crate from https://crates.io/api/v1/crates/tokio-stream/0.1.7/download?dummy=
--->  Attempting to fetch tokio-util-0.6.7.crate from https://crates.io/api/v1/crates/tokio-util/0.6.7/download?dummy=
--->  Attempting to fetch toml-0.5.7.crate from https://crates.io/api/v1/crates/toml/0.5.7/download?dummy=
--->  Attempting to fetch toml_edit-0.13.4.crate from https://crates.io/api/v1/crates/toml_edit/0.13.4/download?dummy=
--->  Attempting to fetch topological-sort-0.1.0.crate from https://crates.io/api/v1/crates/topological-sort/0.1.0/download?dummy=
--->  Attempting to fetch tower-service-0.3.1.crate from https://crates.io/api/v1/crates/tower-service/0.3.1/download?dummy=
--->  Attempting to fetch tracing-0.1.29.crate from https://crates.io/api/v1/crates/tracing/0.1.29/download?dummy=
--->  Attempting to fetch tracing-attributes-0.1.18.crate from https://crates.io/api/v1/crates/tracing-attributes/0.1.18/download?dummy=
--->  Attempting to fetch tracing-core-0.1.21.crate from https://crates.io/api/v1/crates/tracing-core/0.1.21/download?dummy=
--->  Attempting to fetch tracing-log-0.1.2.crate from https://crates.io/api/v1/crates/tracing-log/0.1.2/download?dummy=
--->  Attempting to fetch tracing-subscriber-0.3.3.crate from https://crates.io/api/v1/crates/tracing-subscriber/0.3.3/download?dummy=
--->  Attempting to fetch tracing-tree-0.2.0.crate from https://crates.io/api/v1/crates/tracing-tree/0.2.0/download?dummy=
--->  Attempting to fetch typenum-1.12.0.crate from https://crates.io/api/v1/crates/typenum/1.12.0/download?dummy=
--->  Attempting to fetch ucd-parse-0.1.8.crate from https://crates.io/api/v1/crates/ucd-parse/0.1.8/download?dummy=
--->  Attempting to fetch ucd-trie-0.1.3.crate from https://crates.io/api/v1/crates/ucd-trie/0.1.3/download?dummy=
--->  Attempting to fetch unic-char-property-0.9.0.crate from https://crates.io/api/v1/crates/unic-char-property/0.9.0/download?dummy=
--->  Attempting to fetch unic-char-range-0.9.0.crate from https://crates.io/api/v1/crates/unic-char-range/0.9.0/download?dummy=
--->  Attempting to fetch unic-common-0.9.0.crate from https://crates.io/api/v1/crates/unic-common/0.9.0/download?dummy=
--->  Attempting to fetch unic-emoji-char-0.9.0.crate from https://crates.io/api/v1/crates/unic-emoji-char/0.9.0/download?dummy=
--->  Attempting to fetch unic-ucd-version-0.9.0.crate from https://crates.io/api/v1/crates/unic-ucd-version/0.9.0/download?dummy=
--->  Attempting to fetch unicase-2.6.0.crate from https://crates.io/api/v1/crates/unicase/2.6.0/download?dummy=
--->  Attempting to fetch unicode-bidi-0.3.4.crate from https://crates.io/api/v1/crates/unicode-bidi/0.3.4/download?dummy=
--->  Attempting to fetch unicode-normalization-0.1.13.crate from https://crates.io/api/v1/crates/unicode-normalization/0.1.13/download?dummy=
--->  Attempting to fetch unicode-script-0.5.3.crate from https://crates.io/api/v1/crates/unicode-script/0.5.3/download?dummy=
--->  Attempting to fetch unicode-security-0.0.5.crate from https://crates.io/api/v1/crates/unicode-security/0.0.5/download?dummy=
--->  Attempting to fetch unicode-segmentation-1.6.0.crate from https://crates.io/api/v1/crates/unicode-segmentation/1.6.0/download?dummy=
--->  Attempting to fetch unicode-width-0.1.8.crate from https://crates.io/api/v1/crates/unicode-width/0.1.8/download?dummy=
--->  Attempting to fetch unicode-xid-0.2.2.crate from https://crates.io/api/v1/crates/unicode-xid/0.2.2/download?dummy=
--->  Attempting to fetch unicode_categories-0.1.1.crate from https://crates.io/api/v1/crates/unicode_categories/0.1.1/download?dummy=
--->  Attempting to fetch unified-diff-0.2.1.crate from https://crates.io/api/v1/crates/unified-diff/0.2.1/download?dummy=
--->  Attempting to fetch unindent-0.1.7.crate from https://crates.io/api/v1/crates/unindent/0.1.7/download?dummy=
--->  Attempting to fetch url-1.7.2.crate from https://crates.io/api/v1/crates/url/1.7.2/download?dummy=
--->  Attempting to fetch url-2.2.2.crate from https://crates.io/api/v1/crates/url/2.2.2/download?dummy=
--->  Attempting to fetch utf-8-0.7.5.crate from https://crates.io/api/v1/crates/utf-8/0.7.5/download?dummy=
--->  Attempting to fetch utf8parse-0.1.1.crate from https://crates.io/api/v1/crates/utf8parse/0.1.1/download?dummy=
--->  Attempting to fetch vcpkg-0.2.10.crate from https://crates.io/api/v1/crates/vcpkg/0.2.10/download?dummy=
--->  Attempting to fetch vec_map-0.8.2.crate from https://crates.io/api/v1/crates/vec_map/0.8.2/download?dummy=
--->  Attempting to fetch vergen-5.1.0.crate from https://crates.io/api/v1/crates/vergen/5.1.0/download?dummy=
--->  Attempting to fetch version_check-0.9.3.crate from https://crates.io/api/v1/crates/version_check/0.9.3/download?dummy=
--->  Attempting to fetch vte-0.3.3.crate from https://crates.io/api/v1/crates/vte/0.3.3/download?dummy=
--->  Attempting to fetch walkdir-2.3.1.crate from https://crates.io/api/v1/crates/walkdir/2.3.1/download?dummy=
--->  Attempting to fetch wasi-0.9.0+wasi-snapshot-preview1.crate from https://crates.io/api/v1/crates/wasi/0.9.0+wasi-snapshot-preview1/download?dummy=
--->  Attempting to fetch wasi-0.11.0+wasi-snapshot-preview1.crate from https://crates.io/api/v1/crates/wasi/0.11.0+wasi-snapshot-preview1/download?dummy=
--->  Attempting to fetch winapi-0.3.9.crate from https://crates.io/api/v1/crates/winapi/0.3.9/download?dummy=
--->  Attempting to fetch winapi-i686-pc-windows-gnu-0.4.0.crate from https://crates.io/api/v1/crates/winapi-i686-pc-windows-gnu/0.4.0/download?dummy=
--->  Attempting to fetch winapi-util-0.1.5.crate from https://crates.io/api/v1/crates/winapi-util/0.1.5/download?dummy=
--->  Attempting to fetch winapi-x86_64-pc-windows-gnu-0.4.0.crate from https://crates.io/api/v1/crates/winapi-x86_64-pc-windows-gnu/0.4.0/download?dummy=
--->  Attempting to fetch xattr-0.2.2.crate from https://crates.io/api/v1/crates/xattr/0.2.2/download?dummy=
--->  Attempting to fetch xml5ever-0.16.1.crate from https://crates.io/api/v1/crates/xml5ever/0.16.1/download?dummy=
--->  Attempting to fetch xz2-0.1.6.crate from https://crates.io/api/v1/crates/xz2/0.1.6/download?dummy=
--->  Attempting to fetch yaml-merge-keys-0.4.1.crate from https://crates.io/api/v1/crates/yaml-merge-keys/0.4.1/download?dummy=
--->  Attempting to fetch yaml-rust-0.3.5.crate from https://crates.io/api/v1/crates/yaml-rust/0.3.5/download?dummy=
--->  Attempting to fetch yaml-rust-0.4.4.crate from https://crates.io/api/v1/crates/yaml-rust/0.4.4/download?dummy=
--->  Attempting to fetch yansi-term-0.1.2.crate from https://crates.io/api/v1/crates/yansi-term/0.1.2/download?dummy=
--->  Verifying checksums for rust
--->  Extracting rust
--->  Applying patches to rust
--->  Configuring rust
--->  Building rust
      [                                        ]  18.3 %
```

Wait, what?  Not only did Rust make it into the dependency chain here,
but whatever thing (or things) it's building needs (need) 393 Rust
packages to build?  Including things like
`winapi-x86_64-pc-windows-gnu-0` (I am on `macOS-arm64`) and two
different versions of a WebAssembly runtime?  What the fuck?!

Rust finishes building 35 minutes later, and now we're on to cargo
(the Rust package manager).  Progress!

```
--->  Staging rust into destroot
--->  Installing rust @1.61.0_2
--->  Activating rust @1.61.0_2
--->  Cleaning rust
--->  Computing dependencies for cargo
--->  Fetching archive for cargo
--->  Attempting to fetch cargo-0.62.0_2.darwin_22.arm64.tbz2 from https://packages.macports.org/cargo
--->  Attempting to fetch cargo-0.62.0_2.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/cargo
--->  Attempting to fetch cargo-0.62.0_2.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/cargo
--->  Fetching distfiles for cargo
--->  Attempting to fetch cargo-0.62.0.tar.gz from https://distfiles.macports.org/cargo-crates
--->  Attempting to fetch cargo-1.60.0-aarch64-apple-darwin.tar.gz from https://static.rust-lang.org/dist
--->  Attempting to fetch anyhow-1.0.57.crate from https://crates.io/api/v1/crates/anyhow/1.0.57/download?dummy=
--->  Attempting to fetch arrayvec-0.5.2.crate from https://crates.io/api/v1/crates/arrayvec/0.5.2/download?dummy=
--->  Attempting to fetch bitmaps-2.1.0.crate from https://crates.io/api/v1/crates/bitmaps/2.1.0/download?dummy=
--->  Attempting to fetch bytesize-1.1.0.crate from https://crates.io/api/v1/crates/bytesize/1.1.0/download?dummy=
--->  Attempting to fetch cc-1.0.73.crate from https://crates.io/api/v1/crates/cc/1.0.73/download?dummy=
--->  Attempting to fetch clap-3.1.18.crate from https://crates.io/api/v1/crates/clap/3.1.18/download?dummy=
--->  Attempting to fetch clap_lex-0.2.0.crate from https://crates.io/api/v1/crates/clap_lex/0.2.0/download?dummy=
--->  Attempting to fetch combine-4.6.4.crate from https://crates.io/api/v1/crates/combine/4.6.4/download?dummy=
--->  Attempting to fetch commoncrypto-0.2.0.crate from https://crates.io/api/v1/crates/commoncrypto/0.2.0/download?dummy=
--->  Attempting to fetch commoncrypto-sys-0.2.0.crate from https://crates.io/api/v1/crates/commoncrypto-sys/0.2.0/download?dummy=
--->  Attempting to fetch core-foundation-0.9.3.crate from https://crates.io/api/v1/crates/core-foundation/0.9.3/download?dummy=
--->  Attempting to fetch core-foundation-sys-0.8.3.crate from https://crates.io/api/v1/crates/core-foundation-sys/0.8.3/download?dummy=
--->  Attempting to fetch crc32fast-1.3.2.crate from https://crates.io/api/v1/crates/crc32fast/1.3.2/download?dummy=
--->  Attempting to fetch crossbeam-utils-0.8.8.crate from https://crates.io/api/v1/crates/crossbeam-utils/0.8.8/download?dummy=
--->  Attempting to fetch crypto-hash-0.3.4.crate from https://crates.io/api/v1/crates/crypto-hash/0.3.4/download?dummy=
--->  Attempting to fetch curl-0.4.43.crate from https://crates.io/api/v1/crates/curl/0.4.43/download?dummy=
--->  Attempting to fetch curl-sys-0.4.55+curl-7.83.1.crate from https://crates.io/api/v1/crates/curl-sys/0.4.55+curl-7.83.1/download?dummy=
--->  Attempting to fetch env_logger-0.7.1.crate from https://crates.io/api/v1/crates/env_logger/0.7.1/download?dummy=
--->  Attempting to fetch env_logger-0.9.0.crate from https://crates.io/api/v1/crates/env_logger/0.9.0/download?dummy=
--->  Attempting to fetch fastrand-1.7.0.crate from https://crates.io/api/v1/crates/fastrand/1.7.0/download?dummy=
--->  Attempting to fetch filetime-0.2.16.crate from https://crates.io/api/v1/crates/filetime/0.2.16/download?dummy=
--->  Attempting to fetch flate2-1.0.23.crate from https://crates.io/api/v1/crates/flate2/1.0.23/download?dummy=
--->  Attempting to fetch fnv-1.0.7.crate from https://crates.io/api/v1/crates/fnv/1.0.7/download?dummy=
--->  Attempting to fetch foreign-types-0.3.2.crate from https://crates.io/api/v1/crates/foreign-types/0.3.2/download?dummy=
--->  Attempting to fetch foreign-types-shared-0.1.1.crate from https://crates.io/api/v1/crates/foreign-types-shared/0.1.1/download?dummy=
--->  Attempting to fetch form_urlencoded-1.0.1.crate from https://crates.io/api/v1/crates/form_urlencoded/1.0.1/download?dummy=
--->  Attempting to fetch fwdansi-1.1.0.crate from https://crates.io/api/v1/crates/fwdansi/1.1.0/download?dummy=
--->  Attempting to fetch git2-0.14.2.crate from https://crates.io/api/v1/crates/git2/0.14.2/download?dummy=
--->  Attempting to fetch git2-curl-0.15.0.crate from https://crates.io/api/v1/crates/git2-curl/0.15.0/download?dummy=
--->  Attempting to fetch globset-0.4.8.crate from https://crates.io/api/v1/crates/globset/0.4.8/download?dummy=
--->  Attempting to fetch hashbrown-0.11.2.crate from https://crates.io/api/v1/crates/hashbrown/0.11.2/download?dummy=
--->  Attempting to fetch hex-0.3.2.crate from https://crates.io/api/v1/crates/hex/0.3.2/download?dummy=
--->  Attempting to fetch hex-0.4.3.crate from https://crates.io/api/v1/crates/hex/0.4.3/download?dummy=
--->  Attempting to fetch home-0.5.3.crate from https://crates.io/api/v1/crates/home/0.5.3/download?dummy=
--->  Attempting to fetch humantime-1.3.0.crate from https://crates.io/api/v1/crates/humantime/1.3.0/download?dummy=
--->  Attempting to fetch idna-0.2.3.crate from https://crates.io/api/v1/crates/idna/0.2.3/download?dummy=
--->  Attempting to fetch ignore-0.4.18.crate from https://crates.io/api/v1/crates/ignore/0.4.18/download?dummy=
--->  Attempting to fetch im-rc-15.1.0.crate from https://crates.io/api/v1/crates/im-rc/15.1.0/download?dummy=
--->  Attempting to fetch indexmap-1.8.1.crate from https://crates.io/api/v1/crates/indexmap/1.8.1/download?dummy=
--->  Attempting to fetch itertools-0.10.3.crate from https://crates.io/api/v1/crates/itertools/0.10.3/download?dummy=
--->  Attempting to fetch itoa-1.0.2.crate from https://crates.io/api/v1/crates/itoa/1.0.2/download?dummy=
--->  Attempting to fetch kstring-1.0.6.crate from https://crates.io/api/v1/crates/kstring/1.0.6/download?dummy=
--->  Attempting to fetch libc-0.2.126.crate from https://crates.io/api/v1/crates/libc/0.2.126/download?dummy=
--->  Attempting to fetch libgit2-sys-0.13.2+1.4.2.crate from https://crates.io/api/v1/crates/libgit2-sys/0.13.2+1.4.2/download?dummy=
--->  Attempting to fetch libnghttp2-sys-0.1.7+1.45.0.crate from https://crates.io/api/v1/crates/libnghttp2-sys/0.1.7+1.45.0/download?dummy=
--->  Attempting to fetch libssh2-sys-0.2.23.crate from https://crates.io/api/v1/crates/libssh2-sys/0.2.23/download?dummy=
--->  Attempting to fetch libz-sys-1.1.6.crate from https://crates.io/api/v1/crates/libz-sys/1.1.6/download?dummy=
--->  Attempting to fetch log-0.4.17.crate from https://crates.io/api/v1/crates/log/0.4.17/download?dummy=
--->  Attempting to fetch matches-0.1.9.crate from https://crates.io/api/v1/crates/matches/0.1.9/download?dummy=
--->  Attempting to fetch memchr-2.5.0.crate from https://crates.io/api/v1/crates/memchr/2.5.0/download?dummy=
--->  Attempting to fetch miniz_oxide-0.5.1.crate from https://crates.io/api/v1/crates/miniz_oxide/0.5.1/download?dummy=
--->  Attempting to fetch once_cell-1.11.0.crate from https://crates.io/api/v1/crates/once_cell/1.11.0/download?dummy=
--->  Attempting to fetch opener-0.5.0.crate from https://crates.io/api/v1/crates/opener/0.5.0/download?dummy=
--->  Attempting to fetch openssl-0.10.40.crate from https://crates.io/api/v1/crates/openssl/0.10.40/download?dummy=
--->  Attempting to fetch openssl-macros-0.1.0.crate from https://crates.io/api/v1/crates/openssl-macros/0.1.0/download?dummy=
--->  Attempting to fetch openssl-probe-0.1.5.crate from https://crates.io/api/v1/crates/openssl-probe/0.1.5/download?dummy=
--->  Attempting to fetch openssl-src-111.20.0+1.1.1o.crate from https://crates.io/api/v1/crates/openssl-src/111.20.0+1.1.1o/download?dummy=
--->  Attempting to fetch openssl-sys-0.9.73.crate from https://crates.io/api/v1/crates/openssl-sys/0.9.73/download?dummy=
--->  Attempting to fetch os_info-3.4.0.crate from https://crates.io/api/v1/crates/os_info/3.4.0/download?dummy=
--->  Attempting to fetch os_str_bytes-6.0.1.crate from https://crates.io/api/v1/crates/os_str_bytes/6.0.1/download?dummy=
--->  Attempting to fetch percent-encoding-2.1.0.crate from https://crates.io/api/v1/crates/percent-encoding/2.1.0/download?dummy=
--->  Attempting to fetch pkg-config-0.3.25.crate from https://crates.io/api/v1/crates/pkg-config/0.3.25/download?dummy=
--->  Attempting to fetch pretty_env_logger-0.4.0.crate from https://crates.io/api/v1/crates/pretty_env_logger/0.4.0/download?dummy=
--->  Attempting to fetch proc-macro2-1.0.39.crate from https://crates.io/api/v1/crates/proc-macro2/1.0.39/download?dummy=
--->  Attempting to fetch quick-error-1.2.3.crate from https://crates.io/api/v1/crates/quick-error/1.2.3/download?dummy=
--->  Attempting to fetch rand_xoshiro-0.6.0.crate from https://crates.io/api/v1/crates/rand_xoshiro/0.6.0/download?dummy=
--->  Attempting to fetch regex-1.5.6.crate from https://crates.io/api/v1/crates/regex/1.5.6/download?dummy=
--->  Attempting to fetch regex-syntax-0.6.26.crate from https://crates.io/api/v1/crates/regex-syntax/0.6.26/download?dummy=
--->  Attempting to fetch remove_dir_all-0.5.3.crate from https://crates.io/api/v1/crates/remove_dir_all/0.5.3/download?dummy=
--->  Attempting to fetch rustc-workspace-hack-1.0.0.crate from https://crates.io/api/v1/crates/rustc-workspace-hack/1.0.0/download?dummy=
--->  Attempting to fetch rustfix-0.6.0.crate from https://crates.io/api/v1/crates/rustfix/0.6.0/download?dummy=
--->  Attempting to fetch ryu-1.0.10.crate from https://crates.io/api/v1/crates/ryu/1.0.10/download?dummy=
--->  Attempting to fetch schannel-0.1.20.crate from https://crates.io/api/v1/crates/schannel/0.1.20/download?dummy=
--->  Attempting to fetch semver-1.0.9.crate from https://crates.io/api/v1/crates/semver/1.0.9/download?dummy=
--->  Attempting to fetch serde-1.0.137.crate from https://crates.io/api/v1/crates/serde/1.0.137/download?dummy=
--->  Attempting to fetch serde_derive-1.0.137.crate from https://crates.io/api/v1/crates/serde_derive/1.0.137/download?dummy=
--->  Attempting to fetch serde_ignored-0.1.3.crate from https://crates.io/api/v1/crates/serde_ignored/0.1.3/download?dummy=
--->  Attempting to fetch serde_json-1.0.81.crate from https://crates.io/api/v1/crates/serde_json/1.0.81/download?dummy=
--->  Attempting to fetch shell-escape-0.1.5.crate from https://crates.io/api/v1/crates/shell-escape/0.1.5/download?dummy=
--->  Attempting to fetch sized-chunks-0.6.5.crate from https://crates.io/api/v1/crates/sized-chunks/0.6.5/download?dummy=
--->  Attempting to fetch socket2-0.4.4.crate from https://crates.io/api/v1/crates/socket2/0.4.4/download?dummy=
--->  Attempting to fetch strip-ansi-escapes-0.1.1.crate from https://crates.io/api/v1/crates/strip-ansi-escapes/0.1.1/download?dummy=
--->  Attempting to fetch strsim-0.10.0.crate from https://crates.io/api/v1/crates/strsim/0.10.0/download?dummy=
--->  Attempting to fetch syn-1.0.95.crate from https://crates.io/api/v1/crates/syn/1.0.95/download?dummy=
--->  Attempting to fetch tar-0.4.38.crate from https://crates.io/api/v1/crates/tar/0.4.38/download?dummy=
--->  Attempting to fetch tempfile-3.3.0.crate from https://crates.io/api/v1/crates/tempfile/3.3.0/download?dummy=
--->  Attempting to fetch termcolor-1.1.3.crate from https://crates.io/api/v1/crates/termcolor/1.1.3/download?dummy=
--->  Attempting to fetch textwrap-0.15.0.crate from https://crates.io/api/v1/crates/textwrap/0.15.0/download?dummy=
--->  Attempting to fetch thread_local-1.1.4.crate from https://crates.io/api/v1/crates/thread_local/1.1.4/download?dummy=
--->  Attempting to fetch tinyvec-1.6.0.crate from https://crates.io/api/v1/crates/tinyvec/1.6.0/download?dummy=
--->  Attempting to fetch tinyvec_macros-0.1.0.crate from https://crates.io/api/v1/crates/tinyvec_macros/0.1.0/download?dummy=
--->  Attempting to fetch toml_edit-0.13.4.crate from https://crates.io/api/v1/crates/toml_edit/0.13.4/download?dummy=
--->  Attempting to fetch typenum-1.15.0.crate from https://crates.io/api/v1/crates/typenum/1.15.0/download?dummy=
--->  Attempting to fetch unicode-bidi-0.3.8.crate from https://crates.io/api/v1/crates/unicode-bidi/0.3.8/download?dummy=
--->  Attempting to fetch unicode-ident-1.0.0.crate from https://crates.io/api/v1/crates/unicode-ident/1.0.0/download?dummy=
--->  Attempting to fetch unicode-normalization-0.1.19.crate from https://crates.io/api/v1/crates/unicode-normalization/0.1.19/download?dummy=
--->  Attempting to fetch unicode-xid-0.2.3.crate from https://crates.io/api/v1/crates/unicode-xid/0.2.3/download?dummy=
--->  Attempting to fetch url-2.2.2.crate from https://crates.io/api/v1/crates/url/2.2.2/download?dummy=
--->  Attempting to fetch utf8parse-0.2.0.crate from https://crates.io/api/v1/crates/utf8parse/0.2.0/download?dummy=
--->  Attempting to fetch vcpkg-0.2.15.crate from https://crates.io/api/v1/crates/vcpkg/0.2.15/download?dummy=
--->  Attempting to fetch vte-0.10.1.crate from https://crates.io/api/v1/crates/vte/0.10.1/download?dummy=
--->  Attempting to fetch vte_generate_state_changes-0.1.1.crate from https://crates.io/api/v1/crates/vte_generate_state_changes/0.1.1/download?dummy=
--->  Attempting to fetch windows-sys-0.36.1.crate from https://crates.io/api/v1/crates/windows-sys/0.36.1/download?dummy=
--->  Attempting to fetch windows_aarch64_msvc-0.36.1.crate from https://crates.io/api/v1/crates/windows_aarch64_msvc/0.36.1/download?dummy=
--->  Attempting to fetch windows_i686_gnu-0.36.1.crate from https://crates.io/api/v1/crates/windows_i686_gnu/0.36.1/download?dummy=
--->  Attempting to fetch windows_i686_msvc-0.36.1.crate from https://crates.io/api/v1/crates/windows_i686_msvc/0.36.1/download?dummy=
--->  Attempting to fetch windows_x86_64_gnu-0.36.1.crate from https://crates.io/api/v1/crates/windows_x86_64_gnu/0.36.1/download?dummy=
--->  Attempting to fetch windows_x86_64_msvc-0.36.1.crate from https://crates.io/api/v1/crates/windows_x86_64_msvc/0.36.1/download?dummy=
--->  Verifying checksums for cargo
--->  Extracting cargo
--->  Configuring cargo
--->  Building cargo
      [  ...  ]
```

Thankfully, cargo is relatively faster to build, and now we're ready
to make progress on other things.  Shout-out to the other Windows
packages that were just brought in.  Now we also get a hint into what
exactly brought Rust in:

```
--->  Staging cargo into destroot
--->  Installing cargo @0.62.0_2
--->  Activating cargo @0.62.0_2
--->  Cleaning cargo
--->  Computing dependencies for py310-setuptools-rust
--->  Fetching archive for py310-setuptools-rust
--->  Attempting to fetch py310-setuptools-rust-1.5.2_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-setuptools-rust
--->  Attempting to fetch py310-setuptools-rust-1.5.2_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-setuptools-rust
--->  Installing py310-setuptools-rust @1.5.2_0
--->  Activating py310-setuptools-rust @1.5.2_0
--->  Cleaning py310-setuptools-rust
--->  Computing dependencies for py310-packaging
--->  Fetching archive for py310-packaging
--->  Attempting to fetch py310-packaging-22.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-packaging
--->  Attempting to fetch py310-packaging-22.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-packaging
--->  Installing py310-packaging @22.0_0
--->  Cleaning py310-packaging
--->  Computing dependencies for py310-packaging
--->  Deactivating py310-packaging @21.3_0
--->  Cleaning py310-packaging
--->  Activating py310-packaging @22.0_0
--->  Cleaning py310-packaging
--->  Computing dependencies for py310-pep517
--->  Fetching archive for py310-pep517
--->  Attempting to fetch py310-pep517-0.13.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-pep517
--->  Attempting to fetch py310-pep517-0.13.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-pep517
--->  Installing py310-pep517 @0.13.0_0
--->  Activating py310-pep517 @0.13.0_0
--->  Cleaning py310-pep517
--->  Computing dependencies for py310-build
--->  Fetching archive for py310-build
--->  Attempting to fetch py310-build-0.8.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-build
--->  Attempting to fetch py310-build-0.8.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-build
--->  Installing py310-build @0.8.0_0
--->  Activating py310-build @0.8.0_0
--->  Cleaning py310-build
--->  Computing dependencies for py310-installer
--->  Fetching archive for py310-installer
--->  Attempting to fetch py310-installer-0.6.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-installer
--->  Attempting to fetch py310-installer-0.6.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-installer
--->  Installing py310-installer @0.6.0_0
--->  Activating py310-installer @0.6.0_0
--->  Cleaning py310-installer
--->  Computing dependencies for py310-wheel
--->  Fetching archive for py310-wheel
--->  Attempting to fetch py310-wheel-0.38.4_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-wheel
--->  Attempting to fetch py310-wheel-0.38.4_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-wheel
--->  Installing py310-wheel @0.38.4_0
--->  Activating py310-wheel @0.38.4_0
--->  Cleaning py310-wheel
--->  Computing dependencies for py310-pycparser
--->  Fetching archive for py310-pycparser
--->  Attempting to fetch py310-pycparser-2.21_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-pycparser
--->  Attempting to fetch py310-pycparser-2.21_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-pycparser
--->  Installing py310-pycparser @2.21_0
--->  Activating py310-pycparser @2.21_0
--->  Cleaning py310-pycparser
--->  Computing dependencies for py310-cffi
--->  Fetching archive for py310-cffi
--->  Attempting to fetch py310-cffi-1.15.1_0.darwin_22.arm64.tbz2 from https://packages.macports.org/py310-cffi
--->  Attempting to fetch py310-cffi-1.15.1_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/py310-cffi
--->  Attempting to fetch py310-cffi-1.15.1_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/py310-cffi
--->  Fetching distfiles for py310-cffi
--->  Attempting to fetch cffi-1.15.1.tar.gz from https://distfiles.macports.org/py-cffi
--->  Verifying checksums for py310-cffi
--->  Extracting py310-cffi
--->  Applying patches to py310-cffi
--->  Configuring py310-cffi
--->  Building py310-cffi
--->  Staging py310-cffi into destroot
--->  Installing py310-cffi @1.15.1_0
--->  Activating py310-cffi @1.15.1_0
--->  Cleaning py310-cffi
--->  Computing dependencies for py310-cryptography
--->  Fetching archive for py310-cryptography
--->  Attempting to fetch py310-cryptography-38.0.3_0.darwin_22.arm64.tbz2 from https://packages.macports.org/py310-cryptography
--->  Attempting to fetch py310-cryptography-38.0.3_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/py310-cryptography
--->  Attempting to fetch py310-cryptography-38.0.3_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/py310-cryptography
--->  Fetching distfiles for py310-cryptography
--->  Attempting to fetch cryptography-38.0.3.tar.gz from https://distfiles.macports.org/cargo-crates
--->  Attempting to fetch Inflector-0.11.4.crate from https://crates.io/api/v1/crates/Inflector/0.11.4/download?dummy=
--->  Attempting to fetch aliasable-0.1.3.crate from https://crates.io/api/v1/crates/aliasable/0.1.3/download?dummy=
--->  Attempting to fetch android_system_properties-0.1.5.crate from https://crates.io/api/v1/crates/android_system_properties/0.1.5/download?dummy=
--->  Attempting to fetch asn1-0.12.2.crate from https://crates.io/api/v1/crates/asn1/0.12.2/download?dummy=
--->  Attempting to fetch asn1_derive-0.12.2.crate from https://crates.io/api/v1/crates/asn1_derive/0.12.2/download?dummy=
--->  Attempting to fetch base64-0.13.0.crate from https://crates.io/api/v1/crates/base64/0.13.0/download?dummy=
--->  Attempting to fetch bumpalo-3.10.0.crate from https://crates.io/api/v1/crates/bumpalo/3.10.0/download?dummy=
--->  Attempting to fetch chrono-0.4.22.crate from https://crates.io/api/v1/crates/chrono/0.4.22/download?dummy=
--->  Attempting to fetch iana-time-zone-0.1.47.crate from https://crates.io/api/v1/crates/iana-time-zone/0.1.47/download?dummy=
--->  Attempting to fetch indoc-0.3.6.crate from https://crates.io/api/v1/crates/indoc/0.3.6/download?dummy=
--->  Attempting to fetch indoc-impl-0.3.6.crate from https://crates.io/api/v1/crates/indoc-impl/0.3.6/download?dummy=
--->  Attempting to fetch js-sys-0.3.59.crate from https://crates.io/api/v1/crates/js-sys/0.3.59/download?dummy=
--->  Attempting to fetch libc-0.2.132.crate from https://crates.io/api/v1/crates/libc/0.2.132/download?dummy=
--->  Attempting to fetch lock_api-0.4.8.crate from https://crates.io/api/v1/crates/lock_api/0.4.8/download?dummy=
--->  Attempting to fetch num-integer-0.1.45.crate from https://crates.io/api/v1/crates/num-integer/0.1.45/download?dummy=
--->  Attempting to fetch num-traits-0.2.15.crate from https://crates.io/api/v1/crates/num-traits/0.2.15/download?dummy=
--->  Attempting to fetch once_cell-1.14.0.crate from https://crates.io/api/v1/crates/once_cell/1.14.0/download?dummy=
--->  Attempting to fetch ouroboros-0.15.4.crate from https://crates.io/api/v1/crates/ouroboros/0.15.4/download?dummy=
--->  Attempting to fetch ouroboros_macro-0.15.4.crate from https://crates.io/api/v1/crates/ouroboros_macro/0.15.4/download?dummy=
--->  Attempting to fetch parking_lot-0.11.2.crate from https://crates.io/api/v1/crates/parking_lot/0.11.2/download?dummy=
--->  Attempting to fetch parking_lot_core-0.8.5.crate from https://crates.io/api/v1/crates/parking_lot_core/0.8.5/download?dummy=
--->  Attempting to fetch paste-0.1.18.crate from https://crates.io/api/v1/crates/paste/0.1.18/download?dummy=
--->  Attempting to fetch paste-impl-0.1.18.crate from https://crates.io/api/v1/crates/paste-impl/0.1.18/download?dummy=
--->  Attempting to fetch pem-1.1.0.crate from https://crates.io/api/v1/crates/pem/1.1.0/download?dummy=
--->  Attempting to fetch proc-macro-hack-0.5.19.crate from https://crates.io/api/v1/crates/proc-macro-hack/0.5.19/download?dummy=
--->  Attempting to fetch proc-macro2-1.0.43.crate from https://crates.io/api/v1/crates/proc-macro2/1.0.43/download?dummy=
--->  Attempting to fetch pyo3-0.15.2.crate from https://crates.io/api/v1/crates/pyo3/0.15.2/download?dummy=
--->  Attempting to fetch pyo3-build-config-0.15.2.crate from https://crates.io/api/v1/crates/pyo3-build-config/0.15.2/download?dummy=
--->  Attempting to fetch pyo3-macros-0.15.2.crate from https://crates.io/api/v1/crates/pyo3-macros/0.15.2/download?dummy=
--->  Attempting to fetch pyo3-macros-backend-0.15.2.crate from https://crates.io/api/v1/crates/pyo3-macros-backend/0.15.2/download?dummy=
--->  Attempting to fetch quote-1.0.21.crate from https://crates.io/api/v1/crates/quote/1.0.21/download?dummy=
--->  Attempting to fetch redox_syscall-0.2.16.crate from https://crates.io/api/v1/crates/redox_syscall/0.2.16/download?dummy=
--->  Attempting to fetch smallvec-1.9.0.crate from https://crates.io/api/v1/crates/smallvec/1.9.0/download?dummy=
--->  Attempting to fetch syn-1.0.99.crate from https://crates.io/api/v1/crates/syn/1.0.99/download?dummy=
--->  Attempting to fetch unicode-ident-1.0.3.crate from https://crates.io/api/v1/crates/unicode-ident/1.0.3/download?dummy=
--->  Attempting to fetch unindent-0.1.10.crate from https://crates.io/api/v1/crates/unindent/0.1.10/download?dummy=
--->  Attempting to fetch wasm-bindgen-0.2.82.crate from https://crates.io/api/v1/crates/wasm-bindgen/0.2.82/download?dummy=
--->  Attempting to fetch wasm-bindgen-backend-0.2.82.crate from https://crates.io/api/v1/crates/wasm-bindgen-backend/0.2.82/download?dummy=
--->  Attempting to fetch wasm-bindgen-macro-0.2.82.crate from https://crates.io/api/v1/crates/wasm-bindgen-macro/0.2.82/download?dummy=
--->  Attempting to fetch wasm-bindgen-macro-support-0.2.82.crate from https://crates.io/api/v1/crates/wasm-bindgen-macro-support/0.2.82/download?dummy=
--->  Attempting to fetch wasm-bindgen-shared-0.2.82.crate from https://crates.io/api/v1/crates/wasm-bindgen-shared/0.2.82/download?dummy=
--->  Verifying checksums for py310-cryptography
--->  Extracting py310-cryptography
--->  Configuring py310-cryptography
--->  Building py310-cryptography
--->  Staging py310-cryptography into destroot
--->  Installing py310-cryptography @38.0.3_0
--->  Activating py310-cryptography @38.0.3_0
--->  Cleaning py310-cryptography
--->  Computing dependencies for py310-fido2
--->  Fetching archive for py310-fido2
--->  Attempting to fetch py310-fido2-1.1.0_0.darwin_22.arm64.tbz2 from https://packages.macports.org/py310-fido2
--->  Attempting to fetch py310-fido2-1.1.0_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/py310-fido2
--->  Attempting to fetch py310-fido2-1.1.0_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/py310-fido2
--->  Fetching distfiles for py310-fido2
--->  Attempting to fetch fido2-1.1.0.tar.gz from https://distfiles.macports.org/py-fido2
--->  Verifying checksums for py310-fido2
--->  Extracting py310-fido2
--->  Configuring py310-fido2
--->  Building py310-fido2
--->  Staging py310-fido2 into destroot
--->  Installing py310-fido2 @1.1.0_0
--->  Activating py310-fido2 @1.1.0_0
--->  Cleaning py310-fido2
--->  Computing dependencies for py310-openssl
--->  Fetching archive for py310-openssl
--->  Attempting to fetch py310-openssl-22.1.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-openssl
--->  Attempting to fetch py310-openssl-22.1.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-openssl
--->  Installing py310-openssl @22.1.0_0
--->  Activating py310-openssl @22.1.0_0
--->  Cleaning py310-openssl
--->  Computing dependencies for gsed
--->  Fetching archive for gsed
--->  Attempting to fetch gsed-4.9_0.darwin_22.arm64.tbz2 from https://packages.macports.org/gsed
--->  Attempting to fetch gsed-4.9_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/gsed
--->  Attempting to fetch gsed-4.9_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/gsed
--->  Fetching distfiles for gsed
--->  Attempting to fetch sed-4.9.tar.xz from https://distfiles.macports.org/gsed
--->  Verifying checksums for gsed
--->  Extracting gsed
--->  Configuring gsed
Warning: Configuration logfiles contain indications of -Wimplicit-function-declaration; check that features were not accidentally disabled:
  alignof: found in sed-4.9/config.log
  re_search: found in sed-4.9/config.log
  re_compile_pattern: found in sed-4.9/config.log
  re_set_syntax: found in sed-4.9/config.log
  MIN: found in sed-4.9/config.log
  __fpending: found in sed-4.9/config.log
  strchr: found in sed-4.9/config.log
  free: found in sed-4.9/config.log
--->  Building gsed
--->  Staging gsed into destroot
--->  Installing gsed @4.9_0
--->  Activating gsed @4.9_0
--->  Cleaning gsed
--->  Computing dependencies for swig
--->  Fetching archive for swig
--->  Attempting to fetch swig-4.1.1_0.darwin_22.arm64.tbz2 from https://packages.macports.org/swig
--->  Attempting to fetch swig-4.1.1_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/swig
--->  Attempting to fetch swig-4.1.1_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/swig
--->  Fetching distfiles for swig
--->  Attempting to fetch swig-4.1.1.tar.gz from https://distfiles.macports.org/swig
--->  Verifying checksums for swig
--->  Extracting swig
--->  Configuring swig
Warning: Configuration logfiles contain indications of -Wimplicit-function-declaration; check that features were not accidentally disabled:
  snprintf: found in swig-4.1.1/CCache/config.log
  strcmp: found in swig-4.1.1/CCache/config.log
  exit: found in swig-4.1.1/CCache/config.log
  vsnprintf: found in swig-4.1.1/CCache/config.log
--->  Building swig
--->  Staging swig into destroot
--->  Installing swig @4.1.1_0
--->  Cleaning swig
--->  Computing dependencies for swig
--->  Deactivating swig @4.0.2_2
--->  Cleaning swig
--->  Activating swig @4.1.1_0
--->  Cleaning swig
--->  Computing dependencies for swig-python
--->  Fetching archive for swig-python
--->  Attempting to fetch swig-python-4.1.1_0.darwin_22.arm64.tbz2 from https://packages.macports.org/swig-python
--->  Attempting to fetch swig-python-4.1.1_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/swig-python
--->  Attempting to fetch swig-python-4.1.1_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/swig-python
--->  Fetching distfiles for swig-python
--->  Verifying checksums for swig-python
--->  Extracting swig-python
--->  Configuring swig-python
Warning: Configuration logfiles contain indications of -Wimplicit-function-declaration; check that features were not accidentally disabled:
  snprintf: found in swig-4.1.1/CCache/config.log
  strcmp: found in swig-4.1.1/CCache/config.log
  exit: found in swig-4.1.1/CCache/config.log
  vsnprintf: found in swig-4.1.1/CCache/config.log
--->  Building swig-python
--->  Staging swig-python into destroot
--->  Installing swig-python @4.1.1_0
--->  Cleaning swig-python
--->  Computing dependencies for swig-python
--->  Deactivating swig-python @4.0.2_2
--->  Cleaning swig-python
--->  Activating swig-python @4.1.1_0
--->  Cleaning swig-python
--->  Computing dependencies for py310-pyscard
--->  Fetching archive for py310-pyscard
--->  Attempting to fetch py310-pyscard-2.0.5_0.darwin_22.arm64.tbz2 from https://packages.macports.org/py310-pyscard
--->  Attempting to fetch py310-pyscard-2.0.5_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/py310-pyscard
--->  Attempting to fetch py310-pyscard-2.0.5_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/py310-pyscard
--->  Fetching distfiles for py310-pyscard
--->  Attempting to fetch pyscard-2.0.5.tar.gz from https://distfiles.macports.org/py-pyscard
--->  Verifying checksums for py310-pyscard
--->  Extracting py310-pyscard
--->  Configuring py310-pyscard
--->  Building py310-pyscard
--->  Staging py310-pyscard into destroot
--->  Installing py310-pyscard @2.0.5_0
--->  Activating py310-pyscard @2.0.5_0
--->  Cleaning py310-pyscard
--->  Computing dependencies for py310-zipp
--->  Fetching archive for py310-zipp
--->  Attempting to fetch py310-zipp-3.11.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-zipp
--->  Attempting to fetch py310-zipp-3.11.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-zipp
--->  Installing py310-zipp @3.11.0_0
--->  Activating py310-zipp @3.11.0_0
--->  Cleaning py310-zipp
--->  Computing dependencies for py310-importlib-metadata
--->  Fetching archive for py310-importlib-metadata
--->  Attempting to fetch py310-importlib-metadata-5.1.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-importlib-metadata
--->  Attempting to fetch py310-importlib-metadata-5.1.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-importlib-metadata
--->  Installing py310-importlib-metadata @5.1.0_0
--->  Activating py310-importlib-metadata @5.1.0_0
--->  Cleaning py310-importlib-metadata
--->  Computing dependencies for py310-more-itertools
--->  Fetching archive for py310-more-itertools
--->  Attempting to fetch py310-more-itertools-9.0.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-more-itertools
--->  Attempting to fetch py310-more-itertools-9.0.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-more-itertools
--->  Installing py310-more-itertools @9.0.0_0
--->  Cleaning py310-more-itertools
--->  Computing dependencies for py310-more-itertools
--->  Deactivating py310-more-itertools @8.14.0_0
--->  Cleaning py310-more-itertools
--->  Activating py310-more-itertools @9.0.0_0
--->  Cleaning py310-more-itertools
--->  Computing dependencies for py310-jaraco.classes
--->  Fetching archive for py310-jaraco.classes
--->  Attempting to fetch py310-jaraco.classes-3.2.3_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-jaraco.classes
--->  Attempting to fetch py310-jaraco.classes-3.2.3_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-jaraco.classes
--->  Installing py310-jaraco.classes @3.2.3_0
--->  Activating py310-jaraco.classes @3.2.3_0
--->  Cleaning py310-jaraco.classes
--->  Computing dependencies for py310-keyring
--->  Fetching archive for py310-keyring
--->  Attempting to fetch py310-keyring-23.11.0_0.darwin_any.noarch.tbz2 from https://packages.macports.org/py310-keyring
--->  Attempting to fetch py310-keyring-23.11.0_0.darwin_any.noarch.tbz2.rmd160 from https://packages.macports.org/py310-keyring
--->  Installing py310-keyring @23.11.0_0
--->  Activating py310-keyring @23.11.0_0
--->  Cleaning py310-keyring
--->  Computing dependencies for yubikey-manager
--->  Fetching archive for yubikey-manager
--->  Attempting to fetch yubikey-manager-5.0.0_0.darwin_22.arm64.tbz2 from https://packages.macports.org/yubikey-manager
--->  Attempting to fetch yubikey-manager-5.0.0_0.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/yubikey-manager
--->  Attempting to fetch yubikey-manager-5.0.0_0.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/yubikey-manager
--->  Fetching distfiles for yubikey-manager
--->  Attempting to fetch yubikey_manager-5.0.0.tar.gz from https://distfiles.macports.org/yubikey-manager
--->  Verifying checksums for yubikey-manager
--->  Extracting yubikey-manager
--->  Configuring yubikey-manager
--->  Building yubikey-manager
--->  Staging yubikey-manager into destroot
--->  Installing yubikey-manager @5.0.0_0
--->  Cleaning yubikey-manager
--->  Computing dependencies for yubikey-manager
--->  Deactivating yubikey-manager @3.1.2_0
--->  Cleaning yubikey-manager
--->  Activating yubikey-manager @5.0.0_0
--->  Cleaning yubikey-manager
```

Several minutes later, and about an hour from when I ran that original
command, we're done installing everything.  Except, one of the things
I tried to upgrade failed:

```
--->  Fetching archive for ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://packages.macports.org/ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/ykpers
--->  Computing dependencies for ykpers
--->  Fetching distfiles for ykpers
--->  Attempting to fetch ykpers-1.20.0.tar.gz from https://distfiles.macports.org/ykpers
--->  Verifying checksums for ykpers
--->  Extracting ykpers
--->  Applying patches to ykpers
--->  Configuring ykpers
--->  Building ykpers
--->  Staging ykpers into destroot
--->  Unable to uninstall ykpers @1.20.0_1, the following ports depend on it:
--->    yubikey-manager @3.1.2_0
Warning: Uninstall forced.  Proceeding despite dependencies.
--->  Deactivating ykpers @1.20.0_1
--->  Cleaning ykpers
--->  Uninstalling ykpers @1.20.0_1
--->  Cleaning ykpers
--->  Computing dependencies for ykpers
--->  Fetching archive for ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://packages.macports.org/ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://nue.de.packages.macports.org/ykpers
--->  Attempting to fetch ykpers-1.20.0_1.darwin_22.arm64.tbz2 from https://mse.uk.packages.macports.org/ykpers
--->  Installing ykpers @1.20.0_1
--->  Activating ykpers @1.20.0_1
--->  Cleaning ykpers
--->  Updating database of binaries
--->  Scanning binaries for linking errors
```

You win some, you lose some.  At least now we get to find out exactly
why we needed Rust:

```
$ port rdependents rust
The following ports are dependent on rust:
  cargo
    py310-setuptools-rust
```

The graph ends unexpectedly.  Probably some bug in MacPorts that I'm
going to ignore for now.  Based on the earlier log, I can see
`py310-cryptography` depends on `py310-setuptools-rust`[^1], and
`py310-cryptography` is, in turn, depended on by `yubikey-manager`.  I
also notice it brings in several `wasm-bindgen-*` packages, for what
I'm sure are totally reasonable reasons[^2].

```
$ port info py310-cryptography
py310-cryptography @38.0.3 (python, devel)
...
Build Dependencies:   diffutils-for-muniversal, py310-setuptools-rust, py310-build, py310-installer, py310-setuptools, py310-wheel, rust, cargo
```

There's no moral to this story, except maybe avoid upgrading your
software.  I think Rust is Good, but this sucks.


[^1]: What we've got here is a cryptography package that transitively
    depends on at least 393 other packages, every single one of which
    is a potential attack vector.  Is this fine?  I don't know.
    Maybe?

[^2]: Vaguely, I remember something about some Rust packages that use
    Wasm to perform macro-expansion safely during builds, or something
    along those lines, so these may in fact be reasonable uses of
    these Wasm packages, by some definition of reasonable.  It feels
    like extreme bloat to me, though.
