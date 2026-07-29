---
title: "Building this site: pandoc, make, and nothing else"
author: "Erdiansyah"
date: "2026-07-29"
description: "How this site is built with pandoc, make, and a 30-line shell script — no framework required."
---

![](/media/cat-tutorial.svg)

This site has no framework, no `node_modules` folder with the mass of a
small moon, and no build config longer than the content. Two boring old
tools do everything. Here's the whole machine.

## Step 1: pandoc, the compiler for prose

Every page is plain **markdown** — the same format as your README files.
Browsers want **HTML**, so something has to convert.

That something is **pandoc**, a document converter. Think of it as a
compiler where the source language is markdown and the build target is a
web page:

```sh
pandoc post.md --template templates/main.html --standalone -o post.html
```

## Step 2: a template, like a layout component

Raw converted HTML has no site name, no nav, no styling. The **template**
fixes that — one HTML file with `$title$`, `$date$`, and `$body$` slots.

If you've used React, this is your layout component. Every page renders
as children inside the same shell, so everything matches for free.

Site-wide stuff — nav links, site name — lives in one `site.yaml` file.
Change a nav link once, every page picks it up on the next build. DRY,
but with 2007 technology.

## Step 3: make, the original incremental build

With many pages, who runs pandoc on each one? **make** — the
great-grandparent of every build tool you've used. It reads a recipe of
targets and dependencies, then rebuilds only what changed.

Edit one post, `make` rebuilds one page. Touch the template, it knows
every page depends on it and rebuilds them all. That's the dependency
graph your bundler brags about, invented decades earlier.

## Step 4: the homepage builds its own post list

Maintaining a "recent posts" list by hand survives about three posts.
So a 30-line shell script does it at build time.

The convention: any page with a `date:` in its frontmatter is a post.
The script scrapes titles and dates, sorts newest-first, and feeds the
list to pandoc as metadata. Publishing is just: write markdown, `make`,
push.

## Why go this minimal?

- **The whole system fits in your head** — one template, one Makefile,
  one script. Read everything in one coffee.
- **Debugging is `cat`** — no webpack config archaeology, no plugin
  version bingo.
- **It builds in about a second** — cold. Your framework's dev server is
  still printing its ASCII banner.
- **It'll run in ten years** — pandoc and make will outlive us all.

Static site generators are great — until the day you need to know what
they actually do. This one, you already know. It fits in a blog post.
You just read it.

## FAQ

**Where does it deploy?**
GitHub Pages, via a tiny Actions workflow: install pandoc, run `make`,
publish the `dist/` folder. Push to main and it's live in a minute.

**Why not Hugo, Jekyll, or Astro?**
They're solid — and each is a dependency with its own opinions, updates,
and breaking changes. My entire "framework" is two packages from the
distro repo.

**What breaks first at scale?**
Probably the flat file layout — a few hundred posts would want
subfolders and pagination. I'll take that meeting when it happens.
