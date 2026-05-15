---
name: spec-to-linear
description: Use when starting a new feature or non-trivial change. Orchestrates the canonical flow brainstorm → spec → plan → Linear issues, by invoking superpowers:brainstorming, superpowers:writing-plans, then linear-decompose and linear-issue-spec. Single entry point that ensures every feature gets a properly-decomposed Linear backlog before any code runs.
---

# spec-to-linear

The canonical flow from "I want to build something" to "agent-ready Linear backlog." This skill is glue — it invokes other skills in order. It does not reimplement them.

## When to use

- User says "let's plan/spec/build feature X" and there's no existing Linear backlog for it.
- User says "I have a rough idea, get me to tickets."
- A `*.pbc.md` change is contemplated and the implementation work needs structured tickets.
- The user explicitly invokes the flow: "/spec-to-linear" or "use spec-to-linear."

## When NOT to use

- The work is one ticket — invoke `linear-issue-spec` directly.
- A spec already exists — skip to step 4 (`linear-decompose`).
- Pure exploration ("look around and tell me what you find") — no flow, just look.
- Fixing a known bug — go straight to `superpowers:systematic-debugging`.

## The canonical flow

```
[1] superpowers:brainstorming   →  shared understanding of intent + constraints
[2] write spec                  →  notes/specs/<slug>.md (or repo convention)
[3] superpowers:writing-plans   →  numbered plan with tasks
[4] linear-decompose            →  draft tickets in markdown for review
[5] linear-issue-spec           →  validate template; create issues; link to project
[6] (optional) linear-pickup    →  begin executing the first ticket
```

## Procedure

### Step 1 — Brainstorm

Invoke `superpowers:brainstorming` first. Do not skip even if the user thinks they know what they want — brainstorming surfaces hidden constraints (auth, data shape, who reads it, failure modes). The brainstorming skill is interactive; expect dialog.

Output: a written-down shared understanding. This is NOT yet the spec.

### Step 2 — Write the spec

Persist the brainstorm output as a spec markdown file. For ks-trader the convention is:
- Behavior changes → update or create the relevant `*.pbc.md` (these ARE the spec for behavior).
- Architectural / infrastructure changes → write a section in `PLAN.md` with date and decision.
- Net-new features without a PBC home → create `notes/specs/<slug>.md` (create the directory if needed).

The spec file is the durable artifact. Tickets reference it.

### Step 3 — Write the plan

Invoke `superpowers:writing-plans`. Input: the spec from step 2. Output: a numbered, ordered plan with concrete tasks, dependencies, and verification.

Plans live where the project convention says (often `notes/plans/<slug>-plan.md`). The plan is denser and more concrete than the spec — closer to ticket-shape.

### Step 4 — Decompose to draft tickets

Invoke `linear-decompose` on the plan output. It produces a markdown document of draft tickets, each with the agent-ready template (Goal / Acceptance Criteria / Scope Fence / Files Likely Touched / Verification).

Do NOT skip showing the draft to the user. Decomposition is where humans push back on boundaries — that's the highest-leverage review point in the whole flow.

### Step 5 — Create Linear issues

After user approval, `linear-issue-spec` validates each draft and creates the issues via `mcp__claude_ai_Linear__save_issue`. Apply:
- `agent-ready` label on every ticket
- `pbc-touched` if the ticket modifies a `*.pbc.md`
- `do-not-agent` instead of `agent-ready` if the work touches secrets, payments, auth, or infra you can't verify

Attach issues to a Linear Project. If no project fits, ask the user whether to create one.

Apply `blockedBy` / `blocks` relationships in a second pass once issue IDs are known.

### Step 6 — (Optional) Begin executing

If the user wants to start work immediately, invoke `linear-pickup` on the first ready ticket. Otherwise stop here — the backlog is ready for sync execution (you, locally) or async execution (cloud agent picks up via webhook).

## Why each step exists

| Step | Why it cannot be skipped |
|---|---|
| Brainstorm | Surfaces hidden requirements that decomposition cannot recover later. |
| Spec | Provides a durable reference tickets can point to ("see spec section 2.3"). |
| Plan | Resolves ordering and dependencies before they become Linear bugs. |
| Decompose | Forces ticket-sized chunks; prevents 200-line "build the thing" tickets. |
| Validate template | Without all five sections, async agents will produce bad work or refuse. |
| Pickup | Ensures the agent starts from a verified spec, not from a vague conversation. |

## Composes with

- Upstream: any superpowers skill that produces specs/plans (`brainstorming`, `writing-plans`).
- Downstream: `linear-decompose`, `linear-issue-spec`, `linear-pickup`, `linear-log`.
- Sibling: `feedback-loop` — useful at step 1 if the brainstorm hits a real design fork.

## Anti-patterns

- **Skipping straight to `linear-decompose`** without a written spec/plan. You'll produce tickets that look complete but fall apart when the agent reads them and finds undefined edge cases.
- **Letting the brainstorming skill write tickets directly.** Brainstorming is dialogic and exploratory; ticket creation is final. Keep them separate or you'll end up with half-baked tickets.
- **Treating each plan task as one ticket 1:1.** Plans often have a "do X, then verify Y, then commit Z" structure where multiple tasks fold into one ticket. Use the heuristics in `linear-decompose`.
