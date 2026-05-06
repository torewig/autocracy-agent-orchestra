# PI Notes — Team 07

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will have a lower share of SSH articles acknowledging international funding agencies, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
   - **RC2 — Restrict to grant_agencies field only:** Re-estimate excluding the abstract fallback, using only articles where the `grant_agencies` field is non-missing. This tests whether results are driven by the fallback matching strategy rather than dedicated funding metadata.

## No redesign required — proceed to Analyst session after revisions
