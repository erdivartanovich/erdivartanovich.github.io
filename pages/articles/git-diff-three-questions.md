---
title: "git diff answers three different questions"
author: "Erdiansyah"
date: "2026-07-16"
description: "git diff always compares two of three snapshots — working tree, staging, HEAD. Know which question you're asking."
modified: "2026-08-05"
related:
  - url: /articles/building-this-site.html
    title: "Building this site: pandoc, make, and nothing else"
---

![](/media/cat-tutorial.svg)

You stage a file, run `git diff` to double-check it, and see... nothing.
Cue the tiny heart attack before your first PR of the day.

Relax — your change didn't vanish. You just asked git the wrong question.

## The three places your code lives

Between "I typed it" and "it's committed," every change passes through
three zones:

- **Working tree** — the files in your editor, unsaved chaos included.
- **Index** (a.k.a. **staging**) — the shopping cart. Changes you've
  `git add`-ed, queued up for the next commit.
- **HEAD** — the last commit. The receipt for what you already bought.

Think of them as your three environments. Working tree is dev, where you
tinker. Index is staging, where you line things up. HEAD is prod — what's
already deployed. `git diff` moves a change between environments, two at
a time.

`git diff` always compares exactly two of these zones. Which two depends
on how you call it:

| You type | Compares | Shows |
|---|---|---|
| `git diff` | working tree vs index | what's **not staged yet** |
| `git diff --staged` | index vs HEAD | what's **in the cart** |
| `git diff HEAD` | working tree vs HEAD | **everything** since last commit |

## The gotcha, explained

A fully staged file shows **nothing** in plain `git diff`, because your
working tree and your cart are identical. There's no difference to show.

It's like checking your editor for unsaved changes after you hit save.
Empty isn't broken — empty means you did the thing. The panic-check you
actually wanted is `git diff --staged`.

## The map: git status -s

`git status -s` prints the whole three-zone model as two columns per
file:

- **Left column** = the cart (staged).
- **Right column** = the working tree (unstaged).
- `??` = untracked — git has never met this file.

So `MM app.js` means: some changes staged, plus new edits since you
staged. Yes, you can commit half a file's changes. Yes, that surprises
everyone once.

## The blind spot: untracked files

No diff command shows untracked files — there's no baseline to compare
against. Your brand-new file is invisible to all three questions. A
staged diff over a new project shows nothing until that first `git add`,
which reads like a failed build until you remember the rule.

To list them (stable output, safe for scripts):

```sh
git ls-files --others --exclude-standard
```

## FAQ

**Which one do I run before committing?**
`git diff --staged`. It's literally the preview of your next commit —
the last code review where you're the only reviewer.

**What is HEAD exactly?**
Git's pointer to your latest commit on the current branch. When docs say
"HEAD," read "where I last committed."

**I just want everything I changed today. One command?**
`git diff HEAD`. Working tree versus last commit — staged, unstaged, the
whole mess.
