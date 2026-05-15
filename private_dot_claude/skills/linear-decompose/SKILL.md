---
name: linear-decompose
description: Use when you have a written plan, spec, brainstorm output, or PBC and need to break it into agent-ready Linear tickets. Outputs draft tickets in markdown for human review BEFORE creating them in Linear. Each draft uses the linear-issue-spec template. Never auto-creates without confirmation.
---

# linear-decompose

The bridge between brainstorming/planning and execution. Takes a plan and produces a stack of tickets that — when stacked — accomplish the plan. The output is markdown for human review, not direct Linear writes.

## When to use

- User says "break this into tickets" / "decompose the plan" / "turn this into Linear issues".
- A `superpowers:brainstorming` or `superpowers:writing-plans` session has produced a plan and the next step is execution.
- A `*.pbc.md` file has been updated and the implementation work needs to be tracked.
- Invoked downstream of `spec-to-linear` (the canonical orchestrator).

## Inputs this skill recognizes

- **superpowers writing-plans output** — typically a numbered markdown file with tasks, dependencies, and verification subsections. Map each task or task-group to a ticket.
- **`*.pbc.md` files** — Product Behavior Contracts. Each behavior promise that needs implementation work is a candidate ticket. The PBC update itself is its own (blocking) ticket.
- **Free-form spec** — a markdown file from `notes/specs/`. Less structured; ask clarifying questions before decomposing.
- **Brainstorm transcript** — too raw to decompose directly. Send back to `superpowers:writing-plans` first.

## When NOT to use

- The work is one ticket. Just create it directly with `linear-issue-spec`.
- The plan isn't ready (open questions, undecided architecture). Send it back to brainstorming first.
- The user wants advice on whether to break it up — that's a design conversation, use `feedback-loop`.

## Procedure

### 1. Read the source

Identify the input plan. It might be:
- A markdown file (PLAN.md, a brainstorm output, a `*.pbc.md`)
- The conversation history from a brainstorming session
- A user-pasted spec

Read it fully before decomposing. Surface ambiguities back to the user — do not invent specs.

### 2. Identify ticket boundaries

A ticket should be:
- **Single-objective**: one outcome. "Refactor X" and "add feature Y" are two tickets.
- **Independently verifiable**: has its own acceptance criteria and verification commands.
- **Sized for one async agent run**: a few hours of agent work, not multi-day epics.
- **Not blocked on undecided design**: if the design is open, that's a brainstorming ticket first.

If a chunk is too big, split it. If two chunks share so much context that splitting creates pointless overhead, merge them.

### 3. Assign dependencies

For each ticket, identify what blocks it and what it blocks. Use Linear's `blockedBy` / `blocks` fields when creating later. If everything blocks everything, you have one ticket, not many — re-merge.

### 4. Output draft tickets

Produce markdown like this for the user:

```markdown
# Draft tickets for <plan name>

Source: <path or session reference>
Total tickets: N
Suggested project: <project name or "create new project: <suggestion>">

---

## 1. <Ticket title>

**Labels:** agent-ready[, pbc-touched, do-not-agent as relevant]
**Blocks:** <ticket numbers>
**Blocked by:** <ticket numbers>

### Goal
...

### Acceptance criteria
- [ ] ...

### Scope fence
Out of scope: ...

### Files likely touched
- ...

### Verification
- `...`

---

## 2. <next ticket>
...
```

### 5. Confirm before creating

Show the draft to the user. Ask:
- Are the boundaries right (split / merge)?
- Are acceptance criteria testable and complete?
- Is anything missing?
- Should it go under an existing Project or a new one?

Only after explicit approval ("yes, create them"), batch-create with `mcp__claude_ai_Linear__save_issue`. Apply `blockedBy` relationships in a second pass since they need IDs from the first pass.

### 6. Confirm creation

After creation, output the list of created issue identifiers (e.g., JAY-12, JAY-13) with one-line summaries so the user can verify in Linear.

## Heuristics

- **5 tickets for a "small" plan.** If you produced 1, you under-decomposed. If you produced 20, you're treating refactoring steps as tickets — collapse.
- **Verification for every ticket.** A ticket with no testable verification is not agent-ready and may be a research/spike ticket — label it differently.
- **PBC tickets first.** If a plan touches `*.pbc.md`, the PBC update is its own ticket and blocks the implementation tickets. Per project convention: PBC changes precede behavior changes.

## Anti-patterns

- **"Setup" or "scaffolding" tickets with no observable outcome.** Bad. Either the setup enables a feature (combine into the feature ticket) or it changes observable behavior (write that as the criterion).
- **"Investigate X" tickets with vague exit criteria.** A research ticket should produce a written deliverable: a doc, a decision recorded in PLAN.md, an updated PBC. That deliverable is the acceptance criterion.
- **Tickets ordered by code structure, not user-visible value.** The ordering should let you ship value early. If ticket #1 produces nothing observable, reconsider ordering.
