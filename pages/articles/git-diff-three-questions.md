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
That tiny heart attack before your first PR of the day is real.

Relax — your change didn't vanish. You just asked git the wrong question.

## The three places your code lives

Between "I typed it" and "it's committed," every change passes through
three zones:

- **Working tree** — the files as they sit in your editor, unsaved
  chaos included.
- **Index** (a.k.a. **staging**) — your shopping cart. Everything
  you've `git add`-ed is queued here for the next commit.
- **HEAD** — your last commit. It's the receipt for what you already
  bought.

Think of them as your three environments. The working tree is dev,
where you tinker. The index is staging, where you line things up. HEAD
is the closest thing to prod — it's the last version that actually
shipped.

`git diff` compares two of these zones at a time, and which two depends
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

## Read the zones with git status -s

`git status -s` prints the whole three-zone model as two columns per
file:

- **Left column** = the cart (staged).
- **Right column** = the working tree (unstaged).
- `??` = untracked — git has never met this file.

So `MM app.js` means some changes are staged, plus new edits since you
staged. Yes, you can commit half a file's changes — a fact that
surprises everyone exactly once.

## The blind spot: untracked files

No diff command shows untracked files — there's no baseline to compare
against. Your brand-new file is invisible to all three questions. A
staged diff over a new project shows nothing until that first `git add`,
which reads like a failed build until you remember the rule.

To list them (stable output, safe for scripts):

```sh
git ls-files --others --exclude-standard
```

## Diff any two commits

The three zones are just the default. `git diff` will happily compare
any two commits:

```sh
git diff HEAD~1          # working tree vs the commit before last
git diff HEAD~1 HEAD     # exactly what the last commit touched
git diff main...feature  # what feature adds to main (three dots = common ancestor)
```

Reviewing your own last commit becomes one command instead of a guess.
Add `--stat` and you get a summary of files and line counts instead of
the full patch — handy when you only want to know what a big merge
actually changed.

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
