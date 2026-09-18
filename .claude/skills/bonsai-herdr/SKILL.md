---
name: bonsai-herdr
description: Run independent tasks in parallel — one bonsai git worktree per task, each opened as its own herdr workspace with its own agent, plus an integration worktree whose agent merges accepted branches and verifies them before anything lands on the base branch, all supervised from this session. Use when a request splits into tasks that touch disjoint files and should progress at the same time. Requires HERDR_ENV=1.
---

# bonsai-herdr

Split a request into independent tasks, give each task a worktree, a workspace, and an agent,
then supervise all of them from here. Accepted branches meet in an integration worktree first;
the base branch moves only when the user says how.

| Layer | Owner |
|---|---|
| worktree create / name / remove | bonsai |
| workspace, pane, agent lifecycle | herdr |
| decompose, brief, supervise, harvest, rework, land | this session |
| merge accepted branches, fix glue, resolve conflicts on request | the integration agent |
| tear down — closing anything, removing a worktree | the user, per step 11 |

Read the `herdr` skill first. It is the source of truth for herdr's concepts and CLI, including
the rule that workspace/tab/pane ids compact when things close. This skill adds only what a
fan-out needs on top: `worktree open`, launching an agent in the workspace's own pane, and status
polling by agent name.

Agent names are the durable handle. Ids are not — re-read them from `herdr agent list` at the
moment you need them.

## When to use
- One request splits into 2-4 tasks whose file scopes do not overlap.
- Each task is worth a whole agent — a few minutes of work or more.

## When not to use
- Tasks touch the same files. Serialize them instead and say so.
- `HERDR_ENV` is not `1`. Stop; this skill has no non-herdr path.
- You are already running as a bonsai-herdr child. Nesting is not allowed.

## 1. Preflight

Every check is a stop condition. Report the failure and stop; do not route around it.

```bash
[ "$HERDR_ENV" = "1" ]
command -v herdr
command -v bonsai
git status --porcelain
[ -f .bonsai.toml ]
bonsai list
BASE=$(git branch --show-current); [ -n "$BASE" ]
```

Check the two binaries separately. `command -v herdr bonsai` exits 0 when only one of them
resolves, so a single call would pass with bonsai missing.

- Not inside herdr, or either tool missing → stop.
- `git status` non-empty → stop and ask the user to commit or stash. Worktrees branch from the
  base commit, so uncommitted work would not be in them.
- No `.bonsai.toml` → bonsai is not initialized here. Test the file, not the output of
  `bonsai list`: without it `bonsai list` still prints a normal table and only `bonsai add`
  fails. Ask before running `bonsai init` — it writes `.bonsai.toml` and appends `.bonsai/` to
  `.gitignore`. Do not reach for `bonsai init --dry-run` to preview that; as of bonsai 0.1.5 it
  performs the write.
- `bonsai list` is for reading existing worktrees, so a branch name already taken shows up here.
- `$BASE` is the branch checked out where this skill was invoked. Every task branch and the
  integration branch fork from it, and it is where the result lands in step 10. Empty means a
  detached HEAD → stop; there is no branch to land on.

## 2. Decompose and get approval

Split the request into tasks with disjoint file scopes. Default to at most 3 in flight; ask
before going higher — each agent is a full session against that tool's quota.

Present this table and wait for approval before creating anything:

| task | branch | file scope | agent |
|---|---|---|---|
| … | … | … | claude |

Integration: branch `integ-<slug>`, worktree `.bonsai/integ-<slug>`, agent `claude`.

The agent is `claude` unless the user names another one for that task — `opencode`, or any
other command on PATH. Different rows may use different agents; the `agent` column is what the
user approves. The branch name doubles as the task slug and the agent name, so keep it short and
unique (`docs-readme`, `fix-lint`).

The integration line is part of the same approval. Propose `<slug>` from the request's subject
(`integ-auth`, `integ-docs`). It is not a task: it gets no file scope, and its agent stays idle
until step 9 sends it something to merge.

Agent names are resolved across the whole herdr instance, not per repo. Check `herdr agent list`
for a name already in use — another repo's run may hold it — and prefix the repo name if it does
(`dotfiles-fix-lint`). A duplicate name would send a brief to the wrong agent.

## 3. Create a worktree per task

Steps 3 to 5 are per worktree: each row of the approved table, then the integration line. Run
them for all of them before moving on to supervision, which watches the tasks at once.

