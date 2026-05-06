# Team 19 — Analysis Plan

## Outcome construction
1. Compute `cite_ratio = tot_cites / field_year_mean_cites` for each article.
   This normalizes raw citation counts against the mean for all articles in the same
   field (`subject_primary`) and publication year, removing strong variation in
   citation norms across disciplines and over time.
2. Apply `log1p(cite_ratio)` to address right-skew and preserve zero-citation articles.
3. Aggregate to country-year: compute the mean of `log1p(cite_ratio)` across all
   articles per `iso3` × `year` cell. Drop country-years with fewer than 10 articles.
4. Merge with country-year controls (`v2x_libdem`, `lied_binary`, `e_gdppc`, `e_wb_pop`).

## Controls
- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population

## Model specification

### Primary specification (pre-registered)
Two-way fixed effects (TWFE): country FE + year FE, SE clustered by `iso3`.

- **Estimator:** `feols` (fixest package)
- **Outcome:** `log_cite_ratio_mean` (country-year mean of log1p(cite_ratio))
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** country (`iso3`) + year
- **Standard errors:** clustered by `iso3`

```r
feols(log_cite_ratio_mean ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
      data = cy_panel, cluster = ~iso3)
```

### Secondary specification (descriptive)
Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

- **Estimator:** `feols` (fixest package)
- **Outcome:** `log_cite_ratio_mean`
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year only
- **Standard errors:** clustered by `iso3`

```r
feols(log_cite_ratio_mean ~ v2x_libdem + log_gdppc + log_pop | year,
      data = cy_panel, cluster = ~iso3)
```

## Identification strategy
The design exploits within-country variation in `v2x_libdem` over time. Country fixed
effects remove time-invariant country characteristics; year fixed effects remove global
citation trends. The main identification threat is citation accumulation lag: articles
published recently have fewer citations mechanically, regardless of regime. Year FE
partially absorb this, but within-year cross-country variation in article recency remains.
The primary remedy is a robustness check restricted to articles published at least 5 years
before the corpus end year, ensuring substantial citation accumulation time for all
included articles. GDP per capita is controlled to address the confound that richer
countries both democratize and produce more internationally visible research.

## Robustness checks
- **RC1 — Exclude recent articles:** Re-estimate dropping articles published after 2018. Recent articles have had less time to accumulate citations, introducing right-censoring that may correlate with country-year patterns. This tests whether results are robust to citation maturity concerns.
- **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
- **RC3 — Alternative normalization:** Use `log1p(tot_cites)` as outcome with `subject_primary` × year fixed effects instead of the pre-computed normalization, testing robustness to the normalization procedure.
- **RC4 — Aggregation floor sensitivity:** Re-run with minimum thresholds of 5 and 25 articles per country-year (instead of 10).

## Expected output files
All files written to `teams/team_19/analysis/`:

| File | Description |
|---|---|
| `analysis/analysis.R` | Full analysis script |
| `analysis/figures/fig1_cite_ratio_by_regime.pdf` | Binned scatter of log cite_ratio mean vs. v2x_libdem, residualized on FE |
| `analysis/figures/fig2_main_coef_plot.pdf` | Coefficient plot across main model and robustness specifications |
| `analysis/figures/fig3_trend_by_regime_type.pdf` | Time-series of mean cite_ratio by broad regime category |
| `analysis/tables/tab1_main_regression.tex` | Main regression table (4 columns) |
| `analysis/primary_results.json` | Machine-readable results: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
