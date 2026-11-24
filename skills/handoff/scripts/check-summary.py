#!/usr/bin/env python3
"""check-summary.py: the Python twin of check-summary.sh, for tools and computers without sh (e.g. Windows without
Git Bash). Same checks, same output, same exit codes:
  python check-summary.py [path/to/ai-handoff-summary.md]      (default: ./ai-handoff-summary.md)
Prints one FAIL or WARN line per problem, then a one-line result.
Exit 0 = no FAIL (WARN lines may remain), 1 = at least one FAIL, 2 = file not found.
Python 3.8+, standard library only. Text is handled as bytes (latin-1), so any encoding passes through unchanged.
"""
import os
import re
import sys

WIN = os.name == "nt" or sys.platform.startswith(("cygwin", "msys"))
REQ = ["Now", "Next action", "Verified facts", "Key paths", "Rules for this project", "Open questions",
       "Where to look in handoff.md"]


def arg_text(a):
    """A command-line argument as the bytes the shell would pass, held in a latin-1 str."""
    if os.name == "nt":
        return a.encode("utf-8").decode("latin-1")
    return os.fsencode(a).decode("latin-1")


def env_text(name, default=""):
    v = os.environ.get(name)
    return default if v is None else arg_text(v)


def fs(s):
    """A latin-1 text path back to a file-system path. On Windows, Git Bash's /c/... is C:/..."""
    if os.name == "nt":
        p = s.encode("latin-1").decode("utf-8", "replace")
        m = re.match(r"^/([A-Za-z])(/|$)", p)
        if m:
            p = m.group(1).upper() + ":/" + p[3:]
        return p
    return os.fsdecode(s.encode("latin-1"))


def home():
    h = os.environ.get("HOME")
    return arg_text(h) if h else arg_text(os.path.expanduser("~"))


def read_lines(path):
    """The file's lines as awk reads them: split on LF, no empty record after a final LF."""
    with open(fs(path), "rb") as fh:
        data = fh.read().decode("latin-1")
    lines = data.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    return lines


def chars(s):
    """Characters as the checker counts them: bytes minus UTF-8 continuation bytes."""
    return len(s) - len(re.findall("[\x80-\xbf]", s))


def trim(s):
    s = re.sub(r'^[ \t"]+', "", s, count=1)
    return re.sub(r'[ \t".;]+$', "", s, count=1)


def head(s):
    s = re.sub(r"^##[ \t]+", "", s, count=1)
    return re.sub(r"^[0-9]+[.)][ \t]+", "", s, count=1)


def pass1(lines):
    """Limits, tags, template. Path candidates come out as "PATH<tab>line<tab>path<tab>prev" for pass 2."""
    out = []
    st = {"prev": ""}

    def cand(s, n):
        p = s.find(" (")
        if p >= 0:
            s = s[:p]
        s = trim(s)
        if s == "":
            return
        if "://" in s:
            out.append("WARN line %d: URL, not checked: %s" % (n, s))
            return
        if re.search(r"^[A-Za-z0-9._-][A-Za-z0-9._-]+:/", s):
            out.append("WARN line %d: remote path, not checked: %s" % (n, s))
            return
        if re.search(r"[<>*?]", s) or "..." in s:
            out.append("WARN line %d: placeholder or pattern, not checked: %s" % (n, s))
            return
        absolute = re.search(r"^(/|~|[A-Za-z]:[/\\])", s) is not None
        if (absolute or not re.search(r"[ \t]", s)) and (
                re.search(r"[/\\]", s) or s.startswith(".") or re.search(r"\.[A-Za-z0-9]+$", s)):
            out.append("PATH\t%d\t%s\t%s" % (n, s, st["prev"]))
            t = re.sub(r"[/\\]$", "", s, count=1)
            if re.search(r"[/\\]", t):
                st["prev"] = s
            return
        out.append("WARN line %d: not a path, not checked: %s" % (n, s))

    sec = ""
    first = ""
    fails = 0
    seen = [False] * len(REQ)
    inbody = upd = lc = stl = False
    nnext = nfacts = npaths = 0
    nr = 0
    for raw in lines:
        nr += 1
        line = raw[:-1] if raw.endswith("\r") else raw
        c = chars(line)
        if c > 160:
            out.append("FAIL line %d: %d characters (at most 160)" % (nr, c))
            fails += 1
        if first == "" and re.search(r"[^ \t]", line):
            first = line
        if line.startswith("## "):
            sec = ""
            h = head(line)
            for i, r in enumerate(REQ):
                if h.startswith(r):
                    sec = r
                    seen[i] = True
            inbody = True
            continue
        if not inbody:
            if line.startswith("Updated:"):
                upd = True
            if line.startswith("Last change:"):
                lc = True
            if line.startswith("Status:"):
                stl = True
                if not re.search(r"^Status:[ \t]*(ACTIVE|PAUSED|BLOCKED|DONE)", line):
                    out.append("FAIL line %d: Status must start with ACTIVE, PAUSED, BLOCKED or DONE" % nr)
                    fails += 1
        if not re.search(r"^[-*] ", line):
            continue
        if sec == "Next action":
            nnext += 1
        if sec == "Verified facts":
            nfacts += 1
            if re.search(r"\[verified [^\]]*:[^\]]*\]", line) or re.search(r"\[unverified[^\]]*\]", line):
                pass
            elif re.search(r"\[verified [^\]]*\]", line):
                out.append('WARN line %d: verified tag without ": how"' % nr)
            else:
                out.append("FAIL line %d: fact without a [verified YYYY-MM-DD: how] or [unverified: source] tag" % nr)
                fails += 1
        if sec == "Key paths":
            npaths += 1
            item = re.sub(r"^[-*] +", "", line, count=1)
            p = item.find(": ")
            if p >= 0:
                item = item[:p]
            st["prev"] = ""
            if "`" in item:
                parts = item.split("`")
                for i in range(1, len(parts), 2):
                    cand(parts[i], nr)
            else:
                item = re.sub(r" (and|[+|/]) ", ", ", item)
                item = item.replace("; ", ", ")
                if item != "":
                    for part in item.split(", "):
                        cand(part, nr)
    if not first.startswith("# AI handoff summary:"):
        out.append('FAIL: first line must be "# AI handoff summary: <project>"')
        fails += 1
    if not upd:
        out.append('FAIL: no "Updated:" line above the first ## heading')
        fails += 1
    if not lc:
        out.append('FAIL: no "Last change:" line above the first ## heading')
        fails += 1
    if not stl:
        out.append('FAIL: no "Status:" line above the first ## heading')
        fails += 1
    for i, r in enumerate(REQ):
        if not seen[i]:
            out.append('FAIL: missing heading "## %s"' % r)
            fails += 1
    if nr > 60:
        out.append("FAIL: %d lines (at most 60)" % nr)
        fails += 1
    if nfacts > 12:
        out.append("FAIL: %d facts under Verified facts (at most 12)" % nfacts)
        fails += 1
    if npaths > 10:
        out.append("FAIL: %d entries under Key paths (at most 10)" % npaths)
        fails += 1
    if seen[1] and nnext != 1:
        out.append("FAIL: %d items under Next action (exactly 1)" % nnext)
        fails += 1
    out.append("COUNT\t%d\t%d\t%d\t%d\t%d" % (fails, nr, nfacts, npaths, nnext))
    return out


