# PI Notes — Team 15

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will have a lower share of SSH articles co-authored with researchers from liberal democracies (v2x_libdem > 0.5), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Vary the liberal democracy threshold:** Re-estimate using alternative co-author democracy thresholds: (a) v2x_regime >= 2 (electoral democracy or above) and (b) v2x_regime == 3 (liberal democracy only). This tests sensitivity to the arbitrary 0.5 cut-point on the continuous scale.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` (focal country) with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