```bash
BRANCH=docs-readme   # or integ-<slug> for the integration worktree
AGENT=claude         # or opencode, or whatever the approved table says for this row
bonsai add -c "$BRANCH" --base "$BASE"
WT=$(command bonsai cd "$BRANCH")
[ -d "$WT/.git" ] || [ -f "$WT/.git" ]
```

`command` is required. bonsai's shell integration defines `bonsai` as a function that intercepts
the `cd` subcommand and runs `builtin cd` on the path instead of printing it, so a bare
`bonsai cd` assigns an empty string. Only `cd` is intercepted; every other subcommand passes
through, which is why `bonsai add` above needs nothing special.

The last line is the guard: everything downstream keys off `$WT`, so confirm the path arrived.
If it did not, read it out of `git worktree list --porcelain` instead and fix this skill.

## 4. Open each worktree and start its agent

`herdr worktree open` always creates a root shell pane and herdr has no flag to suppress it, so
run the agent *in* that pane rather than adding a second one. The workspace stays at one pane,
and the agent runs as a child of an interactive shell — Ctrl-Z drops to the prompt and the pane
survives. `herdr agent start` would make the agent the pane's own process instead, so suspending
or exiting it takes the pane down and the work with it.

```bash
OPEN=$(herdr worktree open --path "$WT" --label "$BRANCH" --no-focus --json) || exit 1
read -r WS ROOT REUSED <<<"$(printf '%s' "$OPEN" | python3 -c '
import sys, json
r = json.load(sys.stdin)["result"]
print(r["workspace"]["workspace_id"], r["root_pane"]["pane_id"], str(r["already_open"]).lower())
')"

if [ "$REUSED" = "true" ]; then
  ROOT=$(herdr tab create --workspace "$WS" --cwd "$WT" --label "$BRANCH" --no-focus |
    python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["root_pane"]["pane_id"])') || exit 1
fi

herdr agent rename "$ROOT" "$BRANCH" || exit 1
herdr pane run "$ROOT" "$AGENT"
```

Keep `--no-focus` so the user stays in the pane they are in.

`already_open: true` means the path already had a workspace and `$ROOT` is a pane someone else is
using. Reuse the workspace, but give this task its own tab so nothing lands in that pane.

Name the pane before launching the agent. `herdr agent rename` takes a pane with no agent
detected in it yet, so the durable handle exists from the start instead of racing the agent's
startup.

Whenever `$AGENT` is not `claude`, check that it resolves before opening anything:

```bash
command -v "$AGENT"
```

If it is not on PATH, stop and ask the user how it is invoked. Do not start `claude` instead — a
task the user wanted on another agent would run on this one without them knowing.

## 5. Brief each agent

Step 4 named the pane before the agent was up, so the name alone does not mean it is ready.
`--registered` waits for herdr to actually detect the agent, which is the real signal:

```bash
STATUS=~/.claude/skills/bonsai-herdr/scripts/agent-status.sh
"$STATUS" --registered "$BRANCH"
PANE=$("$STATUS" "$BRANCH" | cut -f3)
herdr pane run "$PANE" "<task text>"
```

`herdr pane run` sends the text plus a real Enter. `herdr agent send` writes literal text without
Enter, so the prompt would sit there unsubmitted.

Send the task as a single line. A newline inside the text reaches the agent's TUI as a submit, so
a multi-line brief arrives as several half-prompts and the agent starts on the first fragment.

Task text template. It is one line; keep it that way when you fill it in.

```
Task: <one line>. Branch: <branch>, already checked out in this worktree — stay in it. In scope: <paths you may change>. Out of scope: everything else; other agents own the rest of the repo. Done when: <observable condition, e.g. `just test` passes>. Do not commit; leave the changes in the working tree. When you finish, print a summary: what you changed, which files, what you verified.
```

The integration agent gets a role brief instead, so the merge briefs in step 9 can stay short:

```
Role: integration. Branch: integ-<slug>, already checked out in this worktree — stay in it. Wait for merge instructions from the parent session; do nothing until then. Do not commit on your own initiative.
```

## 6. Supervise

Watch every task agent from one call, using the names from the ledger:

```bash
NAMES=(docs-readme fix-lint)
"$STATUS" --wait "${NAMES[@]}"
```

`NAMES` holds task agents only. The integration agent is idle by design at this point, and
listing it here would make its `idle` look like a finished task. Step 9 waits on it by itself.

