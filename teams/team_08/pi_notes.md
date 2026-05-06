# PI Notes — Team 08

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit higher mean epistemic hedging rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Restrict to English-language abstracts:** Re-estimate on the subset of abstracts identified as English (e.g. using a simple heuristic such as share of ASCII characters, or the `language` field if available in the corpus). Hedging markers are English-specific; non-English abstracts may introduce noise or systematic bias if autocracies publish more in domestic non-English journals.
   - **RC2 — Narrow hedging dictionary:** Re-estimate removing `"would"` and `"likely"` from the hedging dictionary, as these terms frequently appear in non-defensive academic contexts (e.g. "this would suggest", "future work would benefit"). This tests robustness of results to the broadest-coverage items in the dictionary.

## No redesign required — proceed to Analyst session after revisions
