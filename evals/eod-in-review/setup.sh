#!/bin/sh
# One task finished and in review on staging; the client has the staging access link from the task comment.
d=$(date +%Y-%m-%d)
mkdir -p eod tasks/ABC3-T2
{
  printf '# Handoff: example-clinic\n\n## Goal\nNew pages for https://clinic.example.com (the live site).\n\n'
  printf '## Current State\nABC3-T2 on staging, in Development Review.\n\n'
  printf '## Task chats\n| Task | Title | Task page | Phase |\n|---|---|---|---|\n'
  printf '| ABC3-T2 | Service pages | https://pm.example.net/task/32 | IN REVIEW |\n\n'
  printf '## Active Files\n- tasks/ABC3-T2/report.md\n\n## Changes Made\n- %s: ABC3-T2 on staging.\n\n' "$d"
  printf '## Failed Attempts\n- None.\n\n## Next Steps\n- ABC3-T2 live after the review.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-clinic\nUpdated: %s 16:30 UTC+4 | By: Command Center\n' "$d"
  printf 'Last change: ABC3-T2 sent for review\nStatus: ACTIVE\n\n## Now\n- ABC3-T2 in review\n'
  printf -- '- Waiting on: Development Review\n\n## Next action\n- ABC3-T2 live after the review\n\n'
  printf '## Verified facts\n- Staging forms send mail [verified %s: test emails received]\n\n' "$d"
  printf '## Key paths\n- handoff.md: full log\n\n## Rules for this project\n- No live changes before my go\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- Tasks: handoff.md > Task chats\n'
} > ai-handoff-summary.md
{
  printf '# Report ABC3-T2\n- Zoho comment posted with the staging access for the client:\n'
  printf '  access link https://access.staging.example.net/access?t=c0ffee42aa, site https://clinic.staging.example.net/\n'
} > tasks/ABC3-T2/report.md
{
  printf '# EOD %s: example-clinic\nTimezone: UTC+4\n\n## Log\n' "$d"
  printf -- '- 10:15 ABC3-T2 Service pages: Ultrasound and X-ray pages built, design check passed [verified: QA list]\n'
  printf -- '- 13:40 ABC3-T2 Service pages: staging set up, all forms tested, emails received [verified: inbox]\n'
  printf -- '- 15:10 ABC3-T2 Service pages: Zoho comment posted with staging access [verified: comment read back]\n'
  printf -- '- 16:25 ABC3-T2 Service pages: Request Review done, now Development Review [verified: Zoho status]\n'
} > "eod/$d.md"
cp "eod/$d.md" .eod-log-before
