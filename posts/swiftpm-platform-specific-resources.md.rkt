#lang punct "../common.rkt"

---
title: Platform-Specific Resources in SwiftPM
date: 2024-11-24T09:00:00+02:00
---

[Noise] packages Racket & Chez Scheme boot files[^1] for all the
platforms it supports. Originally, that was just `x86-64` and `arm64`
macOS, but when I added iOS support, that extended to include `arm64`
iOS. These boot files take up about 45MB for each `arch+os` pair and
the way I originally distributed them was placing them all in a `boot`
folder and adding them to the `resources` list for the core `Noise`
[target][before].

That worked fine, but it seemed like a waste to lug around an extra 90MB
of data that would never be used inside my iOS apps. Looking at the
[`PackageDescription`] docs, there doesn't appear to be a way to filter
resources by platform. There is an `exclude` property on `Target`s,
which I tried to use by making the `Package.swift` script manipulate the
target at runtime, but I couldn't figure out a way to get that working
with cross-compilation.

Next, I tried writing a SwiftPM [build tool plugin] to remove files
based on the target platform, but plugin execution is sandboxed and I
couldn't figure out a way to move the boot files out of the package
context[^2].

Finally, I [settled on][after] just making separate targets for macOS
and iOS. Each target contains its respective boot files and the main
target conditionally depends on the platform-specific targets. I really
wanted to avoid this approach because it's somewhat ugly and it means I
have to manually wire things around that the build system should be able
to do for me, but, for now, this seems like the most sensible approach.

[Noise]: https://github.com/Bogdanp/Noise
[before]: https://github.com/Bogdanp/Noise/blob/0581556c6977948d85839c589a1079e53f2368f5/Package.swift#L31-L33
[`PackageDescription`]: https://developer.apple.com/documentation/packagedescription
[build tool plugin]: https://github.com/swiftlang/swift-package-manager/blob/dca0cc27b9d5f08a9c9a38101e322d0f3ab1ba03/Documentation/Plugins.md#implementing-the-build-tool-plugin-script
[after]: https://github.com/Bogdanp/Noise/commit/4fb9fccc84a583b0bf8536063d63ad3aed84bb6c#diff-f913940c58e8744a2af1c68b909bb6383e49007e6c5a12fb03104a9006ae677eR25-R32

[^1]: Object files that contain the Racket and Chez Scheme runtime.
[^2]: As I'm writing this, I wonder if I could've combined the `exclude`
property and a build tool plugin to define a folder into which I
could've moved the unneeded boot files during the build.
