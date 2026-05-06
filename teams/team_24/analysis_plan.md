# Team 24 — Analysis Plan

## Overview

This plan tests whether autocracy predicts a higher share of SSH scholarship that actively legitimizes or endorses the current political system (share_legitimating). The pipeline proceeds in four stages: sampling, LLM classification, aggregation, and regression.

---

## Stage 1: Sampling

Load `data/agent_corpus.rds`. Restrict to observations with non-missing abstract and `nchar(abstract) >= 50`.

Stratification variables: `iso3` x `v2x_regime` (0-3, 4-category factor) x decade (`floor(year / 10) * 10`). Cap: up to 10 articles per stratum. Seed: `set.seed(42)`. Target total N: approximately 1,000,000 abstracts. Cost estimate: ~$0.00052 per abstract (~$520 for 1M abstracts at Claude Haiku rates). Hard cost ceiling: $500 — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500.

Map each `iso3` code to a country name. Save sample (with `wos_id`, `iso3`, `year`, `abstract`, `v2x_libdem`, `v2x_regime`, `subject_primary`) to `teams/team_24/analysis/sample.csv` before any API calls.

---

## Stage 2: LLM Classification

**API:** Claude Haiku (primary) or GPT-4o-mini (fallback).

**Cost guard:** If projected cost exceeds USD 500, halt and notify PI.

**Prompt** ([COUNTRY] and [ABSTRACT] substituted per record):

```
You are a research assistant classifying academic abstracts. Determine whether
the abstract actively legitimizes or endorses the current political system,
state authority, ruling party, government institutions, or leadership of [COUNTRY].

LEGITIMATING means the abstract explicitly presents [COUNTRY]'s political system,
state authority, party, government, or leadership as effective, beneficial,
legitimate, stable, or necessary — where this positive framing is the article's
own argument or conclusion, not merely a reported view of others or a neutral
description.

Examples that qualify as LEGITIMATING:
- The abstract argues that the political system has delivered development,
  stability, or social welfare
- The abstract frames state authority or party leadership as solving governance
  problems
- The abstract endorses the ideological framework that justifies the current
  political order
- The abstract characterizes government actions as legitimate and effective
  without critical qualification

Examples that do NOT qualify as LEGITIMATING:
- Neutral or descriptive accounts of political institutions without evaluative
  stance
- Comparative studies that include [COUNTRY] as one case without endorsing its
  political order
- Historical analysis without normative assessment
- Critical or ambivalent analysis
- Abstracts that do not discuss domestic governance, state authority, or politics
- Abstracts where a positive view is attributed to survey respondents or
  historical actors only

Classify into exactly one category:

LEGITIMATING: The abstract actively endorses or positively frames [COUNTRY]'s
current political system, state authority, ruling party, institutions, or
leadership as effective, legitimate, stable, or beneficial.

NON-LEGITIMATING: All other abstracts.

Rules: Output only the label. No explanation. No punctuation. If any doubt,
output NON-LEGITIMATING.

Abstract: [ABSTRACT]
```

**Output:** Save `wos_id`, `iso3`, `year`, `label`, `nchar_abstract` to
`teams/team_24/analysis/llm_classifications.csv`.

**Validation:** Draw 50 LEGITIMATING and 50 NON-LEGITIMATING abstracts. Manual
review. If precision for LEGITIMATING < 0.70, revise prompt and re-run. Save to
`teams/team_24/analysis/validation_sample.csv`.

---

## Stage 3: Aggregation to Country-Year

Merge labels to corpus metadata by `wos_id`. Compute per country-year:
`n_classified`, `n_legitimating`,
`share_legitimating = n_legitimating / n_classified`. Exclude country-years
with `n_classified < 5`. Merge in `v2x_libdem`, `v2x_regime`, `lied_binary`,
`e_gdppc`, `e_wb_pop`. Add `log_gdppc = log(e_gdppc)`,
`log_pop = log(e_wb_pop)`. Save to
`teams/team_24/analysis/country_year_shares.csv`.

---

## Stage 4: Regression

### Primary model (pre-registered)

Two-way fixed effects: country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)
m1 <- feols(
  share_legitimating ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = cy,
  cluster = ~iso3
)
```

Coefficient of interest: `v2x_libdem`. Expected sign: negative (more autocracy
→ higher share_legitimating).

### Secondary model (descriptive)

Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

```r
m2 <- feols(
  share_legitimating ~ v2x_libdem + log_gdppc + log_pop | year,
  data = cy,
  cluster = ~iso3
)
```

Coefficient of interest: `v2x_libdem`. Expected sign: negative. Note that this estimate reflects both within- and between-country variation and is not causally identified; it is reported for descriptive context alongside the primary TWFE estimate.

### Controls

`log(e_gdppc)` and `log(e_wb_pop)`, both entered as continuous covariates alongside `v2x_libdem`. Country and year fixed effects absorb time-invariant country characteristics and global time trends respectively.

### Causal identification and threats

Source of identification: within-country over-time variation in v2x_libdem.
Country FE absorb time-invariant confounders; year FE absorb global publishing
shocks.

Key threat — self-referential scholarship bias: Countries with more
state-adjacent research cultures may mechanically discuss domestic governance
more, inflating share_legitimating regardless of regime. Addressed by: country
FE absorbing baseline propensity; RC3 (political science restriction); RC4
(abstract-presence check). Reverse causality likely attenuates estimates toward
zero. Non-systematic LLM error attenuates; systematic error caught by validation
and English-only check.

---

## Robustness checks

**RC1 — Sensitive fields only:** Re-estimate restricting the abstract sample to articles in politically sensitive WOS subject categories (political science, international relations, law, sociology, social issues, ethnic studies, women's studies). Legitimating framing should be most visible in fields where engagement with state and governance is constitutive.

**RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

**RC3 — Regime-type heterogeneity:** Replace `v2x_libdem` with
`i(v2x_regime, ref = 3)`; report marginal effects vs. liberal democracy.

**RC4 — Abstract-presence check:** Restrict to country-years where abstract
coverage exceeds 70% of all articles.

**RC5 — Fractional logit:** Re-estimate with
`feglm(..., family = binomial(link = "logit"))`.

---

## Expected output files

| File | Description |
|------|-------------|
| `analysis/sample.csv` | Stratified article sample before classification |
| `analysis/llm_classifications.csv` | Raw LLM output per article |
| `analysis/validation_sample.csv` | 100-abstract manual validation draw |
| `analysis/country_year_shares.csv` | Country-year aggregated outcome |
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/figures/fig1_share_by_regime.pdf` | Mean share_legitimating by v2x_regime category |
| `analysis/figures/fig2_binscatter.pdf` | Binned scatter: v2x_libdem vs. share_legitimating (residualized) |
| `analysis/figures/fig3_coef_plot.pdf` | Coefficient plot: primary + robustness checks |
| `analysis/tables/tab1_main_results.tex` | Regression table (modelsummary) |

---

## API cost disclosure

| Item | Value |
|------|-------|
| API | Claude Haiku (primary); GPT-4o-mini (fallback) |
| Estimated abstracts | ~7,500 |
| Estimated cost | ~$2–4 |
| Hard stop | $20 projected cost |
| Actual cost | Record in analysis.R and primary_results.json |
