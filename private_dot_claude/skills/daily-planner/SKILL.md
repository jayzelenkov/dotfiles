---
name: daily-planner
description: Use when Jay wants help planning his day, structuring tasks, asks to "plan today/tomorrow", "what should I focus on today", "structure my day", or shares a list of things he wants to accomplish today (e.g. "today I want to do X, Y, Z — help me schedule it"). Pulls calendar from Fastmail (Plan / Jay Zelenkov / Dawny Z), habits from `~/Documents/JZ/03-areas/_Habits.md`, errands from macOS Reminders.app (Errands list, Mac-only), then composes a prioritized plan and appends it to today's Obsidian daily note at `~/Documents/JZ/01-daily/YYYY-MM-DD.md`. Gracefully degrades on surfaces without filesystem/Reminders access (Claude.ai web, iOS) by rendering the plan in chat instead.
---

# Daily Planner

## Overview

Composes a prioritized day plan for Jay by combining three inputs — his stated goals for the day, fixed calendar events, and recurring obligations (habits + errands). Writes the plan to today's Obsidian daily note.

**Core principle:** A day plan honors fixed time blocks first, then user-declared priorities, then habits, then errands. The planner never silently drops items — if something doesn't fit, it surfaces the conflict and asks.

## When to use

- User explicitly asks to plan their day ("plan today", "structure my day", "what should I focus on today")
- User shares a brain-dump of today's intended work ("today I want to: A, B, C — help me schedule")
- Morning kickoff routines

**Don't use for:**
- Multi-day or weekly planning → that's a separate workflow (weekly review)
- One-off "add this event to my calendar" requests → use Fastmail MCP directly
- Retrospectives ("what did I do today") → daily note already exists; just read it

## Inputs

| Source | Tool | Surface availability |
|---|---|---|
| User's stated goals | conversation / `AskUserQuestion` | all |
| Calendar events (today) | Fastmail MCP — `list_calendar_events` against Plan, Jay Zelenkov, Dawny Z | all |
| Habits list | `Read` of `~/Documents/JZ/03-areas/_Habits.md` | Claude Code on Mac, Desktop w/ FS MCP |
| Errands | `Bash` running `osascript` against Reminders.app "Errands" list | Mac only (Claude Code, Desktop) |
| Daily note (existing content + append target) | `Read` + `Edit` of `~/Documents/JZ/01-daily/YYYY-MM-DD.md` | Claude Code on Mac, Desktop w/ FS MCP |

## Pipeline

```
1. CAPTURE   — User's goals for the day (ask if not yet provided)
2. GATHER    — Calendar + habits + errands IN PARALLEL (single message)
3. COMPOSE   — Build prioritized plan (calendar fixed, then goals, then habits, then errands)
4. WRITE     — Append `## Plan` section to today's daily note (don't clobber)
5. SUMMARIZE — Short chat summary of what was scheduled + any conflicts surfaced
```

### Step 1: CAPTURE

If the user has already shared their goals in the conversation, use that. Otherwise, ask **one** short question via `AskUserQuestion`:

> "What do you want to accomplish today? (Free-form list — I'll structure it around your calendar.)"

Don't over-clarify. If the user says "just plan around my calendar", skip to step 2 with empty goals.

### Step 2: GATHER (parallel)

Issue all three reads in a **single assistant message** with parallel tool calls:

1. **Fastmail calendar**: list events for today across all three calendars (Plan / Jay Zelenkov / Dawny Z). Use the native Fastmail MCP. Today's date is dynamic — use `currentDate` from system context.
2. **Habits**: `Read` `~/Documents/JZ/03-areas/_Habits Overview.md` (preferred — fall back to `_Habits.md` if not found). Each `- [ ]` line is a candidate habit, with metadata in parentheses: duration (e.g. `1hr`, `3hr`) and applicability rule (`every day`, `Monday-Friday`, `Tuesday, Thursday, Sunday`, `starting from M/DD`). **Parse the metadata, don't just read names.** Today's *applicable* habits = unchecked AND day-of-week matches today AND start-date has passed.
3. **Errands** (Mac only): run `osascript -e 'tell application "Reminders" to get name of (reminders of list "Errands" whose completed is false)'` via Bash. Returns a comma-separated string. If `osascript` is unavailable (non-Mac surface), skip silently.

If a surface lacks filesystem (web/iOS), skip habits + errands and run with calendar-only data. Mention the degradation in the final summary.

### Step 3: COMPOSE

**First: state today's day of week explicitly** ("Day: Friday, 2026-05-15") at the top of the plan. The skill must reason about day-of-week before listing habits.

Build the day plan respecting this priority order:

1. **Calendar events** are immutable time blocks. Note them with times.
2. **Goals from CAPTURE** slot into the largest open blocks, sized realistically (don't promise 4 hours of deep work if calendar has 3 meetings).
3. **Habits applicable today** fill remaining blocks, sized to their stated duration. Habits NOT applicable today (wrong day, future start date) go in a separate `### Habits not applicable today` block with the reason — never silently dropped.
4. **Errands** fill remaining slack — typically as a single "Errands batch" block, not individually timed.

**Surface habit-duration gaps explicitly.** If the user's stated goal undershoots a habit (e.g. user says "1h Build Agents" but habit says 3h), call it out in `### Conflicts / gaps` — don't silently accept the shorter version.

