#lang punct

---
title: Announcing elm-route
date: 2016-02-21T00:00:00+00:00
---

Today marks the first release of [elm-route][elm-route], a type safe
route parsing DSL built on top of [elm-combine][elm-combine]. Its main
additions to the world of type safe route parsing are:

- A generic DSL for expressing arbitrarily-nested dynamic routes (at
  the cost of uglier route constructors as the depth increases).
- An automatic way to do reverse routing that when coupled with a
  small amount of boilerplate should provide the safest approach to
  reverse routing that the Elm language can currently support.

You can see a working demo [here][demo] ([source][source]). Note that
direct linking to routes in the demo does not work due to a limitation
of Gihub Pages.

## Related work

[elm-route-parser][erp] is another type safe route parsing library. In
contrast to `elm-route`, its more rigid matchers make it possible to have
cleaner route constructors (for example, `HomeR` instead of `HomeR ()`).
It does not yet provide automatic reverse routing support.

## Example

Here's a short taste of what the DSL looks like:

```haskell
type Sitemap
  = HomeR ()
  | UsersR ()
  | UserR Int
  | UserPostR (Int, String)

homeR = HomeR := static ""
usersR = UsersR := static "users"
userR = UserR := "users" <//> int
userPostR = UserPostR := "users" <//> int </> string
sitemap = router [homeR, usersR, userR, userPostR]

match : String -> Maybe Sitemap
match = Route.match sitemap

route : Sitemap -> String
route r =
  case r of
    HomeR () -> reverse homeR []
    UsersR () -> reverse usersR []
    UserR id -> reverse userR [toString id]
    UserPostR (uid, pid) -> reverse userPostR [toString uid, pid]
```

For more check out the [README][README] and the [examples][ex] folder.


[elm-route]: https://github.com/Bogdanp/elm-route
[elm-combine]: https://github.com/Bogdanp/elm-combine
[erp]: https://github.com/etaque/elm-route-parser
[README]: https://github.com/Bogdanp/elm-route#example
[ex]: https://github.com/Bogdanp/elm-route/tree/master/examples
[demo]: http://bogdanp.github.io/elm-route/
[source]: https://github.com/Bogdanp/elm-route/tree/master/examples/app
