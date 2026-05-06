# Team 20 — Analysis Plan

## Method

The analysis proceeds in four stages: (1) replicate the Team 04 keyword flag at the article level; (2) construct the normalized citation outcome; (3) estimate the primary interaction model; (4) robustness checks.

### Stage 1 — Keyword flag (replicating Team 04)

Apply the Team 04 `dict_pattern` regex case-insensitively to `paste(title, keywords, sep = " | ")` (NA treated as empty string). Assign `sensitive_flag = 1` if any pattern matches, 0 otherwise. Use the exact combined `dict_pattern` from `teams/team_04/analysis_plan.md` (covers democracy, human rights, civil rights/liberties, corruption/bribery, protest/contention, repression, censorship, political prisoners, authoritarianism, political freedom, electoral fraud, dissent/opposition).

### Stage 2 — Citation outcome

`cite_ratio = tot_cites / field_year_mean_cites`. Drop articles where `field_year_mean_cites` is zero or missing. Outcome: `log1p(cite_ratio)`.

### Stage 3 — Sample restrictions

Non-missing `v2x_libdem`, `tot_cites`, `field_year_mean_cites`, `iso3`; years 1990–2023; articles published no later than 2020 to allow at least 3 years of citation accumulation.

### Stage 4 — Primary regression

```r
feols(log1p(cite_ratio) ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) |
      iso3 + year + subject_primary,
      data = df, cluster = ~iso3)
```

Coefficient of interest: `v2x_libdem:sensitive_flag` — positive expected sign.

## Model specification

**Primary specification (pre-registered):** Article-level regression with country FE + year FE + field FE, SE clustered by `iso3`.

- Outcome: `log1p(cite_ratio)`
- Predictors: `v2x_libdem * sensitive_flag` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: `iso3 + year + subject_primary`
- SE clustering: `~iso3`
- Expected sign on interaction: positive

**Secondary specification (descriptive):** Article-level regression with year FE + field FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional association, complementing the within-country primary estimate. Both specifications should be reported in the same regression table.

- Outcome: `log1p(cite_ratio)`
- Predictors: `v2x_libdem * sensitive_flag` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: `year + subject_primary`
- SE clustering: `~iso3`

## Controls

- `log(e_gdppc)` and `log(e_wb_pop)`, merged at the country-year level
- Field fixed effects (`subject_primary`) included to account for differential citation norms across disciplines; field-year fixed effects may be substituted as an alternative specification

## Causal identification strategy

Country, year, and field FEs absorb time-invariant country traits, global citation trends, and field citation norms. Identifying variation is within-country over time, interacted with article-level topic sensitivity.

Main threat: sensitive topics may attract different citations for non-regime reasons (globally hot-button topics). Field FEs partially address this. The political science/sociology subsample (Robustness 2) is the key diagnostic.

## Robustness checks

- **RC1 — Alternative sensitivity flag:** Re-estimate using Team 03's disciplinary sensitivity classification (`subject_primary` in politically sensitive WOS field) as the sensitivity indicator, instead of Team 04's keyword flag. This tests whether the interaction result is robust to how "sensitivity" is operationalized.
- **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable; interaction becomes `lied_binary * sensitive_flag`.
- Restrict to Political Science, Sociology, Law, International Relations, Area Studies.
- Narrow keyword dictionary (5 patterns: `democra`, `human rights`, `repression`, `authoritarian`, `\bcensor`).
- Title-only keyword matching (exclude `keywords` field).
- Restrict sample to 1990–2015 for longer citation accumulation window.

## Expected output files

Saved to `teams/team_20/analysis/figures/` and `teams/team_20/analysis/`:

| File | Description |
|---|---|
| `fig_interaction.png` | Predicted `log1p(cite_ratio)` by `v2x_libdem` for `sensitive_flag = 0` and `= 1`, with 95% CI bands |
| `fig_coef.png` | Interaction coefficient across primary model and robustness specs |
| `fig_citation_dist.png` | Density of `log1p(cite_ratio)` by sensitive flag and regime quartile |
| `tab_main.txt` | Regression table (primary + robustness 1–2), `modelsummary` |
| `primary_results.json` | Point estimates, SEs, N, model metadata |
