#!/bin/sh
# A coordinator project whose EOD log has three tasks and a summary in an older shape (one-liners, Tomorrow).
d=$(date +%Y-%m-%d)
mkdir -p eod tasks/ABC2-T4
{
  printf '# Handoff: example-shop\n\n## Goal\nWebsite edits for https://shop.example.com (the live site).\n\n'
  printf '## Current State\nABC2-T4 on staging for client review; ABC2-T5 live; ABC2-T6 waits on the lead.\n\n'
  printf '## Task chats\n| Task | Title | Task page | Phase |\n|---|---|---|---|\n'
  printf '| ABC2-T4 | Shop edits | https://pm.example.net/task/4 | IN REVIEW |\n'
  printf '| ABC2-T5 | Footer text | https://pm.example.net/task/5 | DONE |\n'
  printf '| ABC2-T6 | Banner copy | (none yet) | WAITING |\n\n'
  printf '## Active Files\n- tasks/ABC2-T4/notes.md\n\n## Changes Made\n- %s: ABC2-T4 on staging; ABC2-T5 live.\n\n' "$d"
  printf '## Failed Attempts\n- None.\n\n## Next Steps\n- ABC2-T4 live after client approval.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-shop\nUpdated: %s 17:05 UTC+4 | By: Command Center\n' "$d"
  printf 'Last change: ABC2-T4 staging posted for client review\nStatus: ACTIVE\n\n## Now\n- Three tasks\n'
  printf -- '- Waiting on: client review (ABC2-T4), lead (ABC2-T6)\n\n## Next action\n- ABC2-T4 live after approval\n\n'
  printf '## Verified facts\n- ABC2-T5 footer live [verified %s: curl, text found]\n\n' "$d"
  printf '## Key paths\n- handoff.md: full log\n\n## Rules for this project\n- No live changes before my go\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- Tasks: handoff.md > Task chats\n'
} > ai-handoff-summary.md
{
  printf '# Notes ABC2-T4\n- Zoho comment posted for the client with the staging access:\n'
  printf '  access link https://access.staging.example.net/access?t=7f3a9c1e5b2d, site https://shop.staging.example.net/\n'
  printf -- '- Payment test API key (keep private): sk_test_51Hx9PrivateKey\n'
} > tasks/ABC2-T4/notes.md
{
  printf '# EOD %s: example-shop\nTimezone: UTC+4\n\n## Log\n' "$d"
  printf -- '- 09:10 ABC2-T4 Shop edits: plan ready, M [verified: plan.md written]\n'
  printf -- '- 11:30 ABC2-T4 Shop edits: backup taken, local copy built, all 5 items done [verified: local QA list 5/5]\n'
  printf -- '- 13:05 ABC2-T5 Footer text: new footer text live [verified: curl, text found on 3 pages]\n'
  printf -- '- 14:20 ABC2-T4 Shop edits: QA found 3 small issues, all fixed on staging [verified: QA re-check]\n'
  printf -- '- 15:00 ABC2-T6 Banner copy: waiting on the lead to choose banner text A or B [verified: question in chat]\n'
  printf -- '- 16:40 ABC2-T4 Shop edits: staging link posted in Zoho for client review [verified: comment read back]\n'
  printf '\n## EOD summary (written 17:00)\nEOD %s: example-shop\n' "$d"
  printf -- '- [ABC2-T4](https://pm.example.net/task/4) Shop edits: WAITING. On staging.\n'
  printf -- '- [ABC2-T5](https://pm.example.net/task/5) Footer text: DONE. Live.\n'
  printf -- '- ABC2-T6 Banner copy: WAITING. Text A or B.\nNext: ABC2-T4 live after approval.\n'
  printf 'Tomorrow\n* Go live after approval\n'
} > "eod/$d.md"
sed -n '/^## Log/,/^## EOD summary/p' "eod/$d.md" | sed '$d' > .eod-log-before
