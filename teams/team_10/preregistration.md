# Pre-registration: team_10

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 10 — Research Question

## Research question

Does higher authoritarianism increase the share of SSH article abstracts that use exclusively technical, methodological, or administrative vocabulary with no political references, as classified by a large language model?

## Rationale

Self-censorship theory predicts that researchers in autocracies will actively reframe their work to minimize the risk of regime scrutiny — not only by avoiding sensitive topics altogether, but by stripping politically referential language from work they do publish, presenting it instead in purely technical or administrative terms. Technocratic framing is a lower-cost adaptation than topic abandonment: the researcher retains the research but sanitizes its presentation. If this mechanism is widespread, autocratic country-years should exhibit a systematically higher share of abstracts that are purely technocratic in vocabulary and carry no political signal.

## Theoretical mechanism

Researchers in autocracies face institutional incentives — denial of employment, grant funding, or publication access, or in extreme cases legal sanction — when their published work is perceived as politically relevant or threatening to the regime. Even when a researcher's underlying question has political implications, they can reduce their exposure by presenting findings in vocabulary that invokes only technical processes, measurement instruments, statistical methods, or administrative categories, without ever naming political actors, outcomes, institutions, or values. This strategic adoption of technocratic framing makes the abstract appear politically inert to regime surveillance, thereby lowering the personal cost of publication. The expected direction is positive: higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of technocratically framed abstracts, as researchers systematically adopt neutral, apolitical language as a survival strategy.

## Theory family

`framing-neutrality`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH abstracts classified as purely technocratic (no political references), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country association between a country-year's level of liberal democracy (`v2x_libdem`) and the share of that country-year's SSH abstracts classified as TECHNOCRATIC (exclusively technical/methodological/administrative vocabulary, no political references), conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM binary classifications to the country-year level.

## Outcome variable

**`share_technocratic`**: For each abstract in the stratified sample, an LLM assigns one of two labels — TECHNOCRATIC or NOT-TECHNOCRATIC (see LLM classification specification below). The outcome is the share of classified articles receiving the TECHNOCRATIC label, computed per country-year. This is a proportion bounded [0, 1], constructed from the `abstract` field and aggregated using the `iso3` and `year` fields.

Country-years with fewer than 5 sampled and classified abstracts are excluded from regression analysis.

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model); GPT-4o-mini as fallback.

**Task:** Binary classification of each abstract into TECHNOCRATIC or NOT-TECHNOCRATIC.

**Full classification prompt (to be used verbatim in analysis.R):**

```
You are a scientific text classifier. Your task is to classify the following article abstract according to whether it uses exclusively technical, methodological, or administrative vocabulary — with no political references of any kind — or whether it contains at least some political vocabulary.

TECHNOCRATIC means ALL of the following are true:
1. The abstract uses only technical, statistical, methodological, scientific, or administrative terminology.
2. The abstract contains NO references to political actors (e.g., governments, parties, leaders, regimes, states as political entities), political processes (e.g., elections, democratization, governance quality, repression, protest, civil society), political values (e.g., democracy, freedom, human rights, civil liberties, accountability), or politically charged social categories (e.g., ethnic conflict, political prisoners, political opposition).
3. The framing is purely about data, methods, measurement, technical processes, or administrative/managerial outcomes.

NOT-TECHNOCRATIC means AT LEAST ONE of the following is true:
1. The abstract mentions any political actor, institution, process, or outcome.
2. The abstract uses vocabulary that signals a political frame, even if the core methodology is technical (e.g., a study of "protest event detection using machine learning" is NOT-TECHNOCRATIC because it explicitly references protest).
3. The abstract evaluates or discusses governance, state capacity, policy effectiveness, or similar politically loaded concepts.

Instructions:
- Output only the label: TECHNOCRATIC or NOT-TECHNOCRATIC. No explanation.
- If the abstract is borderline, default to NOT-TECHNOCRATIC.
- If the abstract is very short (fewer than 20 words), classify based on what is present, not what is absent.
- Language: classify based on content regardless of the abstract's language.

Abstract:
[ABSTRACT TEXT]
```

**Label scheme:**
- `TECHNOCRATIC` — exclusively technical/methodological/administrative vocabulary, zero political references
- `NOT-TECHNOCRATIC` — contains at least one political reference, actor, institution, process, or politically framed concept

