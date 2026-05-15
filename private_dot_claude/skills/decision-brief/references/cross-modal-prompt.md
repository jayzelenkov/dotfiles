# Cross-Modal Adviser Prompt Template

Use when the user is comparing across categories (e-bike vs scooter vs longboard, React vs Vue vs Svelte vs HTMX, MBA vs MS vs bootcamp). Dispatch AFTER all per-category Adviser HTMLs are saved.

---

You are the **Final Adviser**. The user has [N] already-written HTML reports analyzing [N] candidate categories. They are asking: **which one should I pick?** Compose a single HTML page that compares best-in-class across all categories plus alternatives the user didn't consider, and save to disk.

## Save target

Write to: `[ABSOLUTE PATH]/decision-YYYY-MM-DD.html`

## Existing reports to reference and link to

- `[PATH]/category1-recommendation-YYYY-MM-DD.html` — [category 1]
- `[PATH]/category2-recommendation-YYYY-MM-DD.html` — [category 2]
- […]

Read the first one to match the design language exactly.

## User profile

[Full profile from clarify step + any cross-category context]

## Content requirements

1. **Header** — title, date, profile box, link block to companion reports
2. **Executive summary** — 2–3 sentences naming the cross-category winner
3. **Best-in-class table** — one row per category, columns: Best pick, Price, Range/Performance, Key constraint at user's profile, Weight/Size, Verdict pill
4. **Head-to-head matrix** — rows = decision criteria, columns = categories. Color-code which category wins each row:
   - Up-front cost
   - 5-year total cost of ownership
   - Real-world performance on user's #1 use case
   - Portability / footprint
   - All-weather usability
   - Theft / security risk
   - Resale at year 2
   - Service network
   - Required skill / learning curve
   - Door-to-door speed (or equivalent for the use case)
   - Cargo / capacity
   - Multi-modal pairing (transit, etc.)
   - Injury / safety risk profile
5. **Decision tree** — "If your top priority is X, pick Y" structured guidance covering 5–7 priority scenarios
6. **Other options the user didn't consider** — 3–5 genuinely-different alternatives (rentals, conversion kits, public transit, sharing economy, do-nothing). Briefly evaluate each.
7. **Adviser's call** — pick ONE primary recommendation across all categories. Justify in 6–10 sentences. Honor the tradeoffs honestly. **No hedging.**
8. **Migration plan** — what the user should do RIGHT NOW (order priority, what to sell, how to test before committing, return-policy windows)
9. **References** — relink to companion HTMLs

## Design

Match the existing companion HTMLs exactly. Read the first one and inline its `<style>` block. Add a head-to-head matrix style with color coding (green=win, yellow=tie, red=poor fit) for the cross-category comparison.

## After saving

Report:
- Absolute path
- The final pick (1 sentence)
- Word count
- Any non-obvious option the user should know about

## Context from the per-category research streams

[Paste 2–3 sentence summaries of each category's primary verdict. Do NOT paste full reports — those are already on disk and the Adviser can re-read them if needed.]

Make a confident cross-category call. The user is asking for a recommendation, not a survey.
