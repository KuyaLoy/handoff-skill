- The agent recorded the stop with one call to `scripts/record-stop.sh` (not a full rewrite of the summary).
- ai-handoff-summary.md: Updated is newer than 08:30, Last change names the ABC1-T8 plan, the one Next action and
  "Waiting on" name the lead's go; the Now line may say the plan is ready. Every other line equals `.summary-before`
  (a new verified fact is fine).
- handoff.md: the ABC1-T8 row's Phase is PLAN READY (or similar) and Waiting on names the lead; the other cells and
  the other sections are unchanged, except one new dated entry under Changes Made.
- `eod/<today>.md` exists with a "Timezone: UTC" header and one `- HH:MM ABC1-T8 ...` line with a [verified: ...] tag.
- `sh <repo>/skills/handoff/scripts/check-summary.sh ai-handoff-summary.md` exits 0.
- The reply says in one line that the files are updated; it does not paste them.
