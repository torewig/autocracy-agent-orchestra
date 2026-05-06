# Team 15 — Analysis Plan

## Hypothesis

Researchers in more autocratic countries (lower `v2x_libdem`) publish a lower share of their SSH articles in collaboration with researchers from liberal democracies (`v2x_libdem > 0.5` in co-author country-year).

---

## Data construction — outcome variable

The corpus has one row per article × author-country. Constructing `share_dem_coauthor` requires exploiting this structure as follows:

**Step 1 — Identify multi-country articles and tag democratic co-authors.**

For each wos_id, collect all iso3 values present. For each focal country-year (iso3_focal, year), look up all co-author iso3 values in the same article (iso3 ≠ iso3_focal, same wos_id). Cross-join the article's co-author rows back to the V-DEM data (already merged in the corpus as `v2x_libdem` at the row level for each co-author's country × year). A co-author is "democratic" if their row's `v2x_libdem > 0.5` in that year.

**Step 2 — Flag articles with at least one democratic co-author.**

For each combination of (wos_id, iso3_focal), create a binary indicator `has_dem_coauthor` = 1 if any co-author row for that wos_id has `v2x_libdem > 0.5` and iso3 ≠ iso3_focal, else 0. Articles with no co-author rows (only one iso3 per wos_id) receive `has_dem_coauthor = 0`.

**Step 3 — Aggregate to country-year.**

```
share_dem_coauthor = sum(has_dem_coauthor) / n_articles_country_year
```

where `n_articles_country_year` is the existing variable (count of distinct wos_id values for the focal iso3 × year). Restrict to country-years with at least 5 articles. The output is one row per focal iso3 × year.

**Key implementation note:** Because the corpus already carries `v2x_libdem` merged at the row level (each row is a co-author country × year), the cross-join does not require loading a separate V-DEM file — values for co-author countries are read directly from other rows sharing the same wos_id. A grouped summarise with `any(v2x_libdem[iso3 != iso3_focal] > 0.5)` over wos_id × iso3_focal will be efficient in dplyr.

---

## Model specification

**Estimator:** Two-way fixed effects OLS via `fixest::feols`.

**Primary model (pre-registered):**

```
share_dem_coauthor_iy ~ v2x_libdem_iy + log(e_gdppc_iy) + log(e_wb_pop_iy)
  | iso3 + year
```

- `i` = focal country (iso3), `y` = year
- Country fixed effects (`iso3`) absorb all time-invariant country-level confounders (geography, historical ties to Western academia, language)
- Year fixed effects (`year`) absorb global trends in international collaboration and shifts in the distribution of liberal democracies globally (important: the global share of countries classified as democracies changes over time)
- Standard errors clustered by iso3 (country), to allow for within-country serial correlation

**Secondary model (descriptive):**

```
share_dem_coauthor_iy ~ v2x_libdem_iy + log(e_gdppc_iy) + log(e_wb_pop_iy)
  | year
```

- Year fixed effects only — no country fixed effects
- Standard errors clustered by iso3 (country)
- Estimates the cross-sectional level association between regime type and the outcome, i.e. whether more autocratic countries have lower democratic co-authorship shares on average across all country-years
- Complements the primary TWFE estimate: the TWFE identifies off within-country variation over time, while this pooled OLS identifies off between-country variation
- Both specifications are reported in the same regression table (`tab1_main_results.tex`)

**Controls:**
- `log(e_gdppc)`: richer countries have more resources for international collaboration
- `log(e_wb_pop)`: larger countries may have different collaboration patterns

---

## Identification strategy

**Variation exploited:** Within-country change in `v2x_libdem` over time, net of year fixed effects. The identifying assumption is that within-country democratic transitions or backsliding are not caused by changes in democratic co-authorship shares (reverse causality is implausible at the country level). Country FE remove all stable country-level confounders (e.g., language, colonial legacy, physical distance to democratic research centers).

**Main endogeneity concern:** Democratic countries may themselves be less willing to collaborate with autocratic-country researchers (demand-side suppression), so the mechanism is not purely one-sided self-censorship by autocratic researchers. The within-country FE design does not resolve this: if a country democratizes, both its researchers' willingness to reach out to democratic-country collaborators and democratic countries' willingness to accept those collaborations may increase simultaneously, inflating the estimated coefficient. This threat is acknowledged; the coefficient should be interpreted as the net effect of regime type on the share of democratic co-authorship, not solely as the effect of self-censorship on the supply side.

**Additional threats:**
- *Global trends:* Year FE absorb the global rise of co-authorship and changes in the fraction of countries above the v2x_libdem > 0.5 threshold. However, if the number of democratic countries shifts sharply in a short window (e.g., post-1989), the year FE may not fully absorb this mechanical shift. A robustness check uses the country-specific opportunity set as a denominator (see below).
- *Sparse pre-1990 coverage:* Restrict main estimates to 1990–2023 to avoid sparse early observations driving results; show full-period estimates as a sensitivity check.

---

## Robustness checks

**RC1 — Vary the liberal democracy threshold:** Re-estimate using alternative co-author democracy thresholds: (a) v2x_regime >= 2 (electoral democracy or above) and (b) v2x_regime == 3 (liberal democracy only). This tests sensitivity to the arbitrary 0.5 cut-point on the continuous scale.

**RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.

1. **Alternative IV — `lied_binary`:** Replace `v2x_libdem` with the LIED binary democracy indicator as the focal country's regime measure. Retain the co-author classification threshold at v2x_libdem > 0.5 for consistency (LIED is not available at the co-author row level in the corpus).

2. **Alternative co-author threshold — v2x_libdem > 0.7:** Re-classify democratic co-authors using a stricter threshold (liberal democracy score > 0.7) to capture only consolidated, high-quality democracies. Re-construct `share_dem_coauthor` and re-run the primary model.

3. **Alternative IV + co-author threshold:** `lied_binary` as focal IV with v2x_libdem > 0.7 co-author classification.

4. **Opportunity-set normalisation:** Instead of `n_articles_country_year` as the denominator, use `n_articles_with_any_coauthor` (articles with at least two distinct iso3 values). This focuses the outcome on articles that could have a democratic co-author, removing the mechanical effect of the share of single-author articles.

5. **Subject-field heterogeneity:** Interact `v2x_libdem` with `subject_primary` (or a binary sensitive/neutral field flag) to test whether the effect is concentrated in politically sensitive fields, where the expected cost of democratic co-authorship is higher.

---

## Expected output files

All files written to `teams/team_15/analysis/`:

| File | Description |
|---|---|
| `analysis/analysis.R` | Full analysis script (tidyverse + fixest) |
| `analysis/figures/fig1_share_dem_coauthor_by_regime.png` | Binscatter or conditional means plot: `share_dem_coauthor` vs `v2x_libdem`, within-country variation |
| `analysis/figures/fig2_coef_plot.png` | Coefficient plot for primary model and robustness checks |
| `analysis/figures/tab1_main_results.tex` | Regression table (primary + robustness models) via `modelsummary` |
| `analysis/primary_results.json` | Machine-readable primary results (team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs) |

---

## Software and packages

- `fixest` for `feols` (two-way FE, clustered SE)
- `tidyverse` for data wrangling and the cross-join construction of `has_dem_coauthor`
- `modelsummary` for regression table export
- No external API required
