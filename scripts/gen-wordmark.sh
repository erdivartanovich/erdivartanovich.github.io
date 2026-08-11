#!/bin/sh
# Generate wordmark.yaml: the masthead wordmark as hand-drawn SVG letterforms.
# Drawn rather than set because system serifs are too even to read as cut metal.
# Overlapping subpaths in a glyph must share a winding direction, or nonzero
# fill cancels them.
set -eu

out=${1:-wordmark.yaml}

word=$(awk '/^title-prefix:/{sub(/^title-prefix:[ ]*/,""); gsub(/^"|"$/,""); print; exit}' site.yaml)
[ -n "$word" ] || { echo "gen-wordmark: no title-prefix in site.yaml" >&2; exit 1; }

# Flanking crosses echo the +VLFBERH+T inscription formula the site is named for.
word="+$(printf '%s' "$word" | tr 'A-Z' 'a-z')+"

# advance<TAB>path — glyph box is 100 tall, baseline at y=100.
glyph() {
  case $1 in
  a) printf '78\tM 33 2 L 47 4 L 24 99 L 8 97 Z M 31 4 L 45 2 L 70 97 L 55 99 Z M 18 62 L 60 65 L 59 78 L 17 75 Z' ;;
  b) printf '84\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 11 1 L 56 3 L 55 16 L 10 14 Z M 52 4 L 67 8 L 64 42 L 50 39 Z M 11 38 L 60 41 L 59 53 L 10 51 Z M 56 43 L 71 47 L 68 88 L 54 85 Z M 10 86 L 62 88 L 61 99 L 9 98 Z' ;;
  c) printf '74\tM 16 0 L 62 3 L 61 16 L 15 14 Z M 4 6 L 20 2 L 18 98 L 3 94 Z M 16 86 L 63 88 L 62 100 L 15 99 Z' ;;
  d) printf '84\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 11 1 L 56 4 L 55 17 L 10 15 Z M 52 6 L 68 11 L 65 88 L 50 84 Z M 10 85 L 62 88 L 61 99 L 9 98 Z' ;;
  e) printf '70\tM 12 1 L 29 3 L 27 99 L 10 97 Z M 12 1 L 60 4 L 59 17 L 11 15 Z M 13 43 L 52 46 L 51 58 L 12 56 Z M 10 86 L 61 88 L 60 100 L 9 99 Z' ;;
  f) printf '68\tM 12 1 L 29 3 L 27 99 L 10 97 Z M 12 1 L 60 4 L 59 17 L 11 15 Z M 13 43 L 52 46 L 51 58 L 12 56 Z' ;;
  g) printf '80\tM 16 0 L 62 3 L 61 16 L 15 14 Z M 4 6 L 20 2 L 18 98 L 3 94 Z M 16 86 L 64 88 L 63 100 L 15 99 Z M 52 52 L 67 55 L 64 97 L 50 94 Z M 40 52 L 67 55 L 66 66 L 39 63 Z' ;;
  h) printf '76\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 48 3 L 65 1 L 64 97 L 47 99 Z M 12 44 L 65 41 L 64 55 L 11 58 Z' ;;
  i) printf '44\tM 13 1 L 31 3 L 29 99 L 11 97 Z' ;;
  j) printf '62\tM 33 1 L 50 3 L 48 88 L 31 86 Z M 12 88 L 49 86 L 50 99 L 13 100 Z M 4 74 L 19 71 L 25 97 L 11 100 Z' ;;
  k) printf '76\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 52 1 L 68 5 L 26 55 L 14 47 Z M 28 44 L 41 37 L 70 96 L 55 100 Z' ;;
  l) printf '66\tM 12 1 L 29 3 L 27 99 L 10 97 Z M 10 86 L 60 88 L 59 100 L 9 99 Z' ;;
  m) printf '92\tM 9 1 L 26 3 L 24 99 L 7 97 Z M 66 3 L 83 1 L 82 97 L 65 99 Z M 11 2 L 27 0 L 52 76 L 38 80 Z M 64 0 L 80 3 L 53 80 L 39 76 Z' ;;
  n) printf '78\tM 10 1 L 27 3 L 25 99 L 8 97 Z M 51 3 L 68 1 L 67 97 L 50 99 Z M 13 2 L 28 0 L 66 92 L 51 97 Z' ;;
  o) printf '82\tM 17 0 L 62 3 L 61 16 L 16 14 Z M 16 86 L 63 88 L 62 100 L 15 99 Z M 4 8 L 20 3 L 18 96 L 2 91 Z M 58 3 L 74 8 L 72 91 L 56 96 Z' ;;
  p) printf '82\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 11 1 L 60 4 L 59 16 L 10 14 Z M 56 5 L 71 9 L 68 45 L 54 41 Z M 11 42 L 63 45 L 62 57 L 10 55 Z' ;;
  q) printf '82\tM 17 0 L 62 3 L 61 16 L 16 14 Z M 16 86 L 63 88 L 62 100 L 15 99 Z M 4 8 L 20 3 L 18 96 L 2 91 Z M 58 3 L 74 8 L 72 91 L 56 96 Z M 48 74 L 61 68 L 79 99 L 65 104 Z' ;;
  r) printf '86\tM 11 1 L 28 3 L 26 99 L 9 97 Z M 11 1 L 60 4 L 59 16 L 10 14 Z M 56 5 L 71 9 L 68 42 L 54 39 Z M 11 40 L 63 43 L 62 55 L 10 53 Z M 40 48 L 54 44 L 79 97 L 64 101 Z' ;;
  s) printf '72\tM 16 0 L 62 3 L 61 16 L 15 14 Z M 4 8 L 19 4 L 17 44 L 2 41 Z M 8 38 L 58 44 L 57 56 L 7 51 Z M 52 48 L 67 52 L 64 92 L 50 89 Z M 9 86 L 57 88 L 56 100 L 8 99 Z' ;;
  t) printf '74\tM 3 1 L 71 4 L 70 18 L 2 15 Z M 28 4 L 45 6 L 43 99 L 26 97 Z' ;;
  u) printf '78\tM 8 1 L 25 3 L 22 88 L 6 86 Z M 53 3 L 70 1 L 68 86 L 52 88 Z M 7 85 L 69 87 L 68 100 L 6 99 Z' ;;
  v) printf '78\tM 4 1 L 20 3 L 43 98 L 29 101 Z M 57 3 L 73 1 L 47 101 L 33 98 Z' ;;
  w) printf '92\tM 1 2 L 16 0 L 33 99 L 18 101 Z M 34 0 L 49 2 L 33 99 L 18 101 Z M 34 0 L 49 2 L 65 99 L 50 101 Z M 66 3 L 81 1 L 65 99 L 50 101 Z' ;;
  x) printf '76\tM 4 1 L 19 4 L 70 96 L 55 100 Z M 55 1 L 70 4 L 19 100 L 5 96 Z' ;;
  y) printf '74\tM 4 1 L 19 4 L 42 52 L 29 58 Z M 55 4 L 70 1 L 45 55 L 32 50 Z M 29 48 L 46 50 L 44 99 L 27 97 Z' ;;
  z) printf '74\tM 4 1 L 68 4 L 67 17 L 3 14 Z M 54 3 L 68 8 L 18 96 L 5 90 Z M 4 86 L 69 88 L 68 100 L 3 99 Z' ;;
  +) printf '70\tM 41 9 L 56 15 L 29 90 L 14 85 Z M 7 31 L 69 54 L 63 69 L 1 46 Z' ;;
  -) printf '50\tM 4 46 L 46 48 L 45 60 L 3 58 Z' ;;
  .) printf '34\tM 8 84 L 24 86 L 23 100 L 7 98 Z' ;;
  ' ') printf '34\t' ;;
  *) return 1 ;;
  esac
}

