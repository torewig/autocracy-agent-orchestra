# Team 17 — Analysis Plan

## Hypothesis

Higher liberal democracy (`v2x_libdem`) is associated with a higher mean number of authors per article at the country-year level (positive coefficient), after controlling for country fixed effects, year fixed effects, and economic confounders.

---

## Data construction

### Step 1 — Derive article-level author count

The corpus has one row per article x author-country affiliation. Check whether `n_authors` already exists as a column. If not, construct it by counting distinct author entries per `wos_id`. Identify the correct author identifier column by inspecting `names(corpus)` for columns matching `author|n_auth`.

### Step 2 — Aggregate to country-year

Aggregate to country-year mean, filtering to country-years with at least 10 articles. Compute both `mean_n_authors` and `log_mean_authors = log(mean_n_authors + 1)` for use in robustness checks.

Join regime and control variables from the corpus (already merged at article level; take the first non-missing value per country-year for regime/economic variables).

### Step 3 — Log-transform controls

Construct `log_gdppc = log(e_gdppc)` and `log_pop = log(e_wb_pop)`.

---

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

---

## Model specification

**Primary specification (pre-registered — M1):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

- Outcome: `mean_n_authors` (country-year mean author count per article)
- Key predictor: `v2x_libdem` (continuous, 0-1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: country (`iso3`) + year
- SE clustering: by country (`iso3`)
- Estimator: `fixest::feols`

**Secondary specification (descriptive — M1b):**

- Outcome: `mean_n_authors`
- Key predictor: `v2x_libdem`
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: year only (no country FE)
- SE clustering: by country (`iso3`)
- Estimator: `fixest::feols`
- Purpose: estimates the cross-sectional level association between regime type and author count, complementing the within-country estimate from M1. Both M1 and M1b should be reported in the same regression table.

**Discipline-composition model (M2 — preferred):**

Discipline mix is a major confounder: SSH fields differ sharply in typical team size (e.g., humanities vs. economics), and field composition varies across country-years. Address this by disaggregating to country-year-field cells and adding `subject_primary` as a third fixed effect. This is the preferred specification given the limitation noted in `rq.md`.

---

## Identification strategy

**Variation exploited:** Within-country, within-year variation in `v2x_libdem`, leveraging democratic transitions and backsliding episodes across the 1970-2023 panel.

- Country FE absorb time-invariant country characteristics (geography, baseline research culture, team-size norms).
- Year FE absorb global secular trends in author counts (the well-documented rise in multi-author publishing since the 1980s).
- Economic controls absorb variation in research investment and country size.
- Subject field FE in M2 absorb discipline-specific team-size norms.

**Identification threats:**

1. Discipline composition shift: autocratic country-years may shift toward smaller-team disciplines (humanities, solo-author theory). M2 addresses this directly.
2. Publication selection bias: autocracies may suppress publication of small solo-author papers, biasing the observed mean upward in autocracies and attenuating the true negative effect (conservative-bias direction).
3. Secular authorship inflation: year FE absorb the common global trend; country-specific adoption rates of large-team practices may introduce residual confounding, especially pre-1990.
4. Reverse causality: unlikely (team size does not plausibly cause democratization); country FE reduce spurious omitted-variable correlation.

---

## Robustness checks

| Check | Description |
|---|---|
| RC1: Field fixed effects | Re-estimate at the country × subject_primary × year level, adding `subject_primary` fixed effects (or `subject_primary × year` FE) to control for disciplinary norms that strongly correlate with team size. This is the critical robustness check: if the result disappears after absorbing field composition, it is likely driven by disciplinary mix rather than self-censorship. |
| RC2: Alternative regime measure | Replace `v2x_libdem` with `lied_binary` as the main independent variable. |
| R1: Alternative IV | Replace `v2x_libdem` with `lied_binary`; same model structure |
| R2: Log outcome | Replace `mean_n_authors` with `log(mean_n_authors + 1)` to reduce skew |
| R3: Control for international co-authorship rate | Add share of articles with authors from more than one country as a control; isolates team-size effect from international-network effect |
| R4: Restrict to post-1990 | Drop observations before 1990 to address sparse coverage |
| R5: Raise minimum article threshold | Increase country-year floor from 10 to 25 articles |

---

## Expected output files

All outputs saved to `teams/team_17/analysis/`:

| File | Description |
|---|---|
| `analysis/analysis.R` | Main analysis script (tidyverse + fixest) |
| `analysis/figures/fig1_regime_authors_scatter.pdf` | Binned scatter: v2x_libdem vs. mean_n_authors, residualized on FEs |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: M1 and M2 point estimates with 95% CIs |
| `analysis/figures/fig3_trends_by_regime.pdf` | Time trend of mean_n_authors by regime tercile (low/medium/high libdem) |
| `analysis/tables/table1_main_results.tex` | Main regression table (M1, M2, R1, R2) via modelsummary |
| `analysis/primary_results.json` | Machine-readable primary result: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |

---

## Notes for analyst

- Check `n_authors` column existence before aggregation; `names(corpus)` output should clarify whether it is pre-computed or must be derived.
- If the corpus has multiple rows per article x country (one row per author x country), deduplicate to article level before computing `n_authors` to avoid double-counting.
- Do not use `n_articles_country_year` as the denominator for `mean_n_authors`; it is the article count, not author count.
- Flag in `analysis.R` comments whether `n_authors` was pre-existing or derived, and which author-identifier column was used.
