# Team 03: Analysis Plan

## Method

OLS regression with two-way fixed effects (country + year). The outcome is a country-year-level proportion constructed by aggregating article-level field classifications. No text analysis is required — the outcome is derived from the structured `subject_primary` variable.

## Model specification

### Data construction

1. Define politically sensitive fields: Political Science, International Relations, Sociology, Law, Public Administration, Social Issues, Ethnic Studies, Women's Studies.
2. For each article-country row, code `sensitive = 1` if `subject_primary` is in the sensitive set, 0 otherwise.
3. Collapse to country-year level: compute `share_sensitive` = mean of `sensitive` (i.e., number of sensitive-field articles / total SSH articles for that country-year).
4. Restrict to country-years with at least 20 SSH articles (to avoid noisy proportions from very small counts).
5. Restrict to 1990-2023 (pre-1990 WOS coverage is unreliable per PLAN.md).

### Main specification

```
share_sensitive_{c,t} = beta * v2x_libdem_{c,t} + alpha_c + gamma_t + epsilon_{c,t}
```

- **Outcome:** `share_sensitive` (proportion, 0-1)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Fixed effects:** Country (`alpha_c`) + Year (`gamma_t`)
- **Standard errors:** Clustered at the country level
- **Additional controls:** `log(n_articles_country_year)` — controls for the scale of a country's research system, which may independently affect field composition

### Expected coefficient

`beta > 0`: more democratic country-years have a higher share of SSH output in politically sensitive fields.

## Causal identification strategy

### Variation exploited

Two-way fixed effects exploit within-country, over-time variation in `v2x_libdem`. The identifying variation comes from countries that experience changes in their level of democracy over the 1990-2023 period — democratizing or autocratizing episodes.

### Confounders controlled

- **Country FE:** Absorb all time-invariant country characteristics (geography, colonial history, language, cultural traditions in SSH, size of higher education sector at baseline).
- **Year FE:** Absorb global trends (worldwide expansion of political science as a discipline, shifts in WOS indexing coverage, global funding trends).
- **Log total output:** Controls for the possibility that countries with more total SSH articles mechanically have different field distributions.

### Identification threats

1. **Time-varying economic development:** GDP growth may correlate with both democratization and expansion of specific SSH fields. Not directly controlled (GDP is not in the corpus), but country FE absorb baseline development and year FE absorb global growth trends.
2. **Internationalization of higher education:** Countries that democratize may simultaneously integrate into global academic networks, which could independently shift field composition toward Western-norm disciplines. This is a plausible confounder that cannot be fully separated from the regime effect.
3. **WOS indexing bias:** WOS may start indexing more journals from a country as it democratizes and internationalizes, and newly indexed journals may disproportionately cover political science or sociology. This would bias estimates upward. We partially address this by controlling for total output volume and restricting to post-1990.
4. **Reverse causality:** In principle, a vibrant political science community could contribute to democratization. This is unlikely to drive results at the country-year level given the slow-moving nature of both academic field composition and regime change, but cannot be ruled out.

## Robustness checks

1. **Alternative regime measure:** Replace `v2x_libdem` with `regime_binary` in the main specification.
2. **Alternative threshold for minimum articles:** Use 50 instead of 20.
3. **Narrower definition of sensitive fields:** Restrict to Political Science, Sociology, and Law only (dropping the smaller categories).

## Expected output files

| File | Description |
|------|-------------|
| `figures/descriptive_shares_by_regime.png` | Bar chart: mean share of sensitive fields by `v2x_regime` category |
| `figures/main_regression_table.png` | Regression table: main specification + robustness checks |
| `figures/trend_share_sensitive.png` | Line plot: share of sensitive fields over time, by regime type |
| `figures/coefplot_robustness.png` | Coefficient plot comparing estimates across specifications |