**Handling ambiguous cases:** The prompt instructs the model to default to NOT-TECHNOCRATIC in borderline cases, creating a conservative classifier that minimizes false positives for technocratic framing. The Analyst will validate classification quality by manually reviewing a random sample of 50 abstracts per label after classification.

## Sampling strategy

API cost is managed through stratified random sampling:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 abstracts per stratum (fewer if the stratum is smaller)
- **Eligibility:** articles with non-missing abstracts of at least 50 characters; all SSH fields included
- **Estimated total N:** ~7,000–8,000 abstracts (depending on stratum coverage)
- **Estimated cost:** ~$0.001–0.002 per abstract for Claude Haiku → ~$8–10 total
- **Aggregation:** country-year `share_technocratic` is computed from sampled articles; a weighted estimator adjusts for unequal sampling rates. Country-years with fewer than 5 classified abstracts are excluded from regression.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance.

## Uniqueness check

Performed. Existing teams with completed rq.md files: Teams 01–07.

Most similar team: **Team 05** (critical domestic governance framing — LLM classifying whether abstracts critically examine the author's own country's institutions).

Distinction from Team 05: Team 05 asks whether an abstract *critiques own-country institutions* — a question about the target and evaluative stance of an article toward a specific national context. Team 10 asks a categorically different question: whether an abstract uses *any political vocabulary at all*, regardless of country focus, evaluative direction, or whether the author's own country is mentioned. A comparative study of democratization in twenty countries would be NOT-TECHNOCRATIC for Team 10 (political vocabulary present) but NOT-DOMESTIC for Team 05 (does not focus on own country). A purely methods paper on survey design contains no political reference and is therefore TECHNOCRATIC for Team 10, while it would be NOT-DOMESTIC for Team 05. The two constructs are orthogonal.

Distinction from Team 01: Team 01 constructs a continuous Political Content Index (PCI) score based on the share of abstract word tokens matching a political-content dictionary; Team 10 uses LLM binary classification to identify abstracts with *zero* political reference of any kind. The PCI captures degree of political content; Team 10 captures the presence or absence of a political register in the full semantic sense, including framings and usages that would not be captured by a fixed-vocabulary dictionary.

Distinction from Team 04: Team 04 detects regime-sensitive terms (democracy, human rights, corruption, protest) via regex on titles and author keywords. Team 10 uses LLM classification of full abstract text to detect the complete absence of political vocabulary — a holistic semantic judgment about framing that a regex approach cannot make.

No other existing team measures the technocratic/apolitical framing dimension using LLM classification of full abstract text.


---

## Analysis Plan

# Team 10 — Analysis Plan

## Hypothesis

Higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of SSH article abstracts classified as TECHNOCRATIC (exclusively technical/methodological/administrative vocabulary, no political references) at the country-year level.

---

## Full pipeline

### Stage 1 — Draw stratified sample

From `data/agent_corpus.rds`, restrict to articles with non-missing abstracts of at least 50 characters (eligible pool). Draw a random sample of up to 1,000,000 abstracts with `set.seed(42)`. If the eligible pool contains fewer than 1,000,000 articles, use the full eligible pool. Save sampled article-level data as `teams/team_10/analysis/sample.rds`.

### Stage 2 — LLM binary classification

Submit each abstract to Claude Haiku (or GPT-4o-mini as fallback). Each call receives a single label: `TECHNOCRATIC` or `NOT-TECHNOCRATIC`. Store results progressively in `teams/team_10/analysis/classifications_raw.csv` with columns `wos_id`, `label`, `model`, `timestamp`. Responses not exactly matching either label (after `trimws()` + `toupper()`) coded `NA` and excluded.

**Full LLM classification prompt (use verbatim):**

