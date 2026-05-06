# Team 25 — Analysis Plan

## Full pipeline

### Stage 1: Stratified sampling

1. Load `data/agent_corpus.rds`. Assign each article a decade variable: `decade = floor(year / 10) * 10`.
2. Create a stratification key: `strata_key = paste(iso3, v2x_regime, decade, sep = "_")`.
3. Set `set.seed(42)`. Within each stratum, sample up to 10 abstracts at random. Restrict to articles with non-missing, non-empty abstracts (at least 30 characters).
4. Target total: ~1,000,000 abstracts, stratified by `iso3` × `v2x_regime` (4-category) × decade.
5. **Pre-flight cost check:** Before calling the API, compute projected cost as `n_abstracts * 0.00052`. If projected cost exceeds $500, halt with an informative error message. Do not proceed to Stage 2.
6. Save sample as `analysis/llm_sample.rds` and `analysis/llm_sample.csv`.

### Stage 2: LLM classification

1. **API:** Use Claude Haiku or GPT-4o-mini. Temperature = 0.
2. **Output per record:** `wos_id`, `iso3`, `year`, `llm_label` (0 or 1), `llm_model`, `llm_timestamp`.
3. **Cost monitoring:** Log cumulative API cost after every 500 calls. Halt if estimated total exceeds $500. Expected cost at ~$0.00052 per abstract (~$520 for 1M abstracts); hard ceiling is $500 — enforced by pre-flight check in Stage 1 before any API calls are made.
4. **Retry logic:** On API error or null response, retry up to 3 times with exponential backoff. On persistent failure, assign `llm_label = NA` and log.
5. Save classified results as `analysis/llm_results.rds`.

### Classification prompt (use verbatim, substituting `[ABSTRACT]`)

```
You are a research assistant classifying academic abstracts.

Your task: Determine whether this abstract explicitly critiques liberal democracy,
Western political norms, international democratic institutions, or human rights
frameworks as fundamentally flawed, illegitimate, or harmful.

Label as ANTI-LIBERAL only if the abstract argues or implies that liberal
democracy, Western political institutions, international human rights frameworks,
or democratic conditionality are inherently flawed, harmful, illegitimate, or
inferior — where this is the abstract's own argument or evaluative stance, not
a description of others' views.

Do NOT label as ANTI-LIBERAL:
- Abstracts that study problems within liberal democracies from an internal
  reform perspective
- Abstracts that discuss limitations of democracy without calling for its
  replacement
- Abstracts that describe other countries' or actors' critiques of the West
  without endorsing those critiques
- Neutral comparative studies
- Abstracts not engaging with liberal democracy at all

Classify as exactly one of:
ANTI-LIBERAL: Abstract explicitly argues or implies that liberal democracy,
Western norms, or human rights frameworks are fundamentally flawed, harmful,
illegitimate, or inferior.
NOT-ANTI-LIBERAL: All other abstracts.

Output only the label. No explanation. If in doubt, output NOT-ANTI-LIBERAL.

Abstract: [ABSTRACT]
```

### Stage 3: Validation (manual review)

1. Draw 100 abstracts for manual review: 50 classified ANTI-LIBERAL and 50 NOT-ANTI-LIBERAL.
2. Compute precision (share of ANTI-LIBERAL labels that are correct).
3. **Acceptance threshold:** Precision >= 0.80. If not met, revise prompt and reclassify.
4. Save manual codes and confusion matrix to `analysis/validation_sample.csv`.
5. Document prompt revisions in `analysis/validation_log.md`.

### Stage 4: Aggregation to country-year

```r
cy <- llm_results |>
  filter(!is.na(llm_label)) |>
  group_by(iso3, year) |>
  summarise(
    share_anti_liberal = mean(llm_label == 1),
    n_classified = n(),
    .groups = "drop"
  ) |>
  filter(n_classified >= 5) |>
  left_join(corpus_covs, by = c("iso3", "year")) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(year >= 1990) |>
  mutate(log_gdppc = log(e_gdppc), log_pop = log(e_wb_pop))
```

