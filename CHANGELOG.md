# Changelog

All notable changes to the handoff skill. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions: [Semantic Versioning](https://semver.org/) (fix = patch, new rule = minor, changed workflow = major).

## [Unreleased]

## [1.3.0] - 2026-11-18

### Added
- `scripts/record-stop.sh`: one call per stop. It appends the EOD line (`--eod`, creates the day's file with its
  header), sets the summary's Updated, Last change and Next action (and the Now line, Waiting on, Status when given),
  changes a coordinator's board row in handoff.md > Task chats (`--task` with `--set "Column=value"` or `--row`), runs the
  checker and prints one line. All or nothing: on a FAIL nothing is written. Keeps each file's line endings. Tests.
- `setup.md` (read only when the files are created or found unprotected): the web-root, deploy and git rules, moved
  out of SKILL.md, and the new AGENTS.md pointer: 4 lines next to the handoff files, so any AI tool starts from the
  summary. Web-blocked like the others (the `.htaccess` block names AGENTS), same deploy and git rules; a tracked
  AGENTS.md in a repo whose handoff files stay local is left alone.
- `license: "MIT"` in the SKILL.md frontmatter (Agent Skills format: name, description, license only).
- README: install for other AI tools (Codex, Antigravity, Cursor, OpenCode, Devin Desktop, tools without skills).
- Evals: record-stop and agents-pointer; new-project also checks the pointer; archive follows the 14-day rule.

### Changed
- Updating: the full summary rewrite only at milestones (plan approved, done, deployed, blocked) and before a session
  ends. Other stops refresh only the Updated, Last change and Next action lines (one record-stop call).
- Very large handoff.md: past 100 KB, entries older than 14 days (was 60) and the board rows of finished tasks (DONE,
  ARCHIVED) move to handoff-archive.md, the rows into a `## Task chats (archived)` table; search both for a task ID.
- SKILL.md 148 lines; small rewording to keep it under 150. eod.md points to setup.md for protection.

## [1.2.0] - 2026-11-18

### Added
- Daily EOD log (`eod.md`, read only when needed): `eod/YYYY-MM-DD.md`, one line per finished item or stop, written
  when it happens with how it was verified, append only. "EOD" or "EOD for today" writes the day's summary into the
  file and replies with it in one code block; the same question gets the same answer; "EOD for <date>" reads that
  day's file. No file: it says so and offers a rebuild from dated handoff and task notes and git, marked
  "reconstructed", written only after a yes. Only the chat that owns the root files writes it.
- After a compact or reset (new paragraph in the compact section): the compact summary is a source, not a fact;
  read ai-handoff-summary.md (a task chat: its checkpoint.md or notes.md) and re-check the Next action first.
- README: an optional SessionStart hook (matcher "compact") that reminds the chat of this right after every compact.
- Evals: eod-today and eod-missing.

### Changed
- `eod/` gets the same protection as the handoff files: `eod/.htaccess` with `Require all denied` on Apache, left out
  of deploys, and the same git decision. Updating step 1 adds the EOD line; the One writer rule covers `eod/`.
- The description also triggers on an EOD request (192 characters).
- "Before a compact, reset or switch to another AI" is now "Before and after a compact, reset or switch to another
  AI"; the Style section is one line at the top. Small rewording elsewhere to keep SKILL.md under 150 lines.

## [1.1.0] - 2026-11-17

### Added
- `scripts/check-summary.sh`: a checker for ai-handoff-summary.md (plain sh and awk) that ships with the skill.
  Updating step 3 runs it and fixes every FAIL before saying the files are updated. It checks lines, facts, paths,
  one Next action, line length, fact tags, that every Key paths entry exists, the template lines and headings, and
  warns when handoff.md is over 100 KB. Without a shell, the same list is checked by hand.
- "Very large handoff.md": over 100 KB, old Changes Made entries and Failed Attempts that no longer apply move word
  for word into handoff-archive.md, with a pointer line; the archive gets the same protection.
- Checker tests (`tests/run.sh`, run on Linux and macOS for every pull request) and behaviour cases in `evals/`.

### Changed
- The .htaccess block also covers handoff-archive.md.
- The limits line names every limit, and line length reads "at most 160 characters" everywhere.
- Release automation: the `check` workflow validates every pull request and makes a skill change come with a new
  version; the `release` workflow tags each new version and publishes it with `handoff.zip`. README: how to turn on
  automatic updates, and that colleagues using a shared claude.ai skill get updates by themselves.

## [1.0.0] - 2026-11-13

First shared version. Changes from the private version of 2026-11-09; every other rule is unchanged.

### Added
- "Before a compact, reset or switch to another AI": update both files, then give the user a short resume prompt
  that works pasted into any AI tool.
- "Web roots, deploys and git": the `.htaccess` block that keeps both files off the web (outside generated blocks),
  checked with `curl -I` (403) and a home page load; ask first on live servers; deployed folders keep the files out;
  in git repos, ask once whether the files are committed and record the answer.
- One writer: when a coordinator chat owns the root files, other chats log in their own task folder.
- Same template in every project, also when another skill or workflow creates the files; extra sections and
  numbered headings are fine.
- Size it to the work: a task that just started gets a few lines per section.
- Secrets: write where a secret lives, never its value; check new lines before saving.

### Changed
- Updating step 3 checks every summary limit: 60 lines, 12 facts, 10 paths, one Next action, 160-character lines,
  tagged facts, existing paths, status matching handoff.md.
- "Pick a safe location" points to the new web root section instead of moving the files one level up by default.
- The description mentions compaction and resets (190 characters, under the 200-character limit for claude.ai).
- Personal names replaced by "the user".

[Unreleased]: https://github.com/KuyaLoy/handoff-skill/compare/handoff--v1.1.0...HEAD
[1.1.0]: https://github.com/KuyaLoy/handoff-skill/compare/handoff--v1.0.0...handoff--v1.1.0
[1.0.0]: https://github.com/KuyaLoy/handoff-skill/releases/tag/handoff--v1.0.0
