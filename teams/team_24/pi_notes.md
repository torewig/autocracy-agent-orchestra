# PI Notes — Team 24

## Gate B decision: Approved with revisions

**Date:** 2026-05-06

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a higher share of SSH abstracts that actively legitimize or endorse the current political system, state authority, or leadership, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Sensitive fields only:** Re-estimate restricting the abstract sample to articles in politically sensitive WOS subject categories (Team 03's field list: political science, international relations, law, sociology, social issues, ethnic studies, women's studies). Legitimating framing should be most visible in fields where engagement with state and governance is constitutive; this tests whether the result concentrates where expected.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

4. **Sampling strategy:** Increase the target sample and add an explicit sampling section to rq.md and analysis_plan.md. Target approximately **1,000,000 abstracts**, stratified by `iso3` × `v2x_regime` (4-category) × decade. At Claude Haiku rates (~$0.80/MTok input, ~$4/MTok output, ~600 input tokens + ~10 output tokens per abstract), cost is approximately $0.00052 per abstract, giving ~$520 for 1M abstracts. Set `set.seed(42)` for reproducibility. **Hard cost ceiling: $500** — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500.

## No redesign required — proceed to Analyst session after revisions
