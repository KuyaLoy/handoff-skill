# Setup: where the handoff files live and who sees them

Read this file when you create the handoff files, AGENTS.md or `eod/` in a project, or find them unprotected.

## Web roots, deploys and git

- **Web root** (a web server serves the project folder, local or live): keep the files at the root and block them.
  Apache 2.4: put this block in the root `.htaccess`, outside `# BEGIN WordPress` and any other generated block
  (an older block without AGENTS: update it):
  ```apache
  # BEGIN handoff files (keeps the project notes off the web)
  <FilesMatch "^(handoff|handoff-archive|ai-handoff-summary|AGENTS)\.md$">
      Require all denied
  </FilesMatch>
  # END handoff files
  ```
  Then check: the file's URL gives 403 (`curl -I`) and the home page still loads. Other servers: the same rule in
  their config. On a live server, or when that `.htaccess` gets deployed, ask the user first. If you can't block them,
  move the files one level up into a folder of its own for this project.
- **`eod/`** (daily EOD log): same care. Apache: `eod/.htaccess` with `Require all denied`, then a 403 check.
- **Deployed folders** (a theme or plugin folder, a static build, a zip): check the deploy script or ignore list and
  make sure the handoff files, AGENTS.md and `eod/` stay out.
- **Git repo:** ask the user once whether the handoff files, AGENTS.md and `eod/` are committed or stay local (local:
  list them in `.git/info/exclude`). Record the answer under the project rules in handoff.md.

## AGENTS.md pointer (for any AI tool)

Most AI coding tools read `AGENTS.md` when they start. Put these 4 lines next to the handoff files. If an AGENTS.md is
already there, add them at its top and leave the rest as it is. Exception: the repo tracks that AGENTS.md and the
handoff files stay local. Then leave it alone (the lines would end up in commits) and say so in one line.
```markdown
# Handoff notes for any AI tool
- First read ai-handoff-summary.md; open handoff.md only for history (search for a heading).
- Keep both current with the handoff skill (github.com/KuyaLoy/handoff-skill). Never write secrets in them.
- One writer: if the project rules name an owner chat, other chats log only in their own task notes.
```
