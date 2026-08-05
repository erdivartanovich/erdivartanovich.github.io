---
title: "Shell heredocs: one mental model, four tools"
author: "Erdiansyah"
date: "2026-07-14"
description: "One mental model for shell heredocs: quoted vs unquoted delimiters, writing files with no command, and running whole blocks over ssh."
modified: "2026-08-05"
related:
  - url: /articles/bash-without-if.html
    title: "Most shell scripts don't need if"
  - url: /articles/building-this-site.html
    title: "Building this site: pandoc, make, and nothing else"
---

![](/media/cat-tutorial.svg)

You know that move where you paste a whole config into a Slack code
block, so nobody has to type it line by line? A **heredoc** is that
move, but for your shell.

It hands a multi-line block of text to a command in one go:

```sh
command <<EOF
line one
line two
EOF
```

`EOF` is just a marker meaning "block ends here." You could use `BANANA`.
Please don't.

## The one decision that matters: template or mail-merge?

Tiny quotes around the marker completely change what gets delivered.
This is the part everyone learns the hard way, usually in production.

- `<<'EOF'` (quoted) — behaves like a committed `.env.example`. Every
  `$VARIABLE` stays a literal placeholder. The block is **data**.
- `<<EOF` (unquoted) — behaves like CI doing the mail-merge. Your shell
  fills in every `$VARIABLE` first, *then* delivers. The block is
  **code**.

Writing a config that contains real dollar signs? Quote the marker. Want
to inject your current git tag into the block? Don't.

## Tool 1: write a file with zero middlemen

Most snippets online use `cat` to pipe the block into a file. Plot
twist: you don't need a command at all. The shell does redirection
natively:

```sh
>> ~/.zshrc <<'EOF'
alias gpo='git push origin'
alias ga='git add .'
EOF
```

Why the command-free version wins:

- **Nothing to alias-hijack** — no `cat` that's secretly `bat` (ask me
  how I know).
- **One less process** — the shell opens the file and drops the block in.
- **Fewer moving parts** — fewer 2am debugging sessions.

## Tool 2: run your runbook in one shot

Point the block at an interpreter instead of a file, and every line gets
**executed**. It's the difference between emailing someone a checklist
and having them actually do it:

```sh
ssh user@server <<'EOF'
cd /var/www && git pull
systemctl restart nginx
EOF
```

One SSH connection, the whole deploy checklist, no copy-paste roulette.
Works with `sudo bash`, `docker exec -i`, even `python3`.

The quoting rule pays double here. Quoted marker = `$(df -h)` runs **on
the server**. Unquoted = your laptop fills it in before sending. Mixing
those up is a classic "why is disk usage identical on every host" bug.

## Tool 3: keep it indented

Normally the closing marker must sit flush-left, which ruins your nicely
indented function. Write `<<-EOF` and the shell strips leading **tabs**
(tabs only — spaces don't count, because of course they don't).

## Tool 4: the one-liner

For a single value, skip the ceremony. Three arrows — a **herestring** —
feed one string to a command. It's the `const` of shell input: one
value, no block, no marker:

```sh
tr 'a-z' 'A-Z' <<< "hello world"
```

## FAQ

**What happens if I forget the closing marker?**
The shell sits there waiting, like a PR with no reviewer. Type the
marker on its own line and it snaps out of it.

**Quoted or unquoted — what's the safe default?**
Quoted (`<<'EOF'`). Verbatim delivery never surprises you. Unquote only
when you deliberately want local values baked in.

**Does this work in zsh too, or just bash?**
Both, plus basically every POSIX shell. Heredocs are older than most
codebases you'll ever touch.
