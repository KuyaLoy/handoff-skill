#!/bin/sh
# handoff.md of about 120 KB: many Changes Made entries from early 2026, three recent ones, two failed attempts.
mkdir -p src
printf '<form action="/contact" method="post">\n<input name="email" type="email" required>\n<textarea name="message">' \
  > src/contact.html
printf '</textarea>\n<button type="submit">Send</button>\n</form>\n' >> src/contact.html
{
  printf '# Handoff: example-site\n\n## Goal\nSite for example.com.\n\n## Current State\nContact form in progress.\n\n'
  printf '## Active Files\n- src/contact.html\n\n## Changes Made\n'
  printf -- '- 2026-11-12: contact form markup started.\n- 2026-11-05: header fixed.\n- 2026-10-30: footer done.\n'
  i=0
  while [ $i -lt 1100 ]; do
    m=$((i % 7 + 1)); d=$((i % 28 + 1))
    printf -- '- 2026-0%s-%02d: change %s, a routine edit with enough words to make this log long like a real one.\n' \
      $m $d $i
    i=$((i + 1))
  done
  printf '\n## Failed Attempts\n- 2026-02-03: a form plugin was tried and removed; the site no longer uses any plugin.\n'
  printf -- '- 2026-11-06: an inline captcha broke the layout on mobile; still applies.\n\n'
  printf '## Next Steps\n- Finish the contact form.\n'
} > handoff.md
{
  printf '# AI handoff summary: example-site\nUpdated: 2026-11-12 09:00 UTC | By: an earlier chat\n'
  printf 'Last change: contact form markup started\nStatus: ACTIVE\n\n## Now\n- Contact form\n'
  printf -- '- Waiting on: nothing\n\n## Next action\n- Finish the form in src/contact.html\n\n## Verified facts\n'
  printf -- '- The form posts to /contact [verified 2026-11-12: read src/contact.html]\n\n'
  printf '## Key paths\n- src/contact.html: the form\n\n## Rules for this project\n- No live changes\n\n'
  printf '## Open questions\n- None\n\n## Where to look in handoff.md\n- History: handoff.md > Changes Made\n'
} > ai-handoff-summary.md
