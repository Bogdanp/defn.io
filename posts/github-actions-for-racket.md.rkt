#lang punct "../common.rkt"

---
title: Using GitHub Actions to Test Racket Code
date: 2019-05-01T17:00:00+03:00
---

**This article is outdated as of 2020/05/05 because it refers to the
previous implementation of GitHub Actions. I've put together a revised
version at •(@ "Using GitHub Actions to Test Racket Code (Revised)") so
you should read that instead.**

Like [Alex Harsányi][alex-hhh], I've been looking for a good,
free-as-in-beer, alternative to Travis CI. For now, I've settled on
[GitHub Actions][actions] because using them is straightforward and
because I saves me from creating yet another account with some other
company.

GitHub Actions revolves around the concept of "workflows" and "actions".
Actions execute arbitrary Docker containers on top of a checked-out
repository and workflows describe which actions need to be executed when
a particular [event] occurs. During the execution of a workflow, all
actions, including ones running in parallel, share the same physical
workspace. All of this stuff is declaratively specified using [HCL].

Here's an example workflow:

```hcl
workflow "demo" {
  on = "push"
  resolves = ["echo"]
}

action "make-a" {
  uses = "docker://alpine"
  runs = ["sh", "-c", "echo Hello > $GITHUB_WORKSPACE/a"]
}

action "make-b" {
  uses = "docker://alpine"
  runs = ["sh", "-c", "echo World > $GITHUB_WORKSPACE/b"]
}

action "echo" {
  needs = ["make-a", "make-b"]
  uses = "docker://alpine"
  runs = ["sh", "-c", "cat $GITHUB_WORKSPACE/a $GITHUB_WORKSPACE/b"]
}
```

This is saying that there is a workflow called "demo" that is executed
whenever anything is pushed to the repository. That workflow's goal
is to execute the "echo" action, which happens to depend on actions
"make-a" and "make-b". When the workflow is triggered, those two actions
are run first and the "echo" action only runs after they both succeed.
In this particular example, each of the actions runs a shell command
on top of the `alpine` docker image, but I could've picked any other
image from Docker Hub or any existing GitHub Action repository. [This
page][docs] describes all of the various workflow configuration options.

If you save the above config in a file called `.github/main.workflow` in
any GitHub repository and visit the "Actions" tab, then -- assuming you
have access to the GitHub Actions beta -- you should see the pipeline
execute almost immediately and output:

    Hello
    World

We can leverage all of this to test a Racket package is by using Jack
Firth's [racket] image (or you could roll your own and host it on Docker
Hub yourself):

```hcl
workflow "main" {
  on = "push"
  resolves = ["test"]
}

action "test" {
  uses = "docker://jackfirth/racket:7.2"
  runs = "/github/workspace/ci/test.sh"
}
```

Here are the contents of `ci/test.sh`:

```bash
#!/usr/bin/env bash

set -euo pipefail

pushd "$GITHUB_WORKSPACE"
raco pkg install --batch --auto testpackage/
raco test testpackage/
```

The script sets the working directory to `$GITHUB_WORKSPACE`, installs
all of `testpackage`'s (a hypothetical package for the purposes of this
article) dependencies and then runs its tests.

That's all there is to it! With about 12 LOC we've put together a basic
workflow that tests a package on every commit.

## Gotchas & Limitations

Like I mentioned before, all actions in a workflow share the same
workspace so it's possible for actions to clash with one another when
they operate on the filesystem. That's something you have to keep in
mind when designing your workflows.

Workflow and action names share a namespace. If you call your workflow
"test" and your action "test", you'll get an error saying the workflow
is invalid, but it won't point out exactly why.

Finally, there's no built-in support for notifications. When builds
fail, you won't notice unless you visit the Actions tab. For one of my
non-OSS projects, I've set up a Telegram bot that I can use to notify a
particular channel whenever builds succeed or fail. That works, but it's
fairly ugly because there doesn't seem to be any way to conditionally
execute actions (i.e. things like "if action `a` fails then run action
`b`"), so I had to bundle the notification-handling code into each of my
action scripts.


[HCL]: https://github.com/hashicorp/hcl
[actions]: https://github.com/features/actions
[alex-hhh]: https://alex-hhh.github.io/2019/04/build-racket-packages-with-azure-pipelines.html
[docs]: https://developer.github.com/actions/managing-workflows/workflow-configuration-options/
[event]: https://developer.github.com/actions/managing-workflows/workflow-configuration-options/#events-supported-in-workflow-files
[racket]: https://hub.docker.com/r/jackfirth/racket
