#!/bin/sh
# A project whose summary breaks the limits: 3 Next actions, 14 facts (one untagged), a missing path.
mkdir -p src
printf '<footer><nav aria-label="Main footer"></nav></footer>\n' > src/footer.php
{
  printf '# Handoff: example-site\n\n## Goal\nTheme for example.com.\n\n## Current State\nFooter work in progress.\n\n'
  printf '## Active Files\n- src/footer.php\n\n## Changes Made\n- 2026-11-10: footer markup added.\n\n'
  printf '## Failed Attempts\n- 2026-11-10: a footer widget area clashed with the page builder; not used.\n\n'
  printf '## Next Steps\n- Rename the footer menu.\n- Style the footer.\n- Check mobile.\n\n## Facts\n'
  i=1
  while [ $i -le 14 ]; do printf -- '- Fact %s about the site, checked with ls on 2026-11-10.\n' $i; i=$((i + 1)); done
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: 2026-11-10 09:00 UTC | By: an earlier chat\n'
  printf 'Last change: footer markup added\nStatus: ACTIVE\n\n## Now\n- Footer work\n- Waiting on: nothing\n\n'
  printf '## Next action\n- Rename the footer menu\n- Style the footer\n- Check mobile\n\n## Verified facts\n'
  i=1
  while [ $i -le 13 ]; do printf -- '- Fact %s about the site [verified 2026-11-10: ls]\n' $i; i=$((i + 1)); done
  printf -- '- Fact 14 about the site\n\n## Key paths\n- src/footer.php: footer\n- src/old-header.php: header\n\n'
  printf '## Rules for this project\n- No live changes before the user says go\n\n## Open questions\n- None\n\n'
  printf '## Where to look in handoff.md\n- History: handoff.md > Changes Made\n'
} > ai-handoff-summary.md
