# Evals: behaviour cases for the handoff skill

Each case is a folder: `setup.sh` builds the starting project, `prompt.md` is what the user says, and
`graders/checks.md` lists what must be true afterwards. Most cases end with the summary checker passing.

Run a case (any AI tool that can run a shell):
1. Make an empty scratch folder, `cd` into it and run `sh <repo>/evals/<case>/setup.sh`.
2. Start a fresh chat or agent in that folder with the skill loaded (or tell it to read `skills/handoff/SKILL.md`
   and follow it), and give it the text of `prompt.md`.
3. Check every line of `graders/checks.md`. A case passes when all of them hold.

Run all nine after any change to the skill's rules. The layout follows `claude plugin eval` (prompt.md and graders/),
which was in early access when these were written, so for now they are run by hand or by an agent.

| Case | What it tests |
|---|---|
| new-project | creates both files and the AGENTS.md pointer in a project that has none; the summary passes the checker |
| fix-limits | an update fixes a summary that breaks the limits, without losing facts |
| archive | handoff.md over 100 KB: old entries move to handoff-archive.md, with pointer lines |
| compact-prompt | before a compact: files updated, then a resume prompt in one code block |
| eod-today | "EOD for today" writes the summary from the day's log, replies with it, same answer when asked again |
| eod-missing | "EOD for <date>", no file: says so, offers a rebuild, writes nothing before a yes; rebuild marked |
| eod-summary-shape | "EOD for today" replaces an old-style summary: one linked line per task, the right status, no token |
| record-stop | a coordinator records a stop with one record-stop.sh call: summary lines, EOD line, board row only |
| agents-pointer | an older project: the .htaccess block gains AGENTS; a tracked AGENTS.md is left alone when the files are local |
