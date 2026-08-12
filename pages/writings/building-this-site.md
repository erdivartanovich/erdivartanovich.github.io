---
title: "Building this site: pandoc, make, and nothing else"
author: "Erdiansyah"
date: "2026-07-29"
description: "How this site is built with pandoc, make, and a 30-line shell script — basic commands for both tools, and why the pair beats a framework."
modified: "2026-08-05"
related:
  - url: /writings/heredocs-mental-model.html
    title: "Shell heredocs: power, gotchas, and pro tips"
  - url: /writings/bash-without-if.html
    title: "Most shell scripts don't need if"
---

![Tutorial / How-to — step by step, no magic](/media/cat-tutorial.svg){width=800 height=220}

Years ago I lived in Emacs. org-mode won me over in a week. Notes,
todos, and drafts all live in one plain-text file — no database
anywhere, and nothing to lock you in. The magic part was export. One
keystroke, and that outline became HTML, a PDF, or a clean draft for a
paper. When I finally peeked behind the curtain, **pandoc** was doing
the converting.

That lesson stuck: plain text goes in, documents come out, and nothing
binds you to a vendor. Years later, when I went to build a blog, the
industry had other ideas. Ask around in 2026 and the answer is always a
framework. Astro won content sites with its islands — small interactive
widgets floating in static HTML. Hugo is the speed king. Next.js
absorbs everything into a React runtime. Even the "minimal" pick,
Eleventy, is a Node project: npm install, plugins for sitemap and RSS, a
`package.json` that only grows. The whole SSG stack keeps getting
heavier, and it all produces the same output — a folder of static HTML
files.

The trend makes sense, up to a point. Bundlers and hot reload are
genuinely useful. But a blog is a few pages of words. You're hiring a
full CI pipeline to render it. Your `node_modules` ends up with the mass
of a small moon, and the build config outlives the content.

This site went the other way. There's no framework to install, no
dependencies to audit, and no lockfile arguments to referee. Two boring
old tools do everything: **pandoc** turns words into pages, **make**
decides what needs rebuilding. Here's the whole machine — the basic
commands, why this pair is enough, and how each step works.

## Pandoc, the document converter

**Pandoc** is a document converter. It reads one format and writes
another. Markdown goes in, HTML comes out — or HTML in and PDF out, or
EPUB, LaTeX, plain text. You name it.

Think of pandoc as `sed` for whole documents: one filter that rewrites
any format into any other, at a scale text streams can only dream of.

The basic command is one line:

```sh
pandoc input.md -o output.html
```

Pandoc guesses the input format from the file extension, so you rarely
type more than that. A few handy variants:

```sh
pandoc README.md -o README.pdf    # PDF, if LaTeX is installed
pandoc draft.md -t gfm -o out.md  # convert between Markdown dialects
pandoc --list-input-formats       # everything pandoc can read
pandoc --list-output-formats      # everything it can write
```

