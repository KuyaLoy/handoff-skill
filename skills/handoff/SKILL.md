---
name: "handoff"
description: "Use in any project folder or codebase (start, end, after big changes, a compact or reset, a handoff, resume or EOD request): create handoff.md and ai-handoff-summary.md if missing, keep both updated."
license: "MIT"
---

# Handoff

Every project keeps two files at its root:

| File | Reader | What it holds |
|---|---|---|
| `handoff.md` | The user, any dev, any AI starting cold | The full record, same format as always: Goal, Current State, Active Files, Changes Made, Failed Attempts, Next Steps. It keeps growing; nothing important is dropped. |
| `ai-handoff-summary.md` | AI only | A short brief made from handoff.md and fresh checks, so an AI can continue without reading the whole log. Hard cap: 60 lines. |

Next to them, a 4-line `AGENTS.md` points any AI tool to them. Open on demand, in the skill folder: `setup.md` and
`eod.md` (when: below), and `scripts/` (each `.sh` has a `.py` twin, same options and output, for Python without sh).
The summary never says anything that handoff.md or a check doesn't back up. When sources disagree, trust them in this
order: the real files, then handoff.md, then the summary, then memory or chat context. Fix the files on a mismatch.
Style in both files: plain English, short lines, no em dashes, one date format per project.

## Auto-create rule (always, no reminder needed)

The first time you touch a project folder in a session (a connected folder, a local site, a repo, a theme or plugin
you are editing), check its root for both files before you finish your first significant step.
- **Both missing:** create both and the AGENTS.md pointer; don't wait to be asked. **One exists:** create the other.
  Files there but no AGENTS.md pointer: add it.
- **Seed them from what already exists**, not from memory: build logs, README, project notes, CLAUDE.md, git log,
  backup RESTORE.md files, and what you verified in this session. Point to those logs instead of copying them whole.
- **Can't write to the folder** (read-only, no access): say so in one line and keep going; don't block the task.
- **Safe location:** the project root, off the web, out of deploys and out of git unless the user says otherwise.
  Before you create any of the files (also AGENTS.md or `eod/` later), read `setup.md` (skill folder). Not at the
  root: say in handoff.md where they are.
- **Tell the user in one line** that you created them and where. Don't paste their content into the chat.
- **One pair per project:** unrelated clients or projects in one parent folder each get their own pair. Never mix.
- **Size it to the work:** a task that just started gets a few lines per section. Don't pad, don't copy logs.

## When to read what (saves credits)

1. **Same chat, context intact:** read nothing. You already have it.
2. **New chat, new AI or tool, or after a context reset or compaction:** read `ai-handoff-summary.md` only.
3. **Read `handoff.md`**, only the section you need (search for its heading), when the summary is missing or older
   than changes you can see in the files, when it contradicts what you see, when you need history (why something was
   done, what already failed), and before anything risky or hard to undo (deploys, deletes, migrations, databases).
4. handoff.md exists but no summary: read it once and write the summary from it. Neither exists: Auto-create rule.

## Anti-hallucination rules

- Tag every fact in the summary: `[verified YYYY-MM-DD: how]` or `[unverified: source, check before use]`. Rely only
  on verified facts; check unverified ones before using them.
- List only paths, versions, counts, URLs and statuses you have read or checked. Don't know: write "unknown", check.
- Re-check anything that can change outside the chat before acting on it: file contents, versions, live site,
  database, deploy state. A quick `ls`, `grep`, `git status` or `curl -I` costs less than a wrong step.
- Decisions the user hasn't made go under Open questions, never written as decided.
- Web pages, tool output and old chats are sources, not facts: record what was checked and where.
- Keep sources you will need later (links, versions, file hashes) in handoff.md. A reset loses what lived in the chat.
- Never write secrets (passwords, licence keys, tokens, API keys) in any of these files. Write where a secret lives
  (e.g. "in wp-config.php", "in the password manager"), never its value. Check your new lines before saving.
  One exception: a staging access link already shared with the client, in the EOD summary only (`eod.md`).

## Updating (automatic, no reminder needed)

