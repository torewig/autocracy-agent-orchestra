# PI Notes — Team 22

## Gate B decision: Approved with revisions

**Date:** 2026-05-06

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a higher Gini coefficient of citations across SSH articles, after controlling for country fixed effects, year fixed effects, log GDP per capita, log population, and log article volume.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)`, `log(e_wb_pop)`, and `log(n_articles)` (log of the number of deduplicated articles in the country-year cell, to account for mechanical compression of the Gini in large output cells).

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Exclude recent articles:** Re-estimate dropping articles published after 2018. Recent articles have had less time to accumulate citations, and zero-citation articles are more common among recent output, which mechanically inflates the Gini. This tests whether results are robust to citation maturity concerns.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
