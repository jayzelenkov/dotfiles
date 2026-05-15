---
name: feedback-loop
description: Forcing function for rigorous problem-solving on non-trivial decisions. Use for design choices (which approach is best?), refactoring trade-offs, root-cause diagnostics ("why is X happening?"), and any decision where shipping the wrong answer is costly. Outputs structured option/hypothesis lists with pros, cons, self-criticism, and an explicit recommendation. Skip for trivial tasks (rename, format, one-line fix) or when the user has explicitly named the approach.
---

# Feedback-loop

A two-variant procedure that forces structure on otherwise-vibey decisions. Pick one variant based on the question shape:

| Question shape | Variant |
|---|---|
| "Which approach should we take?" / "How should we design X?" / "What's the right trade-off?" | **Design** |
| "Why is X happening?" / "What's causing this?" / "What's broken?" | **Diagnostic** |

Both variants share the same north star: surface the *real* answer (not the first plausible-sounding one) by attacking each candidate explicitly, then commit.

## When NOT to use this skill

- Trivial tasks: rename a variable, format a file, fix a typo
- The user explicitly says "just do X" with X well-defined
- Reactive bug-stomp tasks ("the build is broken, fix it") — just fix it
- Pure information lookup ("what's the syntax for foo?")

The cost of feedback-loop is time + tokens; for big decisions that cost is well-spent, for small ones it's friction.

---

# Variant A — Design (picking among approaches)

## Procedure

```
1. Propose 5 distinct options    (not minor variants — five tweaks of one
                                  idea is ONE option, not five)
2. For each option, produce:
   a. one-line description
   b. PROS  (what it gets right)
   c. CONS  (intrinsic limitations)
   d. SELF-CRITICISM (active attack — "where does this break?",
                     "what's the worst data that invalidates this?")
3. Final recommendation
   - Single winner if one option is clearly stronger after self-criticism
   - Multiple if it's a true judgment call — name the trade-off explicitly
4. Implement (if winner is clear)
5. Verify on real data — e2e test, smaller slice, manual sanity check
6. Be 100% confident before declaring "ready"
```

## Required output structure

When producing the analysis, conform to this schema:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["question", "options", "recommendation", "verify_plan"],
  "properties": {
    "question": {
      "type": "string",
      "description": "One-sentence framing of the decision."
    },
    "options": {
      "type": "array",
      "minItems": 2,
      "maxItems": 5,
      "items": {
        "type": "object",
        "required": ["id", "name", "description", "pros", "cons", "self_criticism"],
        "properties": {
          "id": {"type": "string", "pattern": "^[A-E]$"},
          "name": {"type": "string"},
          "description": {"type": "string"},
          "pros": {"type": "array", "items": {"type": "string"}, "minItems": 1},
          "cons": {"type": "array", "items": {"type": "string"}, "minItems": 1},
          "self_criticism": {
            "type": "string",
            "description": "Active attack on the option. NOT a restatement of cons. Identifies the worst case, hidden assumption, or breaking failure mode."
          }
        }
      }
    },
    "recommendation": {
      "type": "object",
      "required": ["verdict", "rationale"],
      "properties": {
        "verdict": {
          "oneOf": [
            {"type": "string", "pattern": "^[A-E]$"},
            {"type": "string", "enum": ["genuine_judgment_call"]}
          ]
        },
        "rationale": {"type": "string"},
        "trade_off_if_judgment_call": {"type": "string"}
      }
    },
    "verify_plan": {
      "type": "string",
      "description": "How we'll prove it works on real data after implementing."
    }
  }
}
```

For human-facing output, render this as markdown with one section per option, then a "## Recommendation" + "## Verification" block.

## Few-shot exemplar — design

**User:** "How should we cache API responses for the recommendations service?"

**Output:**

> **Question:** Pick a caching strategy for the recommendations API where p99 latency target is 200ms and the dataset updates every ~5 min.
>
> ### Option A — Redis with TTL=300s
> **Description:** Standard distributed cache, set/get keyed by request hash.
> **Pros:** Multi-instance shareable; battle-tested; sub-ms gets.
> **Cons:** Extra infrastructure dependency; serialization overhead.
> **Self-criticism:** Stampedes on hot-key TTL expiry will hammer the upstream service. Without explicit single-flight or jittered TTLs, every cache miss spawns N concurrent backend calls. Worst case at scale: 10K req/s all hitting upstream when a popular key expires.
>
> ### Option B — In-process LRU
> **Description:** `lru-cache` per app instance.
> **Pros:** Zero network hops; no infra cost; simplest.
> **Cons:** Per-instance, so N instances → N×memory and N× upstream load on cold start.
> **Self-criticism:** Across deploys (rolling restart), every instance is cold simultaneously, producing a cache stampede on top of the deploy. With 50 instances, that's 50× normal upstream load for ~30s every deploy. Will get noticed.
>
> ### Option C — Write-through to local disk
> **Description:** Cache file per response; OS page cache handles hot reads.
> **Pros:** Persistent across restarts; bounded by disk.
> **Cons:** Disk I/O on cache miss; corrupt file handling.
> **Self-criticism:** Concurrent writes need locking; cache invalidation across instances is not free; you've reinvented Redis poorly. Not actually solving the problem.
>
> ### Option D — CDN edge cache
> **Description:** Cloudflare/Fastly fronting the API.
> **Pros:** Global; no app changes; observable.
> **Cons:** Per-region replication lag; per-user keys break edge cacheability.
> **Self-criticism:** Recommendations are personalized — the cache key includes user_id. CDN hit rate will be near zero unless we shard by user-segment buckets. Wrong tool for personalized data.
>
> ### Option E — Don't cache; tune the upstream
> **Description:** Add an index, parallelize sub-queries, accept current latency.
> **Pros:** No new failure modes; cleanest architecture.
> **Cons:** Doesn't actually meet the 200ms target if upstream is the bottleneck.
> **Self-criticism:** "Just make it faster" handwaves the 5-second p99 we already measured. Without a concrete plan for how it gets to 200ms, this is wishful thinking.
>
> ## Recommendation: **A (Redis with TTL=300s)**, with single-flight + jittered TTLs.
>
> A's self-criticism (stampedes) is real but solved by well-known patterns: `redis-lock` single-flight on miss + ±10% TTL jitter. B's deploy-stampede problem is structurally harder. C/D fail the personalization model. E doesn't have a plan.
>
> ## Verification
> Load-test with k6 at 10K req/s sustained, measure: cache hit rate ≥95%, p99 latency ≤200ms, and verify single-flight kicks in by counting upstream calls during artificial TTL expiry.

---

# Variant B — Diagnostic (root-cause analysis)

## Procedure

```
1. Generate multiple hypotheses (typically 5–10)
   Each hypothesis is a candidate EXPLANATION, not a fix.
