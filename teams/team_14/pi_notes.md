# PI Notes — Team 14

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower mean number of distinct co-author countries per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Restrict to multi-author articles:** Re-estimate computing `mean_n_coauthor_countries` only over articles with `n_authors > 1`. This separates the international breadth effect from single-authorship rates, since solo-authored papers are indistinguishable from domestically co-authored papers in the primary specification (both score 1).
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
