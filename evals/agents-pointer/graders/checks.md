- AGENTS.md is unchanged: the repo tracks it and the handoff files stay local, so the pointer lines are not added
  (setup.md's exception). The reply says so in one line.
- `.htaccess`: the handoff block's FilesMatch now names AGENTS
  (`^(handoff|handoff-archive|ai-handoff-summary|AGENTS)\.md$`), still outside `# BEGIN WordPress`; the WordPress
  block is unchanged and there is only one handoff block.
- `.git/info/exclude` and the tracked files are unchanged (`git status` clean apart from untracked local files).
- The agent read ai-handoff-summary.md, not the whole handoff.md, and made no change to index.php.
- No secrets written; the summary checker exits 0.
- The reply says in a line or two what it did (the .htaccess update, AGENTS.md left alone); it pastes no file content.
  A 403 check is either done (if a server serves the folder) or named as not possible here.
- Second run (variant): with AGENTS.md removed from git (`git rm --cached AGENTS.md`, listed in .git/info/exclude),
  the same prompt adds the 4 pointer lines at the top of AGENTS.md and keeps the repo lines below them.
