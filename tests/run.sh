#!/bin/sh
# Tests for skills/handoff/scripts/check-summary.sh.   Run from anywhere: sh tests/run.sh
# Each case copies tests/fixtures/base to a temp folder, changes one thing, runs the checker, and checks the exit code
# and one expected output line. Plain sh, awk and sed (the CI runs it on Ubuntu; it also runs in Git Bash).
set -u
root=$(cd "$(dirname "$0")/.." && pwd)
check="$root/skills/handoff/scripts/check-summary.sh"
base="$root/tests/fixtures/base"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
pass=0
fail=0

# run <name> <expected exit> <expected text> [file]
run() {
  file=${4:-$tmp/c/ai-handoff-summary.md}
  got=$(sh "$check" "$file" 2>&1)
  code=$?
  if [ "$code" = "$2" ] && printf '%s\n' "$got" | awk -v t="$3" 'index($0, t) { found = 1 } END { exit !found }'; then
    pass=$((pass + 1))
    echo "ok   $1"
  else
    fail=$((fail + 1))
    echo "FAIL $1 (exit $code, wanted $2 and \"$3\")"
    printf '%s\n' "$got" | sed 's/^/     /'
  fi
}

# fresh: a new copy of the base fixture in $tmp/c
fresh() { rm -rf "$tmp/c"; cp -R "$base" "$tmp/c"; }
# edit <awk program>: rewrites the copy's summary with an awk program
edit() { awk "$1" "$tmp/c/ai-handoff-summary.md" > "$tmp/e" && mv "$tmp/e" "$tmp/c/ai-handoff-summary.md"; }

fresh; run "base passes" 0 "OK: 34 lines, 2 facts, 5 paths, 1 Next action"
fresh; run "URL in Key paths is a WARN" 0 "WARN line 21: URL, not checked: https://example.com/wp-admin"
fresh; run "non-path label is a WARN" 0 "WARN line 22: not a path, not checked: Staging database"

fresh; edit '{ print } /^## Where to look/ { for (i = 0; i < 27; i++) print "- filler: handoff.md > Goal" }'
run "61 lines" 1 "FAIL: 61 lines (at most 60)"

fresh; edit '{ print } /^## Verified facts/ { for (i = 0; i < 11; i++) print "- fact " i " [verified 2026-11-17: ls]" }'
run "13 facts" 1 "FAIL: 13 facts under Verified facts (at most 12)"

fresh; edit '{ print } /^## Key paths/ { for (i = 0; i < 6; i++) print "- handoff.md: log" }'
run "11 paths" 1 "FAIL: 11 entries under Key paths (at most 10)"

fresh; edit '{ print } /^## Next action/ { print "- Then deploy" }'
run "two Next actions" 1 "FAIL: 2 items under Next action (exactly 1)"

fresh; edit '!/^- Add the form markup/'
run "no Next action" 1 "FAIL: 0 items under Next action (exactly 1)"

fresh; edit '{ print } /^## Now/ { s = "- "; for (i = 0; i < 159; i++) s = s "x"; print s }'
run "161-character line" 1 "FAIL line 7: 161 characters (at most 160)"

fresh; edit '{ print } /^## Now/ { s = "- "; for (i = 0; i < 158; i++) s = s "x"; print s }'
run "160-character line passes" 0 "OK:"

fresh; edit '{ print } /^## Verified facts/ { print "- A fact with no tag" }'
run "untagged fact" 1 "FAIL line 14: fact without a [verified YYYY-MM-DD: how] or [unverified: source] tag"

fresh; edit '{ print } /^## Verified facts/ { print "- A fact [verified 2026-11-17]" }'
run "verified tag without how is a WARN" 0 "WARN line 14: verified tag without \": how\""

fresh; edit '{ print } /^## Key paths/ { print "- src/missing.js: gone" }'
run "missing path" 1 "FAIL line 18: path not found: src/missing.js"

