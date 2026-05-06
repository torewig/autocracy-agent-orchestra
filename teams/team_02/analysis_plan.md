# Team 02 — Analysis Plan

## Method

**Outcome construction (keyword entropy):**
1. Load `data/agent_corpus.rds`. Filter to rows where `author_keywords` is non-missing.
2. Parse `author_keywords` into individual tokens by splitting on `";"` (primary WOS separator) and `"|"` (alternative separator); trim whitespace; convert to lowercase.
3. Aggregate to the country-year level: for each `iso3` x `year` cell, collect all keyword tokens across all articles, compute token frequencies, and calculate Shannon entropy:
   H = -sum(p_k * log(p_k + 1e-10)) where p_k is the relative frequency of keyword k among all tokens for that country-year.
4. Drop country-years with fewer than 10 keyword-bearing articles (entropy is unreliable for very small samples).
5. Join to country-year level controls: `v2x_libdem`, `lied_binary`, `v2x_regime`, `log(e_gdppc)`, `log(e_wb_pop)`, `n_articles_country_year`.

**Regression model:**
OLS with two-way fixed effects (country FE + year FE), estimated via `fixest::feols`. The outcome is `keyword_entropy_cy`. Regression controls are `log(e_gdppc)` and `log(e_wb_pop)`. Country-years are the unit of observation; each observation is weighted by `log(n_articles_country_year)` to down-weight country-years with very few articles (optional sensitivity check: unweighted model as robustness).

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects (TWFE):

- Outcome: `keyword_entropy_cy` (Shannon entropy of author keywords, country-year level)
- Predictors: `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: country FE + year FE
- SE clustering: by `iso3`
- Sample restriction: country-years with >= 10 keyword-bearing articles; years 1990-2023 (pre-1990 data sparse and less reliable)

### Secondary specification (descriptive)

Pooled OLS with year FE only (no country FE):

- Outcome: `keyword_entropy_cy`
- Predictors: `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: year FE only
- SE clustering: by `iso3`
- Sample restriction: same as primary specification

This estimates the cross-sectional level association between regime type and keyword entropy, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

## Causal identification strategy

The key identifying variation is within-country change in `v2x_libdem` over time. Country fixed effects absorb all time-invariant country characteristics (geographic, cultural, structural); year fixed effects absorb global trends in keyword practices and WOS coverage expansion. The coefficient on `v2x_libdem` is therefore identified from within-country democratization and autocratization episodes.

Main threats to identification:
1. **Economic confounding:** Wealthier countries may produce more diverse research and also tend to be more democratic. Addressed by including `log(e_gdppc)` as a control.
2. **WOS coverage changes:** WOS may expand coverage in countries at particular regime moments, inflating keyword counts and entropy. Partially addressed by `n_articles_country_year` weighting and year FE.
3. **Reverse causality:** Unlikely at the country-year level, but possible if regimes selectively restrict publication in fields with diverse keywords.
4. **Composition effects:** Country-level keyword diversity partly reflects which WOS journals cover that country; journal composition shifts may be driven by regime-independent factors. Addressed by including subject field as a robustness check (model with subject FE or restricting to a single broad SSH field).

## Robustness checks

1. **Binary regime measure:** Replicate main model replacing `v2x_libdem` with `lied_binary`. Coefficient should be positive and significant if the main result is robust.
2. **Unweighted model:** Drop `log(n_articles_country_year)` weights; check if results hold.
3. **Full sample (1970-2023):** Extend to pre-1990 years; check coefficient stability.
4. **Type-token ratio alternative:** Replace Shannon entropy with the number of unique keywords divided by total keyword tokens as an alternative diversity measure. This is less sensitive to rare keywords.
5. **Subject-field restricted sample:** Restrict to political science and related fields (`subject_primary` matching political science, sociology, law, IR) to sharpen theoretical focus and reduce noise from fields where self-censorship expectations are weaker.

## Expected output files

All saved to `teams/team_02/analysis/figures/`:

- `fig1_entropy_by_regime.pdf` -- Box plots of `keyword_entropy_cy` by `v2x_regime` category (descriptive; four regime types on x-axis)
- `fig2_entropy_trend.pdf` -- Mean keyword entropy over time by broad regime category (democratic vs. autocratic, `lied_binary`), 1990-2023
- `fig3_main_coef.pdf` -- Coefficient plot for main model and robustness checks (at minimum: main model, `lied_binary` robustness, unweighted robustness)
- `tab1_main_results.tex` -- Main regression table (2-3 columns: baseline OLS no FE, main TWFE model, model with additional controls), formatted with `modelsummary`

`teams/team_02/analysis/primary_results.json` -- standard fields: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs
