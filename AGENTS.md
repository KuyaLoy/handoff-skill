# AGENTS.md

This repository is the **handoff** skill, packaged as a Claude Code plugin and a one-plugin marketplace. Each release
also ships `handoff.zip` for uploads to claude.ai and the Claude desktop app.

## Using it

Read `skills/handoff/SKILL.md` and follow it.

## Changing the skill

- Keep it short: `SKILL.md` at most 150 lines. New or changed lines under 120 characters. Plain English, no em dashes.
- The `description` must stay at most 200 characters (the claude.ai upload limit). The `name` stays `handoff`.
- SKILL.md frontmatter: only `name`, `description` and `license` (the Agent Skills format other AI tools read; claude.ai
  rejects tool-specific fields). Steps in plain words, not one tool's tool names.
- Keep the file names, `record-stop.sh`'s options (and its `.py` twin's), the template's field names (Updated, By, Last change, Status) and
  section headings stable: existing projects and other skills (for example zoho-command-center) rely on them.
- No real names of people, clients, companies or sites. Examples use generic names and example.com.
- Before a change is done:
  - `claude plugin validate . --strict` passes;
  - `sh tests/run.sh` passes (a change to a script in `scripts/` gets a test case). The `.sh` scripts stay plain sh
    and awk; each has a `.py` twin (Python 3.8+, standard library) that must print the same output, exit with the
    same code and write the same files: change both together. run.sh runs every case on both and compares them,
    so it needs Python;
  - a change to the skill's rules: run the cases in `evals/` (see evals/README.md);
  - every change is in CHANGELOG.md: a change to the skill or the manifests (`skills/`, `.claude-plugin/`) under its
    new version (see Release), a docs-only change under Unreleased;
  - a private-name scan of the repo and its history finds nothing (keep the word list outside the repo).
- Release: a merge to main that changes the skill is a release, so main is always a released version.
  1. In the pull request: raise the version in `.claude-plugin/plugin.json` (only there) and add its
     `## [x.y.z] - YYYY-MM-DD` section to CHANGELOG.md (move any Unreleased lines into it). The `check` workflow
     fails a pull request that changes the skill without both.
  2. Run the private-name scan, then merge.
  3. The `release` workflow tags `handoff--v<version>`, builds `handoff.zip` from `skills/handoff` (folder at the root,
     as claude.ai requires; LF line endings) and publishes the GitHub Release with that CHANGELOG section and the zip.
  4. claude.ai: Customize > Skills > + Add > Upload skill with the new `handoff.zip`, then "Upload and replace".
     Colleagues using the shared skill get it at next use.
  If the workflow fails, by hand: `claude plugin tag --push`, then
  `git -c core.autocrlf=false archive --format=zip --prefix=handoff/ -o handoff.zip handoff--v<version>:skills/handoff`
  (`core.autocrlf=false` keeps LF line endings: the root `.gitattributes` is not part of that subtree), then a GitHub
  Release for the tag with that CHANGELOG section and `handoff.zip` attached.
  Users get an update only when the version changes.
- Licence: MIT.
