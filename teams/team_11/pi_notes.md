# PI Notes — Team 11

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit lower mean rates of first-person argumentative stance phrases in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.").

2. **Controls:** Explicitly specify in rq.md and analysis_plan.md: controls are `log(e_gdppc)` and `log(e_wb_pop)`.

3. **Robustness tests:** Add two pre-specified robustness checks to analysis_plan.md:
   - **RC1 — Restrict to English-language abstracts:** The stance-phrase regex is English-only; non-English abstracts will score near-zero regardless of self-censorship. Re-estimate on English-language abstracts only (identified via a language detection heuristic or the corpus language field if available). This is a critical check given that many autocracies publish substantially in non-English languages.
   - **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

## No redesign required — proceed to Analyst session after revisions
