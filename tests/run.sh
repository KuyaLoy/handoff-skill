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

# ---- record-stop.sh: one call records a stop (EOD line, summary lines, board row) ----
stop="$root/skills/handoff/scripts/record-stop.sh"
export RECORD_STOP_NOW="2026-11-18 09:12 +0400"
# board: the base copy plus a Task chats table
board() {
  fresh
  printf '\n## Task chats\n| Task | Status | Chat | Phase | Waiting on |\n|---|---|---|---|---|\n' >> "$tmp/c/handoff.md"
  printf '| ABC1-T8 Metadata | Zoho | abc1-t8 | PLAN READY | lead go |\n' >> "$tmp/c/handoff.md"
}
# rs <name> <expected exit> <expected text> -- <record-stop options>
rs() {
  n=$1 x=$2 t=$3; shift 4
  got=$(sh "$stop" --root "$tmp/c" "$@" 2>&1); code=$?
  if [ "$code" = "$x" ] && printf '%s\n' "$got" | awk -v t="$t" 'index($0, t) { f = 1 } END { exit !f }'; then
    pass=$((pass + 1)); echo "ok   $n"
  else
    fail=$((fail + 1)); echo "FAIL $n (exit $code, wanted $x and \"$t\")"; printf '%s\n' "$got" | sed 's/^/     /'
  fi
}
# has <name> <file> <text>: the file has a line equal to text
has() {
  if awk -v t="$3" '{ sub(/\r$/, "") } $0 == t { f = 1 } END { exit !f }' "$2" 2>/dev/null; then
    pass=$((pass + 1)); echo "ok   $1"
  else
    fail=$((fail + 1)); echo "FAIL $1 (no line \"$3\" in $2)"
  fi
}
same() { if cmp -s "$2" "$3"; then pass=$((pass + 1)); echo "ok   $1"; else fail=$((fail + 1)); echo "FAIL $1 ($2 changed)"; fi; }

board; touch "$tmp/c/.htaccess"
rs "stop: all parts" 0 "OK: stop recorded at 09:12: eod file 2026-11-18.md created (+ eod/.htaccess), summary, board ABC1-T8" -- \
  --last "plan ready" --next "Wait for the go" --now "Plan ready for ABC1-T8" --waiting "lead go" --by "task chat" \
  --eod "ABC1-T8 Metadata: plan ready [verified: plan.md written]" --task ABC1-T8 --set "Phase=IMPLEMENTING 32%"
has "stop: Updated line" "$tmp/c/ai-handoff-summary.md" "Updated: 2026-11-18 09:12 UTC+4 | By: task chat"
has "stop: Last change" "$tmp/c/ai-handoff-summary.md" "Last change: plan ready"
has "stop: Next action" "$tmp/c/ai-handoff-summary.md" "- Wait for the go"
has "stop: Waiting on" "$tmp/c/ai-handoff-summary.md" "- Waiting on: lead go"
has "stop: Now line" "$tmp/c/ai-handoff-summary.md" "- Plan ready for ABC1-T8"
awk 'NR != 2 && NR != 3 && NR != 7 && NR != 8 && NR != 11' "$base/ai-handoff-summary.md" > "$tmp/o1"
awk 'NR != 2 && NR != 3 && NR != 7 && NR != 8 && NR != 11' "$tmp/c/ai-handoff-summary.md" > "$tmp/o2"
same "stop: only the five stop lines changed" "$tmp/o1" "$tmp/o2"
has "stop: board cell" "$tmp/c/handoff.md" "| ABC1-T8 Metadata | Zoho | abc1-t8 | IMPLEMENTING 32% | lead go |"
has "stop: eod header" "$tmp/c/eod/2026-11-18.md" "Timezone: UTC+4"
has "stop: eod line" "$tmp/c/eod/2026-11-18.md" "- 09:12 ABC1-T8 Metadata: plan ready [verified: plan.md written]"
has "stop: eod .htaccess" "$tmp/c/eod/.htaccess" "Require all denied"
sh "$check" "$tmp/c/ai-handoff-summary.md" >/dev/null; [ $? = 0 ] && { pass=$((pass + 1)); echo "ok   stop: checker passes after"; } \
  || { fail=$((fail + 1)); echo "FAIL stop: checker fails after"; }

board
rs "stop: By kept, row added" 0 "board ABC1-T9: row added" -- --last x --next y --task ABC1-T9 \
  --row "| ABC1-T9 Form | Zoho | abc1-t9 | BLOCKED | client |"