2. For each:
   a. Claim — what the hypothesis asserts
   b. Falsification test — what would prove it WRONG
                          (a hypothesis you can't falsify is a vibe, not science)
   c. Expected result if true vs if false
   d. Self-criticism — where the hypothesis is weak
3. Rank by likelihood given current evidence
4. Recommend:
   a. Investigation steps (run the falsification tests)
   b. Tripwires — what would change your mind later
5. After investigation, report findings (CONFIRMED / FALSIFIED / INCONCLUSIVE per hypothesis)
6. Implement fix for confirmed root cause(s); add tripwires for any uncertain ones
```

## Required output structure

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["phenomenon", "hypotheses", "investigation_plan"],
  "properties": {
    "phenomenon": {
      "type": "string",
      "description": "Clear statement of WHAT we're explaining."
    },
    "hypotheses": {
      "type": "array",
      "minItems": 2,
      "items": {
        "type": "object",
        "required": ["id", "claim", "falsification_test", "self_criticism", "prior_likelihood"],
        "properties": {
          "id": {"type": "string", "pattern": "^H[0-9]+$"},
          "claim": {"type": "string"},
          "falsification_test": {
            "type": "string",
            "description": "Concrete observation/experiment that would prove this WRONG."
          },
          "expected_if_true": {"type": "string"},
          "expected_if_false": {"type": "string"},
          "self_criticism": {"type": "string"},
          "prior_likelihood": {
            "type": "string",
            "enum": ["high", "medium", "low"]
          },
          "verdict": {
            "type": "string",
            "enum": ["pending", "confirmed", "falsified", "inconclusive"]
          },
          "evidence": {"type": "string"}
        }
      }
    },
    "investigation_plan": {
      "type": "array",
      "items": {"type": "string"},
      "description": "Ordered steps to run, cheapest+highest-info first."
    },
    "tripwires": {
      "type": "array",
      "items": {"type": "string"},
      "description": "What would change the verdict later (e.g., 'if X happens again after fix, H7 was wrong')."
    },
    "recommendation": {
      "type": "object",
      "properties": {
        "primary_root_cause": {"type": "string"},
        "fix_scope": {"type": "string"},
        "verify_plan": {"type": "string"}
      }
    }
  }
}
```

## Few-shot exemplar — diagnostic

**User:** "This SQL query was 50ms last week, now it's 5 seconds. Why?"

**Output:**

> **Phenomenon:** A SELECT query against `orders` table degraded from p50=50ms to p50=5s between 2024-03-10 and today. Same query text, same parameters, no schema changes deployed.
>
> ### H1 — Bad plan from stale statistics  *(prior: high)*
> **Claim:** Stats haven't been refreshed; planner picks a sequential scan instead of an index seek now that data distribution shifted.
> **Falsification test:** `EXPLAIN ANALYZE` the query; check actual vs estimated rows. If estimate is off by >10× the table needs ANALYZE.
> **Expected if true:** EXPLAIN shows seq scan on a column that has an index; row estimate is wildly off.
> **Self-criticism:** Modern Postgres autovacuum/autoanalyze runs daily; would need a specific reason for stats to be that stale.
>
> ### H2 — Index bloat / dead tuples  *(prior: medium)*
> **Claim:** A churn pattern grew the index without compaction; index pages are mostly dead tuples.
> **Falsification test:** `pg_stat_user_indexes` for the relevant index → check `idx_scan` ratio + size growth vs row count.
> **Expected if true:** Index is N× larger than expected for the row count.
> **Self-criticism:** Bloat usually slows things 2-3×, not 100×. Real but probably not the dominant factor.
>
> ### H3 — Lock contention  *(prior: medium)*
> **Claim:** Another transaction is holding a lock the SELECT needs.
> **Falsification test:** `pg_stat_activity` during a slow execution; look for `wait_event_type = Lock`.
> **Expected if true:** Slow query has wait_event_type=Lock; specific blocker visible.
> **Self-criticism:** SELECTs only block on AccessExclusiveLock holders (DDL, VACUUM FULL). Common in OLTP only during deploys/migrations.
>
> ### H4 — Buffer cache cold  *(prior: low)*
> **Claim:** A restart or eviction blew away the hot pages; first reads hit disk.
> **Falsification test:** Run the query twice; measure t1 vs t2. If t2 ≪ t1 it's I/O cold.
> **Expected if true:** First run 5s, second run <100ms.
> **Self-criticism:** If this were the cause, only the first run after restart would be slow. The user reports consistent slowness, so this is unlikely the dominant factor.
>
> ### H5 — Parameter sniffing on prepared statement  *(prior: medium-high)*
> **Claim:** The plan got cached based on an atypical first parameter and is now applied to all subsequent invocations.
> **Falsification test:** Run with `EXPLAIN (ANALYZE, GENERIC_PLAN)` vs the cached one; compare. Or compare execution time of fresh prepare vs cached.
> **Expected if true:** A direct (unprepared) version of the query is fast; the prepared version is slow.
> **Self-criticism:** Requires the application to use prepared statements with bind parameters. If it concatenates SQL strings, this hypothesis is moot.
>
> ## Investigation plan (cheapest + highest-info first)
> 1. Run `EXPLAIN ANALYZE` on the slow query — covers H1, H2, H4 in one shot.
> 2. Check `pg_stat_activity` during a slow run — H3.
> 3. Compare prepared-vs-direct timings — H5.
>
> ## Tripwires
> - If we ANALYZE the table and the problem persists, H1 is wrong; revisit H5.
> - If query speeds up only briefly after VACUUM, H2 is the dominant factor.
> - If query stays fast after fix for 7 days then degrades again, the underlying churn pattern is recurring; need a maintenance schedule, not a one-off fix.

---

# When the decision is binary

If there are *truly* only two paths, say so explicitly and produce two options. Don't pad with straw-men. The skill's value is in honest analysis, not in formulaic five-bullet lists.

```
"This is a binary choice between A and B; not five-option territory."
```

# Common failure modes (avoid these)

1. **Padding to 5** — listing minor variants instead of distinct approaches. If options 4 and 5 feel forced, they probably are.
2. **Pros/cons with no real self-criticism** — balanced disclaimer-like text that doesn't actually attack. Self-criticism should make the option look bad if it deserves to.
3. **Burying the recommendation** — putting it deep in prose so you don't have to commit. The recommendation should be the loudest piece of the response.
4. **Skipping verify** — "I implemented it, should be fine" without running. Step 5 is non-optional for any non-trivial change.
5. **Hypotheses that can't be falsified** — a vibe like "the API is haunted" isn't a hypothesis. Each must come with a concrete falsification test.
6. **Fake judgment calls** — declaring "it's a true trade-off" to avoid committing when one option is actually stronger.

# Verification & "ready" checklist

Before declaring done:

- [ ] Implemented option survives a fresh self-criticism pass
- [ ] Verification run on real (not stub/mock) data
- [ ] At least one edge case tested
- [ ] No "should work" claims — only "verified to work because X"
- [ ] If diagnostic: confirmed root cause is the one we fixed, not a coincidence

If any unchecked: not ready.
