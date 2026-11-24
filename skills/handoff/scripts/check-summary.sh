#!/bin/sh
# check-summary.sh: checks ai-handoff-summary.md against the handoff skill's limits and template.
#   sh check-summary.sh [path/to/ai-handoff-summary.md]      (default: ./ai-handoff-summary.md)
# Prints one FAIL or WARN line per problem, then a one-line result.
# Exit 0 = no FAIL (WARN lines may remain), 1 = at least one FAIL, 2 = file not found.
# Plain sh and awk, so it runs in Git Bash on Windows, macOS, Linux and sandboxes.
set -u
f="${1:-ai-handoff-summary.md}"
if [ ! -f "$f" ]; then
  printf '%s\n' "FAIL: $f not found"
  exit 2
fi
dir=$(dirname "$f")
tab=$(printf '\t')

# Pass 1 (awk): limits, tags, template. Path candidates come out as "PATH<tab>line<tab>path" for pass 2.
out=$(LC_ALL=C awk '
function trim(s) { sub(/^[ \t"]+/, "", s); sub(/[ \t".;]+$/, "", s); return s }
function head(s) { sub(/^##[ \t]+/, "", s); sub(/^[0-9]+[.)][ \t]+/, "", s); return s }
# cand: one path candidate. A note in brackets after it is dropped. prev = the previous path on the same line, so
# "dir/a.php, b.php" can find b.php next to a.php.
function cand(s, n,   p) {
  p = index(s, " ("); if (p > 0) s = substr(s, 1, p - 1)
  s = trim(s)
  if (s == "") return
  if (s ~ /:\/\//) { print "WARN line " n ": URL, not checked: " s; return }
  if (s ~ /^[A-Za-z0-9._-][A-Za-z0-9._-]+:\//) { print "WARN line " n ": remote path, not checked: " s; return }
  if (s ~ /[<>*?]/ || index(s, "...") > 0) { print "WARN line " n ": placeholder or pattern, not checked: " s; return }
  abs = (s ~ /^(\/|~|[A-Za-z]:[\/\\])/)
  if ((abs || s !~ /[ \t]/) && (s ~ /[\/\\]/ || s ~ /^\./ || s ~ /\.[A-Za-z0-9]+$/)) {
    print "PATH\t" n "\t" s "\t" prev
    t = s; sub(/[\/\\]$/, "", t); if (t ~ /[\/\\]/) prev = s
    return
  }
  print "WARN line " n ": not a path, not checked: " s
}
BEGIN {
  nreq = split("Now|Next action|Verified facts|Key paths|Rules for this project|Open questions|Where to look in handoff.md", req, "|")
  sec = ""; first = ""; fails = 0
}
{
  sub(/\r$/, "")
  line = $0
  s = line; chars = length(s) - gsub(/[\200-\277]/, "", s)
  if (chars > 160) { print "FAIL line " NR ": " chars " characters (at most 160)"; fails++ }
  if (first == "" && line ~ /[^ \t]/) first = line
  if (line ~ /^## /) {
    sec = ""; h = head(line)
    for (i = 1; i <= nreq; i++) if (index(h, req[i]) == 1) { sec = req[i]; seen[i] = 1 }
    inbody = 1
    next
  }
  if (!inbody) {
    if (line ~ /^Updated:/) upd = 1
    if (line ~ /^Last change:/) lc = 1
    if (line ~ /^Status:/) {
      st = 1
      if (line !~ /^Status:[ \t]*(ACTIVE|PAUSED|BLOCKED|DONE)/) {
        print "FAIL line " NR ": Status must start with ACTIVE, PAUSED, BLOCKED or DONE"; fails++
      }
    }
  }
  if (line !~ /^[-*] /) next
  if (sec == "Next action") nnext++
  if (sec == "Verified facts") {
    nfacts++
    if (line ~ /\[verified [^]]*:[^]]*\]/ || line ~ /\[unverified[^]]*\]/) {
    } else if (line ~ /\[verified [^]]*\]/) {
      print "WARN line " NR ": verified tag without \": how\""
    } else {
      print "FAIL line " NR ": fact without a [verified YYYY-MM-DD: how] or [unverified: source] tag"; fails++
    }
  }
  if (sec == "Key paths") {
    npaths++
    l = line; sub(/^[-*] +/, "", l)
    p = index(l, ": "); if (p > 0) l = substr(l, 1, p - 1)
    prev = ""
    if (l ~ /`/) {
      k = split(l, parts, "`")
      for (i = 2; i <= k; i += 2) cand(parts[i], NR)
    } else {
      gsub(/ (and|[+|\/]) /, ", ", l); gsub(/; /, ", ", l)
      k = split(l, parts, ", ")
      for (i = 1; i <= k; i++) cand(parts[i], NR)
    }
  }
}
END {
  if (first !~ /^# AI handoff summary:/) { print "FAIL: first line must be \"# AI handoff summary: <project>\""; fails++ }
  if (!upd) { print "FAIL: no \"Updated:\" line above the first ## heading"; fails++ }
  if (!lc) { print "FAIL: no \"Last change:\" line above the first ## heading"; fails++ }
  if (!st) { print "FAIL: no \"Status:\" line above the first ## heading"; fails++ }
  for (i = 1; i <= nreq; i++) if (!seen[i]) { print "FAIL: missing heading \"## " req[i] "\""; fails++ }
  if (NR > 60) { print "FAIL: " NR " lines (at most 60)"; fails++ }
  if (nfacts > 12) { print "FAIL: " nfacts " facts under Verified facts (at most 12)"; fails++ }
  if (npaths > 10) { print "FAIL: " npaths " entries under Key paths (at most 10)"; fails++ }
  if (seen[2] && nnext != 1) { print "FAIL: " nnext + 0 " items under Next action (exactly 1)"; fails++ }
  print "COUNT\t" fails "\t" NR "\t" nfacts + 0 "\t" npaths + 0 "\t" nnext + 0
}' "$f")

# Pass 2 (sh): every path candidate must exist. Relative paths are relative to the summary's folder; a bare file name
# may also sit in the folder of the path before it on the same line. An absolute path of the other OS family
# (C:\ on Linux or macOS, /home or /tmp on Windows) is from another machine: WARN, not checked.
case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*|CYGWIN*) win=1 ;; *) win=0 ;; esac
resolve() {
  case "$1" in
    "~") r=$HOME ;;
    "~/"*) r="$HOME/${1#\~/}" ;;
    /*|[A-Za-z]:[\\/]*) r=$1 ;;
    *) r="$2/$1" ;;
  esac
  case "$r" in *[\\/]) r=${r%?} ;; esac
}
fails=0
pathfails=0
summary=""
while IFS="$tab" read -r kind a b c d e; do
  case "$kind" in
    PATH)
      resolve "$b" "$dir"
      if [ ! -e "$r" ] && [ -n "$c" ]; then
        case "${b%[\\/]}" in
          */*|*\\*) ;;
          *) case "$c" in *[\\/]) base=$c ;; */*|*\\*) base=${c%[\\/]*} ;; *) base=. ;; esac
             resolve "$base" "$dir"; resolve "$b" "$r" ;;
        esac
      fi
      if [ ! -e "$r" ]; then
        other=0
        if [ "$win" = 1 ]; then
          case "$b" in /home/*|/tmp/*|/var/*|/srv/*|/opt/*|/root/*|/mnt/*|/usr/*|/etc/*|/Users/*) other=1 ;; esac
        else
          case "$b" in [A-Za-z]:[\\/]*) other=1 ;; esac
        fi
        if [ "$other" = 1 ]; then
          printf '%s\n' "WARN line $a: path from another machine, not checked: $b"
        else
          printf '%s\n' "FAIL line $a: path not found: $b"
          pathfails=$((pathfails + 1))
        fi
      fi
      ;;
    COUNT) fails=$a; summary="$b lines, $c facts, $d paths, $e Next action" ;;
    *) printf '%s\n' "$kind${a:+$tab$a}" ;;
  esac
done <<EOF
$out
EOF

if [ "$f" != "${f%ai-handoff-summary.md}" ]; then
  log="$dir/handoff.md"
  if [ -f "$log" ]; then
    size=$(wc -c < "$log" | tr -d ' ')
    if [ "$size" -gt 102400 ]; then
      echo "WARN: handoff.md is $((size / 1024)) KB (over 100 KB): archive old entries (skill: Very large handoff.md)"
    fi
  fi
fi

total=$((fails + pathfails))
if [ "$total" -gt 0 ]; then
  printf '%s\n' "FAILED: $total problem(s). $summary"
  exit 1
fi
printf '%s\n' "OK: $summary"
exit 0
