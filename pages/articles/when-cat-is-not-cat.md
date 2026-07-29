---
title: "When cat isn't cat: an alias that corrupts your files"
author: "Erdiansyah"
date: "2026-07-15"
description: "How an innocent cat alias silently corrupted config files with ANSI color codes — and the two lessons it taught."
---

![](/media/cat-gotchas.svg)

I shipped myself a bug so sneaky it deserved a post-mortem. No error, no
stack trace. Just a config file that looked fine and broke everything that
read it.

## The setup

Like every dotfiles enjoyer, I had aliased `cat` to `bat --style=plain
--color=always` for the pretty syntax highlighting.

An **alias** is a shell nickname: the name stays, the program behind it
changes. Think of it as monkey-patching your terminal. It feels great
right up until it doesn't.

## The incident

One day I wrote a config file the classic way:

```sh
cat << EOF >> ~/.config/app/config
...
EOF
```

Except `cat` was *bat*. And `--color=always` means exactly that — emit
color codes **even when output goes to a file**, overriding the usual
"no colors when not a terminal" behavior.

Terminal colors are invisible escape bytes like `^[[37m` wrapped around
text. On screen: pretty. In a config file: sabotage. It's like committing
your debug `console.log` calls, except they're invisible in `git diff`.

The app choked on the garbage bytes. Silently. Naturally.

## Lesson 1: trust no bare command name

Aliases only fire in interactive shells. The same line inside a script
runs the real `cat`. So the bug exists when you test by hand and vanishes
in CI — the reverse of "works on my machine."

When it matters, bypass the nickname:

```sh
\cat file          # skip the alias once
command cat file   # skip aliases and functions
/bin/cat file      # full path, zero ambiguity
```

Not sure what a name really runs? `type cat` will rat out your alias.

## Lesson 2: delete the moving part

Here's the kicker: `cat` was never needed. The shell writes heredocs to
files all by itself:

```sh
>> ~/.config/app/config <<'EOF'
...
EOF
```

What you gain:

- **No command, so no alias can hijack it.**
- **No extra process to misbehave.**
- **A whole failure category, deleted.**

I didn't fix the bug. I removed the code path it lived on. Best refactor
ever.

## FAQ

**Should I stop aliasing cat to bat?**
Keep it — it's genuinely nice. Just remember it exists when redirected
output looks haunted.

**How do I spot escape codes in a file?**
Open it with `less` (not your aliased cat!). Junk like `^[[37m` around
each line is your smoking gun.

**Why didn't bat notice it wasn't writing to a terminal?**
It did. `--color=always` explicitly tells it to color anyway. The flag
did its job; I just never expected redirection to be in scope.
