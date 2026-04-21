# Team 25 — Analysis Plan

## Hypothesis

The effect of `v2x_libdem` on `share_sensitive` differs significantly across decades — specifically, the negative effect is strongest in the 2010s and weaker in earlier decades.

---

## Data construction

### Step 1 — Replicate Team 04 outcome variable

Construct `share_sensitive` at the country-year level using the Team 04 regime-sensitive keyword dictionary applied to `title` and `keywords` fields. Retain country-years with `n_articles_country_year >= 1`.

### Step 2 — Construct decade dummies

```r
df <- df |>
  mutate(decade = floor(year / 10) * 10,
         decade_fct = factor(decade))
```

Reference category: 1990s (largest, best-covered decade).

### Step 3 — Controls

- `log_gdppc`: log of `e_gdppc`
- `log_pop`: log of `e_wb_pop`

---

## Model specification

### Primary model

```r
feols(
  share_sensitive ~ v2x_libdem * decade_fct + log_gdppc + log_pop | iso3,
  data = df,
  cluster = ~iso3
)
```

**Collinearity note:** Year FE and decade dummies are partially collinear. Two approaches:

- **Option A (preferred):** Country FE only (`| iso3`); decade dummies absorb between-decade variation.
- **Option B:** Country FE + within-decade year FE. Used as sensitivity check.

### Marginal effect extraction

```
ME_decade_d = beta_v2x_libdem + beta_(v2x_libdem:decade_d)   [each d != reference]
```

Report with 95% cluster-robust CIs.

---

## Identification

Within-country over-time variation in `v2x_libdem`. Decade interaction tests whether the within-country slope changes across calendar decades. Country FE removes time-invariant heterogeneity; decade dummies absorb global secular trends.

Main threat: countries that democratized in a given decade may have also changed publishing behaviour for unrelated reasons.

---

## Robustness checks

1. Replace `v2x_libdem` with `lied_binary`; repeat full interaction model.
2. Replace decade dummies with 5-year period dummies.
3. Restrict sample to 1990–2023.
4. Restrict to `n_articles_country_year >= 10`.
5. Exclude China (`iso3 == "CHN"`) to test its outsized influence on 2000s–2010s estimates.

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | Key coefficient, SE, p-value, N |
| `analysis/figures/fig_coef_plot.pdf` | Forest plot: decade-specific `v2x_libdem` marginal effects with 95% CIs |
| `analysis/figures/fig_trend_plot.pdf` | Time-series of mean `share_sensitive` by regime type across decades |
| `analysis/tables/tab_main.tex` | Regression table: primary + robustness (modelsummary) |
