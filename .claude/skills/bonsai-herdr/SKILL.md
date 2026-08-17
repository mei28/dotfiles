---
name: bonsai-herdr
description: Run independent tasks in parallel — one bonsai git worktree per task, each opened as its own herdr workspace with its own claude agent, all supervised from this session. Use when a request splits into tasks that touch disjoint files and should progress at the same time. Requires HERDR_ENV=1.
---

# bonsai-herdr

Split a request into independent tasks, give each task a worktree, a workspace, and an agent,
then supervise all of them from here.

| Layer | Owner |
|---|---|
| worktree create / name / remove | bonsai |
| workspace, pane, agent lifecycle | herdr |
| decompose, brief, supervise, harvest, merge | this session |

Read the `herdr` skill first. It is the source of truth for herdr's concepts and CLI, including
the rule that workspace/tab/pane ids compact when things close. This skill adds only what a
fan-out needs on top: `worktree open`, `agent start`, and status polling by agent name.

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
bonsai list
```

Check the two binaries separately. `command -v herdr bonsai` exits 0 when only one of them
resolves, so a single call would pass with bonsai missing.

- Not inside herdr, or either tool missing → stop.
- `git status` non-empty → stop and ask the user to commit or stash. Worktrees branch from the
  base commit, so uncommitted work would not be in them.
- `bonsai list` prints `not initialized` → ask before running `bonsai init`; it writes to the repo.

## 2. Decompose and get approval

Split the request into tasks with disjoint file scopes. Default to at most 3 in flight; ask
before going higher — each agent is a full claude session against the user's quota.

Present this table and wait for approval before creating anything:

| task | branch | file scope | agent |
|---|---|---|---|
| … | … | … | claude |

The agent is `claude` unless the user asked for `claude-glm` on that task. The branch name
doubles as the task slug and the agent name, so keep it short and unique (`docs-readme`,
`fix-lint`).

Agent names are resolved across the whole herdr instance, not per repo. Check `herdr agent list`
for a name already in use — another repo's run may hold it — and prefix the repo name if it does
(`dotfiles-fix-lint`). A duplicate name would send a brief to the wrong agent.

## 3. Create a worktree per task

Steps 3 to 5 are per task. Run them for each row of the approved table before moving on to
supervision, which watches all of them at once.

```bash
BRANCH=docs-readme
BASE=main
bonsai add -c "$BRANCH" --base "$BASE"
WT=$(bonsai cd "$BRANCH")
[ -d "$WT/.git" ] || [ -f "$WT/.git" ]
```

The last line is the guard: everything downstream keys off `$WT`, so confirm `bonsai cd` printed
a bare path and nothing else. If it did not, read the path out of
`git worktree list --porcelain` instead and fix this skill.

## 4. Open each worktree and start its agent

Run all three calls in one shell invocation. `herdr worktree open` always creates a root shell
pane — herdr has no flag to suppress it — and `herdr agent start` lands the agent as a split of
that pane. The workspace is down to the agent alone only once the root pane is closed, so keep
the window where both exist as short as possible.

```bash
OPEN=$(herdr worktree open --path "$WT" --label "$BRANCH" --no-focus --json) || exit 1
read -r WS ROOT REUSED <<<"$(printf '%s' "$OPEN" | python3 -c '
import sys, json
r = json.load(sys.stdin)["result"]
print(r["workspace"]["workspace_id"], r["root_pane"]["pane_id"], str(r["already_open"]).lower())
')"

herdr agent start "$BRANCH" --cwd "$WT" --workspace "$WS" --no-focus -- claude || exit 1
[ "$REUSED" = "true" ] || herdr pane close "$ROOT"
```

Keep `--no-focus` so the user stays in the pane they are in.

Close the root pane here, before briefing. Pane ids compact when a pane closes, and step 5 reads
the agent's pane id out of `herdr agent list` after this point.

Do not close it when `agent start` failed. It is the workspace's only pane, so closing it takes
the workspace down with whatever the failure left on screen.

`already_open: true` means the path already had a workspace and `$ROOT` is a pane someone else is
using. Reuse the workspace and leave that pane alone.

For `claude-glm`, check that it resolves first:

```bash
command -v claude-glm
```

If it is not on PATH, stop and ask the user how it is invoked. Do not start `claude` instead — a
task the user wanted on another model would run on this one without them knowing.

## 5. Brief each agent

Wait for herdr to detect the agents, then send each task through its pane:

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

## 6. Supervise

Watch every agent from one call, using the names from the ledger:

```bash
NAMES=(docs-readme fix-lint)
"$STATUS" --wait "${NAMES[@]}"
```

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

## 8. Merge and tear down

Commits and merges need the user's approval, per `AGENTS.md`. After approval, commit inside the
worktree with the `commit` skill, merge, then:

```bash
herdr workspace close "$WS"
bonsai remove "$BRANCH"
```

bonsai owns the worktree, so remove it with `bonsai remove`, not `herdr worktree remove`.

## Ledger

Write `.tmp/bonsai-herdr.md` when the worktrees are created, and update it after briefing and
after harvest:

```
| task | branch | worktree | workspace | agent | command | status |
```

herdr's ids go stale; branch names, paths, and agent names do not. After an interruption, rebuild
state from this file plus `herdr agent list`, never from ids remembered earlier in the session.

## Notes

- Child agents load `~/.claude/CLAUDE.md` → `AGENTS.md` themselves, so TDD and tidy-first already
  apply. Do not restate them in the task text.
- Children must not run this skill. Depth is 1.
- Children do not commit. The parent reviews the diffs and commits after the user approves.
- A worktree is a separate checkout, so `.tmp/` is not shared with the children. Everything they
  need goes in the task text.
- A fresh worktree path is new to claude, so the first run there can ask the user to trust the
  folder. It surfaces as `blocked` and goes to the human like any other prompt.
- `herdr worktree open` returns `already_open: true` when that path already has a workspace.
  Reuse it instead of opening a second one.
