---
name: linear-issue-spec
description: Use when creating a Linear issue or marking an existing issue agent-ready. Enforces the ticket template (Goal, Acceptance Criteria, Scope Fence, Files Likely Touched, Verification) so async agents can pick up without further clarification. Refuse to apply the agent-ready label if any section is missing.
---

# linear-issue-spec

A ticket an agent can execute end-to-end is the actual product. This skill is the gatekeeper between a vague request and an agent-ready issue.

## When to use

- The user says "create a Linear issue/ticket" for any non-trivial work.
- The user asks to apply the `agent-ready` label to an existing issue.
- An agent (e.g. via `linear-pickup`) reads an issue and asks "is this agent-ready?"

## When NOT to use

- The user is creating a Bug or Improvement issue purely to capture context for a human (no agent will run on it). Skip the template.
- The user wants a quick scratch issue ("remind me to look at X"). Don't impose ceremony.

## The agent-ready template

Every issue labeled `agent-ready` MUST have these five sections in its description, in order:

```markdown
## Goal
One paragraph. What changes in the world when this is done. Not a list of steps — the outcome.

## Acceptance criteria
- [ ] Testable claim 1
- [ ] Testable claim 2
- [ ] ...

Each item must be verifiable by a command, a UI check, or a passing test. "Looks good" is not acceptance criteria.

## Scope fence
Out of scope: <list of things the agent must NOT change>.
Examples: "do not modify production CSVs in data/paper/", "do not touch *.pbc.md without explicit approval", "do not add new dependencies".

## Files likely touched
- path/to/file.ts — what role
- path/to/other.ts — what role

If unknown, write "TBD — agent must explore and update this section in its log comment before editing."

## Verification
Exact commands the agent runs to prove acceptance criteria pass:
- `pnpm run typecheck`
- `pnpm test path/to/spec.test.ts`
- `pnpm run report -- --data-source parquet` (manual eyeball OK)
```

## Procedure when creating a new issue

1. Read the user's request. If it's a one-line ask, expand it into the template by asking yourself:
   - What is the *outcome*? (Goal)
   - How will I know it's done? (Acceptance criteria)
   - What could go wrong if scope creeps? (Scope fence)
   - Where in the repo does this live? (Files)
   - What command proves it? (Verification)
2. If you cannot fill all five sections from context, ask the user the *minimum* clarifying questions to fill them. Do not invent.
3. Use `mcp__claude_ai_Linear__save_issue` with the full templated description and label `agent-ready`.
4. If the work touches a `*.pbc.md` file, also apply `pbc-touched`.
5. If the work involves secrets, payments, auth, or infra changes you can't verify, apply `do-not-agent` instead of `agent-ready`.

## Procedure when applying agent-ready to an existing issue

1. Fetch the issue with `mcp__claude_ai_Linear__get_issue`.
2. Parse the description. Check all five section headings exist and are non-empty.
3. If any section is missing or vague:
   - Do NOT apply the label.
   - Post a comment listing exactly which sections need work, using `mcp__claude_ai_Linear__save_comment`.
   - Tell the user what's missing.
4. If all five are present and concrete, apply the label.

## Anti-patterns

- **"Acceptance criteria: tests pass."** Useless. Which tests? Pass on what input?
- **"Scope fence: don't break anything."** Useless. Name specific things not to touch.
- **"Files likely touched: TBD"** without a follow-up plan. The skill allows TBD only if the agent commits to scoping in its log comment first.
- **Multi-objective tickets.** "Refactor X and add feature Y" → split into two issues.

## Project hierarchy convention

For ks-trader (this user's primary repo):

- **Initiative** = north-star (e.g., "Live trading by Q3"). Human-curated only.
- **Project** = an epic-sized push (e.g., "Promote first strategy to live"). Has a target date.
- **Issue** = an agent-ready ticket. Lives under a Project.

When creating an issue for ks-trader, prefer attaching it to a Project. If no Project fits, ask whether to create one or whether the issue is genuinely orphaned (rare).
