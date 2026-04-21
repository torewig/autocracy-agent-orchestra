# Team 02: Analysis Plan

## Method

Two-way FE OLS via `fixest::feols()`. The outcome is a country-year-level measure of keyword diversity constructed from the `keywords` field. No text classification APIs or topic models are required — the measure is derived from the structured keyword strings already in the corpus.

## Model specification

### Data construction

1. From each article-country row with non-missing `keywords`, split on semicolons, trim whitespace, and lowercase all keywords.
2. For each country-year, compute:
   - `n_distinct_keywords`: count of unique keyword strings
   - `n_articles_with_kw`: count of articles with non-missing `keywords`
   - `keywords_per_article = n_distinct_keywords / n_articles_with_kw`
3. As a secondary outcome, compute keyword concentration (Herfindahl-Hirschman Index): for each country-year, calculate the share of keyword-bearing articles using each keyword, square, and sum. Higher HHI = more concentrated (less diverse).
4. Restrict to country-years with at least 20 keyword-bearing articles.
5. Restrict to 1990-2023 in the main specification (keyword availability is sparse before 1990).

### Main specification

```
keywords_per_article_{c,t} = beta * v2x_libdem_{c,t} + alpha_c + gamma_t + epsilon_{c,t}
```

- **Outcome:** `keywords_per_article` (continuous, positive)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Fixed effects:** Country (`alpha_c`) + Year (`gamma_t`)
- **Standard errors:** Clustered at the country level
- **Additional controls (extended model):**
  - `log(n_articles_country_year)` — total SSH volume (larger countries mechanically have more distinct keywords; controls for scale)
  - `log(e_gdppc)` — GDP per capita (economic development may independently affect research diversity)
  - `log(e_wb_pop)` — population (country size control)
  - `mean_n_authors` — mean number of authors per article in the country-year (collaborative work may introduce more diverse keywords)

### Expected coefficient

`beta > 0`: more democratic country-years have greater keyword diversity per article — researchers explore a wider range of topics.

## Causal identification strategy

### Variation exploited

Two-way fixed effects exploit within-country, over-time variation in `v2x_libdem`. The identifying variation comes from countries that experience changes in their level of democracy over the 1990-2023 period — democratization episodes (post-Soviet transitions, Latin American openings) and autocratization episodes (recent backsliding cases).

### Confounders controlled

- **Country FE:** Absorb all time-invariant country characteristics (language, research traditions, baseline university capacity, cultural norms around keyword reporting).
- **Year FE:** Absorb global trends in keyword reporting practices (journals increasingly requiring keywords), global SSH publishing norms, and WOS indexing expansion.
- **Log total output:** Controls for scale effects — countries with more articles may mechanically have higher keyword diversity.
- **Log GDP per capita:** Controls for economic development, which may independently affect the breadth of university research.
- **Log population:** Controls for country size.
- **Mean authors:** Controls for collaboration-driven keyword diversity.

### Identification threats

1. **Keyword reporting norms:** WOS journals increasingly required author keywords from the 1990s onward. If autocratic countries' journals adopted keyword requirements later, this could create a spurious correlation. Mitigation: year FE absorb global trends; restricting to 1990+ reduces this concern; a robustness check using `keywords_plus` (WOS-assigned) avoids author reporting behavior entirely.
2. **Economic development:** Richer countries may simultaneously democratize and develop more diverse university systems. Country FE absorb cross-sectional income differences; `log(e_gdppc)` in the extended model controls for time-varying economic development. Residual concern: GDP may not fully capture higher-education investment.
3. **Field composition shifts:** If democratization changes which SSH fields are represented, and fields differ in inherent keyword diversity, this could confound results. Mitigation: add field-share controls or `subject_primary` FE in a robustness specification.
4. **English-language bias:** WOS over-represents English-language journals. If autocracies publish more in non-indexed local outlets, the observed sample may be non-representative. This is a data limitation shared across all teams.
5. **Reverse causality:** Topical diversity in SSH is unlikely to cause regime change, so this is a minor concern.

## Robustness checks

1. Replace `v2x_libdem` with `regime_binary`.
2. Use `keyword_hhi` (concentration) as the outcome — expect `beta < 0`.
3. Use `keywords_plus` (WOS-assigned) instead of `keywords` (author-supplied).
4. Full 1970-2023 time window.
5. Stricter denominator threshold: country-years with 50+ keyword-bearing articles.
6. Add `subject_primary` FE to control for field-level differences in keyword diversity.

## Expected output files

| File | Description |
|------|-------------|
| `figures/fig1_diversity_by_regime.png` | Line plot: mean keywords-per-article over time, by `v2x_regime` category |
| `figures/fig2_main_regression.png` | Coefficient plot from main TWFE model and robustness checks |
| `figures/tab1_main_results.png` | Regression table: main model, extended model, `regime_binary` robustness |
| `figures/fig3_hhi_robustness.png` | Coefficient plot using keyword HHI as alternative outcome |
