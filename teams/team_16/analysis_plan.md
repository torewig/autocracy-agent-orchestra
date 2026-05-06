# Team 16 — Analysis Plan

## Hypothesis

Higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of SSH articles in which all author-country affiliations belong to the same country (domestic-only articles) at the country-year level.

---

## Outcome variable construction

The corpus has one row per article x author-country. Construction proceeds in three steps:

1. **Compute article-level country count:** Group by `wos_id` and count `n_distinct(iso3)`. Flag `domestic_only = (n_countries == 1)`.
2. **Deduplicate to article level:** For each `wos_id`, retain one row (e.g., `slice(1)` after grouping by `wos_id`) carrying the `domestic_only` flag, plus `iso3`, `year`, and country-year controls.
3. **Aggregate to country-year:** `share_domestic_only = sum(domestic_only) / n()` per country-year, where the denominator is the count of distinct articles for that country-year (not the raw row count from the corpus).

The constructed outcome is a proportion in [0, 1].

---

## Method

Panel regression with two-way fixed effects, estimated via `fixest::feols`. The unit of observation is the country-year. The outcome is treated as a linear probability model on the proportion to allow two-way FE and straightforward coefficient interpretation.

---

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

---

## Model specification

### Primary model (pre-registered): Two-way fixed effects

```
share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

- **Outcome:** `share_domestic_only` (proportion, country-year)
- **Main predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `iso3` + `year`
- **Standard errors:** Clustered by `iso3`

Expected sign: negative (higher democracy -> lower domestic-only share).

### Secondary model (descriptive): Pooled OLS with year FE only

```
share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year
```

- **Outcome:** `share_domestic_only` (proportion, country-year)
- **Main predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `year` only (no country FE)
- **Standard errors:** Clustered by `iso3`

This specification estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Country FE are omitted so that between-country variation is retained. Both the primary and secondary specifications are reported in the same regression table.

### RC1 — Restrict to multi-author articles

Re-estimate computing `share_domestic_only` only over articles with `n_authors > 1`. Single-author papers always score as domestic-only regardless of self-censorship; this restriction isolates the collaboration avoidance effect from single-authorship rates.

```
share_domestic_only_multi ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

where `share_domestic_only_multi` is computed using only articles with `n_authors > 1` in both numerator and denominator.

### RC2 — Alternative regime measure

Replace `v2x_libdem` with `lied_binary` as the main independent variable:

```
share_domestic_only ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

Expected sign: positive (autocracy = 1 -> higher domestic-only share).

---

## Identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem`. Country FE absorb all time-invariant cross-country confounders (geography, language, historical ties, research infrastructure). Year FE absorb global shocks to international collaboration norms (internet diffusion, growth of international conferences, global funding programs).

**Key confounders controlled:**
- Country size (`log(e_wb_pop)`): larger countries have deeper domestic labor markets for collaboration.
- Development level (`log(e_gdppc)`): richer countries have stronger international linkages for non-political reasons.
- Global trends: absorbed by year FE.

**Identification threats:**
1. *Reverse causality:* Countries with isolated scientific communities may be more susceptible to autocratic consolidation. Within-country FE reduce but do not eliminate this.
2. *Time-varying confounders:* Economic shocks, sanctions, or language policy changes could jointly affect regime type and collaboration patterns. Log GDP per capita partially addresses this.
3. *Selection into WOS corpus:* WOS over-represents internationally connected researchers regardless of regime, likely attenuating the estimated effect toward zero (conservative bias).
4. *Small-country mechanical bias:* Microstates may have structurally high domestic-only rates. Sensitivity analyses excluding very small countries may be reported.

---

## Expected output files

All outputs written to `teams/team_16/analysis/`:

| File | Content |
|---|---|
| `analysis/analysis.R` | Full analysis script (tidyverse + fixest) |
| `analysis/figures/fig1_domestic_share_by_regime.pdf` | Binned scatter: mean domestic-only share by v2x_libdem decile, loess smoother |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: primary model + robustness checks |
| `analysis/figures/fig3_trend_by_regime.pdf` | Time series of mean domestic-only share by regime category, 1970-2023 |
| `analysis/primary_results.json` | JSON: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/tables/reg_table.tex` | Regression table: primary model + three robustness specs (modelsummary or stargazer) |

---

## Sample restrictions

- Country-years with zero articles are dropped by construction.
- Articles with missing `iso3` are excluded before computing the domestic-only flag.
- Pre-1990 data retained but flagged; sensitivity excluding pre-1990 observations noted in the report.