has "stop: By kept" "$tmp/c/ai-handoff-summary.md" "Updated: 2026-11-18 09:12 UTC+4 | By: test fixture"
has "stop: new row" "$tmp/c/handoff.md" "| ABC1-T9 Form | Zoho | abc1-t9 | BLOCKED | client |"
rs "stop: row replaced" 0 "row replaced" -- --last x --next y --task ABC1-T9 --row "| ABC1-T9 Form | Zoho | abc1-t9 | DONE | nobody |"

board; mkdir "$tmp/c/eod"
printf '# EOD 2026-11-18: example-site\nTimezone: UTC+4\n\n## Log\n- 08:00 A: one [verified: ls]\n\n## EOD summary (written 08:30)\n- A: DONE.\n' \
  > "$tmp/c/eod/2026-11-18.md"
rs "stop: eod line above the summary" 0 "eod line" -- --last x --next y --eod "B two: done [verified: ls]"
awk 'NR == 6' "$tmp/c/eod/2026-11-18.md" > "$tmp/l6"; has "stop: eod line placed" "$tmp/l6" "- 09:12 B two: done [verified: ls]"

board; mkdir "$tmp/c/eod"
awk '{ printf "%s\r\n", $0 }' "$base/ai-handoff-summary.md" > "$tmp/c/ai-handoff-summary.md"
rs "stop: CRLF summary" 0 "OK: stop recorded" -- --last "crlf" --next "keep endings"
n=$(awk -v BINMODE=3 '/\r$/ { n++ } END { print n + 0 }' "$tmp/c/ai-handoff-summary.md"); [ "$n" = 34 ] && { pass=$((pass + 1)); echo "ok   stop: CRLF kept"; } \
  || { fail=$((fail + 1)); echo "FAIL stop: CRLF kept ($n CRLF lines)"; }

RECORD_STOP_NOW="2026-11-18 09:12 +0530" rs "stop: half-hour timezone" 0 "OK:" -- --last x --next y
has "stop: UTC+5:30" "$tmp/c/ai-handoff-summary.md" "Updated: 2026-11-18 09:12 UTC+5:30 | By: test fixture"

# Failures write nothing
board; cp "$tmp/c/ai-handoff-summary.md" "$tmp/s0"; cp "$tmp/c/handoff.md" "$tmp/h0"
rs "stop: no --next" 1 "FAIL: nothing written: --next is required" -- --last x
rs "stop: unknown task" 1 "0 rows start with ABC9" -- --last x --next y --task ABC9 --set "Phase=x"
rs "stop: unknown column" 1 "no column \"Bogus\"" -- --last x --next y --task ABC1-T8 --set "Bogus=x"
rs "stop: pipe in a cell" 1 "can't contain |" -- --last x --next y --task ABC1-T8 --set "Phase=a|b"
rs "stop: row cell count" 1 "--row has 2 cells, the table has 5" -- --last x --next y --task ABC1-T8 --row "| a | b |"
rs "stop: eod without a tag" 1 "needs a [verified: how]" -- --last x --next y --eod "A: done"
rs "stop: bad status" 1 "--status must be" -- --last x --next y --status FINISHED
long=$(awk 'BEGIN { for (i = 0; i < 170; i++) printf "x" }')
rs "stop: line over 160 fails the checker" 1 "fails the checker" -- --last "$long" --next y --eod "A: done [verified: ls]"
same "stop: summary unchanged after failures" "$tmp/s0" "$tmp/c/ai-handoff-summary.md"
same "stop: handoff.md unchanged after failures" "$tmp/h0" "$tmp/c/handoff.md"
[ ! -e "$tmp/c/eod" ] && { pass=$((pass + 1)); echo "ok   stop: no eod file after a failure"; } \
  || { fail=$((fail + 1)); echo "FAIL stop: eod written on a failure"; }
left=$(ls -A "$tmp/c" | grep -c 'record-stop'); [ "$left" = 0 ] && { pass=$((pass + 1)); echo "ok   stop: no temp files left"; } \
  || { fail=$((fail + 1)); echo "FAIL stop: $left temp files left"; }
board; edit '!/^## Next action/'
rs "stop: summary without Next action" 1 "no ## Next action heading" -- --last x --next y
rs "stop: no summary" 2 "not found" -- --root "$tmp/none" --last x --next y

echo "$pass passed, $fail failed"
[ "$fail" = 0 ]