Reference: [pandoc.org](https://pandoc.org). The manual is famously
long. The getting-started page covers 90% of daily use, and it's short.

## Make, the build tool

**Make** is the build tool that refused to die, and for good reason: it
solved the original build problem in 1976, and nothing since has done it
better. *Only rebuild what changed.*

::: margin
Make's recipes must be indented with a literal tab, never spaces. Stuart
Feldman knew it was a mistake almost immediately — but he already had about a
dozen users and didn't want to break them. Fifty years on, everyone still pays
that tab.
:::

You give make a **Makefile** — a recipe of targets. Each target lists
what it needs (**dependencies**) and the commands that build it
(**recipe**):

```make
OUT = dist

$(OUT)/page.html: pages/page.md
	mkdir -p $(OUT)
	pandoc pages/page.md -o $(OUT)/page.html

clean:
	rm -rf $(OUT)

.PHONY: clean
```

Read the middle block like a sentence: `page.html` **depends on**
`page.md`; if the source is newer than the output, make runs the recipe.
That's the whole engine — the same dependency graph your bundler brags
about, without the packaging drama.

Basic commands:

```sh
make        # build the first target
make clean  # run one specific target
make -j4    # run independent jobs in parallel
make -n     # dry run: print the plan, change nothing
```

Reference: the [GNU make manual](https://www.gnu.org/software/make/manual/make.html).
The manual is dry, and the first 30 pages are all you'll ever need.

## Why these two fit a blog

A blog has exactly two hard jobs: turning plain words into styled
pages, and knowing which pages need rebuilding. Everything else is easy
or optional.

Pandoc does job one. Make does job two. Neither demands a runtime: the
output is a folder of static HTML files. Patching servers, auditing
dependency trees, debating lockfiles — none of that applies. Deploying
is copying files. It's the blog equivalent of a static binary —
everything it needs is right there, and nothing else can break.

What you get:

- **The whole system fits in your head** — one template, one Makefile,
  one script. Read everything in one coffee.
- **Debugging is `cat`** — you read the output instead of excavating
  webpack config or playing plugin version bingo.
- **It builds in about a second** — cold. Your framework's dev server
  is still printing its ASCII banner.
- **The output is readable** — plain HTML you can grep, inspect, and
  hand-edit, not a minified artifact that lies to you.
- **It'll run in ten years** — pandoc and make will outlive us all.

What you give up: tags, search, pagination, hot reload — all DIY.
That's the honest trade. A personal blog is mostly words, and words are
exactly what pandoc is best at. When your blog outgrows this, you'll
know — and you'll know why.

## Step 1: pandoc, the compiler for prose

Every page is plain **markdown** — the same format as your README files.
Browsers want **HTML**, so something has to convert.

That something is pandoc, and this is the actual command this site runs:

```sh
pandoc post.md --template templates/main.html \
  --standalone --toc --toc-depth=3 \
  --metadata-file=site.yaml --metadata-file=writings.yaml \
  -o post.html
```

Two flags matter most:

- `--template` — render into a hand-written HTML shell instead of
  pandoc's default page.
- `--standalone` — embed that shell and its metadata into the output, so
  each page is a self-contained file.

`--toc` adds a table of contents to writings. `--metadata-file` loads
site-wide settings from YAML, so no page hardcodes its own nav or URL.

## Step 2: a template, like a layout component

Raw converted HTML arrives bare — there's no site name, no nav, and no
styling. The **template** fixes that: one HTML file with `$title$`,
`$date$`, and `$body$` slots.

Pandoc's template language is deliberately tiny. A variable is `$name$`,
a loop is `$for(name)$...$endfor$`, and a conditional is `$if(name)$`.
That's the whole language, and it's enough for a whole site.

If you've used React, this is your layout component. Every page renders
as children inside the same shell, so everything matches for free.

Site-wide stuff — nav links, site name — lives in one `site.yaml` file.
Change a nav link once, every page picks it up on the next build. DRY,
but with 2007 technology.

## Step 3: make, the original incremental build

With many pages, who runs pandoc on each one? **make** — and this is
where it earns its keep. One rule handles the entire folder:

```make
$(OUT)/%.html: pages/%.md $(TEMPLATE) $(SITEMETA) $(WRITINGS_META)
	@mkdir -p $(@D)
	$(PANDOC) $< --template $(TEMPLATE) --standalone \
	  --highlight-style=monochrome \
	  $$(awk '/^---$$/{n++; if(n==2) exit} /^date:/{print "--toc --toc-depth=3"; exit}' $<) \
	  --metadata-file=$(SITEMETA) --metadata-file=$(WRITINGS_META) -o $@
```

Here's what each piece does:

- `%.html` — a **pattern rule**. The `%` matches any page, so you write
  this once and make generates it for every file. No per-page boilerplate.
- `$<` — the source (`page.md`). `$@` — the target (`page.html`). `$(@D)` —
  the target's directory. Make's shorthand for "the thing I'm building."
- The `awk` line — if the page has a `date:` in its frontmatter, it's an
  writing, so add the table of contents. That's plain-text plumbing
  doing real work.
- **Dependencies** after the colon include the template and both YAML
  files. Touch the template, and every page rebuilds — a dependency
  graph that predates your bundler by decades. Your dev server's hot
  reload? This is its fossilized ancestor, minus the 400MB.

Side jobs live in the same file: `all` builds everything, `clean` wipes
`dist/`, and a loop writes redirect stubs for old URLs. The whole
Makefile is about 45 lines.

## Step 4: the homepage builds its own post list

Maintaining a "recent posts" list by hand survives about three posts.
So a 30-line shell script does it at build time.

The convention: any page with a `date:` in its frontmatter is a post.
`gen-writings.sh` scrapes titles and dates with `awk`, sorts
newest-first, and writes `writings.yaml`. Pandoc feeds that file back in
as metadata, and the template's `$for(writings)$` loop prints the list.
Add a post, rebuild — the homepage updates itself. There's no
list-maintenance left to do.

The same convention drives two more outputs:

- **feed.xml** — an Atom feed, so readers get new posts without visiting.
- **sitemap.xml** — every page, for search engines.

Publishing is just: write markdown, `make`, push.

## Pro tips

Full disclosure: this site was built in Neovim. I was an Emacs person
for years — the org-mode days this writing opened with — before moving
to Vim/Neovim for its simplicity. Both camps get a tip, because the
whole machine is one Makefile. Your editor becomes the dev server.
There's no daemon and no hot-reload agent — just a command.

**In Vim or Neovim**, `:make` runs make right where you are and drops
the output into the **quickfix list**:

```vim
:make   " rebuild; errors land in quickfix
:copen  " open the error list
:cn     " jump to the next problem
```

**In Emacs**, `M-x compile` (then `make`), and `M-x recompile` after
that. Errors show up in the compilation buffer; `C-x \`` walks through
them. org-mode, pandoc, and a compile buffer — the old combo still
works.

**Want literal hot reload?** One line replaces the dev server's watch
mode (needs `inotify-tools` on Linux):

```sh
while inotifywait -q -r -e close_write pages; do make; done
```

Every save rebuilds, no framework required. The `:make` way is still
simpler: one keystroke triggers a full rebuild, and it's done in a
second.

Static site generators are great — until the day you need to know what
they actually do. This one, you already know. It fits in a blog post.
You just read it.

## FAQ

**Where does it deploy?**
This site lives on GitHub Pages, via a tiny Actions workflow: install
pandoc, run `make`, publish the `dist/` folder. Push to main and it's
live in a minute.

The neat part: that `dist/` folder is plain static files. The same
folder deploys to Firebase Hosting (the free tier covers a personal
blog easily), Cloudflare Pages, or your own server behind a simple
nginx/Caddy gateway. There's no adapter and no runtime — just files, so
there's nothing to lock you in.

**Why not Hugo, Jekyll, or Astro?**
They're solid — and each is a dependency with its own opinions, updates,
and breaking changes. My entire "framework" is two packages from the
distro repo.

**How do I actually add a post?**
Write a markdown file in `pages/writings/` with a `date:` in the
frontmatter, run `make`, push. The script picks it up, and the homepage,
feed, and sitemap update themselves. If a post doesn't show up, check
the `date:` — without it, the post never makes the list.

**Can I write posts in org-mode instead of markdown?**
Mostly. Pandoc reads org files natively, so conversion is a non-issue.
The one wrinkle: the post list is scraped from YAML frontmatter, so an
org post would still carry a small `date:` header for the homepage and
feed to notice it. It's a compromise this org-mode refugee accepted
long ago.

**What breaks first at scale?**
Probably the flat file layout — a few hundred posts would want
subfolders and pagination. I'll take that meeting when it happens.

**What would you change next, architecture-wise?**
The template is the obvious seam. Today nav, footer, and page shell all
live in one `main.html`. The next step is **template separation**: split
each region into its own fragment and let the build assemble them.

Make can `cat` the partials together, or pandoc's `--include-before-body`
and `--include-after-body` hooks can slot them around the body.
Interactive pieces would follow the same path — a search box or comment
widget becomes one self-contained fragment, a static shell plus a small
script. It's Astro-style islands, hand-rolled, with no framework in the
room.
