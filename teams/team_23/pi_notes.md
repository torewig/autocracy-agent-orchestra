# PI Notes — Team 23

## Gate B decision: Approved with revisions

**Date:** 2026-05-06

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit a lower share of SSH abstracts with liberal/neutral political-economy framing (NEUTRAL + NONE) and a higher share with ideologically aligned framing (LEFT or RIGHT-CONSERVATIVE), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Sensitive fields only:** Re-estimate restricting the abstract sample to articles in politically sensitive WOS subject categories (Team 03's field list: political science, international relations, law, sociology, social issues, ethnic studies, women's studies). Ideological framing signals should be stronger in these fields; this tests whether the main result is concentrated where it is theoretically expected.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

4. **Classifier label revision:** Revise the LLM classifier from a four-label to a five-label scheme:
   - `LEFT`: The abstract frames its subject using statist, redistributive, collectivist, anti-capitalist, or class-struggle language as an evaluative or normative lens — including advocacy against oppression of marginalized groups and minorities — not merely as a topic under study.
   - `RIGHT-CONSERVATIVE`: The abstract frames its subject using nationalist, traditionalist, anti-cosmopolitan, social-conservative, or authoritarian-order language as an evaluative or normative lens — not merely as a topic under study.
   - `RIGHT-LIBERAL`: The abstract frames its subject using classical liberal language — free markets, individual rights, limited government, rule of law, or personal autonomy — as an evaluative or normative lens — not merely as a topic under study.
   - `NEUTRAL`: The abstract discusses political-economy topics in an explicitly empiricist, technocratic, or non-partisan framing — describing mechanisms or measuring effects without endorsing a normative direction.
   - `NONE`: The abstract does not engage with political-economy topics or ideological framing in any discernible way.

   **Primary outcome:** `share_apolitical` = `share_neutral` + `share_none` (the share of abstracts that avoid ideological framing in any direction).
   **Secondary outcomes:** `share_left`, `share_right_conservative`, `share_right_liberal` — examined separately and in regime-ideology interaction models.

   Update the prompt specification in rq.md and analysis_plan.md accordingly. Validation sample: 70 abstracts per class (350 total for the five-label scheme).

5. **Sampling strategy:** Add an explicit sampling section to rq.md and analysis_plan.md. Target approximately **1,000,000 abstracts**, stratified by `iso3` × `v2x_regime` (4-category) × decade. At Claude Haiku rates (~$0.80/MTok input, ~$4/MTok output, ~600 input tokens + ~10 output tokens per abstract), cost is approximately $0.00052 per abstract, giving ~$520 for 1M abstracts. Set `set.seed(42)` for reproducibility. **Hard cost ceiling: $500** — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500.

## No redesign required — proceed to Analyst session after revisions
