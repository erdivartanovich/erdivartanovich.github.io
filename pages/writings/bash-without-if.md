---
title: "Most shell scripts don't need if"
author: "Erdiansyah"
date: "2026-07-18"
description: "Guard clauses with && and || make shell scripts flatter and more readable than nested if blocks."
modified: "2026-08-05"
related:
  - url: /writings/heredocs-mental-model.html
    title: "Shell heredocs: power, gotchas, and pro tips"
  - url: /writings/when-cat-is-not-cat.html
    title: "When cat isn't cat: an alias that corrupts your files"
---

![](/media/cat-opinion.svg)

Open any seasoned engineer's dotfiles and you'll notice something odd:
there's barely an `if` statement in sight. Your own deploy script, by
contrast, has five levels of nesting, and nobody on the team trusts it.

The secret is two operators you already half-know: `&&` and `||`.

## How exit codes work

Every command ends with an **exit code** — a small status number, the
shell's version of a CI build status. Zero means success; anything else
means failure. Your CI pipeline lives and dies by this number, and so
can your scripts.

- `&&` — "**and then**": run the next command only if the last one passed.
- `||` — "**or else**": run the next command only if the last one failed.

You already think this way: *tests pass, and then deploy, or else page
someone.* That's a pipeline. Now write your scripts like it.

## Before and after

The textbook version:

```sh
if [ -d "$dir" ]; then
  cd "$dir"
fi
```

The one-liner:

```sh
[ -d "$dir" ] && cd "$dir"
```

It reads like a sentence — the directory exists, **and then** you enter
it. Four lines become one, and nothing was lost but ceremony. It's the
shell equivalent of a diff that deletes more lines than it adds.

## The guard clause pattern

`||` is your script's code reviewer, rejecting bad input at the top:

```sh
[ -f "$config" ] || { echo "missing config" >&2; exit 1; }
[ -n "$API_KEY" ] || { echo "API_KEY not set" >&2; exit 1; }
mkdir -p "$out" && cp "$src" "$out" && echo "done"
```

Each line checks one condition and bails out if it fails. Only when
every check has passed does the real work run. It's the shell version of
**early returns** — the same trick that makes functions readable. It
follows the philosophy of a CI job where one failing step halts the
whole build: fail fast, make the failure visible, and stop at the top
before anything worse can happen.

Why this style wins:

- **Scannable** — each line is one complete thought.
- **Flat** — no staircase of nested blocks, just a straight run of guards.
- **Honest.** Every failure path sits right where it happens, visible at
  a glance.

## Where the shortcut goes wrong

One trap: `a && b || c` is **not** if/else. If `b` fails, `c` runs too.
That bug has shipped more times than anyone will admit in standup.

```sh
[ -f "$config" ] && parse "$config" || echo "no config found"
```

The config exists and `parse` fails halfway through — the script prints
"no config found" anyway, and now the logs are lying. The message claims
a problem that isn't there and hides the one that is.

So keep real `if` for genuine either/or branches with multiple steps.
Use the operators for guards, defaults, and chains — which is, honestly,
90% of every script you'll write.

## FAQ

**Does this work outside bash?**
Yes — zsh, dash, and every other POSIX shell. The operators are older
than git, older than Linux even.

**How do I check an exit code myself?**
Run a command, then `echo $?`. Zero means success. Try it with `true`
and `false` — the two most honest programs ever written.

**Is nesting `if` statements actually bad?**
Nested ifs aren't bad — they're just harder to scan six months later.
Flat guard clauses read top-to-bottom like a checklist, and future-you
loves a checklist.

**Does this clash with `set -e`?**
No — the two work well together. Under `set -e`, a failing command
exits the script, and a guard chain that short-circuits fails the whole
line, so the script stops on its own. You can often drop the explicit
`exit 1`; the flag does it for you.
