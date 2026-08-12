#!/bin/sh
# Generate writings.yaml from pages/writings/*.md frontmatter.
# Convention: writings live under pages/writings/ and carry a `date:`.
set -eu

out=${1:-writings.yaml}
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Reads one frontmatter field, unquoted, with any inner " escaped for YAML.
field() {
  awk -v key="^$2:" '
    /^---$/{n++; if(n==2) exit}
    $0 ~ key {sub(/^[a-z-]+:[ ]*/,""); gsub(/^"|"$/,""); gsub(/"/,"\\\""); print; exit}
  ' "$1"
}

for f in pages/writings/*.md; do
  date=$(field "$f" date)
  [ -n "$date" ] || continue
  title=$(field "$f" title)
  desc=$(field "$f" description)
  slug=$(basename "$f" .md)
  printf '%s\t%s\t/writings/%s.html\t%s\n' "$date" "${title:-$slug}" "$slug" "$desc"
done | sort -r >"$tmp"

{
  echo 'writings:'
  while IFS="$(printf '\t')" read -r d t u s; do
    printf '  - title: "%s"\n    date: "%s"\n    url: "%s"\n' "$t" "$d" "$u"
    [ -n "$s" ] && printf '    description: "%s"\n' "$s"
  done <"$tmp"
} >"$out"
