# PI Notes — Team 10

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Expand sample to 1,000,000 abstracts:** Drop the stratified-sample cap of 10 per stratum. Draw a random sample of up to 1,000,000 abstracts from the eligible pool (non-missing abstract, ≥ 50 characters) with `set.seed(42)`. If the eligible pool is smaller than 1,000,000, use the full eligible pool. Update the cost estimate in analysis.R comments accordingly (at ~$0.80/million input tokens for Claude Haiku 3.5, 1,000,000 abstracts at ~500 tokens each ≈ $400–450 total). Log actual cost and halt if it exceeds $800.

2. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a higher share of SSH abstracts classified as purely technocratic (no political references), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
   - **RC2 — Restrict to politically sensitive fields:** Re-estimate on the subset of articles in politically sensitive disciplines (Political Science, International Relations, Law, Sociology, Social Issues, Ethnic Studies, Women's Studies — per Team 03's primary field list). This tests whether the result holds within fields where political vocabulary would be expected, and is not driven by compositional shifts toward apolitical disciplines.

## No redesign required — proceed to Analyst session after revisions
