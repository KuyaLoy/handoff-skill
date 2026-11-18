#!/bin/sh
# A project with valid handoff files and today's EOD log (three Log lines, no summary yet).
d=$(date +%Y-%m-%d)
mkdir -p src eod
printf 'body { color: #222; }\n' > src/style.css
{
  printf '# Handoff: example-site\n\n## Goal\nFix example.com.\n\n## Current State\nMetadata live; form blocked.\n\n'
  printf '## Active Files\n- src/style.css\n\n## Changes Made\n- %s: 12 page titles and descriptions live.\n\n' "$d"
  printf '## Failed Attempts\n- None.\n\n## Next Steps\n- Form fix when the SMTP login arrives.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: %s 11:10 UTC+4 | By: an earlier chat\n' "$d"
  printf 'Last change: form fix blocked\nStatus: BLOCKED\n\n## Now\n- Form fix\n- Waiting on: client SMTP login\n\n'
  printf '## Next action\n- Fix the form when the SMTP login arrives\n\n## Verified facts\n'
  printf -- '- 12 titles live [verified %s: curl 12/12]\n\n' "$d"
  printf '## Key paths\n- src/style.css: all styles\n\n## Rules for this project\n- No live changes before my go\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- History: handoff.md > Changes Made\n'
} > ai-handoff-summary.md
{
  printf '# EOD %s: example-site\nTimezone: UTC+4\n\n## Log\n' "$d"
  printf -- '- 09:12 ABC1-T8 Metadata: plan ready, M [verified: plan.md written]\n'
  printf -- '- 10:40 ABC1-T8 Metadata: 12 titles and descriptions live [verified: curl 12/12]\n'
  printf -- '- 11:05 ABC1-T9 Form fix: blocked, client SMTP login needed [verified: SMTP auth error in the mail log]\n'
} > "eod/$d.md"
cp "eod/$d.md" .eod-log-before
