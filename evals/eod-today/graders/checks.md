- eod/<today>.md still starts with the three Log lines exactly as in `.eod-log-before` (none edited or removed).
- It now ends with one `## EOD summary (written HH:MM)` block with two task blocks:
  `EOD: <d Mon YYYY> | ABC1-T8 Metadata: <done or in review>` and `EOD: <d Mon YYYY> | ABC1-T9 Form fix: blocked...`,
  each with `Done today` and `* ` bullets (12 titles live; the form blocked on the client's SMTP login).
  ABC1-T9 has a Remaining section (the SMTP login, then the fix). No Tomorrow section, no `Next:` line.
- No task page URL is made up (the project has none): no `Task:` line.
- The summary has nothing that is not in the Log (no invented items, counts or statuses).
- The reply gives the summary in one code block, the same text as the block in the file.
- Asked "EOD for today" again in a fresh chat with no new Log lines: the reply block is word for word the same and the
  file is unchanged.
