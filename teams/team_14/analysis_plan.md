# Team 14 — Analysis Plan

## Overview

Test whether higher autocracy (lower `v2x_libdem`) is associated with fewer distinct co-author countries per article, aggregated to the country-year level. All data come directly from the corpus — no external API is required.

---

## Step 1: Compute article-level distinct co-author country count

The corpus is structured as one row per article × author-country (`wos_id` × `iso3`). For each article, count the number of distinct `iso3` values across all rows sharing that `wos_id`:

```r
article_level <- corpus |>
  distinct(wos_id, iso3, year) |>   # deduplicate in case of duplicate rows
  group_by(wos_id, year) |>
  summarise(
    n_coauthor_countries = n_distinct(iso3),
    .groups = "drop"
  )
```

This gives, for each article, the total number of distinct countries represented among all authors. A value of 1 means all authors are from the same country; values > 1 indicate international co-authorship.

---

## Step 2: Link articles back to focal country

Each article may be associated with multiple focal countries (all countries contributing at least one author). Join back to identify, for each (iso3_focal, year) pair, all articles where that country appears:

```r
focal_articles <- corpus |>
  distinct(wos_id, iso3_focal = iso3, year) |>
  left_join(article_level, by = c("wos_id", "year"))
```

---

## Step 3: Aggregate to country-year

```r
cy_data <- focal_articles |>
  group_by(iso3 = iso3_focal, year) |>
  summarise(
    mean_n_coauthor_countries = mean(n_coauthor_countries, na.rm = TRUE),
    n_articles = n(),
    .groups = "drop"
  ) |>
  filter(n_articles >= 5)
```

Drop country-years with fewer than 5 articles to ensure a stable mean.

---

## Step 4: Merge covariates

Join country-year panel to regime and economic controls available in the corpus:

- `v2x_libdem` — primary IV (continuous, 0–1)
- `lied_binary` — robustness IV (binary)
- `log(e_gdppc)` — log GDP per capita (control)
- `log(e_wb_pop)` — log population (control)

---

## Step 5: Main regression

Two specifications are estimated and reported in the same regression table.

---

### Primary specification (pre-registered): Two-way fixed effects

**Estimator:** `fixest::feols` with country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)

