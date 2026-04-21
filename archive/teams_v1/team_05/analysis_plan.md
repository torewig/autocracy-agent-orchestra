# Team 05: Analysis Plan

## Method

OLS regression with two-way fixed effects (country + year), estimated using `fixest::feols()`. The outcome is the number of distinct co-author countries per article. Since this is a count variable concentrated at low integers (mean ~1.17, most values 1-3), OLS on the raw count is the primary specification. A Poisson model is reported as a robustness check.

## Model specification

### Primary model

```
n_co_countries ~ v2x_libdem + n_authors + log(n_articles_country_year)
                 | country + year + subject_primary
```

- **Outcome:** `n_co_countries` (integer, number of distinct author-affiliation countries per article)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:**
  - `n_authors`: number of authors on the article (more authors mechanically increases the chance of multiple countries)
  - `log(n_articles_country_year)`: logged SSH output volume for that country-year (larger research systems may have more international links)
- **Fixed effects:**
  - Country FE: absorbs all time-invariant country characteristics (language, geography, research infrastructure)
  - Year FE: absorbs global trends in internationalization of research
  - Field FE (`subject_primary`): absorbs systematic differences in co-authorship norms across disciplines
- **SE clustering:** Country level (accounts for within-country correlation across articles and years)

### Sample restrictions

- Years: 1990-2019 (pre-1990 data unreliable per brief; post-2019 may have COVID artifacts)
- Country-years with at least 20 SSH articles (avoids noise from tiny research systems)

### Robustness specifications

1. Replace `v2x_libdem` with `regime_binary` (binary autocracy/democracy)
2. Replace `v2x_libdem` with `v2x_regime` as a factor (4-category ordinal)
3. Poisson regression (appropriate for count outcome)
4. Restrict to country-years with >= 50 articles

## Causal identification strategy

### Variation exploited

Within-country over-time variation in `v2x_libdem`. Country fixed effects absorb all stable country characteristics. Identification comes from countries that experience changes in their democracy level (democratic transitions, backsliding episodes) and asks whether those changes predict shifts in the internationalization of their research output.

### Confounders controlled

- **Country FE:** language, geography, colonial history, research system size and maturity, cultural attitudes toward collaboration
- **Year FE:** global trends in internationalization, growth of digital communication, expansion of international funding programs
- **Field FE:** discipline-specific collaboration norms (e.g., economics vs. history)
- **n_authors:** mechanical relationship between team size and country count
- **n_articles_country_year:** scale of national research output

### Threats to identification

1. **Economic development:** GDP growth may drive both democratization and internationalization of research independently. A robustness check adding GDP per capita (if available in V-DEM) or using within-country variation that nets out smooth trends would help.
2. **Reverse causality:** International collaboration could promote democratization rather than the other way around. The large volume of articles and slow-moving nature of regime change makes this less concerning at the article level, but it cannot be fully ruled out.
3. **Sanctions and geopolitical isolation:** Some autocracies face international sanctions that restrict collaboration independently of the domestic democracy level. This is a genuine confounder for specific countries (Iran, North Korea, Cuba).
4. **WOS selection bias:** WOS indexes a non-random subset of journals. If internationally co-authored papers from autocracies are more likely to appear in WOS-indexed journals, the effect could be attenuated. Country FE partially address this.

## Expected output files

| File | Description |
|---|---|
| `figures/fig1_descriptive_trends.png` | Line plot: mean n_co_countries over time by regime type (autocracy vs. democracy) |
| `figures/fig2_coefficient_plot.png` | Coefficient plot from the primary regression and key robustness checks |
| `figures/tab1_regression_table.tex` | Main regression table: primary model + robustness checks |
| `figures/fig3_robustness_regime_binary.png` | Coefficient plot using `regime_binary` and `v2x_regime` as alternative IVs |
