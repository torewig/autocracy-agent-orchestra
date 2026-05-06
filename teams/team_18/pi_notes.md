# PI Notes — Team 18

## Gate B decision: Approved with revisions

**Date:** 2026-05-06

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower mean number of distinct author institutions per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, log population, and mean co-author country count.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)`, `log(e_wb_pop)`, and `mean_n_coauthor_countries` (country-year mean of distinct co-author countries per article, from Team 14's construction). Adding this control separates the institutional breadth mechanism from the international collaboration breadth mechanism — without it, the coefficient on v2x_libdem could reflect cross-border collaboration suppression (Team 14's domain) rather than organizational fragmentation per se.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Restrict to multi-author articles:** Re-estimate `mean_n_inst` only over articles with `n_authors > 1`. Single-author articles always score 1 institution regardless of regime; this restriction isolates the institutional breadth effect among collaborative papers.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
