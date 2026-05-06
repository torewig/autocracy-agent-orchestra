# Team 21 — Analysis Plan (Redesign, 2026-05-06)

## Method

Two-way fixed-effects OLS regression (`fixest::feols`) at the country-year level. The outcome is a proportion bounded [0, 1]; a linear probability model with two-way FE is the primary specification.

---

## Data construction

### Step 1: Deduplicate and compute ever_cited

The corpus has one row per article x country. Deduplicate at `wos_id` within each country-year before computing proportions:

```r
article_level <- corpus |>
  group_by(iso3, year, wos_id) |>
  slice(1) |>
  ungroup() |>
  mutate(ever_cited = as.integer(tot_cites >= 1))
```

### Step 2: Collapse to country-year

```r
cy <- article_level |>
  group_by(iso3, year) |>
  summarise(
    prop_ever_cited = mean(ever_cited, na.rm = TRUE),
    n_articles      = n(),
    v2x_libdem      = first(v2x_libdem),
    lied_binary     = first(lied_binary),
    log_gdppc       = log(first(e_gdppc) + 1),
    log_pop         = log(first(e_wb_pop) + 1),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10, !is.na(v2x_libdem), !is.na(prop_ever_cited))
```

Country-years with fewer than 10 distinct articles are dropped.

---

## Model specification

### Primary model (pre-registered)

Two-way fixed effects: country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)

m1 <- feols(
  prop_ever_cited ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data    = cy,
  cluster = ~iso3
)
```

- **Outcome:** `prop_ever_cited` — proportion of articles with `tot_cites >= 1` in a country-year
- **Key IV:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log_gdppc`, `log_pop`
- **Fixed effects:** country (`iso3`) + year
- **SE clustering:** by `iso3` (country-level, to account for within-country serial correlation)
- **Coefficient of interest:** the coefficient on `v2x_libdem` — interpreted as the average within-country change in the share of ever-cited articles associated with a one-unit increase in the liberal democracy index

---

### Secondary model (descriptive)

Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

```r
m2 <- feols(
  prop_ever_cited ~ v2x_libdem + log_gdppc + log_pop |
    year,
  data    = cy,
  cluster = ~iso3
)
```

- **Outcome:** `prop_ever_cited`
- **Key IV:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log_gdppc`, `log_pop`
- **Fixed effects:** year only (no country FE)
- **SE clustering:** by `iso3`
- **Coefficient of interest:** the coefficient on `v2x_libdem` — interpreted as the cross-sectional association between regime type and the share of ever-cited articles, averaging across all country-years within a given calendar year

---

## Causal identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem`. Country fixed effects absorb all time-invariant country characteristics correlated with both regime type and the share of ever-cited articles (e.g., language, research infrastructure baseline, WOS coverage of domestic journals). Year fixed effects absorb global trends in citation practices and WOS database growth.

**Confounders controlled:** `log(e_gdppc)` controls for economic development, which affects research investment and citation uptake through channels other than regime type. `log(e_wb_pop)` controls for country size, which determines the potential domestic citation market.

**Identification threats:**
1. *Reverse causality:* Unlikely — the share of cited articles in a country does not plausibly cause regime change.
2. *Time-varying WOS coverage:* Country-specific changes in WOS journal coverage over time could shift `prop_ever_cited` mechanically. Year FE absorbs global coverage trends; country-specific shifts are a residual threat to be flagged in the report.
3. *Citation lag:* Year FE absorbs the global maturation trend for citation accumulation; within-country compositional shifts in article age are a minor residual concern.

---

## Robustness checks

**RC1 (sample restriction — 1990–2023):** Repeat the main model restricting to `year >= 1990` to avoid sparse pre-1990 WOS coverage. This is the primary substantive robustness check.

**RC2 (alternative regime measure):** Replace `v2x_libdem` with `lied_binary` (0 = autocracy, 1 = democracy) in the identical model specification. Tests whether results are robust to a dichotomous rather than continuous operationalization of regime type.

---

## Expected output files

All outputs written to `teams/team_21/analysis/` and `teams/team_21/report/`:

| File | Contents |
|---|---|
| `analysis/analysis.R` | Full script: data construction, primary model, robustness checks, figure and table export |
| `analysis/figures/fig_scatter.pdf` | Scatter plot of country-year mean `v2x_libdem` vs. `prop_ever_cited`, with regression line |
| `analysis/figures/fig_coef.pdf` | Coefficient plot for `v2x_libdem` across primary model and robustness specifications |
| `analysis/figures/fig_trend.pdf` | Time-series of mean `prop_ever_cited` for democracies vs. autocracies (1990-2023) |
| `analysis/primary_results.json` | Fields: `team`, `hypothesis_label`, `theory_family`, `predictor`, `outcome`, `coefficient`, `SE`, `p_value`, `n_obs` |
| `report/tab_main.tex` | LaTeX regression table: primary model + RC1 + RC2 |
