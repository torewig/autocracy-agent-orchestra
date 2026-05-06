# PI Notes — Team 05

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Expand sample to 2,000,000 abstracts:** Drop the stratified sampling cap. Classify up to 2,000,000 article-country rows from the corpus (filter to non-missing abstracts of ≥ 50 characters; if the eligible pool exceeds 2,000,000, draw a random sample of exactly 2,000,000 with `set.seed(42)`). PI has approved the increased API cost. **Note for Analyst:** Update the cost estimate in analysis.R comments — at ~$0.80/million input tokens for Claude Haiku 3.5, 2,000,000 abstracts at ~500 tokens each ≈ $800–900 total. Log actual cost and halt if it exceeds $1,500.

2. **Co-authored papers — classify per author-country row:** For articles with multiple author countries, classify each article-country row independently, using the respective `iso3` as the "own country" reference for that row. This means a paper co-authored by a Chinese and an American researcher will be classified twice — once asking "does this critically examine China?" and once asking "does this critically examine the US?" This is intentional: the unit of analysis is the article-country observation, consistent with the rest of the corpus structure.

3. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower share of SSH articles critically examining their own governance and institutions, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

4. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

5. **Validation sample:** Increase manual validation to 70 abstracts per class (70 × 3 = 210 abstracts total) for CRITICAL-DOMESTIC, NEUTRAL-DOMESTIC, and NOT-DOMESTIC.

## No redesign required — proceed to Analyst session after revisions
