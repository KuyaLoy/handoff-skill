#!/usr/bin/env python3
"""session-hook.py: prints the handoff reminder for a SessionStart hook, in the format each tool reads.
  python session-hook.py --tool claude|codex|antigravity
claude: plain text (Claude Code adds hook output to the chat's context).
codex: {"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": ...}}
antigravity: {"injectSteps": [{"systemMessage": {"systemMessage": ...}}]}
Python 3.8+, standard library only. It reads nothing and writes nothing; setup per tool: the skill's README.
"""
import json
import sys

MESSAGE = ("Context was compacted or the session restarted. Before your next step, read ai-handoff-summary.md at the "
           "project root (a task chat: its checkpoint.md or notes.md) and re-check its Next action against the real "
           "files. The files win over the compact summary.")


def answer(tool):
    if tool == "claude":
        return MESSAGE
    if tool == "codex":
        return json.dumps({"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": MESSAGE}})
    if tool == "antigravity":
        return json.dumps({"injectSteps": [{"systemMessage": {"systemMessage": MESSAGE}}]})
    return None


def main(argv):
    tool = argv[2] if len(argv) == 3 and argv[1] == "--tool" else ""
    out = answer(tool)
    if out is None:
        sys.stderr.write("usage: python session-hook.py --tool claude|codex|antigravity\n")
        return 2
    sys.stdout.write(out + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
