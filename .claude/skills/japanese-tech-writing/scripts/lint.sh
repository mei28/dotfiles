#!/usr/bin/env bash
# Lint Japanese prose for AI smell with textlint and suiko.
#
# Usage:
#   lint.sh [--genre essay|tech|business] <file>...
#
# Accepts .md, .markdown, .txt and .tex. A .tex file is converted to Markdown with pandoc
# in a temporary directory, and Japanese sentence punctuation written as ", " and "."
# (the jlreq/jsarticle habit) is normalized to "、" and "。" so that suiko can split
# sentences. The original file is never modified. Findings for a .tex input point at the
# converted copy, so locate the source by the quoted excerpt, not the line number.
#
# Output: a header, then textlint findings (unix format), then suiko's text report.
#         Findings never change the exit code; they are suspicions for the ledger.
#         All textlint rules are pinned to severity "warning" in .textlintrc.json for
#         that reason: an "error" finding would make textlint exit 1.
#
# Exit codes:
#   0  both tools ran (findings or not)
#   1  a tool is not on PATH, an input is missing or unsupported, or a tool failed
#   2  usage error
#
# The tools are installed by the user (see ../references/lint.md). This script never
# installs them and never falls back to a manual checklist.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEXTLINT_CONFIG="$SKILL_DIR/.textlintrc.json"
SUIKO_CONFIG="$SKILL_DIR/.suiko.toml"

usage() {
  echo "Usage: lint.sh [--genre essay|tech|business] <file>...  (.md .markdown .txt .tex)" >&2
}

die() {
  echo "error: $*" >&2
  exit 1
}

need_tool() {
  command -v "$1" >/dev/null 2>&1 \
    || die "$1 not found on PATH. Install it first (see $SKILL_DIR/references/lint.md)."
}

# Normalize Japanese punctuation in place: a half-width "." or "," right after a Japanese
# character (or a closing bracket) becomes "。" or "、", and the full-width "．" "，" likewise.
# Digits and Latin text are untouched, so "v0.3.8" and URLs survive.
normalize_punctuation() {
  perl -CSD -Mutf8 -pi -e '
    my $ja = qr/[\p{Han}\p{Hiragana}\p{Katakana}ー々〆）」』】\]]/;
    s/($ja)\.(?:[ \t]+|$)/$1。/g;
    s/($ja),(?:[ \t]+|$)/$1、/g;
    s/($ja)．/$1。/g;
    s/($ja)，/$1、/g;
  ' "$1"
}

genre=""
files=()
while [ $# -gt 0 ]; do
  case "$1" in
    --genre)
      [ $# -ge 2 ] || { usage; exit 2; }
      genre="$2"
      shift 2
      ;;
    --genre=*)
      genre="${1#--genre=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      files+=("$@")
      break
      ;;
    -*)
      usage
      exit 2
      ;;
    *)
      files+=("$1")
      shift
      ;;
  esac
done

[ ${#files[@]} -gt 0 ] || { usage; exit 2; }
case "$genre" in
  ""|essay|tech|business) ;;
  *) usage; exit 2 ;;
esac

# Validate inputs before touching any tool, so a typo fails fast.
needs_tex=0
inputs=()
for f in "${files[@]}"; do
  [ -f "$f" ] || die "file not found: $f"
  case "$f" in
    *.md|*.markdown|*.txt) ;;
    *.tex) needs_tex=1 ;;
    *) die "unsupported extension: $f (expected .md, .markdown, .txt or .tex)" ;;
  esac
  inputs+=("$(cd "$(dirname "$f")" && pwd)/$(basename "$f")")
done

need_tool textlint
need_tool suiko
if [ "$needs_tex" -eq 1 ]; then
  need_tool pandoc
  need_tool perl
fi

tmpdir=""
# An if, not an and-list: in an EXIT trap the and-list's false branch would
# leak status 1 into the script's exit code when no temporary directory exists.
cleanup() {
  if [ -n "$tmpdir" ]; then
    rm -rf "$tmpdir"
  fi
}
trap cleanup EXIT

targets=()
converted=()
for f in "${inputs[@]}"; do
  case "$f" in
    *.tex)
      [ -n "$tmpdir" ] || tmpdir="$(mktemp -d)"
      out="$tmpdir/$(basename "${f%.tex}").md"
      pandoc -f latex -t gfm --wrap=none "$f" -o "$out" \
        || die "pandoc failed on $f"
      normalize_punctuation "$out"
      targets+=("$out")
      converted+=("$f -> $out")
      ;;
    *)
      targets+=("$f")
      ;;
  esac
done

echo "== ja-lint =="
echo "textlint $(textlint --version) / suiko $(suiko --version) / genre: ${genre:-tech (.suiko.toml default)}"
for c in "${converted[@]+"${converted[@]}"}"; do
  echo "converted with pandoc: $c"
done

echo "== textlint =="
textlint --config "$TEXTLINT_CONFIG" --format unix -- "${targets[@]}" \
  || die "textlint failed (exit $?)"

echo "== suiko =="
suiko_args=(lint --config "$SUIKO_CONFIG" --experimental --reading-load)
if [ -n "$genre" ]; then
  suiko_args+=(--genre "$genre")
fi
suiko "${suiko_args[@]}" "${targets[@]}" \
  || die "suiko failed (exit $?)"
