#lang punct

---
title: Sharing Data Between Widgets and iOS Apps
date: 2025-04-13T09:31:00+03:00
---

Following up on the [previous post], another thing that's not
well-documented when it comes to implementing widgets on iOS is how to
share data between the widget and the main app.

The widget is supposed to be small and efficient so loading all your
models in there seems wrong (and the extension probably(?) can't event
access the app's sandboxed database).

The documentation mentions using network requests a bunch, presumably
because a lot of these widgets are expected to be used to display remote
data, but what about if you want to keep everything local?

The best solution I've found so far is to use `UserDefaults` with a
shared [app group]. I created a new app group (`Target Settings ->
Signing & Capabilities -> Add Capability -> App Groups`) and added both
the main app target and the widget extension target to it.

Then, I made some `Codable` structs that are shared between the two
targets and a coordinator, also shared between the targets, that reads
and writes those structs as JSON through a `UserDefaults(suiteName:
"app-group-id")` instance.

Finally, whenever something relevant to the widgets happens in the app,
an event listener updates the shared data and calls [`WidgetCenter`]'s
`reloadAllTimelines` method to have the system instruct the widgets to
reload the next time they're rendered. As far as I can tell, reloading
the timelines is always deferred, so calling `reloadAllTimelines`
multiple times in a row won't cause issues.

[previous post]: /2025/04/13/performing-widget-intents-in-ios-app/
[app group]: https://developer.apple.com/documentation/xcode/configuring-app-groups
[`WidgetCenter`]: https://developer.apple.com/documentation/widgetkit/widgetcenter
