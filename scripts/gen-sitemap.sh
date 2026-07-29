#!/bin/sh
# Generate sitemap.xml from pages/*.md and pages/articles/*.md
# (404 excluded; index maps to /).
set -eu

out=${1:-dist/sitemap.xml}
siteurl=$(awk '/^siteurl:/{gsub(/"/,""); print $2; exit}' site.yaml)

{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
  for f in pages/*.md pages/articles/*.md; do
    rel=${f#pages/}
    rel=${rel%.md}
    [ "$rel" = "404" ] && continue
    loc="$siteurl/$rel.html"
    [ "$rel" = "index" ] && loc="$siteurl/"
    date=$(awk '/^---$/{n++; if(n==2) exit} /^date:/{sub(/^date:[ ]*/,""); gsub(/"/,""); print; exit}' "$f")
    if [ -n "$date" ]; then
      printf '  <url><loc>%s</loc><lastmod>%s</lastmod></url>\n' "$loc" "$date"
    else
      printf '  <url><loc>%s</loc></url>\n' "$loc"
    fi
  done
  printf '</urlset>\n'
} >"$out"
