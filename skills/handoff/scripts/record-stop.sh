#!/bin/sh
# record-stop.sh: records one stop in a project's handoff files in a single call.
#   sh record-stop.sh --last "<one line>" --next "<one step>" [--now "<phase line>"] [--waiting "<who or what>"]
#                     [--status STATUS] [--by "<AI or chat>"] [--eod "<task> <title>: <what> [verified: how]"]
#                     [--task <ID> (--set "Column=value" ... | --row "| full | row |")] [--root <dir>]
# Run from the project root (or pass --root). It:
#   1. appends "- HH:MM <text>" to eod/YYYY-MM-DD.md (--eod; creates the file with its header);
#   2. sets the summary's Updated, Last change and Next action (and the Now line, Waiting on, Status when given);
#   3. changes the task's row in handoff.md > "## Task chats" (--task with --set or --row; --row adds a missing row);
#   4. runs check-summary.sh on the new summary and prints one line.
# All or nothing: on any FAIL nothing is written. Exit 0 = recorded, 1 = FAIL, 2 = no summary file.
# The time comes from `date` (tests may set RECORD_STOP_NOW="YYYY-MM-DD HH:MM +HHMM"). Plain sh and awk.
set -u
here=$(cd "$(dirname "$0")" && pwd)
root=.
last=""; next=""; waiting=""; status=""; by=""; eod=""; task=""; row=""; sets=""
hasw=0; hass=0; hasn=0; now=""
nl='
'
die() { echo "FAIL: nothing written: $1"; exit "${2:-1}"; }
while [ $# -gt 0 ]; do
  [ $# -ge 2 ] || die "$1 needs a value"
  case "$1" in
    --last) last=$2 ;;
    --next) next=$2 ;;
    --now) now=$2; hasn=1 ;;
    --waiting) waiting=$2; hasw=1 ;;
    --status) status=$2; hass=1 ;;
    --by) by=$2 ;;
    --eod) eod=$2 ;;
    --task) task=$2 ;;
    --set) case "$2" in *=*) ;; *) die "--set needs \"Column=value\"" ;; esac
           case "$2" in *"|"*) die "a --set value can't contain |" ;; esac
           sets="$sets$2$nl" ;;
    --row) row=$2 ;;
    --root) root=$2 ;;
    *) die "unknown option $1" ;;
  esac
  case "$2" in *"$nl"*) die "$1: one line only" ;; esac
  shift 2
done
[ -n "$last" ] || die "--last is required"
[ -n "$next" ] || die "--next is required"
if [ "$hass" = 1 ]; then
  case "$status" in ACTIVE|PAUSED|BLOCKED|DONE) ;; *) die "--status must be ACTIVE, PAUSED, BLOCKED or DONE" ;; esac
fi
if [ -n "$task" ]; then
  [ -n "$sets" ] || [ -n "$row" ] || die "--task needs --set or --row"
  [ -z "$sets" ] || [ -z "$row" ] || die "use --set or --row, not both"
else
  [ -z "$sets$row" ] || die "--set and --row need --task"
fi
case "$row" in ""|"|"*"|") ;; *) die "--row must start and end with |" ;; esac

sum="$root/ai-handoff-summary.md"
log="$root/handoff.md"
[ -f "$sum" ] || die "$sum not found" 2

# Time: "YYYY-MM-DD HH:MM +HHMM"
clock=${RECORD_STOP_NOW:-$(date '+%Y-%m-%d %H:%M %z')}
day=${clock%% *}; rest=${clock#* }; hm=${rest%% *}; z=${rest#* }
sign=$(printf '%s' "$z" | cut -c1); zh=$(printf '%s' "$z" | cut -c2-3); zm=$(printf '%s' "$z" | cut -c4-5)
zh=${zh#0}
case "$z" in +0000|-0000) tz=UTC ;; *) tz="UTC$sign${zh:-0}"; [ "$zm" = "00" ] || tz="$tz:$zm" ;; esac

tmps=""
cleanup() { [ -z "$tmps" ] || rm -f $tmps; }
trap cleanup EXIT
newtmp() { t="$1.record-stop.$$"; tmps="$tmps $t"; }

# Awk reads and writes keep each line's own ending, LF or CRLF (BINMODE=3: gawk on Windows; other awks ignore it).
export RS_LAST="$last" RS_NEXT="$next" RS_WAIT="$waiting" RS_HASW="$hasw" RS_NOW="$now" RS_HASN="$hasn"
export RS_STATUS="$status" RS_BY="$by"
export RS_STAMP="$day $hm $tz" RS_TASK="$task" RS_SETS="$sets" RS_ROW="$row"

