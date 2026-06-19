Hand the current work back to the other AI tool (usually Claude Code), e.g. before hitting a usage limit.

Write or update `.tmp/progress.md` in the repo root with exactly this structure:

```
# Goal:   <what we are achieving>
# Plan:   <path to plan file, or bullet plan>
# Done:   <changes already made, with key file paths>
# Next:   <immediate next steps, ordered>
# Open:   <unresolved questions / decisions needed>
# Resume: <files/commands the next tool should read or run first>
```

Rules:
- Be specific and current. List actual file paths and commands, not vague summaries.
- Put anything the next tool must read FIRST under `Resume:`.
- Do not change source code in this step — only write the handoff note.
- After writing it, print the path and a one-line summary of where things stand.
