# PI Notes — Team 13

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will publish a higher share of SSH output in domestically dominated journals, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add the following pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Vary domesticity threshold:** Re-estimate using alternative journal domesticity thresholds of 50% and 70% (in addition to the primary 60% threshold). This tests whether results are sensitive to the arbitrary cut-point.
   - **RC2 — Restrict to small and medium SSH producers:** Re-estimate excluding country-years above the 75th percentile of `n_articles_country_year`. Large producers (USA, UK, China) mechanically dominate many journals; this restriction reduces that confound and tests whether the effect holds among smaller research communities.
   - **RC3 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
