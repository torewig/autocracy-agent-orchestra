# PI Notes — Team 17

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower mean number of authors per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Field fixed effects:** Re-estimate at the country × subject_primary × year level, adding `subject_primary` fixed effects (or `subject_primary × year` FE) to control for disciplinary norms that strongly correlate with team size. This is the critical robustness check: if the result disappears after absorbing field composition, it is likely driven by disciplinary mix rather than self-censorship.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
