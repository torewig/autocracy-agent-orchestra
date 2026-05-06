# Team 18 — Analysis Plan

## Method

### Data structure note

`agent_corpus.rds` is structured as article × country rows (one row per article identifier × `iso3` pair). The `institutions` column is duplicated across all rows sharing the same article. Before parsing, deduplicate to one row per article. The article identifier in the corpus may be `ut` or `wos_id` — check `names(corpus)` to confirm.

### Institution field parsing

The `institutions` column is a semicolon-delimited string of all author affiliations for a given article. Parsing steps:

1. Load `data/agent_corpus.rds`. Deduplicate to one row per article.
2. Filter to articles where `institutions` is non-NA and non-empty.
3. For each article, split `institutions` on `";"`, trim whitespace from each token, remove empty tokens, then count distinct tokens: `n_inst = n_distinct(str_trim(str_split(institutions, ";")[[1]]))`.
4. The result is one `n_inst` value per article, ranging from 1 upward.

### Aggregation to country-year

5. Re-join `n_inst` values to the full article-country row frame to recover `iso3` and `year` for each article. (A multinational article contributes its `n_inst` value to each contributing country's rows.)
6. Group by `iso3` × `year`; compute `mean_n_inst = mean(n_inst, na.rm = TRUE)` and `n_articles_inst = n()`.
7. Exclude country-years with `n_articles_inst < 5`.

### Fallback if `institutions` is absent or poorly structured

If `institutions` is missing for > 50% of articles, use `n_authors` as a fallback proxy with a note: "The `institutions` field was insufficiently populated; `n_authors` is used as a proxy for collaborative breadth."

---

## Model specification

**Primary specification (pre-registered):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  mean_n_inst ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = cy_panel,
  cluster = ~iso3
)
```

- **Outcome:** `mean_n_inst` — country-year mean of distinct institutions per article
- **Key predictor:** `v2x_libdem` (continuous, 0–1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`, `mean_n_coauthor_countries`
- **Fixed effects:** country (`iso3`) and year
- **Standard errors:** clustered by `iso3`

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

```r
feols(
  mean_n_inst ~ v2x_libdem + log_gdppc + log_pop | year,
  data    = cy_panel,
  cluster = ~iso3
)
```

- **Outcome:** `mean_n_inst`
- **Key predictor:** `v2x_libdem` (continuous, 0–1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`, `mean_n_coauthor_countries`
- **Fixed effects:** year only (no country FE)
- **Standard errors:** clustered by `iso3`

---

## Identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem`. Country FE remove time-invariant confounders. Year FE absorb global trends in multi-institutional collaboration.

**Identification threats:**
1. Reverse causality: countries with vibrant multi-institutional sectors may be more likely to democratize.
2. Time-varying confounders: expansion of national higher education systems may coincide with democratization. Controlled by `log_gdppc` and `log_pop`.
3. Measurement scope: `institutions` in WOS captures all institutions on the article, including those from co-author countries — not purely domestic institutional diversity.
4. Missing data: `institutions` may be more consistently populated in recent years or high-income countries.

---

## Robustness checks

- **RC1 — Restrict to multi-author articles:** Re-estimate `mean_n_inst` only over articles with `n_authors > 1`. Single-author articles always score 1 institution regardless of regime; this restriction isolates the institutional breadth effect among collaborative papers.
- **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
- **Log-transformed outcome:** Use `log(mean_n_inst)`.
- **Post-1990 sample:** Restrict to 1990–2023 for better institution field coverage.

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Full analysis script |
| `analysis/figures/fig1_coef_plot.pdf` | Coefficient plot: primary + robustness |
| `analysis/figures/fig2_binscatter.pdf` | Binscatter of `mean_n_inst` vs. `v2x_libdem` |
| `analysis/figures/fig3_trend.pdf` | Mean `n_inst` over time by regime quartile |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