# Stable id per character, so punctuation does not produce invalid ids.
glyph_id() {
  case $1 in
  +) printf 'cross' ;;
  -) printf 'dash' ;;
  .) printf 'dot' ;;
  ' ') printf 'space' ;;
  *) printf '%s' "$1" ;;
  esac
}

space=10
x=0
defs=''
uses=''
seen=''

i=1
len=$(printf '%s' "$word" | wc -c)
while [ "$i" -le "$len" ]; do
  ch=$(printf '%s' "$word" | cut -c "$i")
  i=$((i + 1))

  if ! entry=$(glyph "$ch"); then
    echo "gen-wordmark: no glyph for '$ch', skipped" >&2
    continue
  fi
  adv=${entry%%	*}
  path=${entry#*	}

  id=$(glyph_id "$ch")
  if [ -n "$path" ]; then
    case " $seen " in
    *" $id "*) ;;
    *)
      seen="$seen $id"
      defs="$defs<path id=\"mw-g-$id\" d=\"$path\" />"
      ;;
    esac
    uses="$uses<use href=\"#mw-g-$id\" x=\"$x\" />"
  fi

  x=$((x + adv + space))
done

width=$((x - space))

{
  echo "wordmark-defs: $defs"
  echo "wordmark-uses: $uses"
  echo "wordmark-viewbox: -8 -14 $((width + 16)) 132"
} >"$out"
