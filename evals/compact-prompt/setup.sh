#!/bin/sh
# A project with valid handoff files; the user is about to compact the chat.
mkdir -p src
printf 'body { color: #222; }\n' > src/style.css
{
  printf '# Handoff: example-site\n\n## Goal\nRestyle example.com.\n\n## Current State\nColours done.\n\n'
  printf '## Active Files\n- src/style.css\n\n## Changes Made\n- 2026-11-16: text colour set.\n\n'
  printf '## Failed Attempts\n- None.\n\n## Next Steps\n- Set the link colour in src/style.css.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: 2026-11-16 09:00 UTC | By: an earlier chat\n'
  printf 'Last change: text colour set\nStatus: ACTIVE\n\n## Now\n- Restyle\n- Waiting on: nothing\n\n'
  printf '## Next action\n- Set the link colour in src/style.css\n\n## Verified facts\n'
  printf -- '- Text colour is #222 [verified 2026-11-16: read src/style.css]\n\n'
  printf '## Key paths\n- src/style.css: all styles\n\n## Rules for this project\n- No live changes before my go\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- History: handoff.md > Changes Made\n'
} > ai-handoff-summary.md
