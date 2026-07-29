#!/bin/sh
# Generate an Atom feed (feed.xml) from post frontmatter (pages with date:).
set -eu

out=${1:-dist/feed.xml}
siteurl=$(awk '/^siteurl:/{gsub(/"/,""); print $2; exit}' site.yaml)
sitename=$(awk '/^title-prefix:/{gsub(/"/,""); print $2; exit}' site.yaml)

esc() { printf '%s' "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

fm() { # fm <key> <file> — frontmatter value, quotes stripped
  awk -v k="$1" '/^---$/{n++; if(n==2) exit}
    $0 ~ "^"k":" {sub("^"k":[ ]*",""); gsub(/^"|"$/,""); print; exit}' "$2"
}

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for f in pages/articles/*.md; do
  date=$(fm date "$f")
  [ -n "$date" ] || continue
  printf '%s\t%s\n' "$date" "$f"
done | sort -r >"$tmp"

latest=$(head -1 "$tmp" | cut -f1)

{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<feed xmlns="http://www.w3.org/2005/Atom">\n'
  printf '  <title>%s</title>\n' "$(esc "$sitename")"
  printf '  <link href="%s/"/>\n' "$siteurl"
  printf '  <link rel="self" href="%s/feed.xml"/>\n' "$siteurl"
  printf '  <id>%s/</id>\n' "$siteurl"
  printf '  <updated>%sT00:00:00Z</updated>\n' "$latest"
  printf '  <author><name>Erdiansyah</name></author>\n'
  while IFS="$(printf '\t')" read -r date f; do
    slug=$(basename "$f" .md)
    title=$(fm title "$f")
    desc=$(fm description "$f")
    url="$siteurl/articles/$slug.html"
    printf '  <entry>\n'
    printf '    <title>%s</title>\n' "$(esc "$title")"
    printf '    <link href="%s"/>\n' "$url"
    printf '    <id>%s</id>\n' "$url"
    printf '    <updated>%sT00:00:00Z</updated>\n' "$date"
    [ -n "$desc" ] && printf '    <summary>%s</summary>\n' "$(esc "$desc")"
    printf '  </entry>\n'
  done <"$tmp"
  printf '</feed>\n'
} >"$out"
