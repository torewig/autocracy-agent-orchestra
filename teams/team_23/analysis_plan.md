# Team 23 — Analysis Plan

## Overview

The analysis tests whether regime type — and regime ideology type in particular — predicts the political-economy ideological lean of SSH scholarship. The pipeline proceeds in five stages: sampling, LLM classification, validation, aggregation to country-year, and regression. The primary test is whether `v2x_libdem` positively predicts `share_liberal` (liberal/neutral framing). Secondary tests use interaction models to identify whether communist autocracies shift output left and nationalist autocracies shift output right.

---

## Stage 1: Sampling

Draw a stratified random sample from `data/agent_corpus.rds`.

**Eligibility filter:**
- Non-missing abstract with `nchar(abstract) >= 50`
- Non-missing `iso3`, `year`, `v2x_libdem`

**Stratification variables:** `iso3` x `v2x_regime` (4-category: 0–3) x decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)

**Target N per stratum:** up to 10 articles per stratum

**Expected total N:** approximately 7,000–8,500 abstracts

**Seed:** `set.seed(42)`

**Exclusion after classification:** Country-years with fewer than 5 classified abstracts excluded from regression.

```r
library(tidyverse)
library(fixest)

set.seed(42)

corpus <- readRDS("data/agent_corpus.rds")

sample_df <- corpus |>
  filter(!is.na(abstract), nchar(abstract) >= 50,
         !is.na(iso3), !is.na(year), !is.na(v2x_libdem)) |>
  mutate(decade = floor(year / 10) * 10) |>
  group_by(iso3, v2x_regime, decade) |>
  slice_sample(n = 10) |>
  ungroup()
```

---

## Stage 2: LLM Classification

For each sampled abstract, call Claude Haiku (GPT-4o-mini as fallback). Returns exactly one label: LEFT, RIGHT, NEUTRAL, or NONE. Stored in `teams/team_23/analysis/llm_classifications.csv` with columns: wos_id, iso3, year, label, abstract_nchar.

### Classification prompt

```
You are a research assistant classifying the political-economy ideological
framing of academic abstracts in social science and humanities.

Your task is to identify the dominant ideological framing -- if any -- through
which the abstract discusses its subject matter. Focus on framing, not topic:
an abstract that studies inequality as a phenomenon is not necessarily
left-leaning; an abstract that frames inequality as the result of capitalist
exploitation or advocates redistribution as a social right IS left-leaning.

Classify the abstract into exactly one of the following four categories:

LEFT: The abstract uses statist, redistributive, collectivist, anti-capitalist,
or class-struggle framing as a normative or evaluative lens. This includes
language presenting state intervention, wealth redistribution, worker solidarity,
or anti-market positions as desirable, natural, or correct -- not merely as a
topic under investigation.

RIGHT: The abstract uses market-efficiency, market-freedom, nationalist,
traditionalist, anti-redistributive, or anti-cosmopolitan framing as a normative
or evaluative lens. This includes language presenting free markets, national
identity, traditional values, or anti-immigration positions as desirable,
natural, or correct -- not merely as a topic under investigation.

NEUTRAL: The abstract discusses political-economy topics (inequality, markets,
redistribution, capitalism, governance, economic policy, class, etc.) in an
empiricist, technocratic, or explicitly non-partisan framing. The abstract
measures, describes, or analyzes these topics without endorsing a normative
ideological direction.

NONE: The abstract does not engage with political-economy or ideological content
in any discernible way. This includes purely historical, linguistic, cultural,
or scientific subject matter with no political-economy dimension.

Rules:
- Output only the label (LEFT, RIGHT, NEUTRAL, or NONE). No explanation.
  No punctuation.
- If ambiguous between LEFT and RIGHT, output NEUTRAL.
- If ambiguous between NEUTRAL and NONE, output NONE.
- Assign LEFT or RIGHT only when normative framing language is present and
  unmistakable.
- Do not be influenced by the country of origin or the author's name.

Abstract: [ABSTRACT]
```

### Batching and cost control

Process in batches of 500. Log cumulative cost after each batch. Halt if cost exceeds $30; proceed with classified subset. Expected cost: $3–6 for ~7,500 abstracts at $0.0004–0.0008/abstract (Claude Haiku pricing).

---

## Stage 3: Validation

Manually review 75 abstracts (~25 per label for LEFT, RIGHT, NEUTRAL). Compute precision per label. If precision for LEFT or RIGHT falls below 0.65, revise prompt and re-classify a 500-abstract test batch before proceeding.

Output: `teams/team_23/analysis/validation_sample.csv` — columns: wos_id, iso3, year, llm_label, human_label, match

---

## Stage 4: Aggregation to country-year

