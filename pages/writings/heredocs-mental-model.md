---
title: "Shell heredocs: power, gotchas, and pro tips"
author: "Erdiansyah"
date: "2026-07-14"
description: "Heredocs write files, run commands over ssh, and feed any interpreter — but quotes around the marker can trip you up. The power, the gotchas, and the pro tips."
modified: "2026-08-05"
related:
  - url: /writings/when-cat-is-not-cat.html
    title: "When cat isn't cat: an alias that corrupts your files"
  - url: /writings/bash-without-if.html
    title: "Most shell scripts don't need if"
---

![](/media/cat-tutorial.svg)

Do you ever watch a senior dev type several lines of config right at
the shell prompt, without opening an editor or a scratch file? The
whole block goes to a command in one shot. That's a **heredoc**.

A heredoc is a multi-line block of text handed to a command as one
input. Here's the shape:

```sh
command <<EOF
line one
line two
EOF
```

`EOF` is just a marker that says "block ends here." You could use
`BANANA`. Please don't.

That one shape does a surprising amount of real work — writing config
files, deploying to a server, running scripts without saving them. It
also hides a couple of ways to shoot yourself. Here's the power, the
gotchas, and the pro tips.

## The power

### Write a file without a command

Most snippets online use `cat` to pipe a block into a file. You don't
need a command for that. The shell writes the file itself:

```sh
>> ~/.zshrc <<'EOF'
alias gpo='git push origin'
alias ga='git add .'
EOF
```

Why this version wins:

- **Nothing to hijack** — there's no command for an alias to swap in.
  A `cat` aliased to `bat` will corrupt a config file written this way —
  see [When cat isn't cat](/writings/when-cat-is-not-cat.html).
- **One less process** — the shell opens the file and drops the block in.
- **Fewer moving parts** — which means fewer things to debug at 2 a.m.

### Feed commands to ssh, sudo, and docker

A heredoc can point at a whole shell session instead of one command,
and every line gets **executed** there. Start with the remote server:

**ssh** opens a secure terminal session on another computer, so you
type commands there as if you were sitting in front of it. Without a
heredoc you'd paste each line one at a time into that session:

```sh
ssh user@server <<'EOF'
cd /var/www && git pull
systemctl restart nginx
EOF
```

One SSH connection runs the whole deploy checklist, with no
copy-pasting command by command.

**sudo** runs one command with admin rights. It can't take a whole
script, so you hand it `bash`: `sudo bash` reads the heredoc, and every
line runs with admin rights:

```sh
sudo bash <<'EOF'
apt-get update
apt-get install -y nginx
EOF
```

**docker exec** runs a command inside a running container — an isolated
Linux environment. Point `docker exec` at the container's `bash`, and
the heredoc runs a whole build sequence inside it, in one go:

```sh
docker exec -i web bash <<'EOF'
cd /app
npm ci && npm run build
EOF
```

Which marker quoting to use over ssh is a gotcha of its own — more on
that below.

### Run a program without creating a file

A heredoc is just standard input. Any command that reads stdin will
take the block, so you can run a whole script that never touches disk:

```sh
python3 <<'EOF'
for i in range(3):
    print(f"line {i}")
EOF
```

Python sees those lines exactly as if you had typed them into a REPL.

## The gotchas

### Quotes around the marker change everything

This is the big one. Tiny quotes around the marker completely change
what gets delivered.

- `<<'EOF'` (quoted) — behaves like a committed `.env.example`. Every
  `$VARIABLE` stays a literal placeholder. The block is **data**.
- `<<EOF` (unquoted) — behaves like a CI step that bakes real values
  into the artifact. Your shell fills in every `$VARIABLE` first, then
  hands the finished block to the command. The block is **code**.

Writing a config that contains real dollar signs? Quote the marker.
Want to inject your current git tag into the block? Don't.

The same rule applies over ssh. A quoted marker means `$(df -h)` runs
**on the server**. An unquoted marker means your laptop fills it in
before sending. Mixing those up is a classic "why is disk usage
identical on every host" bug.

### Escape one value with a backslash

Sometimes you want almost everything expanded except one value. Put a
backslash before it:

```sh
cat <<EOF
host: $(hostname)
build: \$(date +%F)
EOF
```

Quoted would freeze every variable; unquoted expands them all. The
backslash keeps exactly one `$(date +%F)` on paper instead of running
it. Handy when a config snippet contains shell syntax that isn't meant
for your shell.

### Don't forget the closing marker

If the marker never shows up on its own line, the shell waits forever,
like a PR with no reviewer. The marker also has to sit at the very
start of the line, which is why a nicely indented block breaks. The fix
is the first pro tip below.

## Pro tips

### Keep the block indented

Write `<<-EOF` instead of `<<EOF` and the shell strips leading **tabs**
from the block. It only strips tabs, not spaces — spaces are ordinary
characters to the shell, so an indent made of spaces still counts as
content. Your heredoc can sit inside an indented function without
dragging its closing marker along.

### One value? Use a herestring

For a single line, skip the marker entirely. A **herestring** — three
arrows — passes one string to a command:

```sh
tr 'a-z' 'A-Z' <<< "hello world"
```

::: margin
Nota bene — `<<<` is bash, zsh and ksh only. It never made POSIX, so a
`#!/bin/sh` script on Debian, where `sh` is dash, will reject it.
:::

There's no block and no closing marker to manage. It's the short
version of a heredoc.

### Preview the block before you write it

Run the block through `cat` first and you'll see exactly what the shell
will deliver:

```sh
cat <<'EOF'
config path: $HOME
deploy host: $(hostname)
EOF
```

Print it with the wrong quoting and the difference stares right at you.
It's much cheaper to catch here than inside a config file.

## FAQ

**Quoted or unquoted — what's the safe default?**
Quoted (`<<'EOF'`). Verbatim delivery never surprises you. Unquote only
when you deliberately want local values baked in.

**Does this work in zsh too, or just bash?**
Both, plus basically every POSIX shell. Heredocs are older than most
codebases you'll ever touch.
