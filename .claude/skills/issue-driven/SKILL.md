---
name: issue-driven
description: Start branch/worktree work from an approved GitHub issue, keep progress visible in the issue thread, land via a PR whose Closes #N auto-closes the issue (squash by default), and clean up the workspace/worktree after the merge on confirmation. Use when a task gets its own branch — solo or in a bonsai-herdr batch — or when the user says issue駆動, issue を建てて, 起票して.
---

# issue-driven

The what and why (approval gates, naming, merge defaults, cleanup scope) are pinned in
`AGENTS.md` → Issue-driven Development. This skill is the how. `bonsai-herdr` defers to this
skill for everything issue/PR-shaped.

## Requires

`gh` authenticated and the working repo on GitHub: `gh repo view --json name`. If that fails,
stop and ask whether to proceed issue-less. Never skip the issue silently — the issue is the
user's visibility into what is running.

## 1. Approve, then create issues

Issue creation always needs the user's approval first.

- Solo task: present a 1-2 line draft (title + body) and wait for a yes, then create.
- bonsai-herdr batch: the decomposition table gains an `issue` column; approving the table
  approves creating all of them, plus one parent tracking issue (§4).

Create with `gh issue create` and parse the number from the returned URL:

```bash
URL=$(gh issue create --title "<title>" --body "<body>")
NUM=${URL##*/}
```

Body template, kept short:

```
## Goal
<one line>
## 背景 / Context
<one or two lines>
## Done when
<observable condition, e.g. `just test` passes / PR merged>
```

## 2. Name everything after the issue

branch, worktree, herdr workspace, and herdr agent all take `i<issue#>-<slug>` — e.g.
`i123-fix-lint`. `bonsai list` and `herdr agent list` then point straight at the issue.

herdr agent names must match `[a-z][a-z0-9_-]{0,31}` — keep slugs short, and prefix the repo
name on collision across the herdr instance (`dotfiles-i123-fix-lint`). The integration
branch keeps its `integ-<slug>` name; it has no issue of its own.

Ordering is fixed: create issues first, then branches/worktrees. The name needs the number.

## 3. Progress comments

The supervising session posts; child agents never run `gh`. Post one short comment per
transition — briefed / settled / accepted / PR opened / merged — so the issue thread reads as
a timeline without anyone watching the panes:

```bash
gh issue comment "$NUM" -R ":owner/:repo" --body "settled: <one-line outcome>"
```

In a bonsai-herdr worktree the remote path is unchanged, so plain `gh issue comment` resolves
`:owner/:repo` from the worktree's origin.

## 4. Batches: one parent tracking issue

For a bonsai-herdr batch, create one parent issue whose body is a task list of the children:

```
- [ ] #123
- [ ] #124
```

GitHub checks each item as that child issue closes, so the parent is a live status board.
Close the parent manually once the batch has landed and cleanup is confirmed.

## 5. Land via PR (two shapes; the user picks per batch, default: integ PR)

- integ PR (bonsai-herdr default): task branches meet in `integ-<slug>` as before; one PR
  from `integ-<slug>` lists every task issue: `Closes #123 Closes #124`.
- Per-task PRs (small batch, or the user asks to go one by one): one PR per task branch,
  `Closes #123` each.

Rules that apply to both:

- PR creation and merge each need their own approval (AGENTS.md Hard Rules).
- Default merge: `gh pr merge --squash`, run only when the user tells you to. Otherwise the
  user merges on GitHub and reports it; verify with `gh pr view "$PR" --json state -q .state`
  == MERGED before proposing cleanup.
- `Closes` auto-closes only when the PR's base is the repo's default branch. For any other
  base, close the issues manually right after the merge and say you did.
- Never pass `--delete-branch`: it deletes the local branch too, and cleanup is scoped to
  workspace + worktree by design. Remote branch buildup is the repo's
  "Automatically delete head branches" setting's job, not this command's.

## 6. After merge: cleanup (confirm every time)

The merge never implies teardown. Verify MERGED, show the exact scope, get a yes, then run
only what was named:

```bash
herdr workspace close "$WS"
bonsai remove "$BRANCH"
```

herdr owns the workspace; bonsai owns the worktree (`herdr worktree remove` is never the
tool). Local branches stay: a squash merge breaks ancestry, so deleting them takes
`git branch -D`, which is a separate explicit request.

## 7. Ledger and recovery

bonsai-herdr's `.tmp/bonsai-herdr.md` gains `issue` and `pr` columns. After an interruption,
rebuild from the ledger plus `herdr agent list`, and reconcile the issue/pr columns with
`gh issue view` / `gh pr view` — never from ids or issue numbers remembered in-session.
