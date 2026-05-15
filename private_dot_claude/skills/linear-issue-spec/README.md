# Linear skill family

Four skills that compose into an async-agent-friendly Linear workflow.

## The skills

| Skill | Role |
|---|---|
| `linear-decompose` | Plan/brainstorm → draft tickets (markdown for human review, then batch-create) |
| `linear-issue-spec` | Enforce the agent-ready ticket template when creating or labeling |
| `linear-pickup` | Agent claims a ticket: validate preconditions, open worktree, init log |
| `linear-log` | Maintain ONE pinned "Agent log" comment per run; new comments only for distinct events |

## The end-to-end loop

The canonical flow is wrapped by the **`spec-to-linear`** orchestrator skill.

```
spec-to-linear (orchestrator)
├─ superpowers:brainstorming   →  shared understanding (interactive)
├─ write spec                  →  *.pbc.md or notes/specs/<slug>.md
├─ superpowers:writing-plans   →  numbered plan
├─ linear-decompose            →  draft tickets (review)
└─ linear-issue-spec           →  create issues with template validation

[time passes]

linear-pickup <ID>             →  agent starts: validate, worktree, status=In Progress
linear-log (init)              →  pinned "Agent log" comment created
[agent works]
linear-log (update)            →  edit pinned comment at checkpoints
[agent opens PR]
linear-log (PR-opened comment) →  new comment, status=In Review
[human reviews & merges]
Linear GitHub sync             →  status=Done automatically
```

## Workspace setup

Labels created in the Linear workspace:

- `agent-ready` — fully specified, agent can pick up
- `agent-blocked` — agent hit a verifiable blocker, needs human triage
- `human-review` — PR open, awaiting review (also achievable via Linear's "In Review" status)
- `pbc-touched` — modifies a `*.pbc.md`, extra care
- `do-not-agent` — humans only (secrets, payments, auth, infra)

`agent-in-progress` was deliberately not created — Linear's native "In Progress" status covers it.

## Hard rules these skills enforce

1. **No agent edits without `agent-ready` label.** `linear-pickup` refuses.
2. **No `agent-ready` without all five template sections.** `linear-issue-spec` refuses.
3. **No comment spam.** `linear-log` edits one pinned comment; new comments only for genuine events.
4. **No silent spec disagreement.** If the agent thinks the spec is wrong, it posts a comment and waits — never silently corrects in code.
5. **Agent never merges.** Opens PR, sets In Review, stops.

## Not yet built

- `linear-okr-snapshot` — read initiatives/projects, produce a weekly status digest.
- A skill for delegating to GitHub Actions / claude-code-action runs once that's wired.
- A skill for cycle planning (which agent-ready tickets to pull into the next cycle).

Add these as the workflow gets used.
