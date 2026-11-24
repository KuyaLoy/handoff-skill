#!/usr/bin/env python3
"""record-stop.py: the Python twin of record-stop.sh, for tools and computers without sh (e.g. Windows without
Git Bash). Same options, same output, same exit codes, same files written:
  python record-stop.py --last "<one line>" --next "<one step>" [--now "<phase line>"] [--waiting "<who or what>"]
                        [--status STATUS] [--by "<AI or chat>"] [--eod "<task> <title>: <what> [verified: how]"]
                        [--task <ID> (--set "Column=value" ... | --row "| full | row |")] [--root <dir>]
All or nothing: on any FAIL nothing is written. Exit 0 = recorded, 1 = FAIL, 2 = no summary file.
The time comes from the clock (tests may set RECORD_STOP_NOW="YYYY-MM-DD HH:MM +HHMM"). Python 3.8+, stdlib only.
"""
import datetime
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("check_summary", os.path.join(HERE, "check-summary.py"))
cs = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(cs)
fs, arg_text, env_text, chars = cs.fs, cs.arg_text, cs.env_text, cs.chars

TMPS = []


class Stop(Exception):
    def __init__(self, msg, code):
        Exception.__init__(self, msg)
        self.code = code


def die(msg, code=1):
    raise Stop("FAIL: nothing written: " + msg, code)


def say(s):
    sys.stdout.buffer.write((s + "\n").encode("latin-1"))


def split_lines(data):
    """Lines as awk reads them, each with its own CR kept apart: [(text, cr)]."""
    lines = data.split("\n")
    if lines and lines[-1] == "":
        lines.pop()
    return [(l[:-1], "\r") if l.endswith("\r") else (l, "") for l in lines]


def read(path):
    with open(fs(path), "rb") as fh:
        return fh.read().decode("latin-1")


def write(path, text):
    TMPS.append(path)
    with open(fs(path), "wb") as fh:
        fh.write(text.encode("latin-1"))


def trim(s):
    return re.sub(r"^[ \t]+|[ \t]+$", "", s)


def cells(s):
    s = trim(s)
    s = re.sub(r"^\|", "", s, count=1)
    s = re.sub(r"\|$", "", s, count=1)
    if s == "":
        return []
    return [trim(x) for x in s.split("|")]


def lower(s):
    return re.sub("[A-Z]", lambda m: m.group(0).lower(), s)


def zone(clock):
    day, _, rest = clock.partition(" ")
    hm, _, z = rest.partition(" ")
    if " " not in rest:
        z = rest
    sign, zh, zm = z[:1], z[1:3], z[3:5]
    if zh.startswith("0"):
        zh = zh[1:]
    if z in ("+0000", "-0000"):
        tz = "UTC"
    else:
        tz = "UTC" + sign + (zh or "0")
        if zm != "00":
            tz += ":" + zm
    return day, hm, tz


def summary_pass(text, o):
    """Step 1: the new summary text and the list of problems."""
    out = []
    errs = []
    body = insec = innow = False
    nexts = u = l = w = nw = 0
    for line, cr in split_lines(text):
        def emit(s):
            out.append(s + cr + "\n")
        if line.startswith("## "):
            body = True
            insec = re.search(r"^## +Next action", line) is not None
            innow = re.search(r"^## +Now", line) is not None
            emit(line)
            if insec:
                emit("- " + o["next"])
                nexts += 1
            continue
        if not body and line.startswith("Updated:"):
            b = o["by"]
            if b == "":
                p = line.find("| By:")
                if p >= 0:
                    b = line[p + 5:]
                b = re.sub(r"^ +", "", b, count=1)
            emit("Updated: " + o["stamp"] + (" | By: " + b if b != "" else ""))
            u += 1
            continue
        if not body and line.startswith("Last change:"):
            emit("Last change: " + o["last"])
            l += 1
            continue
        if not body and line.startswith("Status:") and o["status"] != "":
            emit("Status: " + o["status"])
            continue
        if insec and (re.search(r"^[-*] ", line) or re.search(r"^[ \t]+[^ \t]", line)):
            continue
        waitline = re.search(r"^[-*] +Waiting on:", line) is not None
        if innow and waitline and o["hasw"]:
            emit("- Waiting on: " + o["waiting"])
            w += 1
            continue
        if innow and not waitline and not nw and re.search(r"^[-*] ", line) and o["hasn"]:
            emit("- " + o["now"])
            nw += 1
            continue
        emit(line)
    if not u:
        errs.append("no Updated: line")
    if not l:
        errs.append("no Last change: line")
    if not nexts:
        errs.append("no ## Next action heading")
    if o["hasn"] and not nw:
        errs.append("no phase line (first bullet) under ## Now")
    if o["hasw"] and not w:
        errs.append('no "- Waiting on:" line under ## Now')
    return "".join(out), errs