Output structure (markdown, see `references/plan-template.md` for exemplar):

```markdown
## Plan

**Today's focus:** <1-line summary of the top 1-2 priorities>

### Fixed
- HH:MM–HH:MM — <event> (calendar: Plan|Jay|Dawny)

### Priorities (from your goals)
- <goal 1> — proposed slot HH:MM–HH:MM
- <goal 2> — proposed slot HH:MM–HH:MM

### Habits
- [ ] <habit>
- [ ] <habit>

### Errands (batch — when you have 20 min)
- <errand>
- <errand>

### Conflicts / deferred
- <thing> — <reason>
```

Skip empty subsections entirely (don't write `### Errands` if errands is empty).

### Step 4: WRITE

Target file: `~/Documents/JZ/01-daily/YYYY-MM-DD.md` where YYYY-MM-DD = today.

**Append behavior:**
- **Note doesn't exist**: create it from the [daily-notes-template](/Users/jzelenkov/Documents/JZ/90-templates/daily-notes-template.md) (copy the `## Weekly Glance` / `## Log` / `## Decisions` scaffold), then append `## Plan` at the top before `## Weekly Glance`.
- **Note exists, no `## Plan` section**: insert `## Plan` as the first section (above `## Weekly Glance`). Jay reads top-down; daily plan should be first.
- **Note exists, `## Plan` already there**: ask via `AskUserQuestion`: Replace / Amend / Skip. Default to Amend (append new bullets under existing subsections, preserve checked boxes).

Never modify `## Log`, `## Decisions`, `## Weekly Glance`, or any user-authored content.

### Step 5: SUMMARIZE

After writing, print a **3-line** chat summary:
1. What's the top focus today (one line)
2. How many items scheduled / how many deferred (one line)
3. Where it was written (file path link) and any surface degradation (one line)

Example: *"Top focus: ship KS-Trader v0.2. Scheduled 4 priorities, 2 habits, 3 errands; deferred Mando (no time after meetings). Written to [2026-05-15.md](/Users/jzelenkov/Documents/JZ/01-daily/2026-05-15.md)."*

## Cross-surface behavior

| Surface | Behavior |
|---|---|
| Claude Code on Mac | Full pipeline — reads Reminders + writes Obsidian |
| Claude Desktop on Mac (w/ FS + AppleScript MCP) | Full pipeline if those MCPs installed; otherwise calendar-only |
| Claude Desktop without filesystem access | Calendar-only; renders plan in chat, asks user to paste into note |
| Claude.ai web | Calendar-only; chat output |
| Claude iOS | Calendar-only; chat output |

When degrading, **always state in the summary** what was skipped (e.g. "Habits + errands skipped — no filesystem access on this surface").

## Quick reference

| Phase | Tool | Parallel? |
|---|---|---|
| Capture | `AskUserQuestion` (if needed) | n/a |
| Gather calendar | Fastmail MCP `list_calendar_events` | **yes — same message as habits + errands** |
| Gather habits | `Read` `_Habits.md` | **yes** |
| Gather errands | `Bash` osascript | **yes** |
| Compose | (local reasoning) | n/a |
| Write | `Edit` or `Write` daily note | n/a |

## Common mistakes

| Mistake | Fix |
|---|---|
| Reading calendar/habits/errands sequentially | Single message, parallel tool calls. Sequential adds ~3× latency. |
| Clobbering existing daily note | Always `Read` first. Only append `## Plan`; never touch `## Log` / `## Decisions`. |
| Over-scheduling on a meeting-heavy day | Be realistic. If calendar has 5h of meetings, you have ~3h of deep work, not 8. |
| Silently dropping unscheduled goals | Surface them in the `### Conflicts / deferred` block with a reason. |
| Asking user to clarify habits or errands | The lists are authoritative. Don't re-litigate what counts as a habit. |
| Writing to wrong date | Use `currentDate` from system context, not assumptions. |
| Listing all habits regardless of day | Parse the `(every day)` / `(Monday-Friday)` / `(Tuesday, Thursday, Sunday)` / `(starting from M/DD)` metadata. List inapplicable ones in their own section with the reason, don't pretend they're optional today. |
| Honoring user's stated duration over habit-target | If user says "1h Build Agents" and habit says 3h, flag the 2h gap in `### Conflicts / gaps`. Don't silently take the shorter number. |
| Reading stale habits filename | The file is `_Habits Overview.md` (with space). Fall back to `_Habits.md` only if Overview missing. |
| Using HTML format | Daily notes are markdown. HTML preference applies to [[obsidian_vault_html_preference]] *trackers/analyses*, not daily notes. |

## Notes on calendar defaults

If the user asks the planner to *create* a new calendar event (e.g. "block out 2pm-4pm for KS-Trader work"), default to the **Plan** calendar per [[feedback-calendar-default]]. Don't ask which calendar unless the user explicitly names another.

## When to push back

If the user shares a goal list that's clearly unrealistic for the available time (e.g. "today I want to ship 3 apps and learn Mandarin and bike 50 miles" with 6h of meetings), name the gap honestly in the summary — don't pretend the math works. Offer to defer items or strip meetings.
