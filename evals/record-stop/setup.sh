#!/bin/sh
# A coordinator project (one chat per task) with valid handoff files and a board; a task just reported PLAN READY.
mkdir -p tasks/ABC1-T8
printf '# Plan ABC1-T8\n- Update 12 page titles.\n' > tasks/ABC1-T8/plan.md
{
  printf '# Handoff: example-agency\n\n## Goal\nRun client tasks, one chat per task.\n\n'
  printf '## Current State\nABC1-T8 planning.\n\n## Active Files\n- tasks/ABC1-T8/plan.md\n\n'
  printf '## Changes Made\n- 2026-11-18 08:30: ABC1-T8 started.\n\n## Failed Attempts\n- None.\n\n'
  printf '## Next Steps\n- Wait for the ABC1-T8 plan.\n\n## Task chats\n'
  printf '| Task | Source / status | Chat | Size | Phase | Waiting on | Plan / notes |\n|---|---|---|---|---|---|---|\n'
  printf '| ABC1-T8 Metadata | Zoho: Ready | abc1-t8 | M | PLANNING | task chat | tasks/ABC1-T8/plan.md |\n'
} > handoff.md
{
  printf '# AI handoff summary: example-agency\nUpdated: 2026-11-18 08:30 UTC+4 | By: coordinator\n'
  printf 'Last change: ABC1-T8 started\nStatus: ACTIVE\n\n## Now\n- ABC1-T8 planning\n- Waiting on: task chat\n\n'
  printf '## Next action\n- Read the ABC1-T8 plan when it is ready\n\n## Verified facts\n'
  printf -- '- ABC1-T8 chat started [verified 2026-11-18: session list]\n\n'
  printf '## Key paths\n- tasks/ABC1-T8/plan.md: the plan\n\n## Rules for this project\n'
  printf -- '- This chat owns the root files and eod/; task chats log in tasks/<ID>/notes.md\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- Board: handoff.md > Task chats\n'
} > ai-handoff-summary.md
cp ai-handoff-summary.md .summary-before
