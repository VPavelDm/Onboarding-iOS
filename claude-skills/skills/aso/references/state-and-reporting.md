# State & Reporting

## aso/state.json (one per app, committed to the app repo)

```json
{
  "app_id": "6467501401",
  "runs": [
    {
      "date": "2026-07-12",
      "listing": { "us": { "name": "...", "subtitle": null, "rating": 4.8, "rating_count": 17, "version": "1.81" } },
      "ranks": { "us": { "german vocabulary app": 12, "der die das": 3 } },
      "reviews": { "velocity_per_month": 2, "themes": ["wants android", "loves focus mode"] },
      "competitors": { "1234567890": { "name": "...", "rating_count": 480, "note": "new subtitle targets 'flashcards'" } },
      "analytics": { "impressions": 5200, "page_views": 900, "conversion": 0.031, "top_search_terms": ["der die das"] },
      "providers": { "posthog_first_opens": 210, "activation_rate": 0.44, "trial_starts": 18, "trial_to_paid": 0.33 },
      "actions": [
        { "type": "release", "what": "subtitle en-US set to 'German words & der die das'",
          "target_metric": "impressions", "expect": "visible within 2 cycles" },
        { "type": "code", "what": "review prompt after 7-day streak", "target_metric": "rating_count" }
      ]
    }
  ]
}
```

Append one run object per invocation; never rewrite history. The `actions[].target_metric`
field is what makes month-over-month attribution possible — always fill it.

## aso/reports/YYYY-MM.md

Lead with the verdict, then evidence. Template:

```markdown
# ASO Report — {App} — {YYYY-MM}

**Verdict:** {one sentence: where the bottleneck is and what this month's actions target}

## Metrics vs last month
| Metric | Last | Now | Δ |
(ranks per priority keyword, rating count/value per storefront, impressions, conversion,
 first-opens, trial starts — only rows with data; "unavailable" rows listed once below)

## Last month's actions → outcomes
(each past action: target metric, expected vs observed, keep/iterate/revert)

## Diagnosis
(visibility vs conversion, per storefront, with the 2–3 data points that drove it)

## Actions taken this run
(`[now]` applied · `[release]` pack at aso/metadata-pack-YYYY-MM.md · `[code]` diffs landed)

## Your queue (`[human]`)
(checkbox list with concrete instructions)

## Data gaps
(sources unavailable this run + what enabling them would add)
```

## Hygiene

- Commit `aso/` with the app repo so history travels with the project.
- The metadata pack is a dated file (`aso/metadata-pack-YYYY-MM.md`) — never overwrite an
  old pack; the user may not have pasted it yet.
- If a proposed action from last month was NOT executed (pack not pasted, release not
  shipped), carry it forward explicitly rather than proposing it again as new.