def board_pass(text, task, row, sets):
    """Step 2: (new handoff.md text, message) or raises Stop."""
    rows = split_lines(text)
    state = 0
    hdr = lastrow = hits = hit = 0
    for i, (line, _) in enumerate(rows, 1):
        if state == 0 and re.search(r"^## +Task chats *$", line):
            state = 1
            continue
        if state == 1 and line.startswith("|"):
            state = 2
            hdr = i
            continue
        if state == 1 and line.startswith("## "):
            state = 0
        if state == 2:
            if not line.startswith("|"):
                state = 3
            else:
                lastrow = i
                if i > hdr + 1:
                    c = cells(line)
                    a1 = c[0] if c else ""
                    if a1 == task or a1.startswith(task + " "):
                        hits += 1
                        hit = i
    if not hdr:
        die('no "## Task chats" table in handoff.md')
    head = cells(rows[hdr - 1][0])
    nh = len(head)
    if not lastrow:
        lastrow = hdr
    L = [r[0] for r in rows]
    addat = 0
    if row != "":
        nr = len(cells(row))
        if nr != nh:
            die("--row has %d cells, the table has %d" % (nr, nh))
        if hits > 1:
            die("%d rows start with %s" % (hits, task))
        if hits == 1:
            L[hit - 1] = row
            msg = "row replaced"
        else:
            addat = lastrow
            msg = "row added"
    else:
        if hits != 1:
            die("%d rows start with %s (need exactly 1)" % (hits, task))
        c = cells(L[hit - 1])
        c += [""] * (nh - len(c))
        changed = 0
        for s in sets:
            p = s.find("=")
            k = trim(s[:p])
            v = trim(s[p + 1:])
            col = 0
            for j in range(nh):
                if lower(head[j]) == lower(k):
                    col = j + 1
            if not col:
                die('no column "%s" in the Task chats table' % k)
            c[col - 1] = v
            changed += 1
        L[hit - 1] = "|" + "".join(" " + c[j] + " |" for j in range(nh))
        msg = "%d cell(s) set" % changed
    out = []
    for i, (line, cr) in enumerate(rows, 1):
        out.append(L[i - 1] + cr + "\n")
        if i == addat:
            out.append(row + cr + "\n")
    return "".join(out), msg


def eod_pass(text, line):
    """Step 3, existing file: the line goes at the end of the Log (above the EOD summary)."""
    rows = split_lines(text)
    sumat = 0
    for i, (l, _) in enumerate(rows, 1):
        if not sumat and re.search(r"^## +EOD summary", l):
            sumat = i
    at = len(rows)
    if sumat:
        at = sumat - 1
        while at > 0 and re.search(r"^[ \t]*$", rows[at - 1][0]):
            at -= 1
    out = []
    for i, (l, cr) in enumerate(rows, 1):
        out.append(l + cr + "\n")
        if i == at:
            out.append(line + cr + "\n")
    if at == 0:
        out.append(line + "\n")
    return "".join(out)


