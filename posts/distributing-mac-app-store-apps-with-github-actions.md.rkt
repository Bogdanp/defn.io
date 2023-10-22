#lang punct "../common.rkt"

---
title: Distributing Apps to the Mac App Store With GitHub Actions
date: 2023-10-22T23:00:00+03:00
---

•(define other-post "Distributing Mac Apps With GitHub Actions")

This weekend, I decided to try and get [Franz] published on the Mac
App Store. Since I'm already •(@ other-post "using GitHub Actions to
build distributions for my customers"), I figured I'd extend that same
workflow to handle build submissions to the Mac App Store.

Most of the steps are the same as for manual distribution, but some
details are different and documentation is sparse, so I wanted to jot down some notes.

You can find the workflow definition on [GitHub][src].

## Apple Developer Certificates

Mac App Store apps are distributed as `.pkg` installers, so I generated
a "Mac Installer Distribution" certificate in Xcode and exported it. I
also needed an "Apple Distribution" certificate and a "Mac Development"
certificate. As in my previous post, these are stored as base64-encoded
secrets that are then added to a keychain during the workflow run.

## Provisioning Profile

This mode of distribution requires a provisioning profile. I
tried generating a profile from the [Certificates, Identifiers &
Profiles][profiles] section of the Apple Developer site, but I couldn't
get Xcode on the runner to recognize the profile no matter what I tried.
So, I gave up and I copied the provisioning profile Xcode generated
from `~/Library/MobileDevice/Provisioning Profiles` and added it as a
base64-encoded secret under GHA. The workflow writes the secret to the
provisioning profiles folder on the build machine:

```bash
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo -n "$MAC_PROVISIONING_PROFILE" | \
  base64 --decode -o ~/Library/MobileDevice/Provisioning\ Profiles/franz.provisionprofile
```

## Building the App

To build the app, I run the `xcodebuild archive` command:

```bash
xcodebuild \
  archive \
  -project FranzCocoa.xcodeproj/ \
  -scheme 'Franz MAS' \
  -destination 'generic/platform=macOS' \
  -archivePath dist/Franz.xcarchive
```

And to generate the `.pkg`, I run `xcodebuild` with the `-exportArchive`
flag:

```bash
xcodebuild \
  -exportArchive \
  -archivePath dist/Franz.xcarchive \
  -exportOptionsPlist FranzCocoa/MASExportOptions.plist \
  -exportPath dist/
```

The `exportOptionsPlist` file has to have a `method` key whose value is
`app-store`. When this `method` is specified, `xcodebuild` implicitly
exports a `.pkg` instead of an `.app` directory. All other options are
the same as in the developer ID method.

Finally, to upload the build to App Store Connect, I use `altool`:

```bash
xcrun altool \
  --upload-package dist/Franz.pkg \
  --type macos \
  --asc-public-id '69a6de7a-5947-47e3-e053-5b8c7c11a4d1' \
  --apple-id '6470144907' \
  --bundle-id 'io.defn.Franz' \
  --bundle-short-version-string "$(/usr/libexec/PlistBuddy -c 'Print ApplicationProperties:CFBundleShortVersionString' dist/Franz.xcarchive/Info.plist)" \
  --bundle-version "$(/usr/libexec/PlistBuddy -c 'Print ApplicationProperties:CFBundleVersion' dist/Franz.xcarchive/Info.plist)" \
  --username 'bogdan@defn.io' \
  --password "$APPLE_ID_PASSWORD"
```

To find my public ID, I had to run `xcrun altool --list-providers`.
To get an Apple ID for my app, I had to first create it in App Store
Connect. The ID can be found under "General" -> "App Information".

## Release Process

Since every submitted build must have a unique build number, I made this
part of the workflow optional. It only runs when the workflow is run
manually and the `masBuild` flag is set. So, my release process for the
Mac App Store is:

1. Bump the build number.
2. Run the workflow manually.
3. Go to App Store Connect and publish the new version.

[Franz]: https://franz.defn.io
[src]: https://github.com/Bogdanp/Franz/blob/e9f88613a62b4dcf9486cba59e7297cd732dad93/.github/workflows/build_macos.yml
[profiles]: https://developer.apple.com/account/resources/profiles/list