Act on the exit code:

- `2` — still working. Call it again. Report a one-line status to the user every third call
  (roughly every five minutes) so the wait stays visible; say nothing in between. After ten calls
  with no agent leaving `working`, stop polling and hand it back: name the stuck agents and let
  the user decide whether to keep waiting or look at the pane.
- `3` — someone is blocked. End the Bash call and show the human what the agent is asking:
  ```bash
  herdr agent read <the name whose line says blocked> --source recent --lines 80
  ```
  Present that output as-is and end the turn. Never pick an approval option yourself. When the
  user answers, send exactly what they chose with `herdr pane send-keys` or `pane send-text`,
  then go back to `--wait`.
- `0` — everyone settled. Harvest.

Do not use `herdr agent wait` or `herdr wait agent-status` here. They are edge-triggered, so a
timeout is not evidence that an agent is still running.

## 7. Harvest

Per worktree, in the ledger's order:

```bash
git -C "$WT" status --porcelain
git -C "$WT" diff --stat
```

Run the repo's test command inside each worktree. Report per task: what changed, what passed,
what the agent flagged. Read the diffs — a settled agent is not a correct agent.

## 8. Rework or accept

Harvest ends in one of three outcomes. Decide per task, not for the batch.

- Accept → step 9.
- Abandon → say so and leave everything standing. Step 11 still needs its own yes.
- Rework → send a follow-up to the same agent, then go back to step 6.

The agent name is durable, so re-resolve the pane and reuse it:

```bash
PANE=$("$STATUS" "$BRANCH" | cut -f3)
herdr pane run "$PANE" "<follow-up text>"
```

One line, for the same reason the first brief is one line. State only what changed:

```
Follow-up: <what to fix, one line>. Same branch and worktree — stay in it. In scope: <paths>. Done when: <observable condition>. Do not commit.
```

If the status line reads `missing`, or the pane sits at a bash prompt, the agent has exited. Start
it again in the same pane and wait for detection before briefing:

```bash
herdr pane run "$PANE" "$AGENT"
"$STATUS" --registered "$BRANCH"
```

A restart loses the agent's conversation. Write the follow-up so it stands on its own — a whole
brief, not a correction to something the agent no longer remembers.

## 9. Integrate

Accepted branches go into the integration branch one at a time, in the ledger's order. The base
branch does not move here; that is step 10.

```bash
SLUG=auth                                  # from the integration line approved in step 2
INTEG=$(command bonsai cd "integ-$SLUG")
[ -d "$INTEG/.git" ] || [ -f "$INTEG/.git" ]
```

Per accepted task:

1. Ask the user once. The approval covers committing the task branch and merging it into
   `integ-<slug>`, per `AGENTS.md`.
2. Commit inside the task worktree with the `commit` skill.
3. Brief the integration agent. One line, like every brief:
   ```
   Merge: run `git merge --no-ff <branch>` on integ-<slug>, then run `<test cmd>`. If the merge conflicts, stop without resolving and print the conflicting files. If tests fail, print the failing output and say whether it looks like an interaction between branches or a bug inside <branch>. Otherwise print a one-line summary. The merge commit is the only commit you make.
   ```
4. Wait on it alone, with the same exit-code handling as step 6:
   ```bash
   "$STATUS" --wait "integ-$SLUG"
   ```
5. Read what it printed and branch on the outcome.

Merging one branch at a time is what tells you which one broke the build. Two branches that
each pass alone can still break together.

### Passed

Next task.

### Conflict

Ask the user which way to go; do not resolve it yourself. The default is to send it back,
because the agent that wrote the branch knows the intent:

- Send back: abort the merge, then follow up the task agent and take that task through steps
  6, 7, and 8 again before returning to 3.
  ```bash
  git -C "$INTEG" merge --abort
  ```
  ```
  Follow-up: merge integ-<slug> into <branch> and resolve the conflicts in <files>. Same branch and worktree — stay in it. Done when: no conflict markers remain and `<test cmd>` passes. Do not commit.
  ```
- Resolve here: brief the integration agent, then review its resolution before completing the
  merge. The merge commit is still covered by the approval in 1.
  ```
  Resolve: the merge of <branch> on integ-<slug> is conflicted in <files>. Resolve it and leave the merge in progress; do not commit. Done when: no conflict markers remain and `<test cmd>` passes.
  ```
  ```bash
  "$STATUS" --wait "integ-$SLUG"
  git -C "$INTEG" diff --cached
  git -C "$INTEG" commit --no-edit
  ```

