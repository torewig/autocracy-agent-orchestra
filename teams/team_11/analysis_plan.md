# Team 11 — Analysis Plan

## Hypothesis

**H11:** Researchers affiliated with more autocratic countries use first-person argumentative stance phrases at lower rates in SSH article abstracts. Formally: the coefficient on `v2x_libdem` in the main regression is positive and statistically significant.

---

## Outcome variable construction

### Stance-phrase regex

The following patterns are matched case-insensitively on the `abstract` field:

```
we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim
```

All patterns are applied with word-boundary anchors where applicable. No stemming or fuzzy matching is used. The pattern list covers the most common first-person argumentative constructions in English-language SSH abstracts. Variants such as "the authors argue" (third-person) are intentionally excluded: the mechanism is self-exposure via first-person attribution, not any assertion structure.

### Normalization

For each article:
- `n_stance` = number of regex matches in the lowercased abstract
- `n_words` = number of whitespace-delimited tokens matching `\w+`
- `stance_rate` = `n_stance / n_words`

Exclusions before computing the rate:
- Articles with missing or empty abstracts
- Articles with `n_words < 20` (likely non-English fragments or placeholder text)

### Aggregation to country-year

`stance_rate_mean` = arithmetic mean of `stance_rate` across all qualifying articles for a given `iso3` x `year` cell. Country-years with fewer than 5 qualifying articles are dropped from the regression sample to avoid noisy estimates from very small cells.

---

## Regression model

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

- **Estimator:** `fixest::feols` (OLS with fixed effects via the Frisch-Waugh-Lovell partialling approach)
- **Outcome:** `stance_rate_mean` (country-year mean stance-phrase rate)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)` — log-transformed to reduce skew; both entered as continuous variables
- **Fixed effects:** country (`iso3`) + year (`year`) — two-way FE absorbing all time-invariant country characteristics and common year shocks
- **Standard errors:** clustered by country (`iso3`) to allow arbitrary within-country serial correlation

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`.

```r
feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    year,
  data = cy_data,
  cluster = ~iso3
)
```

- **Estimator:** `fixest::feols`
- **Outcome:** `stance_rate_mean`
- **Key predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year (`year`) only — no country FE
- **Standard errors:** clustered by country (`iso3`)
- **Purpose:** Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Because country FE are omitted, the coefficient reflects both within- and between-country variation and should be interpreted descriptively, not causally.

Both specifications are reported in the same regression table.

### Rationale for fixed-effects design

Country FE remove all between-country confounders (geography, colonial history, language environment, base level of academic culture). Year FE remove global trends in abstract writing style (e.g., increasing norm of explicit argumentative framing in international journals over time). The identifying variation is within-country change in regime level over time, correlated with within-country change in the mean stance rate. The secondary pooled OLS specification retains between-country variation, providing a complementary descriptive picture of the cross-sectional level difference between autocracies and democracies.

---

## Identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem` — regime transitions, gradual liberalization or autocratization — that predict changes in the mean stance-phrase rate within the same country.

**Confounders controlled:**

| Threat | How addressed |
|---|---|
| Time-invariant country differences (language, academic culture, institutional tradition) | Country FE |
| Global secular trend in abstract style (increasing explicit argumentation in anglophone journals) | Year FE |
| Economic development (richer countries publish more and may have different writing norms) | `log(e_gdppc)` |
| Country size / publication volume | `log(e_wb_pop)` |

**Remaining identification threats:**

1. **Composition effect — journal selectivity:** Journals indexed by WOS skew toward international, English-language outlets that may already select for explicit argumentative style, attenuating the true effect downward. This is a concern for level differences; the within-country FE design mitigates this for trend estimates.
2. **Non-English abstracts:** Stance phrases are defined for English; non-English abstracts will by construction have near-zero stance rates, which creates measurement error correlated with country and possibly with regime type if non-English output is more common in certain autocracies. This is addressed in a robustness check (see below).
3. **Reverse causality / simultaneity:** Stance rate is unlikely to affect regime type; directional concern is minimal.
4. **Pre-trends / slow-moving treatment:** V-Dem scores change slowly; year-over-year within-country variation may be small, leading to imprecise estimates. Event-study analysis around large regime transitions (if data density permits) would strengthen identification — flagged for future extension.

---

## Robustness checks

### RC1 — Restrict to English-language abstracts *(critical)*

The stance-phrase regex is English-only; non-English abstracts will register near-zero stance rates by construction, generating measurement error correlated with country and potentially with regime type (many autocracies publish substantially in non-English languages). Re-estimate on the subsample of abstracts identified as English via the corpus language field (if available) or an ASCII/function-word heuristic: articles where `abstract` contains high-frequency English function words ("the", "and", "of", "in", "to") at a rate >= 1 per 20 words. This is the most important robustness check given the multilingual nature of the corpus.

### RC2 — Alternative regime measure: `lied_binary`

Re-estimate the primary model replacing `v2x_libdem` with `lied_binary` (binary: 1 = electoral democracy, 0 = non-democracy). This tests whether the result is robust to a dichotomous operationalization of regime type and to a different coding source (LIED vs. V-DEM).

### R3 — Disciplinary subsample: political science and sociology

If self-censorship through argumentative-stance suppression is politically motivated, the effect should be strongest in the most politically exposed disciplines. Re-estimate on the subsample where `subject_primary` is "Political Science" or "Sociology." A larger (more negative) coefficient in this subsample relative to the full sample would be consistent with the theoretical mechanism.

### R4 — Expanded phrase list

Re-estimate using an expanded regex that additionally captures: `we suggest|we propose|we hypothesize|we posit|this paper contends|the authors argue`. This tests sensitivity to the phrase-list boundary.

---

## Expected output files

All files written to `teams/team_11/analysis/`:

| File | Content |
|---|---|
| `analysis.R` | Full reproducible R script (tidyverse + fixest) |
| `figures/fig1_stance_rate_by_regime.pdf` | Binscatter of `stance_rate_mean` vs. `v2x_libdem`, within-country demeaned, with regression line |
| `figures/fig2_coef_plot.pdf` | Coefficient plot: primary model + robustness checks (RC1, RC2, R3, R4) on the same axis |
| `figures/tab1_main_regression.tex` | Main regression table (modelsummary or stargazer): primary spec + RC1 + RC2 |
| `primary_results.json` | Machine-readable primary result: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |

---

Step 1 complete — ready for PI review.
