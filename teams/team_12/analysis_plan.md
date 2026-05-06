# Team 12 — Analysis Plan

## Hypothesis

Higher liberal democracy (`v2x_libdem`) is associated with a higher country-year share of SSH abstracts that conclude with an explicit normative or policy recommendation (`share_normative_conclusion`).

---

## Method overview

Four sequential stages:
1. **Sampling** — Stratified random sample from `agent_corpus.rds`
2. **LLM classification** — Binary classification of each abstract's final sentences via Anthropic API
3. **Aggregation** — Country-year shares from classified sample
4. **Regression** — Two-way FE OLS

---

## Stage 1 — Sampling

- Retain rows with non-missing `abstract` and `nchar(abstract) >= 50`
- Deduplicate on article identifier before sampling
- **No per-stratum cap.** Draw a random sample sized to stay within a $500 API budget.
  At Claude Haiku 3.5 pricing (~$0.80/million input tokens, ~500 tokens per abstract including prompt overhead), this corresponds to approximately **1,000,000–1,250,000 abstracts**.
  The Analyst must calculate the exact maximum N at current API pricing before running, log that estimate in `analysis.R`, and halt if actual cost exceeds $700.
- `set.seed(42)`
- Extract last two sentences; if extraction fails or yields fewer than 20 characters, use the full abstract as the primary fallback (no character cap on fallback)

---

## Stage 2 — LLM classification

**Model:** Claude Haiku (Anthropic API)

### Full classification prompt (use verbatim in analysis.R)

```
You are a scientific text classifier. Read the following excerpt from the end of an academic abstract in the social sciences or humanities.

Classify this excerpt using EXACTLY ONE of the following labels:

NORMATIVE - The excerpt contains an explicit normative or policy conclusion: a recommendation, a "should" or "ought" claim, a call to action, a statement that a policy should be adopted or reformed, or a judgment that a particular outcome is desirable or undesirable.

DESCRIPTIVE - The excerpt does not make any normative or policy recommendation. It summarizes empirical findings, states the contribution of the paper, identifies limitations, suggests future research directions, or presents implications in factual terms without prescribing what should be done.

Output ONLY the label (NORMATIVE or DESCRIPTIVE). No explanation, punctuation, or other text.

Abstract excerpt:
{ABSTRACT_EXCERPT}
```

**Implementation notes:**
- Batch with exponential backoff on HTTP 429 errors
- Any response not exactly "NORMATIVE" or "DESCRIPTIVE" (after `trimws()` + `toupper()`) coded `NA`; excluded from denominator
- Validate on random 50-abstract-per-label spot-check before regression

**API cost disclosure:**

| Item | Value |
|---|---|
| Model | Claude Haiku 3.5 |
| Pricing | ~$0.80/million input tokens |
| Avg tokens per abstract (incl. prompt) | ~500 |
| API budget | $500 |
| Estimated abstracts | ~1,000,000–1,250,000 |
| Analyst action | Calculate exact max N at current pricing before running; log in analysis.R |
| Cost cap | Halt and notify PI if actual cost exceeds $700 |
| Actual cost | To be logged in analysis.R after run |

---

## Stage 3 — Aggregation

```r
panel <- classified |>
  group_by(iso3, year) |>
  summarise(
    share_normative_conclusion = mean(label == "NORMATIVE", na.rm = TRUE),
    n_classified = sum(!is.na(label)),
    .groups = "drop"
  ) |>
  filter(n_classified >= 5)
```

Merge with V-DEM country-year data and `n_articles_country_year`.

---

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  share_normative_conclusion ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    iso3 + year,
  data = panel,
  cluster = ~iso3
)
```

- **Outcome:** `share_normative_conclusion` (country-year proportion, [0,1])
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** country (`iso3`) + year
- **SE:** clustered by `iso3`

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

```r
feols(
  share_normative_conclusion ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    year,
  data = panel,
  cluster = ~iso3
)
```

- **Outcome:** `share_normative_conclusion` (country-year proportion, [0,1])
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year only (no country FE)
- **SE:** clustered by `iso3`

---

## Identification strategy

Within-country change in `v2x_libdem` over time. Country FE absorb time-invariant confounders. Year FE absorb global trends in abstract writing conventions.

**Key threats:**
1. Compositional shift — democratization may shift disciplinary mix toward applied fields. Addressed by R3.
2. LLM classification error — non-English abstracts may be misclassified. Addressed by manual validation.

---

## Robustness checks

Pre-specified (PI-approved):

- **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable. Tests sensitivity to regime coding scheme.
- **RC2 — Restrict to politically sensitive fields:** Re-estimate on the subset of articles in politically sensitive disciplines: Political Science, International Relations, Law, Sociology, Social Issues, Ethnic Studies, Women's Studies. Tests whether normative conclusion suppression is concentrated in fields where policy recommendations are most politically exposed.

Additional:

- R3: Add `subject_primary` to the FE set (addresses compositional shift threat)
- R4: Restrict to 1990–2023

---

## Expected output files

| File | Description |
|---|---|
| `analysis/data/sample_abstracts.rds` | Stratified sample, pre-classification |
| `analysis/data/classified_abstracts.rds` | Sample with LLM labels |
| `analysis/data/country_year_panel.rds` | Country-year panel for regression |
| `analysis/figures/fig1_coef_plot.pdf` | Coefficient plot: primary + robustness |
| `analysis/figures/fig2_scatter.pdf` | Binned scatter: outcome by `v2x_libdem` decile |
| `analysis/figures/fig3_time_series.pdf` | Mean share over time by regime quartile |
| `analysis/tables/table1_regression.tex` | Regression table (modelsummary) |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
