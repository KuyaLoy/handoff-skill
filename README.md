# handoff

A skill for Claude that keeps two files at the root of every project, so work survives a new chat, a compaction, a
context reset or a switch to another AI tool:

| File | For | What it holds |
|---|---|---|
| `handoff.md` | you, any developer, any AI starting cold | The full record: Goal, Current State, Active Files, Changes Made, Failed Attempts, Next Steps. Dated entries; nothing important is dropped. |
| `ai-handoff-summary.md` | AI | A short brief (60 lines at most) built from handoff.md and fresh checks, so the next chat can continue without reading the whole log. |

What the skill makes Claude do:

- **Create both files** the first time it works in a project folder, seeded from what already exists (README, build
  logs, git log), without being asked.
- **Read as little as possible:** the summary in a new chat; handoff.md only by section, for history or before
  anything risky.
- **No guessing:** every fact in the summary is tagged `[verified date: how]` or `[unverified: source]`, and only
  checked paths, versions and URLs are listed.
- **Update both files** after every significant change and before a session ends, checking the summary's limits.
- **Give you a resume prompt** before a compact, reset or switch to another AI.
- **Keep the notes private:** blocked on web roots, left out of deploys, and committed to git only if you say so.
  Secrets are never written, only where they live.

It came out of daily use on more than 70 web projects (WordPress, Shopify, static sites, apps).

## Install

Pick **one** way per computer. Two installs load two copies of the skill.

**claude.ai or the Claude desktop app** (chat, Cowork and the Code tab):
download `handoff.zip` from the [latest release](https://github.com/KuyaLoy/handoff-skill/releases/latest), then go to
Customize > Skills > Upload a skill. On a Team or Enterprise plan you can share it with colleagues from the same page:
colleagues who use your shared skill get your updates by themselves the next time they use it, so one person uploads
and the others use the shared copy.

**Claude Code plugin:**

```
/plugin marketplace add KuyaLoy/handoff-skill
/plugin install handoff@handoff
```

Then turn on automatic updates (once): `/plugin` > Marketplaces > handoff > Enable auto-update. Or add this to
`~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "handoff": {
    "source": { "source": "github", "repo": "KuyaLoy/handoff-skill" },
    "autoUpdate": true
  }
}
```

**By hand:** copy `skills/handoff/` into `~/.claude/skills/` (no automatic updates).

## Make it load every session (recommended)

The skill's description makes Claude load it in project folders. To make it a rule, add this to `~/.claude/CLAUDE.md`:

```markdown
## Handoff files
- Every project keeps handoff.md (full log) and ai-handoff-summary.md (short AI brief, max 60 lines) at its root.
- At the start of every session in a project folder, load the handoff skill and follow it. Read ai-handoff-summary.md first.
- After every significant change and before ending a session, update both files without being asked.
```

## Update

- claude.ai or desktop app: claude.ai can't update a skill from GitHub by itself. Download the new `handoff.zip` and
  upload it the same way (choose "Upload and replace"). If the replace doesn't work, delete the old skill first
  (Customize > Skills > ... > Delete), then upload. Colleagues using your shared skill then get it at next use.
- Plugin: with auto-update on (see Install), Claude Code updates it by itself: a few minutes after the first message
  of a chat it checks this repository and installs a new version when the version number changed ("Plugin updated";
  run `/reload-plugins` or open a new chat). By hand: `/plugin marketplace update handoff`, then
  `/plugin update handoff@handoff`. Turn it off: `/plugin` > Marketplaces > handoff > Disable auto-update.
- Git clone: `git pull --ff-only`. By hand: copy the new `skills/handoff/` over the old one.

Every release is a [GitHub Release](https://github.com/KuyaLoy/handoff-skill/releases) with `handoff.zip`
(Watch > Custom > Releases emails you each one); what changed is in [CHANGELOG.md](CHANGELOG.md).

## Uninstall

- claude.ai or desktop app: Customize > Skills > handoff > ... > Delete.
- Plugin: `/plugin uninstall handoff@handoff`, then `/plugin marketplace remove handoff`.
- By hand: delete `~/.claude/skills/handoff/`.

Your projects keep their handoff files; they are plain Markdown.

## Layout

```
.claude-plugin/plugin.json         the plugin
.claude-plugin/marketplace.json    this repo as a one-plugin marketplace
skills/handoff/SKILL.md            the skill
CHANGELOG.md                       what changed in each version
AGENTS.md                          rules for changing the skill and releasing it
```

## Licence

MIT. See [LICENSE](LICENSE).
