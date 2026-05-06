# PI Notes — Team 12

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Fallback to full abstract:** Clarify in analysis_plan.md that the full abstract is used as input whenever last-two-sentence extraction fails or yields fewer than 20 characters. This is already mentioned in rq.md but should be the explicit primary fallback rule in the analysis code.

2. **Expand sample to ~$500 API budget:** Drop the 10-per-stratum cap. Draw a random sample of abstracts sized to stay within a $500 API budget. At Claude Haiku 3.5 pricing (~$0.80/million input tokens, ~500 tokens per abstract including prompt overhead), this corresponds to approximately 1,000,000–1,250,000 abstracts. The Analyst should calculate the exact maximum N at current API pricing before running, log the estimate in analysis.R, and halt if actual cost exceeds $700. Use `set.seed(42)`.

3. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower share of SSH abstracts ending with an explicit normative or policy conclusion, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

4. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

5. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
   - **RC2 — Restrict to politically sensitive fields:** Re-estimate on the subset of articles in politically sensitive disciplines (Political Science, International Relations, Law, Sociology, Social Issues, Ethnic Studies, Women's Studies). Tests whether normative conclusion suppression is concentrated in fields where policy recommendations are most politically exposed.

## No redesign required — proceed to Analyst session after revisions
