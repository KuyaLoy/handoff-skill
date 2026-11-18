# Daily EOD log

Read this file when you write an EOD line or the user asks for an EOD (end-of-day report). One small file per day
answers "EOD" without reading old chats, and the lines are written when things happen, so nothing is recalled later.

## The file

`eod/YYYY-MM-DD.md` at the project root, next to handoff.md, one file per day (the user's local date). It gets the same
protection as the handoff files (`setup.md`).

```markdown
# EOD 2026-11-18: example.com
Timezone: UTC+4

## Log
- 09:12 ABC1-T8 Metadata: plan ready, M [verified: plan.md written]
- 10:40 ABC1-T8 Metadata: 12 titles and descriptions live [verified: curl 12/12]
- 11:05 ABC1-T9 Form fix: blocked, client SMTP login needed [verified: SMTP auth error in the mail log]

## EOD summary (written 17:55)
EOD: 18 Nov 2026 | ABC1-T8 Metadata: in review
Done today

* New page titles and descriptions written for 12 pages and put live
* All 12 pages checked on the live site

Links

* Live site: https://example.com
* Task: https://pm.example.net/8

EOD: 18 Nov 2026 | ABC1-T9 Form fix: blocked, needs the client's email login
Done today

* Found why the contact form fails: the client's email (SMTP) login is needed

Links

* Live site: https://example.com
* Task: https://pm.example.net/9

Remaining

* Fix and test the form once the client sends the email login
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

- **"EOD" or "EOD for today":** read today's file only. Write the `## EOD summary (written HH:MM)` block at its end.
  Reply with that block, exactly as in the file, in one code block, ready to paste.
- **Same question, same answer:** if the file already has a summary and no Log line is newer than it, reply with that
  summary word for word. If new lines came after it, or it is not in the shape below, replace the block (one summary
  per file) with a new time.
- **"EOD for <date>"** (e.g. "EOD for 15 Nov"): read that day's file only and answer the same way. If it has no
  summary yet, write one into it first.
- **No file for that day:** say so in one line. Offer a rebuild from dated entries in handoff.md, task notes and the
  git log of that day. Write nothing until the user says yes. A rebuilt file has the line
  `Reconstructed: <date and time of the rebuild>, from <sources>` under the header, and every Log line ends with
  `[reconstructed: <source>]`. Items with no time in the source get `--:--`. Never fill gaps from memory.
- **A chat that doesn't own the root files** answers only by reading the file; if it is missing, it says so and names
  the owner chat.
- **Other ranges** ("EOD for this week"): read each day's file and join their summaries, one heading per day.

## The EOD summary

The lead pastes the EOD of every project into one chat that writes the full daily report, so every project uses this
shape, also when another skill asks for it. One block per task worked on that day, a blank line between blocks:
```
EOD: <d Mon YYYY> | <TASK-ID> <task title>: <state in plain words>
Done today

* <what was done today, in words the client can read>

Links

* Live site: <URL>
* Task: <task page URL>

Staging

* Access link (open first): <staging access link>
* Site: <staging site URL>

Remaining

* <work still left, or what we wait for from the client>
```
- **State**, from the task's latest Log line, in plain words: "done" (nothing left), "in review" (our work is
  finished and waits on a reviewer or the client; add the stage when the log names it, e.g. "in review (Development
  Review)"), "waiting on <who>", "blocked, <why>", "in progress" (a share such as "around 90% done" only when the log
  or notes say it), "paused". Finished work that waits on a review is never "waiting".
- **Done today:** from that day's Log lines only, one bullet per result. Plain words, no methods, tools, file names,
  times or verification tags. Nothing that isn't in the log.
- **Links and Staging:** only links found in the files (the handoff.md board, Goal or rules; the task's brief, notes
  or report) or in the posted task comment; never guessed. Leave out a line, or a whole section, with nothing to show.
  Staging: the access link first, then the site.
- **The staging access link** (a magic link) is the one token allowed, because the lead needs it: only one already
  shared with the client in the task comment, and only in this summary (never in Log lines, handoff.md or
  ai-handoff-summary.md). If `eod/` is committed to git, write "Access link: in the task comment" instead. Never
  passwords, API keys, admin login links or any other token.
- **Remaining:** only when work is really left, or the client owes us something other than the review. A task that
  only waits on its review has no Remaining.
- No Tomorrow section and no Next line. Plain text, `* ` bullets and bare URLs, so it pastes cleanly: no bold, tables,
  emoji or Markdown links.
