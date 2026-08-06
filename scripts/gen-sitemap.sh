#!/bin/sh
# Generate sitemap.xml from pages/*.md and pages/writings/*.md
# (404 excluded; index maps to /).
# lastmod = date of last commit touching the source file (git), falling
# back to frontmatter date: when not in a repo. Needs full history
# (fetch-depth: 0) in CI.
set -eu

out=${1:-dist/sitemap.xml}
siteurl=$(awk '/^siteurl:/{gsub(/"/,""); print $2; exit}' site.yaml)

# lastmod FILE -> print ISO date or nothing
lastmod() {
  d=$(git log -1 --format=%cs -- "$1" 2>/dev/null) || true
  if [ -n "$d" ]; then
    printf '%s' "$d"
  else
    awk '/^---$/{n++; if(n==2) exit} /^date:/{sub(/^date:[ ]*/,""); gsub(/"/,""); print; exit}' "$1"
  fi
}

{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
  for f in pages/*.md pages/writings/*.md; do
    rel=${f#pages/}
    rel=${rel%.md}
    [ "$rel" = "404" ] && continue
    loc="$siteurl/$rel.html"
    [ "$rel" = "index" ] && loc="$siteurl/"
    date=$(lastmod "$f")
    if [ -n "$date" ]; then
      printf '  <url><loc>%s</loc><lastmod>%s</lastmod></url>\n' "$loc" "$date"
    else
      printf '  <url><loc>%s</loc></url>\n' "$loc"
    fi
  done
  printf '</urlset>\n'
} >"$out"
