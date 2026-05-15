---
name: linear-log
description: Use to post or update agent progress on a Linear issue. Maintains a single canonical "Agent log" comment per issue rather than spamming new comments. Edit the existing comment in-place; only create new comments for genuinely separate events (PR opened, blocked, escalation). Prevents Linear comment threads from rotting under agent noise.
---

# linear-log

The default failure mode of async agents on PM tools is comment spam: one new comment per file edited, per thought, per retry. This destroys the human reading experience and trains operators to ignore agent updates.

This skill enforces the inverse: **one pinned comment per agent run, edited in place, with a structured format.**

## When to use

- An agent has just started a Linear-tracked task (initialize the log).
- An agent reaches a meaningful checkpoint (update the log).
- A genuinely new event occurs that deserves its own comment (PR opened, blocked, escalation).

## When NOT to use

- After every single file edit. That's noise; do not log it.
- For passing thoughts the agent had. The log records work, not stream-of-consciousness.
- For trivial tickets where the PR itself is sufficient communication.

## The canonical comment format

```markdown
**Agent log** — run started <ISO timestamp UTC>, last updated <ISO timestamp UTC>

## Status
<one-line current state: Exploring | Implementing | Verifying | Blocked | PR open | Done>

## Branch
`lin-<n>-<slug>` (worktree: `<path>`)

## Files touched so far
- path/to/file.ts — <one-line what>
- path/to/other.ts — <one-line what>

## Acceptance criteria progress
- [x] <criterion 1> — <how verified>
- [ ] <criterion 2>
- [ ] <criterion 3>

## Verification status
- `<cmd 1>` — <pass/fail/not yet run>
- `<cmd 2>` — <pass/fail/not yet run>

## Notes / decisions
- <decision 1 with one-line rationale>
- <decision 2>

## Next
<one sentence: what the agent will do in the next checkpoint>
```

## Procedure

### Initialize (start of run)

1. Call `mcp__claude_ai_Linear__list_comments` for the issue.
2. Look for an existing comment whose body starts with `**Agent log**` from this user/agent.
3. If found and stale (run finished, or last update >24h ago for fresh runs): create a new one. The old one becomes archive.
4. If found and recent (active run): you are entering an active run — STOP. See `linear-pickup` for concurrent-run handling.
5. If not found: create a new comment via `mcp__claude_ai_Linear__save_comment` using the format above with empty progress sections.
6. **Save the returned comment ID** in working memory — every subsequent update rewrites THIS comment.

### Update (at checkpoints)

A "checkpoint" is one of:
- Finished exploration; about to start editing files
- Completed a logical chunk (one acceptance criterion satisfied)
- Hit a blocker
- Verification commands run (with outcome)
- About to open a PR

NOT a checkpoint: every file save, every test run, every grep.

To update: call `mcp__claude_ai_Linear__save_comment` with the saved comment ID and a fully rewritten body (the tool replaces, not appends).

### Escalation (genuinely new comment)

Create a NEW comment (not edit the log) only for these events:
- **Blocked**: requires human action. Tag the human, describe the blocker, link to the log.
- **PR opened**: link to the PR, summarize what shipped.
- **Spec disagreement**: the agent thinks the issue is wrong. Describe disagreement and proposed correction.
- **Found another bug**: outside scope; suggest a new issue.

Each of these is genuinely a separate event the human needs to see distinctly.

## Cadence rules

- Initialize: once at the very start.
- Update: at most every ~10 minutes of agent work, or at logical checkpoints — whichever is rarer.
- Final update: when PR opens, set Status to "PR open", check off all criteria with verification evidence.
- After PR opens: stop updating the log. The PR is now the source of truth.

## Why this design

Linear comments are a *human* communication channel. Treat each new comment as something a human must read in their inbox. Editing the pinned log keeps history (Linear shows comment edits) without flooding the inbox. New comments only for events the human genuinely needs to act on.

## On run handoff

If the run is interrupted and resumes (e.g., a second agent invocation continues the same issue), the new agent should:
1. Find the existing Agent log comment.
2. Update it in place with the new agent's continuation, NOT create a fresh one.
3. Note in the "Notes / decisions" section that a handoff occurred at <timestamp>.
