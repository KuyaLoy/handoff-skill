#!/bin/sh
# A local WordPress-style web root with handoff files from an older version: an .htaccess block without AGENTS,
# and a repo AGENTS.md of its own (tracked in git). No pointer lines yet.
git init -q . && git config user.email test@example.com && git config user.name test
printf '# AGENTS.md\n\nBuild with `npm run build`. Code style: 2 spaces.\n' > AGENTS.md
printf '<?php echo "home";\n' > index.php
{
  printf '# BEGIN handoff files (keeps the project notes off the web)\n'
  printf '<FilesMatch "^(handoff|handoff-archive|ai-handoff-summary)\.md$">\n    Require all denied\n</FilesMatch>\n'
  printf '# END handoff files\n\n# BEGIN WordPress\nRewriteEngine On\n# END WordPress\n'
} > .htaccess
git add AGENTS.md index.php .htaccess && git commit -qm init
{
  printf '# Handoff: example-site\n\n## Project rules\n- Handoff files stay local (git exclude), decided 2026-11-10.\n\n'
  printf '## Goal\nTheme fixes.\n\n## Current State\nIdle.\n\n## Active Files\n- index.php\n\n'
  printf '## Changes Made\n- 2026-11-10: handoff files created.\n\n## Failed Attempts\n- None.\n\n## Next Steps\n- Footer fix.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: 2026-11-10 10:00 UTC+4 | By: an earlier chat\n'
  printf 'Last change: handoff files created\nStatus: ACTIVE\n\n## Now\n- Idle\n- Waiting on: nothing\n\n'
  printf '## Next action\n- Fix the footer in index.php\n\n## Verified facts\n- Home page loads [verified 2026-11-10: curl]\n\n'
  printf '## Key paths\n- index.php: theme entry\n\n## Rules for this project\n- Handoff files stay local\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- Rules: handoff.md > Project rules\n'
} > ai-handoff-summary.md
printf 'handoff.md\nai-handoff-summary.md\neod/\n' >> .git/info/exclude
