#!/bin/sh
# A project with handoff files and an EOD log for 16 Nov, but none for 15 Nov.
mkdir -p src eod tasks/ABC1-T7
printf 'body { color: #222; }\n' > src/style.css
{
  printf '# Handoff: example-site\n\n## Goal\nFix example.com.\n\n## Current State\nRedirects live.\n\n'
  printf '## Active Files\n- src/style.css\n\n## Changes Made\n'
  printf -- '- 2026-11-16: link colour set in src/style.css.\n'
  printf -- '- 2026-11-15: 30 redirects added and checked (curl 30/30), task ABC1-T7.\n'
  printf -- '- 2026-11-14: project started.\n\n'
  printf '## Failed Attempts\n- 2026-11-15: redirect plugin import failed (CSV encoding); done by hand instead.\n\n'
  printf '## Next Steps\n- Footer menu.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: 2026-11-16 17:00 UTC+4 | By: an earlier chat\n'
  printf 'Last change: link colour set\nStatus: ACTIVE\n\n## Now\n- Restyle\n- Waiting on: nothing\n\n'
  printf '## Next action\n- Footer menu in src/style.css\n\n## Verified facts\n'
  printf -- '- Link colour set [verified 2026-11-16: read src/style.css]\n\n'
  printf '## Key paths\n- src/style.css: all styles\n\n## Rules for this project\n- No live changes before my go\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- History: handoff.md > Changes Made\n'
} > ai-handoff-summary.md
printf '# Notes: ABC1-T7 Redirects\n\n## 2026-11-15\n- 14:20 30 redirects added; curl 30/30 return 301.\n' \
  > tasks/ABC1-T7/notes.md
{
  printf '# EOD 2026-11-16: example-site\nTimezone: UTC+4\n\n## Log\n'
  printf -- '- 16:50 Restyle: link colour set [verified: read src/style.css]\n'
} > eod/2026-11-16.md