fresh; edit '{ print } /^## Key paths/ { print "- `src/app.js` and `docs/gone.md`: one of two missing" }'
run "missing backticked path" 1 "FAIL line 18: path not found: docs/gone.md"

fresh; edit '{ print } /^## Key paths/ { print "- tasks/<TASK-ID>/: per task" }'
run "placeholder is a WARN" 0 "WARN line 18: placeholder or pattern, not checked: tasks/<TASK-ID>/"

fresh; edit '{ print } /^## Key paths/ { print "- " ENVIRON["HOME"] ": home folder" }'
run "absolute path" 0 "OK:"

fresh; edit '{ print } /^## Key paths/ { print "- ~/: home folder" }'
run "home path" 0 "OK:"

export T="$tmp"; fresh; mkdir "$tmp/c/my folder"; edit '{ print } /^## Key paths/ { print "- " ENVIRON["T"] "/c/my folder/: a folder with a space" }'
run "absolute path with a space" 0 "OK:"

fresh; edit '{ print } /^## Key paths/ { print "- my notes folder: words, not a path" }'
run "relative text with spaces is a WARN" 0 "WARN line 18: not a path, not checked: my notes folder"

fresh; edit '{ print } /^## Key paths/ { print "- src/app.js, gone.js: second name sits next to the first" }'
run "bare name next to the path before it" 1 "FAIL line 18: path not found: gone.js"

fresh; mkdir "$tmp/c/src/lib"; touch "$tmp/c/src/b.js"; edit '{ print } /^## Key paths/ { print "- src/app.js + b.js (both), lib/ / docs/notes.md (old: see log): mixed list" }'
run "names split on + and / with notes" 0 "OK:"

fresh; edit '{ print } /^## Key paths/ { print "- live:/home/site/public_html: live web root" }'
run "remote path is a WARN" 0 "WARN line 18: remote path, not checked: live:/home/site/public_html"

case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) other=/home/someone/site ;; *) other='D:\sites\example' ;; esac
export O="$other"; fresh; edit '{ print } /^## Key paths/ { print "- " ENVIRON["O"] ": a path on another machine" }'
run "path of the other OS is a WARN" 0 "WARN line 18: path from another machine, not checked:"

fresh; edit '{ print } /^## Key paths/ { print "- .../themes/site/style.css: shortened path" }'
run "shortened path is a WARN" 0 "WARN line 18: placeholder or pattern, not checked:"

fresh; edit '{ sub(/^Status: ACTIVE/, "Status: launched, reported") } { print }'
run "bad Status" 1 "FAIL line 4: Status must start with ACTIVE, PAUSED, BLOCKED or DONE"

fresh; edit '{ sub(/^Status: ACTIVE/, "Status: PAUSED (waiting on review)") } { print }'
run "Status with a note" 0 "OK:"

fresh; edit '!/^Updated:/'
run "no Updated line" 1 "FAIL: no \"Updated:\" line above the first ## heading"

fresh; edit '!/^## Rules for this project/'
run "missing heading" 1 "FAIL: missing heading \"## Rules for this project\""

fresh; edit '{ sub(/^## Now/, "## 1. Now") } { print }'
run "numbered heading" 0 "OK:"

fresh; awk '{ printf "%s\r\n", $0 }' "$base/ai-handoff-summary.md" > "$tmp/c/ai-handoff-summary.md"
run "CRLF line endings" 0 "OK: 34 lines"

fresh; awk 'BEGIN { for (i = 0; i < 2000; i++) print "- 2026-01-01: an old entry with enough text to grow the file past the limit" }' \
  >> "$tmp/c/handoff.md"
run "handoff.md over 100 KB is a WARN" 0 "WARN: handoff.md is"

run "no template" 1 "FAIL: first line must be" "$root/tests/fixtures/no-template/ai-handoff-summary.md"
run "no template, headings" 1 "FAIL: missing heading \"## Next action\"" "$root/tests/fixtures/no-template/ai-handoff-summary.md"
run "file not found" 2 "not found" "$tmp/none/ai-handoff-summary.md"

echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