```
You are a scientific text classifier. Your task is to classify the following article abstract.

TECHNOCRATIC means ALL of the following are true:
1. The abstract uses only technical, statistical, methodological, scientific, or administrative terminology.
2. The abstract contains NO references to political actors (e.g., governments, parties, leaders, regimes, states as political entities), political processes (e.g., elections, democratization, governance quality, repression, protest, civil society), political values (e.g., democracy, freedom, human rights, civil liberties, accountability), or politically charged social categories (e.g., ethnic conflict, political prisoners, political opposition).
3. The framing is purely about data, methods, measurement, technical processes, or administrative/managerial outcomes.

NOT-TECHNOCRATIC means AT LEAST ONE of the following is true:
1. The abstract mentions any political actor, institution, process, or outcome.
2. The abstract uses vocabulary that signals a political frame, even if the core methodology is technical.
3. The abstract evaluates or discusses governance, state capacity, policy effectiveness, or similar politically loaded concepts.

Instructions:
- Output only the label: TECHNOCRATIC or NOT-TECHNOCRATIC. No explanation.
- If the abstract is borderline, default to NOT-TECHNOCRATIC.
- If the abstract is very short (fewer than 20 words), classify based on what is present, not what is absent.

Abstract:
{ABSTRACT TEXT}
```

### Stage 3 — Validation

Manually review 50 abstracts per label (100 total). Report precision before proceeding to regression. Flag systematic errors.

### Stage 4 — Aggregate to country-year

```r
cy <- classified |>
  group_by(iso3, year) |>
  summarise(
    share_technocratic = mean(label == "TECHNOCRATIC", na.rm = TRUE),
    n_classified = sum(!is.na(label)),
    .groups = "drop"
  ) |>
  filter(n_classified >= 5)
```

---

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  share_technocratic ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = analysis_data,
  cluster = ~iso3
)
```

- **Outcome:** `share_technocratic` (proportion, [0, 1])
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** country (`iso3`) + year
- **SE:** clustered by `iso3`
- **Expected sign:** negative (more autocracy → more technocratic framing)

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

```r
feols(
  share_technocratic ~ v2x_libdem + log_gdppc + log_pop | year,
  data = analysis_data,
  cluster = ~iso3
)
```

- **Outcome:** `share_technocratic` (proportion, [0, 1])
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year only
- **SE:** clustered by `iso3`
- **Interpretation:** cross-sectional association between regime type and technocratic framing, net of year effects

---

## Identification strategy

Within-country variation in `v2x_libdem` over time. Country + year FE absorb time-invariant characteristics and global trends.

**Key threats:**
1. LLM systematic bias: classifier may label non-English abstracts as TECHNOCRATIC due to simpler vocabulary. Addressed by English-only robustness check.
2. Disciplinary composition confound: autocracies may publish more in technically oriented fields. Addressed by discipline-restricted robustness check.
3. WOS corpus selection bias.
4. Economic development confounding: controlled by `log_gdppc`.

---

## Robustness checks

- **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable. All other specification details unchanged.
- **RC2 — Restrict to politically sensitive fields:** Re-estimate on the subset of articles in politically sensitive disciplines (Political Science, International Relations, Law, Sociology, Social Issues, Ethnic Studies, Women's Studies — per Team 03's primary field list). This tests whether the result holds within fields where political vocabulary would be expected, and is not driven by compositional shifts toward apolitical disciplines.
- **RC3 — English-only abstracts subsample:** Restrict to abstracts identified as English-language to address potential LLM classification bias toward simpler non-English vocabulary.
- **RC4 — Alternative classification threshold:** Prompt modified to default to TECHNOCRATIC on borderline cases, testing sensitivity to the conservative default.

---

## API cost disclosure

| Item | Value |
|---|---|
| Model | Claude Haiku 3.5 |
| Estimated abstracts | up to 1,000,000 |
| Pricing | ~$0.80/million input tokens |
| Estimated tokens/abstract | ~500 |
| Estimated total cost | ~$400–450 |
| Cost cap | Halt and notify PI if cost exceeds $800 |
| Actual cost | Log in analysis.R and record in primary_results.json |

---

## Expected output files

| File | Description |
|---|---|
| `analysis/sample.rds` | Stratified sample before classification |
| `analysis/classifications_raw.csv` | Raw LLM output |
| `analysis/country_year_outcome.rds` | Country-year aggregated share_technocratic |
| `analysis/analysis_data.rds` | Final merged analysis dataset |
| `analysis/analysis.R` | Full R script |
| `analysis/figures/fig1_regime_technocratic.pdf` | Binscatter: v2x_libdem vs share_technocratic |
| `analysis/figures/fig2_main_coef.pdf` | Coefficient plot: main + robustness |
| `analysis/figures/fig3_time_trend.pdf` | Time trend by regime quartile |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs, api_cost_usd |
