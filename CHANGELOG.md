# Changelog

All notable changes to the handoff skill. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions: [Semantic Versioning](https://semver.org/) (fix = patch, new rule = minor, changed workflow = major).

## [Unreleased]
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

[Unreleased]: https://github.com/KuyaLoy/handoff-skill/compare/handoff--v1.0.0...HEAD
[1.0.0]: https://github.com/KuyaLoy/handoff-skill/releases/tag/handoff--v1.0.0
