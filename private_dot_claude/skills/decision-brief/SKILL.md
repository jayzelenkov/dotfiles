---
name: decision-brief
description: Use when the user is choosing between 2+ options for a personal or consumer purchase decision (gadgets, gear, vehicles, services, vendors, software, courses, schools, etc) and asks for research-backed help — typical phrasing "I'm considering X, Y, Z", "compare these", "help me pick", "should I buy A or B", or pasting 2+ product/vendor URLs.
---

# Decision Brief

## Overview

Produces a research-backed HTML decision document for a personal/consumer choice. Two adversarial agents (Researcher + Critic) run in parallel — one surfaces upside, the other surfaces failure modes — then a third agent (Adviser) synthesizes into a structured HTML page with a real recommendation, not a hedged survey.

**Core principle:** A decision worth asking about is a decision worth running adversarial research on. Single-agent research either over-promises (Researcher voice alone) or under-recommends (Critic voice alone). Both, then synthesis.

## When to use

- User lists 2+ candidate options and asks for an opinion
- User asks "what's the best X for my use case" with non-trivial budget
- Cross-category comparisons ("e-bike vs scooter vs longboard")

**Don't use for:**
- Single-item lookups → web search or Context7
- B2B/enterprise procurement (different rigor)
- Decisions with regulatory/legal weight (consult a professional)
- Decisions the user wants in <2 minutes

## Pipeline

```
1. CLARIFY    — AskUserQuestion (2-4 questions to bound the decision)
2. RESEARCH   — Researcher + Critic agents IN PARALLEL (single message, both background)
3. SYNTHESIZE — Adviser agent composes HTML
4. (OPTIONAL) Cross-category Adviser if user spans modes
```

### Step 1: CLARIFY (mandatory)

Ask 2–4 questions via `AskUserQuestion` covering: use case, hard constraints (budget/size/weight/OS), priorities (#1 must-have vs nice-to-have), user profile (skill level, environment). Don't dispatch agents until answered.

### Step 2: RESEARCH (parallel)

Dispatch **both agents in a single assistant message** with `run_in_background: true`. Use the templates in `references/researcher-prompt.md` and `references/critic-prompt.md` — fill in user profile, options list, budget, category specifics.

The Researcher uses parallel:parallel-deep-research if available; otherwise parallel-web-search and direct vendor sites. The Critic checks Trustpilot, Reddit complaints, recall databases, and reviewer "negative" videos.

### Step 3: SYNTHESIZE (HTML)

Once both agents return, dispatch the Adviser using `references/adviser-prompt.md`. The Adviser MUST:
- Save HTML to user's docs vault (ask path if unknown; default `~/Documents/`)
- Use the canonical design from `references/html-template.html`
- File name: `<topic>-recommendation-YYYY-MM-DD.html`
- Pick a real **primary + backup** recommendation. No hedging.
- Surface any "5th option you didn't consider" the Critic flagged

### Step 4: CROSS-CATEGORY (optional)

If the user is comparing across modes (e-bike vs scooter vs board, React vs Vue vs Svelte), dispatch a final Adviser using `references/cross-modal-prompt.md` to produce a single cross-category HTML with one winner.

## Quick reference

| Phase | Tool | Parallel? |
|---|---|---|
| Clarify | `AskUserQuestion` | n/a |
| Researcher | `Agent(general-purpose, run_in_background: true)` | **yes — same message as Critic** |
| Critic | `Agent(general-purpose, run_in_background: true)` | **yes — same message as Researcher** |
| Adviser | `Agent(general-purpose)` | parallel-OK if multiple HTMLs |

## Common mistakes

| Mistake | Fix |
|---|---|
| Dispatching agents before clarify | Always `AskUserQuestion` first. The clarifications scope the agents' prompts. |
| Running Researcher and Critic sequentially | They MUST be in a single assistant message. Sequential wastes ~5 min. |
| Hotlinking brand product images | 404 risk. Use the styled placeholders from the HTML template. |
| Adviser produces a "balanced survey" | Reject. Adviser must pick a primary + backup with a real call. |
| Forgetting the Critic's "5th option" | If the Critic surfaces an option not in the user's list, the Adviser must include it as a callout. |
| Writing markdown when user prefers HTML | Check user memory for output format preferences. This skill defaults to HTML. |

## Notes on cost

A full run dispatches 3–4 sub-agents and may use parallel-deep-research (paid). Expect 10–20 min wall time and meaningful token spend. Worth it for decisions ≥ $500. Skip the Critic on low-stakes ones to halve the cost.
