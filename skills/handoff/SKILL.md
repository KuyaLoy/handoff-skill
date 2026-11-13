---
name: "handoff"
description: "Use whenever you work in any project folder or codebase (start, end, after big changes, before a compact or reset): create handoff.md and ai-handoff-summary.md if missing, keep both updated."
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
- **Pick a safe location:** use the project root, and keep the files off the web and out of deploys (see "Web roots,
  deploys and git" below). Say in handoff.md where they are if they are not at the root.
- **Tell the user in one line** that you created them and where. Don't paste their content into the chat.
- **One pair per project:** if several unrelated clients or projects share a parent folder, each project gets its own pair. Never mix two clients in one handoff.
- **Size it to the work:** a task that just started gets a few lines per section. Don't pad, don't copy logs.

## Web roots, deploys and git

- **Web root** (a web server serves the project folder, local or live): keep the files at the root and block them.
  Apache 2.4: put this block in the root `.htaccess`, outside `# BEGIN WordPress` and any other generated block:
  ```apache
  # BEGIN handoff files (keeps the project notes off the web)
  <FilesMatch "^(handoff|ai-handoff-summary)\.md$">
      Require all denied
  </FilesMatch>
  # END handoff files
  ```
  Then check: the file's URL gives 403 (`curl -I`) and the home page still loads. Other servers: the same rule in
  their config. On a live server, or when that `.htaccess` gets deployed, ask the user first. If you can't block them,
  move the pair one level up into a folder of its own for this project.
- **Deployed folders** (a theme or plugin folder, a static build, a zip): check the deploy script or ignore list and
  make sure both files stay out.
- **Git repo:** ask the user once whether the two files are committed or stay local (local: list them in
  `.git/info/exclude`). Record the answer under the project rules in handoff.md.

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
- Never write secrets (passwords, licence keys, tokens, API keys) in either file. Write where a secret lives
  (e.g. "in wp-config.php", "in the password manager"), never its value. Check your new lines before saving.

## Updating (automatic, no reminder needed)

After every significant change and before ending every session:
1. Update `handoff.md`: all six sections true to the current state; new entries under Changes Made and Failed Attempts are dated.
2. Rewrite `ai-handoff-summary.md` from it with the template below. Refresh the Updated and Last change lines. Keep exactly one Next action.
3. Check the summary: at most 60 lines, 12 facts and 10 paths; exactly one Next action; no line over 160 characters;
   every fact tagged; every path exists; the status matches handoff.md. Fix it before you finish.
4. Tell the user in one line that both files are updated. Don't paste their content into the chat.

**One writer.** When a coordinator chat owns the root files (for example a Command Center that runs one chat per task),
the other chats don't edit them: they log in their own task folder (e.g. `tasks/<ID>/notes.md`) and the coordinator
merges. Same files, same template in every project, also when another skill or workflow creates them. Extra sections
(e.g. Project rules, Task chats) and numbered headings are fine; the six handoff.md sections stay.

## Before a compact, reset or switch to another AI

When the user is about to compact, clear or reset the chat, or move the work to another AI or tool:
1. Update both files as above.
2. Give the user a resume prompt in one code block, short enough to paste anywhere and written for any AI tool:
   ```
   Continue <project> in <path>. Read ai-handoff-summary.md first; open handoff.md only for history.
   Next action: <one step>. Rules: <the hard rules, e.g. no live changes before my go>.
   ```
   No secrets, and nothing the files don't back up.

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