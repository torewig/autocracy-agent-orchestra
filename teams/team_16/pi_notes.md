# PI Notes — Team 16

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a higher share of SSH articles with exclusively domestic authorship, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Restrict to multi-author articles:** Re-estimate computing `share_domestic_only` only over articles with `n_authors > 1`. Single-author papers always score as domestic-only regardless of self-censorship; this restriction isolates the collaboration avoidance effect from single-authorship rates (which are Team 17's domain).
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