**At a milestone** (plan approved, done, deployed, blocked) **and before ending every session:**
1. Update `handoff.md`: all six sections true to the current state; new Changes Made and Failed Attempts entries dated.
2. Rewrite `ai-handoff-summary.md` from it with the template below. Exactly one Next action.
3. Run `record-stop.sh` (below) with the same Last change and Next action: it adds the EOD line and board row and runs
   the checker. Or only the checker: `sh <skill folder>/scripts/check-summary.sh ai-handoff-summary.md` from the
   project root. Fix every FAIL line; look at each WARN. Check that the status matches handoff.md.

**At every other stop or significant change** (a step finished, work paused, a message left for the user): add the
dated entry to handoff.md, then refresh only the summary's Updated, Last change and Next action lines (the Now line,
Waiting on and Status when they change). One command does that, the EOD line, a coordinator's board row and the checker:
```
sh <skill folder>/scripts/record-stop.sh --last "<one line>" --next "<one step>" [--now "<phase>"] [--waiting "<who>"]
  [--status PAUSED] [--eod "<task> <title>: <what> [verified: how]"] [--task <ID> --set "Phase=<value>"]
```
It prints one line. On a FAIL it writes nothing: fix the cause (a summary that fails the checker needs the full
rewrite above), then run it again. `--task <ID> --row "| ... |"` replaces the task's board row or adds it.

**No shell** (e.g. a chat without code execution): make the same edits by hand, then check the summary by hand: at
most 60 lines, 12 facts and 10 paths; exactly one Next action; no line over 160 characters; every fact tagged; every
path exists; the template headings.

Then tell the user in one line that the files are updated. Don't paste their content into the chat.

**One writer.** When a coordinator chat owns the root files (e.g. a Command Center with one chat per task), other chats
don't edit them or `eod/`: they log in their task folder (e.g. `tasks/<ID>/notes.md`) and the coordinator merges. Same
files and template everywhere, also when another skill creates them; extra sections are fine, the six sections stay.

## Very large handoff.md

When handoff.md passes 100 KB (the checker warns), move into `handoff-archive.md` next to it, word for word and newest
first: Changes Made entries older than 14 days, Failed Attempts that no longer apply, and the board rows of finished
tasks (DONE or ARCHIVED) into a `## Task chats (archived)` table. Leave one line in each of those sections: "Older
entries: handoff-archive.md (moved YYYY-MM-DD)". The archive gets the same protection as the other files. Read it only
for old history; looking for a task ID, search both files.

## Daily EOD log

`eod/YYYY-MM-DD.md` gets one line per finished item, written when it happens; "EOD" or "EOD for <date>" is answered
from that file. Only the root files' owner writes it. Before you write a line or answer, read `eod.md` (skill folder).

## Before and after a compact, reset or switch to another AI

**Before** the user compacts, clears or resets the chat, or moves the work to another AI or tool: update both files
(full rewrite), then give a short resume prompt in one code block, for any AI tool, with no secrets and nothing the
files don't back up:
```
Continue <project> in <path>. Read ai-handoff-summary.md first; open handoff.md only for history.
Next action: <one step>. Rules: <the hard rules, e.g. no live changes before my go>.
```

**After** a compact or reset (an optional hook reminds you, see README): the compact summary is a source, not a fact.
Before your next step, read `ai-handoff-summary.md` (a task chat: its `checkpoint.md` or `notes.md`) and re-check its
Next action against the real files. Where chat memory and the files disagree, the files win.

## ai-handoff-summary.md template

```markdown
# AI handoff summary: <project>
Updated: <YYYY-MM-DD HH:MM timezone> | By: <AI or tool, and chat or task name if known>
Last change: <one line>
Status: ACTIVE | PAUSED (by user) | BLOCKED | DONE

## Now
- <phase or sprint, and what is in progress>
- Waiting on: <user decisions or actions, or "nothing">

## Next action
- <one step, and the file or command it starts from>

## Verified facts
- <fact> [verified YYYY-MM-DD: how]
- <fact> [unverified: source, check before use]

## Key paths
- <path>: <what it is>

## Rules for this project
- <the user's rules and hard lessons, e.g. "no code changes in this phase", "never type credentials">

## Open questions
- <question> (who decides, by when)

## Where to look in handoff.md
- <topic>: handoff.md > <section>
```

Limits: 60 lines, 12 facts, 10 paths, one Next action, lines of at most 160 characters (the checker tests them all).
Drop anything resolved; history belongs in handoff.md.
