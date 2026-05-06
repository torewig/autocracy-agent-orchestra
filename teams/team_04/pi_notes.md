# PI Notes — Team 04

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will have a lower share of SSH articles containing regime-sensitive terms in titles, author keywords, and abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Extend matching to abstracts:** The primary outcome should match the regime-sensitive dictionary across title, author keywords, AND abstract (not title + keywords only). Update rq.md and analysis_plan.md accordingly. Rationale: abstracts are the most complete textual record of a paper's content; restricting to title + keywords may miss papers that discuss sensitive topics without flagging them in metadata.

3. **Fix dictionary — protest cluster:** Remove `"demonstrat"` from the protest cluster. It is too broad and will match "demonstrate", "demonstrated", "demonstrates" — common scientific language. Replace with the specific stem `"demonstration"` (which captures demonstrations, mass demonstration, protest demonstration, etc.).

4. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Title + keywords only:** Re-estimate restricting the match to title and author keywords only (the original specification), to test whether the abstract extension changes the result.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

5. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

## No redesign required — proceed to Analyst session after revisions