### Tests fail, bug inside the branch

Undo the merge so the integration branch stays green, then send that task to rework in step 8:
```bash
git -C "$INTEG" reset --hard HEAD~1
```
Run this right after the failed merge and before any other merge, so `HEAD~1` is the state
before it.

### Tests fail, interaction between branches

This glue belongs to no task branch, so the integration agent owns it:
```
Fix: <what breaks and why>. In scope: <paths>. Done when: `<test cmd>` passes. Do not commit; leave the changes in the working tree.
```
When it settles, read `git -C "$INTEG" diff` yourself, ask the user for commit approval, and
commit with the `commit` skill in the integration worktree.

## 10. Land

When every accepted task is in and the integration worktree passes, report and stop:

```bash
git -C "$INTEG" diff --stat "$BASE...integ-$SLUG"
```

Give the user the diff stat, the test result, and the list of glue commits. Then ask how to land.
This skill has no default; the user says which each time. Two shapes they may name:

- Local merge, in this session's checkout, which is on `$BASE`:
  ```bash
  git merge --no-ff "integ-$SLUG"
  ```
  then run the test command here.
- Pull request. `push` and `pr create` need their own approval per `AGENTS.md`; run them only
  when the landing instruction included them:
  ```bash
  git push -u origin "integ-$SLUG"
  gh pr create --base "$BASE"
  ```

Run the landing yourself. The integration agent's job ended with the last green merge.

## 11. Tear down — only when the user says so

Nothing is closed or removed until the user says so in the message just before it. This is a
separate decision from the merge, and it stays separate when the merge has just succeeded.

Approval to commit, merge, or push is not approval to tear down. Approval for one branch is not
approval for the next. Silence is not approval.

These are the destructive calls. Do not run them unasked, and do not run them as cleanup after a
failure either:

| call | destroys |
|---|---|
| `herdr workspace close` | the workspace and every pane in it |
| `herdr tab close`, `herdr pane close` | the pane and whatever is running in it |
| `bonsai remove`, `bonsai prune` | the worktree checkout |

The integration workspace and worktree are on this list like any other. A landed integration
branch whose worktree is still standing is as normal an end state as a merged task branch.

When the work settles, report the state and print the commands. Do not run them:

```bash
# when you are done with <branch>:
herdr workspace close "$WS"
bonsai remove "$BRANCH"
```

If the user does say yes, repeat the scope back first — which branches, and whether it covers the
workspace, the worktree, or both — then run only what they named, in that order. herdr closes the
workspace; bonsai owns the worktree, so remove it with `bonsai remove`, never
`herdr worktree remove`.

A merged branch whose worktree is still standing is a normal end state, not an untidy one. Leave
it and record it in the ledger.

## Ledger

Write `.tmp/bonsai-herdr.md` when the worktrees are created, and update it after briefing, after
harvest, and after anything is torn down:

```
| task | branch | worktree | workspace | agent | command | status | teardown |
```

The integration worktree gets a row too, with `integration` in the `task` column.

`teardown` is `open` or `closed`, and it records what was actually run. Never write `closed` for a
worktree you left standing. A ledger that disagrees with `git worktree list` is worse than no
ledger, because the next session rebuilds state from it.

herdr's ids go stale; branch names, paths, and agent names do not. After an interruption, rebuild
state from this file plus `herdr agent list`, never from ids remembered earlier in the session.

## Notes

- Child agents load the shared `AGENTS.md` themselves — Claude Code through `~/.claude/CLAUDE.md`,
  opencode through `~/.config/opencode/AGENTS.md` — so TDD and tidy-first already apply. Do not
  restate them in the task text.
- Children must not run this skill. Depth is 1. The integration agent is a child too.
- Task agents do not commit. The parent reviews the diffs and commits after the user approves.
  The integration agent's only commits are merge commits, each covered by an acceptance approval
  in step 9; glue fixes are committed by the parent.
- A worktree is a separate checkout, so `.tmp/` is not shared with the children. Everything they
  need goes in the task text.
- A fresh worktree path is new to the agent, so the first run there can ask the user to trust the
  folder. It surfaces as `blocked` and goes to the human like any other prompt.
- `herdr worktree open` returns `already_open: true` when that path already has a workspace.
  Reuse it instead of opening a second one.
