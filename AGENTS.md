# AGENTS.md

This repository is the **handoff** skill, packaged as a Claude Code plugin and a one-plugin marketplace. Each release
also ships `handoff.zip` for uploads to claude.ai and the Claude desktop app.

## Using it

Read `skills/handoff/SKILL.md` and follow it.

## Changing the skill

- Keep it short: `SKILL.md` under 150 lines. New or changed lines under 120 characters. Plain English, no em dashes.
- The `description` must stay at most 200 characters (the claude.ai upload limit). The `name` stays `handoff`.
- Keep the file names, the template's field names (Updated, By, Last change, Status) and section headings stable:
  existing projects and other skills (for example zoho-command-center) rely on them.
- No real names of people, clients, companies or sites. Examples use generic names and example.com.
- Before a change is done:
  - `claude plugin validate . --strict` passes;
  - every change is in CHANGELOG.md under Unreleased;
  - a private-name scan of the repo and its history finds nothing (keep the word list outside the repo).
- Release:
  1. Move Unreleased to a new version and set the same version in `.claude-plugin/plugin.json` (only there). Commit.
  2. `claude plugin tag --push` (tag `handoff--v<version>`).
  3. Build the upload zip from the tag (folder at the root, as claude.ai requires):
     `git -c core.autocrlf=false archive --format=zip --prefix=handoff/ -o handoff.zip handoff--v<version>:skills/handoff`
     (`core.autocrlf=false` keeps LF line endings: the root `.gitattributes` is not part of that subtree.)
  4. GitHub Release for the tag with that CHANGELOG section, and `handoff.zip` attached.
  Users get an update only when the version changes.
- Licence: MIT.
