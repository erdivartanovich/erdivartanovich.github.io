---
title: "Most shell scripts don't need if"
author: "Erdiansyah"
date: "2026-07-18"
description: "Guard clauses with && and || make shell scripts flatter and more readable than nested if blocks."
---

![](/media/cat-opinion.svg)

Open any seasoned engineer's dotfiles and you'll notice something odd:
barely any `if` statements. Meanwhile your deploy script has five levels
of nesting and a trust problem.

The secret is two operators you already half-know: `&&` and `||`.

## Exit codes are the whole trick

Every command ends with an **exit code** — a hidden report card. Zero
means success; anything else means failure. Your CI pipeline lives and
dies by this number, and so can your scripts.

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

Reads like a sentence: directory exists, **and then** enter it. Four lines
become one, and nothing was lost but ceremony.

## The guard clause pattern

`||` is your script's code reviewer, rejecting bad input at the top:

```sh
[ -f "$config" ] || { echo "missing config" >&2; exit 1; }
[ -n "$API_KEY" ] || { echo "API_KEY not set" >&2; exit 1; }
mkdir -p "$out" && cp "$src" "$out" && echo "done"
```

Check, bail. Check, bail. Then do the work. It's the shell version of
early returns — the same trick that makes functions readable.

Why this style wins:

- **Scannable** — each line is one complete thought.
- **Flat** — no staircase of nested blocks.
- **Honest** — every failure path is visible, right where it happens.

## Where the shortcut bites

One trap: `a && b || c` is **not** if/else. If `b` fails, `c` runs too.
That bug has shipped more times than anyone will admit in standup.

So keep real `if` for genuine either/or branches with multiple steps.
Use the operators for guards, defaults, and chains — which is, honestly,
90% of every script you'll write.

## FAQ

**Does this work outside bash?**
Yes — zsh, dash, every POSIX shell. It's older than git. Older than
Linux, even.

**How do I check an exit code myself?**
Run a command, then `echo $?`. Zero is success. Try it with `true` and
`false` — the two most honest programs ever written.

**Is nesting `if` statements actually bad?**
Not bad — just harder to scan six months later. Flat guard clauses read
top-to-bottom like a checklist, and future-you loves a checklist.