```r
cy_shares <- llm_df |>
  group_by(iso3, year) |>
  summarise(
    n_classified  = n(),
    n_left        = sum(label == "LEFT"),
    n_right       = sum(label == "RIGHT"),
    n_neutral     = sum(label == "NEUTRAL"),
    n_none        = sum(label == "NONE"),
    share_left    = n_left    / n_classified,
    share_right   = n_right   / n_classified,
    share_neutral = n_neutral / n_classified,
    share_none    = n_none    / n_classified,
    share_liberal = (n_neutral + n_none) / n_classified,
    .groups = "drop"
  ) |>
  filter(n_classified >= 5)

reg_df <- cy_shares |>
  left_join(vdem_covs, by = c("iso3", "year")) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  mutate(log_gdppc = log(e_gdppc), log_pop = log(e_wb_pop))
```

`share_liberal` = `share_neutral` + `share_none`: the primary outcome — share of abstracts avoiding directional political-economy framing.

---

## Stage 5: Regression

### Model specification

**Primary specification (pre-registered):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`. Identifies within-country, over-time variation in regime type after absorbing stable cross-national differences and global trends.

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

### Primary model (H1: autocracy suppresses liberal/neutral framing)

```r
# Primary specification (pre-registered): TWFE — country FE + year FE
m1 <- feols(
  share_liberal ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = reg_df, cluster = ~iso3
)

# Secondary specification (descriptive): Pooled OLS — year FE only
m1_ols <- feols(
  share_liberal ~ v2x_libdem + log_gdppc + log_pop | year,
  data = reg_df, cluster = ~iso3
)
```

Outcome: `share_liberal`. Primary predictor: `v2x_libdem`. Controls: `log(e_gdppc)`, `log(e_wb_pop)`. SE: clustered by `iso3` in both specifications. Expected direction: positive (more democracy → more liberal/neutral framing). Both `m1` and `m1_ols` are reported together in `tab1_main_results.tex`.

### Secondary models (H2/H3: regime ideology heterogeneity)

```r
m2_left <- feols(share_left ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
                 data = reg_df, cluster = ~iso3)

m3_right <- feols(share_right ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
                  data = reg_df, cluster = ~iso3)

m4_interact <- feols(
  share_left ~ v2x_libdem * regime_ideo + log_gdppc + log_pop | iso3 + year,
  data = reg_df |> filter(!is.na(regime_ideo)), cluster = ~iso3
)
```

H2: communist autocracies elevate `share_left`; interaction `v2x_libdem x communist` is negative.
H3: nationalist autocracies elevate `share_right`; interaction `v2x_libdem x nationalist_right` is negative.

---

## Causal identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem` after country and year FE.

**Confounders addressed:** Country FE absorbs stable cross-national factors. Year FE absorbs global ideological trends (including post-1991 Marxist decline). Log GDP and log population control for development-level differences.

**Main threats:**

1. *Global ideological shocks.* 1989–1991 transitions conflate regime change and ideological shift. Year FE absorb common component; post-2000 robustness check tests whether results survive.
2. *LLM classification error (random).* Attenuates toward zero; significant findings are conservative.
3. *LLM classification error (systematic).* Language-driven misclassification addressed by validation sample and English-only robustness check.
4. *Compositional field shift.* Post-communist expansion of political science departments may confound outcomes. Robustness check adds `subject_primary x year` interactions.
5. *Reverse causality.* Implausible direction. Design is explicitly descriptive-associational.

---

## Robustness checks

1. **Alternative regime measure (binary):** Replace `v2x_libdem` with `lied_binary`.
2. **Alternative regime measure (ordinal):** Replace with `v2x_regime` (0–3 factor, liberal democracy as reference).
3. **Post-2000 restriction:** Re-estimate on 2000–2023 to rule out post-communist transition confounding.
4. **Fractional logit:** Re-estimate primary model with `feglm(family = quasibinomial)`.
5. **Exclude NONE category:** Recompute shares using only LEFT/RIGHT/NEUTRAL abstracts.

---

## Expected output files

| File | Description |
|------|-------------|
| `analysis/llm_classifications.csv` | Article-level LLM labels |
| `analysis/country_year_shares.csv` | Country-year aggregated shares |
| `analysis/validation_sample.csv` | 75-abstract validation subsample with human labels |
| `analysis/analysis.R` | Full reproducible pipeline |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/figures/fig1_share_by_regime.pdf` | Distribution of share_liberal and share_left by v2x_regime |
| `analysis/figures/fig2_binscatter_liberal.pdf` | Binscatter of share_liberal on v2x_libdem (residualized) |
| `analysis/figures/fig3_coef_plot.pdf` | Coefficient plot: main model and robustness specifications |
| `analysis/figures/fig4_hetero_interact.pdf` | Interaction plot: share_left and share_right by v2x_libdem x regime_ideo |
| `analysis/tables/tab1_main_results.tex` | Regression table for primary + secondary models |
| `analysis/tables/tab2_robustness.tex` | Robustness table |

---

## API cost disclosure

| Item | Value |
|------|-------|
| Primary API | Claude Haiku (Anthropic) |
| Fallback | GPT-4o-mini (OpenAI) |
| Target sample | ~7,500 abstracts |
| Estimated cost | ~$3–6 |
| Hard ceiling | $30 — halt if exceeded |
| Actual cost | Record in analysis.R and primary_results.json |