def run(argv):
    o = {"last": "", "next": "", "waiting": "", "status": "", "by": "", "now": "",
         "hasw": False, "hass": False, "hasn": False}
    eod = task = row = ""
    sets = []
    root = "."
    args = [arg_text(a) for a in argv[1:]]
    while args:
        if len(args) < 2:
            die(args[0] + " needs a value")
        k, v = args[0], args[1]
        if k in ("--last", "--next", "--by"):
            o[k[2:]] = v
        elif k == "--now":
            o["now"] = v
            o["hasn"] = True
        elif k == "--waiting":
            o["waiting"] = v
            o["hasw"] = True
        elif k == "--status":
            o["status"] = v
            o["hass"] = True
        elif k == "--eod":
            eod = v
        elif k == "--task":
            task = v
        elif k == "--set":
            if "=" not in v:
                die('--set needs "Column=value"')
            if "|" in v:
                die("a --set value can't contain |")
            sets.append(v)
        elif k == "--row":
            row = v
        elif k == "--root":
            root = v
        else:
            die("unknown option " + k)
        if "\n" in v:
            die(k + ": one line only")
        args = args[2:]
    if o["last"] == "":
        die("--last is required")
    if o["next"] == "":
        die("--next is required")
    if o["hass"] and o["status"] not in ("ACTIVE", "PAUSED", "BLOCKED", "DONE"):
        die("--status must be ACTIVE, PAUSED, BLOCKED or DONE")
    if task != "":
        if not sets and row == "":
            die("--task needs --set or --row")
        if sets and row != "":
            die("use --set or --row, not both")
    elif sets or row != "":
        die("--set and --row need --task")
    if row != "" and not (len(row) >= 2 and row.startswith("|") and row.endswith("|")):
        die("--row must start and end with |")

    sum_ = root + "/ai-handoff-summary.md"
    log = root + "/handoff.md"
    if not os.path.isfile(fs(sum_)):
        die(sum_ + " not found", 2)

    clock = env_text("RECORD_STOP_NOW") or datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %z")
    day, hm, tz = zone(clock)
    o["stamp"] = "%s %s %s" % (day, hm, tz)
    pid = os.getpid()

    # 1. Summary (the checker reads it from the same folder, so relative paths resolve).
    new_sum, errs = summary_pass(read(sum_), o)
    if errs:
        die("ai-handoff-summary.md: %s: rewrite it from the template" % "; ".join(errs))
    tsum = "%s/.record-stop.%d.ai-handoff-summary.md" % (root, pid)

    # 2. Board row in handoff.md
    boardmsg = ""
    tlog = new_log = None
    if task != "":
        if not os.path.isfile(fs(log)):
            die(log + " not found (needed for --task)")
        new_log, msg = board_pass(read(log), task, row, sets)
        tlog = "%s.record-stop.%d" % (log, pid)
        boardmsg = "board %s: %s" % (task, msg)

    # 3. EOD line
    eodmsg = ""
    hta = False
    ef = teod = new_eod = None
    if eod != "":
        if "[verified" not in eod and "[unverified" not in eod and "[reconstructed" not in eod:
            die("--eod needs a [verified: how] or [unverified: source] tag")
        line = "- %s %s" % (hm, eod)
        n = chars(line)
        if n > 160:
            die("EOD line is %d characters (at most 160)" % n)
        ef = "%s/eod/%s.md" % (root, day)
        teod = "%s/.record-stop.%d.eod.md" % (root, pid)
        if os.path.isfile(fs(ef)):
            new_eod = eod_pass(read(ef), line)
            eodmsg = "eod line"
        else:
            first = read(sum_).split("\n", 1)[0]
            project = ""
            m = re.match(r"^# AI handoff summary: *", first)
            if m:
                project = first[m.end():].replace("\r", "")
            if project == "":
                project = arg_text(os.path.basename(os.path.abspath(fs(root))))
            new_eod = "# EOD %s: %s\nTimezone: %s\n\n## Log\n%s\n" % (day, project, tz, line)
            eodmsg = "eod file %s.md created" % day
            if os.path.isfile(fs(root + "/.htaccess")) and not os.path.isfile(fs(root + "/eod/.htaccess")):
                hta = True
                eodmsg += " (+ eod/.htaccess)"

    # 4. Checker on the new summary, then move everything in place.
    write(tsum, new_sum)
    if new_log is not None:
        write(tlog, new_log)
    if new_eod is not None:
        write(teod, new_eod)
    chk, code = cs.check(tsum)
    if code != 0:
        for c in chk:
            if c.startswith("FAIL"):
                say(c)
        die("the new summary fails the checker: fix it (full rewrite), then run again")
    warns = sum(1 for c in chk if c.startswith("WARN"))
    big = ""
    for c in chk:
        m = re.search(r"handoff.md is [0-9]* KB", c)
        if m:
            big = m.group(0)
            break
    if eod != "":
        try:
            os.makedirs(fs(root + "/eod"), exist_ok=True)
        except OSError:
            die("can't create %s/eod" % root)
    try:
        os.replace(fs(tsum), fs(sum_))
    except OSError:
        die("can't write " + sum_)
    if tlog is not None:
        os.replace(fs(tlog), fs(log))
    if eod != "":
        if hta:
            with open(fs(root + "/eod/.htaccess"), "wb") as fh:
                fh.write(b"Require all denied\n")
        os.replace(fs(teod), fs(ef))
    del TMPS[:]
    what = "summary"
    if eodmsg:
        what = eodmsg + ", " + what
    if boardmsg:
        what = what + ", " + boardmsg
    okline = ""
    for c in chk:
        if c.startswith("OK: "):
            okline = c[4:]
    extra = ""
    if warns:
        extra = " (%d WARN)" % warns
    if big:
        extra += "; %s: archive (skill: Very large handoff.md)" % big
    say("OK: stop recorded at %s: %s; checker OK, %s%s" % (hm, what, okline, extra))
    return 0


def main(argv):
    try:
        return run(argv)
    except Stop as e:
        say(str(e))
        return e.code
    finally:
        for t in TMPS:
            try:
                os.remove(fs(t))
            except OSError:
                pass
        sys.stdout.flush()


if __name__ == "__main__":
    sys.exit(main(sys.argv))