m1 <- feols(
  mean_n_coauthor_countries ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

- Outcome: `mean_n_coauthor_countries`
- Primary IV: `v2x_libdem`
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: country (`iso3`) + year
- SE: clustered by `iso3`

Identification relies on within-country, over-time variation in `v2x_libdem`. Country fixed effects absorb time-invariant country-level confounders; year fixed effects absorb global shocks.

Expected sign on `v2x_libdem`: **positive** (more democratic → more distinct co-author countries per article).

---

### Secondary specification (descriptive): Pooled OLS with year FE only

**Estimator:** `fixest::feols` with year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. It captures both between-country and within-country variation, and is interpreted descriptively rather than causally.

```r
m1_ols <- feols(
  mean_n_coauthor_countries ~ v2x_libdem + log_gdppc + log_pop |
    year,
  data = cy_data,
  cluster = ~iso3
)
```

- Outcome: `mean_n_coauthor_countries`
- Primary IV: `v2x_libdem`
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: year only
- SE: clustered by `iso3`

Both `m1` and `m1_ols` are reported side by side in the same regression table (`table_main.tex`).

---

## Step 6: Robustness checks

### RC1: Restrict to multi-author articles

Re-estimate `mean_n_coauthor_countries` computed only over articles with `n_authors > 1`. This separates the international breadth effect from solo-authorship rates: solo-authored papers are indistinguishable from domestically co-authored papers in the primary specification (both score 1 on `n_coauthor_countries`). Restricting to multi-author articles ensures the outcome reflects the spread of collaborative links rather than the incidence of solo work.

```r
# Requires article-level author count; add to article_level in Step 1:
article_level_multi <- corpus |>
  group_by(wos_id, year) |>
  mutate(n_authors = n()) |>
  ungroup() |>
  filter(n_authors > 1) |>
  distinct(wos_id, iso3, year) |>
  group_by(wos_id, year) |>
  summarise(
    n_coauthor_countries = n_distinct(iso3),
    .groups = "drop"
  )

focal_articles_multi <- corpus |>
  distinct(wos_id, iso3_focal = iso3, year) |>
  left_join(article_level_multi, by = c("wos_id", "year")) |>
  filter(!is.na(n_coauthor_countries))

cy_multi <- focal_articles_multi |>
  group_by(iso3 = iso3_focal, year) |>
  summarise(
    mean_n_coauthor_countries = mean(n_coauthor_countries, na.rm = TRUE),
    n_articles = n(),
    .groups = "drop"
  ) |>
  filter(n_articles >= 5)

m_rc1 <- feols(
  mean_n_coauthor_countries ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    iso3 + year,
  data = cy_multi |> left_join(covariates, by = c("iso3", "year")),
  cluster = ~iso3
)
```

### RC2: Alternative regime measure

Replace `v2x_libdem` with `lied_binary` as the main independent variable. A positive coefficient on `lied_binary` (democracy = 1) would support the same directional prediction under a dichotomous operationalisation of regime type.

```r
m_rc2 <- feols(
  mean_n_coauthor_countries ~ lied_binary + log(e_gdppc) + log(e_wb_pop) |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

---

### R1: Binary regime IV

Replace `v2x_libdem` with `lied_binary`:

```r
m_rob1 <- feols(
  mean_n_coauthor_countries ~ lied_binary + log_gdppc + log_pop |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

### R2: Median instead of mean

Recompute outcome as the within-country-year *median* of `n_coauthor_countries` to reduce sensitivity to outlier articles with unusually many co-author countries:

```r
cy_median <- focal_articles |>
  group_by(iso3 = iso3_focal, year) |>
  summarise(
    median_n_coauthor_countries = median(n_coauthor_countries, na.rm = TRUE),
    n_articles = n(),
    .groups = "drop"
  ) |>
  filter(n_articles >= 5)

m_rob2 <- feols(
  median_n_coauthor_countries ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data = cy_median |> left_join(covariates, by = c("iso3", "year")),
  cluster = ~iso3
)
```

### R3: Log-transformed outcome

`n_coauthor_countries` is right-skewed (most articles have 1–3 countries; a few have many). Log-transform the mean:

```r
cy_data <- cy_data |>
  mutate(log_mean_n_coauthor_countries = log(mean_n_coauthor_countries))

m_rob3 <- feols(
  log_mean_n_coauthor_countries ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

The coefficient on `v2x_libdem` is now a semi-elasticity (proportional change in mean n_countries per unit change in libdem).

### R4: Intensive margin — internationally co-authored articles only

Restrict to articles with `n_coauthor_countries > 1` to isolate the intensive margin (how many countries are involved, conditional on any international co-authorship):

```r
cy_intl <- focal_articles |>
  filter(n_coauthor_countries > 1) |>
  group_by(iso3 = iso3_focal, year) |>
  summarise(
    mean_n_coauthor_countries_intl = mean(n_coauthor_countries, na.rm = TRUE),
    n_articles = n(),
    .groups = "drop"
  ) |>
  filter(n_articles >= 5)

m_rob4 <- feols(
  mean_n_coauthor_countries_intl ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data = cy_intl |> left_join(covariates, by = c("iso3", "year")),
  cluster = ~iso3
)
```

---

## Identification strategy

Identification relies on within-country, over-time variation in `v2x_libdem`. Country fixed effects absorb time-invariant country-level confounders (geography, language, academic infrastructure, baseline international integration). Year fixed effects absorb global shocks (post-Cold-War opening of international science, growth of WOS coverage, COVID disruptions to collaboration). Log GDP per capita and log population control for the most plausible time-varying confounder — economic development shocks that may drive both democratization and international scientific integration simultaneously.

Standard errors are clustered at the country level to account for serial correlation within countries over time. No strong causal claim is advanced; results are interpreted as consistent or inconsistent with the self-censorship/collaboration-constraint mechanism net of country and year effects.

---

## Expected output files

All output files written to `teams/team_14/analysis/`.

| File | Content |
|---|---|
| `cy_panel.rds` | Country-year panel with outcome, IV, and controls |
| `article_coauthor_counts.rds` | Article-level distinct co-author country counts (intermediate) |
| `main_results.rds` | List of fitted `feols` model objects (m1, m_rob1–m_rob4) |
| `table_main.tex` | `modelsummary` regression table (main + robustness) |
| `fig_binscatter.pdf` | Binscatter of `mean_n_coauthor_countries` on `v2x_libdem` (residualised on FE) |
| `fig_coef_plot.pdf` | Coefficient plot showing main estimate with 90% and 95% CIs |

---

## Notes on corpus structure

The corpus contains one row per article × author-country. A given `wos_id` appears multiple times if the article has authors from multiple countries. The aggregation in Step 1 uses `distinct(wos_id, iso3, year)` before grouping to guard against duplicate (wos_id, iso3) rows. The `n_coauthor_countries` count includes the focal country itself, so its minimum value is 1. This is consistent across all articles and does not affect the regression coefficient.
