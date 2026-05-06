# Team 09 — Analysis Plan

## Hypothesis

Researchers from more autocratic countries use normative and prescriptive language at a lower rate in SSH article abstracts. Formally: the coefficient on `v2x_libdem` in a regression of country-year mean normative term rate on regime score, country fixed effects, year fixed effects, and standard economic controls is positive and statistically significant.

---

## Step 1 — Data inspection (to be run before analysis)

```r
library(tidyverse)
corpus <- readRDS("data/agent_corpus.rds")
set.seed(42); s <- corpus |> slice_sample(n = 3000)

s |> summarise(
  has_abstract = mean(!is.na(abstract)),
  mean_words   = mean(str_count(abstract, "\\w+"), na.rm = TRUE)
)

s |> filter(!is.na(abstract)) |>
  mutate(
    norm_count = str_count(tolower(abstract),
      "\\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\\b"),
    word_count = str_count(abstract, "\\w+"),
    norm_rate  = norm_count / word_count
  ) |>
  summarise(mean_rate = mean(norm_rate, na.rm = TRUE))
```

---

## Step 2 — Normative term dictionary

All matches are whole-word (`\b`), case-insensitive, applied to the `abstract` field.

| Cluster | Regex pattern |
|---|---|
| Obligation / prescription | `\b(should|ought)\b` |
| Rights | `\brights\b` |
| Justice | `\b(justice|fairness)\b` |
| Freedom / liberty | `\b(freedom|liberty)\b` |
| Equality / dignity | `\b(equality|dignity)\b` |
| Accountability | `\baccountability\b` |
| Democracy (normative register) | `\bdemocracy\b` |

Combined pattern: `\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\b`

Notes:
- `democracy` included because it is used predominantly normatively in SSH abstracts. Robustness check R2 excludes `democracy` and `rights` (closest overlap with Team 01 PCI) to confirm results are not overlap-driven.
- Terms not stemmed; whole-word matching avoids false positives ("right" as direction, "free" as adjective).

---

## Step 3 — Outcome variable construction

```r
corpus_norm <- corpus |>
  filter(!is.na(abstract), str_count(abstract, "\\w+") >= 20) |>
  mutate(
    norm_count = str_count(tolower(abstract),
      "\\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\\b"),
    word_count = str_count(abstract, "\\w+"),
    norm_rate  = norm_count / word_count
  )

cy <- corpus_norm |>
  group_by(iso3, year) |>
  summarise(
    mean_norm_rate          = mean(norm_rate, na.rm = TRUE),
    median_norm_rate        = median(norm_rate, na.rm = TRUE),
    n_abstracts             = n(),
    v2x_libdem              = first(v2x_libdem),
    lied_binary             = first(lied_binary),
    e_gdppc                 = first(e_gdppc),
    e_wb_pop                = first(e_wb_pop),
    .groups = "drop"
  ) |>
  mutate(log_gdppc = log(e_gdppc), log_pop = log(e_wb_pop)) |>
  filter(!is.na(v2x_libdem), !is.na(mean_norm_rate), n_abstracts >= 5)
```

---

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)
m1 <- feols(
  mean_norm_rate ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = cy,
  vcov = ~iso3
)
```

- Outcome: `mean_norm_rate`
- Primary IV: `v2x_libdem` (continuous 0–1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: `iso3` + `year`
- SE: clustered by `iso3`
- Expected sign: positive

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

```r
m2 <- feols(
  mean_norm_rate ~ v2x_libdem + log_gdppc + log_pop | year,
  data = cy,
  vcov = ~iso3
)
```

- Outcome: `mean_norm_rate`
- Primary IV: `v2x_libdem` (continuous 0–1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: `year` only
- SE: clustered by `iso3`
- Interpretation: cross-sectional association between regime type and normative language use, net of global year trends

---

## Causal identification strategy

Variation exploited: within-country variation in `v2x_libdem` over 1970–2023, purged of global year shocks and time-invariant country characteristics.

Confounders controlled: country FE (research culture, language, institutions); year FE (global normative vocabulary trends); log GDP per capita; log population.

Identification threats:
1. Selection into publishing: pre-publication suppression attenuates estimates toward zero — positive findings are conservative.
2. Compositional confounding: disciplinary mix changes may drive normative rate changes. Addressed by R3.
3. English-language bias: flag share of non-English abstracts by regime quartile in descriptive statistics.
4. Reverse causality: implausible at country-year resolution.

---

## Robustness checks

| ID | Description |
|---|---|
| RC1 | Restricted dictionary: re-estimate the primary model using a version of the normative term dictionary that excludes "democracy" and "rights", as these terms overlap with dictionaries used by Teams 01 and 04. This isolates the result to normative vocabulary unique to this team's theoretical claim. |
| R1 | Replace `v2x_libdem` with `lied_binary` |
| R2 | Restrict dictionary to terms with minimal PCI overlap (exclude `democracy`, `rights`) |
| R3 | Restrict corpus to politically sensitive disciplines (Political Science, Sociology, Law, International Relations, Public Administration) |
| R4 | One-year within-country lag of `v2x_libdem` |
| R5 | Replace `mean_norm_rate` with `median_norm_rate` |

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | Coefficient, SE, p-value, N |
| `analysis/figures/fig1_raw_scatter.pdf` | Binned scatter: mean normative rate vs. v2x_libdem |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: M1 and R1–R5 |
| `analysis/figures/fig3_within_country.pdf` | Within-country time series for 6–8 illustrative countries |
| `analysis/tables/tab1_descriptives.txt` | Descriptive statistics by regime quartile |
| `analysis/tables/tab2_main_results.txt` | Regression table: M1 + R1–R3 |
