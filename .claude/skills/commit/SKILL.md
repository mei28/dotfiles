---
name: commit
description: Split a working tree of mixed changes into logically grouped commits with Angular.js-prefixed messages, then commit them after you approve the plan. Use when the working tree holds several unrelated changes that need separating, or to decide where the commit boundaries should fall.
---

# commit

Group a dirty working tree into commits that each say one thing. Prefixes, the signature ban, and
the test gate live in `~/.claude/AGENTS.md`. Splitting structural from behavioral change:
`../tidy-first/SKILL.md`.

## When to use

- The working tree holds more than one logical change.
- A diff mixes restructuring with behavior change and the boundary needs drawing.
- Not for a single obvious change. Write the message and commit.

## Steps

1. Read the whole picture before grouping: `git status --short`, `git diff`, `git diff --staged`,
   and `git log --oneline -10` for the message style already in use.
2. Scan for secrets. Never stage `.env`, credential files, keys, or tokens. If the diff contains
   one, stop and report it before doing anything else.
3. Run the test suite and the linter. If either fails, stop and report. Do not commit a red tree
   and do not offer to skip the check.
4. Group the changes. See `## Grouping`.
5. Write each message as `<prefix>: <what changed>` under 72 characters, then a body saying why
   when the reason is not evident from the diff. Use heredoc so the body survives the shell:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat: add user profile retrieval

   Fetch user data through the API and cache it in memory for five minutes,
   because the profile view re-renders on every keystroke in the search box.
   EOF
   )"
   ```
6. Present the full plan — every group, its files, and its message — and stop. Wait for approval.
7. On approval, commit the groups in order. Structural commits go before the behavioral commits
   that depend on them. Check `git status` after each.

## Grouping

Split on:

- Behavior against structure. A rename and the feature that motivated it are two commits, never one.
- Feature boundary. A fix and the test that pins it belong together; two unrelated fixes do not.
- Dependency order. If group B does not build without group A, A commits first.

Infer the prefix from what the diff does, not from the directory it sits in. New behavior is
`feat`, corrected behavior is `fix`, a move or rename with identical behavior is `refactor`,
and whitespace or import ordering alone is `style`.

## Notes

- Never force push and never rewrite history. If a commit needs fixing, say so and let me decide.
- On a pre-commit hook failure, report the exact output and stop. Fixing the cause is the answer;
  skipping the group is not.
- On merge conflicts, report the conflicted paths and stop.

## Mistakes

- Bundling a "while I was in there" cleanup into a feature commit. Split it out as `refactor`.
- Committing formatting alongside logic, forcing the review to read both at once.
- Staging with `git add -A` and finding out afterward what went in.
- Writing the message from the file names instead of the diff.
- Treating silence at step 6 as approval. It is not.
