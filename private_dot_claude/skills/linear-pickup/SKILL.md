---
name: linear-pickup
description: Use when starting work on a Linear issue, especially as an async agent. Validates the issue is agent-ready, sets up an isolated worktree, moves status to In Progress, and initializes the agent log. Refuses to start if preconditions fail.
---

# linear-pickup

The handoff point between Linear and code. An agent that picks up a ticket without verifying it is agent-ready will produce optimistic, lying status updates. This skill is the gate that prevents that.

## When to use

- User says "pick up LIN-123" / "work on this issue" / "start LIN-123".
- An async agent run starts with a Linear issue ID as input.
- You're about to begin coding for a ticket and have not yet validated it.

## When NOT to use

- User says "just fix this bug" with no Linear ticket — there's nothing to pick up.
- The work is exploratory ("look around and tell me what you find") — no ticket needed.

## Procedure

### 1. Read the issue

Call `mcp__claude_ai_Linear__get_issue` with the identifier (e.g., `JAY-12`).

### 2. Validate preconditions (refuse loudly if any fail)

- [ ] Issue exists and is not Cancelled or Done.
- [ ] Issue has the `agent-ready` label.
- [ ] Issue does NOT have `do-not-agent`.
- [ ] Issue does NOT have `agent-blocked` without explicit user override ("yes, retry it").
- [ ] Description contains all five required sections (Goal / Acceptance criteria / Scope fence / Files likely touched / Verification). Use `linear-issue-spec` mental model.
- [ ] Issue is not already in "In Progress" with a recent `Agent log` comment from a different agent (avoid concurrent runs).

If any check fails: STOP. Do not edit code. Post a comment via `mcp__claude_ai_Linear__save_comment` explaining what failed, and tell the user.

### 3. Move the issue to In Progress

Use `mcp__claude_ai_Linear__save_issue` with `state: "In Progress"`. If the user wants Done/Cancelled later, it's their call — agent only sets In Progress.

### 4. Open an isolated worktree

If the project uses git worktrees (most do), invoke the `superpowers:using-git-worktrees` skill.

Branch name: use the `gitBranchName` field returned by `mcp__claude_ai_Linear__get_issue`. Linear's native GitHub integration auto-links PRs only when the branch matches what Linear suggests — typically `<teamKey-lowercase>/<n>-<slug>` (e.g., `jay/jay-5-foo-bar`). Do NOT improvise a branch name; use the issue's `gitBranchName` verbatim.

For ks-trader specifically: this repo uses **jj (Jujutsu)** not plain git. Read `CLAUDE.md` in the repo root before any branch operation. Do NOT run `git checkout` or `git branch` — it leaves the repo detached. Use `jj new` and `jj bookmark set` instead.

### 5. Initialize the agent log comment

Invoke the `linear-log` skill to create the canonical "Agent log" comment for this run. Do NOT post status updates as new comments.

### 6. Read the project context

For ks-trader: read `CLAUDE.md`, all `*.pbc.md` files relevant to the issue's scope, and any files listed in the issue's "Files likely touched" section.

### 7. Begin work

Now you have:
- A worktree branch
- An issue in In Progress
- A pinned log comment to update
- Scope clarity from the validated template

Start coding. Update the log comment at meaningful checkpoints (not after every file edit — see `linear-log` for cadence rules).

## Failure modes & responses

| Situation | Response |
|---|---|
| Issue lacks `agent-ready` | Comment "Cannot pick up: missing label `agent-ready`. Apply `linear-issue-spec` to validate." STOP. |
| Description missing sections | Comment listing exactly which sections are missing. STOP. |
| Already In Progress with recent agent log | Comment "Another agent appears active (last log update <timestamp>). Aborting to avoid concurrent runs." STOP. |
| `do-not-agent` present | Comment "Cannot pick up: `do-not-agent` label present. Human handles this." STOP. |
| Acceptance criteria can't be verified locally | Comment "Cannot pick up: acceptance criterion `<exact text>` requires <missing access/tool>. Refine the criterion or grant access." STOP. |

## On disagreement

If you (the agent) think the spec is wrong — wrong approach, wrong scope, missing constraint — DO NOT silently fix it in code. Post a comment with your disagreement and your proposed change. Wait for human response before continuing. Silent course-correction is the failure mode that erodes trust in async agents.

## At task completion

The PR is the deliverable. When acceptance criteria pass and verification commands all return clean:

1. Open a PR. Title: same as issue. Body must reference the issue with `Fixes <ID>` or `Closes <ID>` so Linear auto-closes on merge.
2. Update the agent log comment with the final summary and PR link.
3. Move issue to "In Review" via `mcp__claude_ai_Linear__save_issue`.
4. Stop. Do not merge. Humans merge.
