# Team 22 — Analysis Plan

## Hypothesis

Higher autocracy (lower `v2x_libdem`) is associated with a higher Gini coefficient of `tot_cites` within country-year, reflecting greater citation concentration in autocratic scientific output.

---

## Data construction

### Step 1: Deduplicate articles

The corpus has one row per article x author-country. Before computing the Gini, deduplicate to one row per `wos_id` per country-year. For each `wos_id`, retain the row for each unique `iso3` that contributed to that article (a multinational article contributes its `tot_cites` value to each contributing country's pool).

### Step 2: Compute Gini per country-year

Apply the custom Gini function to the vector of `tot_cites` values for each `iso3 x year` cell:

```r
gini_approx <- function(x) {
  x <- sort(x[!is.na(x) & x >= 0])
  n <- length(x)
  if (n < 2 || sum(x) == 0) return(NA)
  sum((2 * seq_along(x) - n - 1) * x) / (n * sum(x))
}
```

Drop country-years with fewer than 10 deduplicated articles.

### Step 3: Merge regime and controls

Join the country-year Gini dataset with `v2x_libdem`, `lied_binary`, `e_gdppc`, `e_wb_pop`, and `n_articles_country_year`. Construct:
- `log_gdppc = log(e_gdppc)`
- `log_pop = log(e_wb_pop)`
- `log_n_articles = log(n_articles_country_year)` — required control (see below)

---

## Model specification

### Primary specification (pre-registered): Two-way fixed effects

```r
feols(
  gini_tot_cites ~ v2x_libdem + log_gdppc + log_pop + log_n_articles |
    iso3 + year,
  data = cy_panel,
  cluster = ~iso3
)
```

- **Outcome:** `gini_tot_cites` (continuous, 0–1)
- **Primary predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`, `log(n_articles)` (log of the number of deduplicated articles in the country-year cell, to account for mechanical compression of the Gini in large output cells)
- **Fixed effects:** country (`iso3`) + year
- **Standard errors:** clustered by country (`iso3`)
- **Package:** `fixest::feols`

Expected sign: negative on `v2x_libdem` (more democracy → lower Gini / less concentration).

### Secondary specification (descriptive): Pooled OLS with year FE only

```r
feols(
  gini_tot_cites ~ v2x_libdem + log_gdppc + log_pop + log_n_articles |
    year,
  data = cy_panel,
  cluster = ~iso3
)
```

- **Fixed effects:** year only (no country FE)
- **Standard errors:** clustered by country (`iso3`)
- **Package:** `fixest::feols`
- **Purpose:** Estimates the cross-sectional level association between regime type and citation concentration, complementing the within-country estimate from the TWFE specification. Because country FE are omitted, variation across countries is retained and the coefficient on `v2x_libdem` reflects both within- and between-country differences.

Both specifications should be reported side by side in the same regression table (`tab1_main_results.tex`).

---

## Causal identification strategy

**Variation exploited:** Within-country over-time variation in `v2x_libdem` after absorbing country and year fixed effects.

**Key identification threat — article volume:** Gini coefficients computed on small samples are mechanically biased toward 0. More autocratic countries also tend to have smaller scientific communities. `log_n_articles_country_year` is included as a control to partial out this mechanical relationship.

**Additional threats:**
- *Field composition:* If autocracies are disproportionately specialized in low-citation fields, field composition could confound the Gini.
- *Citation cohort effects:* Older articles have had more time to accumulate citations. Year FE partially absorb this; a robustness check uses the field-year normalized `cite_ratio` instead of raw `tot_cites`.

---

## Robustness checks

1. **RC1 — Exclude recent articles:** Re-estimate dropping articles published after 2018. Recent articles have had less time to accumulate citations, and zero-citation articles are more common among recent output, which mechanically inflates the Gini. This tests whether results are robust to citation maturity concerns.
2. **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
3. **Alternative cell-size thresholds:** Re-run with minimum cell sizes of 20 and 30 articles.
4. **Top-1% citation share:** Construct `top1_share` = share of total country-year citations accruing to the top 1% of articles. Simpler, non-parametric concentration measure.
5. **Normalized citations Gini:** Compute Gini on `cite_ratio = tot_cites / field_year_mean_cites` instead of raw `tot_cites`.
6. **Lagged IV:** Replace contemporaneous `v2x_libdem` with one-year lag.

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Main R script |
| `analysis/figures/fig1_gini_by_regime.pdf` | Binscatter: Gini vs. v2x_libdem (residualized on FE) |
| `analysis/figures/fig2_gini_trend_autocracy_democracy.pdf` | Time-series of mean Gini by regime group, 1990–2023 |
| `analysis/tables/tab1_main_results.tex` | Regression table: primary model + robustness |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