# 1. Summary (the checker reads it from the same folder, so relative paths resolve).
tsum="$root/.record-stop.$$.ai-handoff-summary.md"; tmps="$tmps $tsum"
err=$(LC_ALL=C awk -v BINMODE=3 -v out="$tsum" '
function emit(s) { print s cr > out }

{
  cr = ""; if (sub(/\r$/, "")) cr = "\r"
  line = $0
  if (line ~ /^## /) {
    body = 1; insec = (line ~ /^## +Next action/); innow = (line ~ /^## +Now/)
    emit(line)
    if (insec) { emit("- " ENVIRON["RS_NEXT"]); nexts++ }
    next
  }
  if (!body && line ~ /^Updated:/) {
    b = ENVIRON["RS_BY"]
    if (b == "") { p = index(line, "| By:"); if (p > 0) b = substr(line, p + 5); sub(/^ +/, "", b) }
    emit("Updated: " ENVIRON["RS_STAMP"] (b != "" ? " | By: " b : "")); u++; next
  }
  if (!body && line ~ /^Last change:/) { emit("Last change: " ENVIRON["RS_LAST"]); l++; next }
  if (!body && line ~ /^Status:/ && ENVIRON["RS_STATUS"] != "") { emit("Status: " ENVIRON["RS_STATUS"]); next }
  if (insec && (line ~ /^[-*] / || line ~ /^[ \t]+[^ \t]/)) next
  waitline = (line ~ /^[-*] +Waiting on:/)
  if (innow && waitline && ENVIRON["RS_HASW"] == 1) { emit("- Waiting on: " ENVIRON["RS_WAIT"]); w++; next }
  if (innow && !waitline && !nw && line ~ /^[-*] / && ENVIRON["RS_HASN"] == 1) { emit("- " ENVIRON["RS_NOW"]); nw++; next }
  emit(line)
}
END {
  if (!u) print "no Updated: line"
  if (!l) print "no Last change: line"
  if (!nexts) print "no ## Next action heading"
  if (ENVIRON["RS_HASN"] == 1 && !nw) print "no phase line (first bullet) under ## Now"
  if (ENVIRON["RS_HASW"] == 1 && !w) print "no \"- Waiting on:\" line under ## Now"
}' "$sum" 2>&1)
err=$(printf '%s' "$err" | tr '\n' ';' | sed 's/;$//; s/;/; /g')
[ -z "$err" ] || die "ai-handoff-summary.md: $err: rewrite it from the template"

# 2. Board row in handoff.md
boardmsg=""
if [ -n "$task" ]; then
  [ -f "$log" ] || die "$log not found (needed for --task)"
  newtmp "$log"; tlog=$t
  res=$(LC_ALL=C awk -v BINMODE=3 -v out="$tlog" '
function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
function cells(s, a,   n, i) {
  s = trim(s); sub(/^\|/, "", s); sub(/\|$/, "", s)
  n = split(s, a, "|"); for (i = 1; i <= n; i++) a[i] = trim(a[i])
  return n
}
function ismatch(s,   a) { cells(s, a); return a[1] == T || index(a[1], T " ") == 1 }
BEGIN { T = ENVIRON["RS_TASK"]; state = 0 }
{ cr[NR] = ""; if (sub(/\r$/, "")) cr[NR] = "\r"; L[NR] = $0
  if (state == 0 && $0 ~ /^## +Task chats *$/) { state = 1; next }
  if (state == 1 && $0 ~ /^\|/) { state = 2; hdr = NR; next }
  if (state == 1 && $0 ~ /^## /) state = 0
  if (state == 2) {
    if ($0 !~ /^\|/) state = 3
    else { lastrow = NR; if (NR > hdr + 1 && ismatch($0)) { hits++; hit = NR } }
  }
}
END {
  if (!hdr) { print "FAIL\tno \"## Task chats\" table in handoff.md"; exit }
  nh = cells(L[hdr], H)
  if (!lastrow) lastrow = hdr
  if (ENVIRON["RS_ROW"] != "") {
    nr = cells(ENVIRON["RS_ROW"], R)
    if (nr != nh) { print "FAIL\t--row has " nr " cells, the table has " nh; exit }
    if (hits > 1) { print "FAIL\t" hits " rows start with " T; exit }
    if (hits == 1) { L[hit] = ENVIRON["RS_ROW"]; msg = "row replaced" }
    else { addat = lastrow; msg = "row added" }
  } else {
    if (hits != 1) { print "FAIL\t" hits + 0 " rows start with " T " (need exactly 1)"; exit }
    nc = cells(L[hit], C)
    ns = split(ENVIRON["RS_SETS"], S, "\n")
    for (i = 1; i <= ns; i++) {
      if (S[i] == "") continue
      p = index(S[i], "="); k = trim(substr(S[i], 1, p - 1)); v = trim(substr(S[i], p + 1))
      col = 0; for (j = 1; j <= nh; j++) if (tolower(H[j]) == tolower(k)) col = j
      if (!col) { print "FAIL\tno column \"" k "\" in the Task chats table"; exit }
      C[col] = v; changed++
    }
    s = "|"; for (j = 1; j <= nh; j++) s = s " " C[j] " |"
    L[hit] = s; msg = changed " cell(s) set"
  }
  for (i = 1; i <= NR; i++) {
    print L[i] cr[i] > out
    if (i == addat) print ENVIRON["RS_ROW"] cr[i] > out
  }
  print "OK\t" msg
}' "$log")
  case "$res" in
    OK*) boardmsg="board $task: ${res#OK	}" ;;
    *) die "${res#FAIL	}" ;;
  esac
fi

# 3. EOD line
eodmsg=""
if [ -n "$eod" ]; then
  case "$eod" in *"[verified"*|*"[unverified"*|*"[reconstructed"*) ;;
    *) die "--eod needs a [verified: how] or [unverified: source] tag" ;; esac
  line="- $hm $eod"
  n=$(printf '%s' "$line" | LC_ALL=C awk '{ s = $0; print length(s) - gsub(/[\200-\277]/, "", s) }')
  [ "$n" -le 160 ] || die "EOD line is $n characters (at most 160)"
  ef="$root/eod/$day.md"
  teod="$root/.record-stop.$$.eod.md"; tmps="$tmps $teod"; hta=0
  if [ -f "$ef" ]; then
    export RS_LINE="$line"
    LC_ALL=C awk -v BINMODE=3 -v out="$teod" '
{ cr[NR] = ""; if (sub(/\r$/, "")) cr[NR] = "\r"; L[NR] = $0; if (!sumat && $0 ~ /^## +EOD summary/) sumat = NR }
END {
  at = NR; if (sumat) { at = sumat - 1; while (at > 0 && L[at] ~ /^[ \t]*$/) at-- }
  for (i = 1; i <= NR; i++) { print L[i] cr[i] > out; if (i == at) print ENVIRON["RS_LINE"] cr[i] > out }
  if (at == 0) print ENVIRON["RS_LINE"] > out
}' "$ef"
    eodmsg="eod line"
  else
    project=$(sed -n '1s/^# AI handoff summary: *//p' "$sum" | tr -d '\r')
    [ -n "$project" ] || project=$(basename "$(cd "$root" && pwd)")
    printf '# EOD %s: %s\nTimezone: %s\n\n## Log\n%s\n' "$day" "$project" "$tz" "$line" > "$teod"
    eodmsg="eod file $day.md created"
    if [ -f "$root/.htaccess" ] && [ ! -f "$root/eod/.htaccess" ]; then
      hta=1; eodmsg="$eodmsg (+ eod/.htaccess)"
    fi
  fi
fi

# 4. Checker on the new summary, then move everything in place.
chk=$(sh "$here/check-summary.sh" "$tsum" 2>&1); code=$?
if [ "$code" != 0 ]; then
  printf '%s\n' "$chk" | grep '^FAIL'
  die "the new summary fails the checker: fix it (full rewrite), then run again"
fi
warns=$(printf '%s\n' "$chk" | grep -c '^WARN')
big=$(printf '%s\n' "$chk" | grep -o 'handoff.md is [0-9]* KB' | head -1)
[ -z "$eod" ] || mkdir -p "$root/eod" || die "can't create $root/eod"
mv "$tsum" "$sum" || die "can't write $sum"
[ -z "$task" ] || mv "$tlog" "$log"
if [ -n "$eod" ]; then
  [ "$hta" = 0 ] || printf 'Require all denied\n' > "$root/eod/.htaccess"
  mv "$teod" "$ef"
fi
tmps=""
what="summary"
[ -z "$eodmsg" ] || what="$eodmsg, $what"
[ -z "$boardmsg" ] || what="$what, $boardmsg"
okline=$(printf '%s\n' "$chk" | sed -n 's/^OK: //p')
extra=""
[ "$warns" = 0 ] || extra=" ($warns WARN)"
[ -z "$big" ] || extra="$extra; $big: archive (skill: Very large handoff.md)"
echo "OK: stop recorded at $hm: $what; checker OK, $okline$extra"
exit 0
