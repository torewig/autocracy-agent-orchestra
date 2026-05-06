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
