# Daily EOD log

Read this file when you write an EOD line or the user asks for an EOD (end-of-day report). One small file per day
answers "EOD" without reading old chats, and the lines are written when things happen, so nothing is recalled later.

## The file

`eod/YYYY-MM-DD.md` at the project root, next to handoff.md, one file per day (the user's local date). It gets the same
protection as the handoff files (SKILL.md, "Web roots, deploys and git").

```markdown
# EOD 2026-11-18: example.com
Timezone: UTC+4

## Log
- 09:12 ABC1-T8 Metadata: plan ready, M [verified: plan.md written]
- 10:40 ABC1-T8 Metadata: 12 titles and descriptions live [verified: curl 12/12]
- 11:05 ABC1-T9 Form fix: blocked, client SMTP login needed [verified: SMTP auth error in the mail log]

## EOD summary (written 17:55)
- ABC1-T8 Metadata: DONE. 12 pages live and checked. In review.
- ABC1-T9 Form fix: BLOCKED on the client's SMTP login. Asked in Zoho.
Next: ABC1-T9 when the login arrives.
```

## Writing the log

- **Who writes:** only the chat that owns the root handoff files (in a Command Center project, Command Center: one line
  for each stop it reports). Other chats log in their own task notes; the owner adds the line.
- **When:** at the moment an item finishes or work stops: plan ready, done, deployed, blocked, paused, a comment posted
  or a message sent for the user. Part of Updating step 1. Not for every small edit.
- **Line:** `- HH:MM <task ID or short name> <short title>: <what happened> [verified: how]`. Use
  `[unverified: source]` when it was not checked. A blocked or waiting line names who it waits on. At most 160
  characters. Time in the header's timezone.
- **Timezone:** the user's, as a numeric offset (from `date +%z`: +0400 is UTC+4), never read from a zone
  abbreviation (AST, CST and IST each mean more than one zone).
- **Append only.** New lines go at the end of `## Log` (above the summary, if there is one). Never edit or delete an
  earlier line; a correction is a new line ("correction: ...").
- First line of the day: create the file with the header. Work past midnight goes in the new day's file.
- Same rules as the summary: no secrets, no guesses, only what was done and checked.

## Answering "EOD"

- **"EOD" or "EOD for today":** read today's file only. Write the `## EOD summary (written HH:MM)` block at its end:
  one line per task or item in the log (`<task> <title>: <STATUS>. <what was done>.`, STATUS = DONE, IN REVIEW,
  IN PROGRESS, WAITING, BLOCKED or PAUSED, from the item's latest log line), then one `Next:` line. Reply with that
  block, exactly as in the file, in one code block, ready to paste. Nothing in the summary that is not in the log.
- **Same question, same answer:** if the file already has a summary and no Log line is newer than it, reply with that
  summary word for word. If new lines came after it, replace the block (one summary per file) with a new time.
- **"EOD for <date>"** (e.g. "EOD for 15 Nov"): read that day's file only and answer the same way. If it has no
  summary yet, write one into it first.
- **No file for that day:** say so in one line. Offer a rebuild from dated entries in handoff.md, task notes and the
  git log of that day. Write nothing until the user says yes. A rebuilt file has the line
  `Reconstructed: <date and time of the rebuild>, from <sources>` under the header, and every Log line ends with
  `[reconstructed: <source>]`. Items with no time in the source get `--:--`. Never fill gaps from memory.
- **A chat that doesn't own the root files** answers only by reading the file; if it is missing, it says so and names
  the owner chat.
- **Other ranges** ("EOD for this week"): read each day's file and join their summaries, one heading per day.
