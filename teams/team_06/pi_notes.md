# PI Notes — Team 06

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

2. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit lower mean pairwise semantic diversity of SSH abstracts within country-field-year clusters, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

3. **Robustness check — country-field-year level:** Add a pre-specified robustness check to analysis_plan.md: re-estimate the primary model at the country × subject_primary × year level (rather than aggregating to country-year), including `subject_primary × year` fixed effects in addition to country FE. This tests whether the result holds within field-year cells and is not driven by field composition shifts.

4. **Large cell handling:** Specify in analysis_plan.md how to handle computationally large cells. Proposed rule: within each country × subject_primary × year cell, if the number of articles exceeds a threshold (e.g. N > 500), draw a random subsample of 500 articles with `set.seed(42)` before computing pairwise distances. Record the threshold and the number of cells affected in analysis.R comments.

## No redesign required — proceed to Analyst session after revisions
