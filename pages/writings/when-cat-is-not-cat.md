---
title: "When cat isn't cat: an alias that corrupts your files"
author: "Erdiansyah"
date: "2026-07-15"
description: "How an innocent cat alias silently corrupted config files with ANSI color codes — and the two lessons it taught."
modified: "2026-08-05"
related:
  - url: /writings/bash-without-if.html
    title: "Most shell scripts don't need if"
---

![Gotchas — sharp edges, found the hard way](/media/cat-gotchas.svg){width=800 height=220}

I shipped myself a bug so sneaky it deserved a post-mortem. There was no
error and no stack trace — just a config file that looked fine and broke
everything that read it.

## The setup

Like every dotfiles enjoyer, I had aliased `cat` to `bat --style=plain
--color=always` for the pretty syntax highlighting.

An **alias** is a shell nickname: the name stays, the program behind it
changes. Think of it as monkey-patching your terminal. It feels great
right up until the monkey bites.

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
text. On screen they look pretty. In a config file they're sabotage.
It's like shipping a debug `console.log` you forgot to remove — except
the log line is invisible in `git diff`. No one flags it in review, and
prod eats it anyway.

Here's what the file actually contained:

```
^[[38;5;39mtheme = dark^[[0m
^[[38;5;39mport = 8080^[[0m
^[[0m
```

The app's parser saw one giant blob of bytes per line, all of them
garbage. It choked on them, silently and without any fanfare. It was a
production incident with no alert configured, in miniature.

## Lesson 1: trust no bare command name

Aliases only fire in **interactive shells**. The same line inside a
script runs the real `cat`. So the bug exists when you test by hand and
vanishes in CI — the reverse of "works on my machine." Local checks
pass, review looks clean, and production is the only place it breaks.

When it matters, bypass the nickname:

```sh
\cat file          # skip the alias once
command cat file   # skip aliases and functions
/bin/cat file      # full path, zero ambiguity
```

::: margin
The backslash works because alias expansion only fires on a bare, unquoted
first word. `\cat`, `'cat'` and `"cat"` all slip past it.
:::

Not sure what a name really runs? `type cat` will rat out your alias.
Run plain `alias` and you'll see every nickname your shell has loaded.
It's a code review for your shell: it shows you what actually executes,
not what you think does.

## Lesson 2: skip the command entirely

Here's the kicker: `cat` was never needed. The shell writes heredocs to
files all by itself:

```sh
>> ~/.config/app/config <<'EOF'
...
EOF
```

What you gain:

- **There's no command to hijack** — an alias can only swap in for a
  name that's actually invoked.
- **There's no extra process** — the shell opens the file and writes the
  block itself, so nothing can misbehave in between.
- **The whole failure category disappears** — you can't hit a bug on a
  code path that doesn't exist.

I didn't fix the bug. I removed the code path it lived on. It's like
deleting a flaky test instead of praying over it, and honestly, it was
the best refactor ever.

## FAQ

**Should I stop aliasing cat to bat?**
Keep it — it's genuinely nice. Just remember it exists when redirected
output comes out wrong.

**How do I spot escape codes in a file?**
Open it with `less` (not your aliased cat!). Junk like `^[[37m` around
each line is the sign you're looking for.

**Why didn't bat notice it wasn't writing to a terminal?**
It did. `--color=always` explicitly tells it to color anyway. The flag
did its job; I just never expected redirection to be in scope.
