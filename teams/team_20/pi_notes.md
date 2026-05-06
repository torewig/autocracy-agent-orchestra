# PI Notes — Team 20

## Gate B decision: Approved with revisions

**Date:** 2026-05-06

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: The citation penalty associated with lower v2x_libdem scores will be larger for politically sensitive articles than for non-sensitive articles, as indicated by a positive coefficient on the v2x_libdem × sensitive_flag interaction term, after controlling for country fixed effects, year fixed effects, field fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)` (merged at the country-year level). Field fixed effects (or field-year fixed effects) should also be specified as part of the model to account for differential citation norms across disciplines.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Alternative sensitivity flag:** Re-estimate using Team 03's disciplinary sensitivity classification (`subject_primary` in politically sensitive WOS field) as the sensitivity indicator, instead of Team 04's keyword flag. This tests whether the interaction result is robust to how "sensitivity" is operationalized.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
