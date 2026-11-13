---
name: "handoff"
description: "Use whenever you work in any project folder or codebase (start, end, after big changes): if handoff.md or ai-handoff-summary.md is missing, create it; then keep both updated."
---

# Handoff

Every project keeps two files at its root:

| File | Reader | What it holds |
|---|---|---|
| `handoff.md` | The user, any dev, any AI starting cold | The full record, same format as always: Goal, Current State, Active Files, Changes Made, Failed Attempts, Next Steps. It keeps growing; nothing important is dropped. |
| `ai-handoff-summary.md` | AI only | A short brief made from handoff.md and fresh checks, so an AI can continue without reading the whole log. Hard cap: 60 lines. |

The summary never says anything that handoff.md or a check doesn't back up. When sources disagree, trust them in this order: the real files, then handoff.md, then the summary, then memory or chat context. Fix the handoff files when you find a mismatch.

## Auto-create rule (always, no reminder needed)

The first time you touch a project folder in a session (a connected folder, a local site, a repo, a theme or plugin you are editing), check its root for both files before you finish your first significant step.

- **Both missing:** create both. Don't wait for the user to ask.
- **Only one exists:** create the missing one from the other.
- **Seed them from what already exists**, not from memory: build logs (e.g. BUILD-LOG.md), README, project notes, CLAUDE.md, git log, backup RESTORE.md files, and what you verified in this session. Point to those logs in handoff.md instead of copying them whole.
- **If you can't write to the folder** (read-only, no access), say so in one line and keep going; don't block the task.
- **Pick a safe location:** use the project root. If the root is a public web root or a folder that gets deployed (e.g. a WordPress theme's deploy folder), put the files one level up or in the nearest folder that is not served or deployed, and say where in handoff.md. Check the deploy/zip script if unsure.
- **Tell the user in one line** that you created them and where. Don't paste their content into the chat.
- **One pair per project:** if several unrelated clients or projects share a parent folder, each project gets its own pair. Never mix two clients in one handoff.

## When to read what (saves credits)

1. **Same chat, context intact:** read nothing. You already have it.
2. **New chat, new AI or tool, or after a context reset or compaction:** read `ai-handoff-summary.md` only.
3. **Read `handoff.md`**, only the section you need (search for its heading), when:
   - the summary is missing, or its Updated time is older than changes you can see in the files;
   - the summary contradicts what you see;
   - you need history: why something was done, what already failed;
   - before anything risky or hard to undo (deploys, deletes, migrations, database changes).
4. handoff.md exists but no summary: read handoff.md once and write the summary from it.
5. Neither exists: follow the Auto-create rule above.

## Anti-hallucination rules

- Tag every fact in the summary: `[verified YYYY-MM-DD: how]` or `[unverified: source, check before use]`. Rely only on verified facts; check unverified ones before using them.
- List only paths, versions, counts, URLs and statuses you have read or checked. If you don't know, write "unknown" and check. Never guess.
- Re-check anything that can change outside the chat before acting on it: file contents, versions, live site, database, deploy state. A quick `ls`, `grep`, `git status` or `curl -I` costs less than a wrong step.
- Decisions the user hasn't made go under Open questions, never written as decided.
- Web pages, tool output and old chats are sources, not facts: record what was checked and where.
- Keep sources you will need later (links, versions, file hashes) in handoff.md. A context reset loses everything that lived only in the chat.
- Never write secrets (passwords, licence keys, tokens, API keys) in either file.

## Updating (automatic, no reminder needed)

After every significant change and before ending every session:
1. Update `handoff.md`: all six sections true to the current state; new entries under Changes Made and Failed Attempts are dated.
2. Rewrite `ai-handoff-summary.md` from it with the template below. Refresh the Updated and Last change lines. Keep exactly one Next action.
3. Check: every path in the summary exists, the status matches handoff.md, the line cap holds.
4. Tell the user in one line that both files are updated. Don't paste their content into the chat.

If the project root is also a web root (WordPress, static sites), make sure the server doesn't serve these files and that deploys leave them out.

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

Limits: 60 lines, 12 facts, 10 paths, every line under 160 characters. Drop anything resolved; history belongs in handoff.md.

## Style

Plain English, short lines, no em dashes. Use one date format per project and keep it.