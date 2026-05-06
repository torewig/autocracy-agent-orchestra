# Pre-registration: team_24

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 24 — Research Question

## Research question

Does higher authoritarianism predict a higher share of SSH scholarship that actively legitimizes or endorses the current political system, state authority, ruling party, or leadership in the author's country?

## Rationale

Self-censorship theories have largely focused on what researchers avoid; yet autocratic regimes do not merely suppress dissent — they actively incentivize, fund, and reward scholarship that validates state power and ideology. If career rewards flow disproportionately toward work that positively frames the regime, we should observe not just an absence of critical framing but a measurable elevation in the share of SSH output that endorses or legitimizes the political status quo. This is the active, productive dimension of scholarly self-censorship — distinct from silence — and it has received little systematic empirical attention.

## Theoretical mechanism

In autocracies, researchers face strong incentives to produce scholarship that is not merely inoffensive but affirmatively supportive of the regime: state-funded research programs, publication outlets controlled by party or state bodies, and promotion criteria that reward ideological alignment all channel scholarly output toward legitimating framings. At the individual level, anticipating these incentive structures, scholars may adopt legitimating frames proactively even without explicit instruction, as a rational career strategy. At the aggregate level, this produces a higher country-year share of SSH abstracts that characterize the political system, state authority, or leadership as effective, stable, or beneficial. The expected direction is negative: higher authoritarianism (lower v2x_libdem) is associated with a higher share of actively legitimating scholarship (share_legitimating).

## Theory family

ideological-alignment

## Estimand

The average within-country association between a country-year's level of liberal democracy (v2x_libdem) and the share of that country-year's SSH articles whose abstracts actively legitimize or endorse the current political system, state authority, ruling party, or leadership, conditional on country fixed effects, year fixed effects, and standard economic controls.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Name:** `share_legitimating`

**Construction:** For each abstract in the stratified sample, an LLM assigns one of two labels: LEGITIMATING or NON-LEGITIMATING. The outcome is the share of classified articles receiving the LEGITIMATING label, computed per country-year. This is a proportion bounded [0, 1].

The outcome is constructed from the `abstract` and `iso3` fields. The "own country" reference is the author's country identified by `iso3`.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Expected sign on v2x_libdem: negative (more autocracy → higher share_legitimating).

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model) or GPT-4o-mini as alternative.

**Binary label scheme:**

- **LEGITIMATING:** The abstract explicitly endorses, positively frames, or validates the current political system, state authority, ruling party, government institutions, or national leadership of [COUNTRY] as effective, beneficial, legitimate, stable, or necessary. This includes: praise of the political system's achievements or governance capacity; framing state intervention or authority as solving social problems; positive characterization of political stability under the current system; endorsement of ideological frameworks that justify the political order. The endorsement must be explicit and attributable to the article's own argument — not merely reported as a position held by others.

- **NON-LEGITIMATING:** All other abstracts. This includes: neutral or descriptive analysis of the political system; comparative work that includes [COUNTRY] without evaluating its political order positively; critical analysis; historical description; policy analysis without political endorsement; and any abstract that does not discuss domestic governance or politics at all. If there is any doubt, classify as NON-LEGITIMATING.

**Rationale for binary (not three-class) scheme:** The outcome of interest is the presence of active legitimation, which is a distinct and detectable act. A three-class scheme (legitimating / neutral / critical) would replicate Team 05's design rather than test the positive mirror. Binary classification also reduces ambiguity and improves inter-rater reliability in validation.

**Handling non-English abstracts:** The model classifies based on content regardless of language.

**Handling abstracts without regime reference:** If the abstract does not reference domestic politics, governance, or state authority, classify as NON-LEGITIMATING (the default).

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH abstracts that actively legitimize or endorse the current political system, state authority, or leadership, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Sampling strategy

Stratified random sample to manage API cost:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 articles (fewer if stratum is smaller)
- **Eligibility:** non-missing abstract with `nchar(abstract) >= 50`
- **Seed:** `set.seed(42)`
- **Target total N:** ~1,000,000 abstracts
- **Cost estimate:** ~$0.00052 per abstract (~$520 for 1M abstracts at Claude Haiku rates)
- **Hard cost ceiling:** $500 — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500

## Uniqueness check

**Most similar team:** Team 05 (critical domestic governance framing, LLM-based, topic-avoidance family).

**Why Team 24 is distinct:** Team 05 tests whether autocracy *suppresses* critical framing of own-country governance — the absence of negative evaluation. Team 24 tests whether autocracy *produces* positive/legitimating framing — the presence of active endorsement. These are not logical complements: a country could show low critical framing simply due to silence (researchers avoiding domestic governance entirely), without any elevation in legitimating content; conversely, a regime could reward legitimating scholarship while also tolerating some neutral descriptive work, producing both low critical framing AND high legitimating shares. Distinguishing suppression-through-silence from active production of legitimating content is theoretically important for understanding the mechanisms of autocratic influence over scholarship. Team 24 is the only team testing the active/positive dimension.

No other team in the orchestra tests the share of actively legitimating SSH scholarship as the primary outcome.


---

## Analysis Plan

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