def resolve(p, base):
    if p == "~":
        r = home()
    elif p.startswith("~/"):
        r = home() + "/" + p[2:]
    elif p.startswith("/") or re.match(r"^[A-Za-z]:[\\/]", p):
        r = p
    else:
        r = base + "/" + p
    if r.endswith(("/", "\\")):
        r = r[:-1]
    return r


def exists(r):
    return os.path.exists(fs(r))


def fields(line):
    """Split like the shell's `read -r kind a b c d e` with IFS=<tab>."""
    parts = re.split(r"\t+", line.strip("\t"), maxsplit=5) if line.strip("\t") else [""]
    return parts + [""] * (6 - len(parts))


def dirname(f):
    d = os.path.dirname(f)
    return d if d else "."


def check(f):
    """Returns (output lines, exit code) for the summary at f (a latin-1 text path)."""
    if not os.path.isfile(fs(f)):
        return ["FAIL: %s not found" % f], 2
    d = dirname(f)
    out = []
    fails = 0
    pathfails = 0
    summary = ""
    for line in pass1(read_lines(f)):
        kind, a, b, c, dd, e = fields(line)
        if kind == "PATH":
            r = resolve(b, d)
            if not exists(r) and c != "":
                bb = b[:-1] if b.endswith(("/", "\\")) else b
                if not re.search(r"[/\\]", bb):
                    if c.endswith(("/", "\\")):
                        base = c
                    elif re.search(r"[/\\]", c):
                        base = re.sub(r"[/\\][^/\\]*$", "", c, count=1)
                    else:
                        base = "."
                    r = resolve(b, resolve(base, d))
            if not exists(r):
                if WIN:
                    other = re.match(r"^/(home|tmp|var|srv|opt|root|mnt|usr|etc|Users)/", b) is not None
                else:
                    other = re.match(r"^[A-Za-z]:[\\/]", b) is not None
                if other:
                    out.append("WARN line %s: path from another machine, not checked: %s" % (a, b))
                else:
                    out.append("FAIL line %s: path not found: %s" % (a, b))
                    pathfails += 1
        elif kind == "COUNT":
            fails = int(a)
            summary = "%s lines, %s facts, %s paths, %s Next action" % (b, c, dd, e)
        else:
            out.append(kind + ("\t" + a if a else ""))
    if f.endswith("ai-handoff-summary.md"):
        log = d + "/handoff.md"
        if os.path.isfile(fs(log)):
            size = os.path.getsize(fs(log))
            if size > 102400:
                out.append("WARN: handoff.md is %d KB (over 100 KB): archive old entries (skill: Very large handoff.md)"
                           % (size // 1024))
    total = fails + pathfails
    if total > 0:
        out.append("FAILED: %d problem(s). %s" % (total, summary))
        return out, 1
    out.append("OK: %s" % summary)
    return out, 0


def main(argv):
    f = arg_text(argv[1]) if len(argv) > 1 else "ai-handoff-summary.md"
    out, code = check(f)
    sys.stdout.buffer.write(("\n".join(out) + "\n").encode("latin-1"))
    sys.stdout.flush()
    return code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
