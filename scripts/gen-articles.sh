#!/bin/sh
# Generate articles.yaml from pages/articles/*.md frontmatter.
# Convention: articles live under pages/articles/ and carry a `date:`.
set -eu

out=${1:-articles.yaml}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

for f in pages/articles/*.md; do
  date=$(awk '/^---$/{n++; if(n==2) exit} /^date:/{sub(/^date:[ ]*/,""); gsub(/^"|"$/,""); print; exit}' "$f")
  [ -n "$date" ] || continue
  title=$(awk '/^---$/{n++; if(n==2) exit} /^title:/{sub(/^title:[ ]*/,""); gsub(/^"|"$/,""); print; exit}' "$f")
  slug=$(basename "$f" .md)
  printf '%s\t%s\t/articles/%s.html\n' "$date" "${title:-$slug}" "$slug"
done | sort -r >"$tmp"

{
  echo 'articles:'
  while IFS="$(printf '\t')" read -r d t u; do
    printf '  - title: "%s"\n    date: "%s"\n    url: "%s"\n' "$t" "$d" "$u"
  done <"$tmp"
} >"$out"