Save aggregated data as `analysis/analysis_data.rds`.

---

## Controls

- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population

---

## Model specifications

### Primary specification (pre-registered): Two-way fixed effects

```r
library(fixest)

m1 <- feols(
  share_anti_liberal ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = cy,
  cluster = ~iso3
)
```

- **Outcome:** `share_anti_liberal`
- **Primary predictor:** `v2x_libdem` (continuous, 0–1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `iso3` + `year`
- **SE clustering:** `~iso3`
- **Expected direction:** negative coefficient on `v2x_libdem` (more autocracy → higher share_anti_liberal)

### Secondary specification (descriptive): Pooled OLS with year FE only

```r
m2 <- feols(
  share_anti_liberal ~ v2x_libdem + log_gdppc + log_pop | year,
  data = cy,
  cluster = ~iso3
)
```

- **Outcome:** `share_anti_liberal`
- **Primary predictor:** `v2x_libdem` (continuous, 0–1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `year` only (no country FE)
- **SE clustering:** `~iso3`
- **Interpretation:** Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country estimate from the primary TWFE specification.

Both specifications should be reported in the same regression table (`analysis/tables/tab1_main.tex`).

---

## Causal identification and threats

**Variation exploited:** Within-country, over-time variation in `v2x_libdem` after absorbing country and year FE.

**Main threats:**

1. *Reverse causality:* Ideological consolidation and anti-liberal production may be jointly driven by regime-level campaigns. Robustness check 3 (pre-2011 restriction) directly tests the Xi/Putin assertive-autocracy period.
2. *Selection into WOS indexing:* Anti-liberal articles may be disproportionately published in national journals not indexed in WOS; any significant result is conservative.
3. *Classifier measurement error (random):* Attenuates toward zero; significant findings are conservative.
4. *Classifier measurement error (systematic):* Addressed by precision >= 0.80 threshold in validation.
5. *Field composition confounding:* Addressed by RC1 (field restriction).

---

## Robustness checks

**RC1 — Sensitive fields only:** Re-estimate restricting the abstract sample to articles in politically sensitive WOS subject categories: political science, international relations, law, sociology, social issues, ethnic studies, women's studies. Anti-liberal framing should be most prevalent in fields where engagement with political order is constitutive; this tests whether the result concentrates where theoretically expected.

**RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary`.

**RC3 — Pre-2011 restriction:** Exclude 2011 onward; tests whether the result is driven by post-2010 Chinese and Russian ideological assertiveness.

**RC4 — Non-linear specification:** Add `I(v2x_libdem^2)` or estimate by regime quartile to test non-linearity (largest effect in closed autocracies).

---

## Expected output files

| File | Description |
|------|-------------|
| `analysis/llm_sample.rds` | Stratified abstract sample |
| `analysis/llm_results.rds` | LLM classification results |
| `analysis/validation_sample.csv` | Manual review codes |
| `analysis/analysis_data.rds` | Country-year aggregated data |
| `analysis/analysis.R` | Full reproducible pipeline |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/figures/fig1_coef_plot.pdf` | Coefficient plot: primary model + robustness |
| `analysis/figures/fig2_trend.pdf` | Mean share_anti_liberal by regime category over time |
| `analysis/figures/fig3_scatter.pdf` | Country-year share_anti_liberal vs v2x_libdem |
| `analysis/tables/tab1_main.tex` | Regression table |

---

## API cost disclosure

| Item | Value |
|------|-------|
| Primary API | Claude Haiku |
| Fallback | GPT-4o-mini |
| Target sample | ~1,000,000 abstracts |
| Estimated cost | ~$0.00052 per abstract (~$520 for 1M) |
| Hard ceiling | $500 — pre-flight check halts before API calls if exceeded |
| Cost logging | Every 500 API calls |
| Actual cost | Record in analysis.R and primary_results.json |
