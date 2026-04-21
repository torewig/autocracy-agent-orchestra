# Team 30 — Analysis Plan

## Method

The analysis runs three parallel OLS fixed-effects regressions and compares their coefficients and fit statistics. The three models are:

- **Model A:** `share_sensitive` ~ `v2x_libdem` + controls + FE (replication of Team 04 baseline)
- **Model B:** `share_sensitive` ~ `v2clacfree` + controls + FE (academic-freedom-only model)
- **Model C:** `share_sensitive` ~ `v2x_libdem` + `v2clacfree` + controls + FE (horse-race)

The comparison of interest is whether Model B improves on Model A in model fit (within-R² and RMSE), and whether `v2clacfree` retains a significant positive coefficient in Model C while the `v2x_libdem` coefficient is attenuated. This constitutes a test of mechanism specificity: if academic freedom is the more proximate driver of the self-censorship outcome, Model B should fit better than Model A and `v2clacfree` should dominate in Model C.

The outcome `share_sensitive` is constructed exactly as in Team 04: the country-year proportion of distinct articles matching the regime-sensitive keyword dictionary (title + author keywords, same `dict_pattern`). Do not re-derive the keyword flag independently — import or replicate Team 04's Stage 1 output.

---

## Model specification

All three models use `fixest::feols()` with the following shared elements:

- **Fixed effects:** Country FE + Year FE (`| iso3 + year`)
- **Standard errors:** Clustered by country (`cluster = ~iso3`)
- **Controls:** `log(e_gdppc)` + `log(e_wb_pop)`
- **Sample:** Country-years with `n_articles_country_year >= 5`, years 1990–2023, non-missing `v2x_libdem` and `v2clacfree`

Formal model equations:

**Model A**

    share_sensitive_{c,t} = beta_A * v2x_libdem_{c,t} + gamma * log(e_gdppc_{c,t}) + delta * log(e_wb_pop_{c,t}) + alpha_c + tau_t + epsilon_{c,t}

**Model B**

    share_sensitive_{c,t} = beta_B * v2clacfree_{c,t} + gamma * log(e_gdppc_{c,t}) + delta * log(e_wb_pop_{c,t}) + alpha_c + tau_t + epsilon_{c,t}

**Model C (horse-race)**

    share_sensitive_{c,t} = beta_C1 * v2x_libdem_{c,t} + beta_C2 * v2clacfree_{c,t} + gamma * log(e_gdppc_{c,t}) + delta * log(e_wb_pop_{c,t}) + alpha_c + tau_t + epsilon_{c,t}

**Expected signs:** beta_A > 0, beta_B > 0. In Model C, beta_C2 > 0 (v2clacfree retains significance) and beta_C1 is attenuated toward zero relative to Model A.

Report for all three models: coefficient estimates, clustered SEs, t-statistics, p-values, within-R², RMSE, and N. Present together in a single coefficient comparison table.

---

## Identification and multicollinearity note

This analysis is **descriptive and predictive**, not causal. The fixed-effects design removes time-invariant country confounders and global time trends, but the estimands in Models A and B are partial correlations, not causal effects.

**Model C multicollinearity warning:** `v2x_libdem` and `v2clacfree` are highly correlated (expected r approximately 0.7–0.85 in the within-country, within-year variation used by feols). This means:

1. Standard errors on both coefficients in Model C will be inflated relative to Models A and B. This is expected and should be reported transparently, not treated as a sign of model misspecification.
2. Coefficients in Model C should be interpreted as partial predictive contributions — the unique predictive weight of each variable after accounting for the other — not as independent causal effects.
3. Compute and report the Variance Inflation Factor (VIF) for `v2x_libdem` and `v2clacfree` in Model C using the within-transformed data (demeaned by FE). A VIF above 10 is a strong indicator that the horse-race coefficients cannot be meaningfully separated and should be flagged explicitly.
4. If VIF is high, the primary inferential weight should rest on the Model A vs. Model B comparison (fit statistics), not on the Model C coefficient signs.

---

## Robustness checks

1. **Binary democracy IV:** Replace `v2x_libdem` in Model A with `lied_binary` (1 = democracy, 0 = autocracy) to check whether the democracy coefficient is robust to a dichotomous classification, and to provide an alternative for the horse-race (Model C variant: `lied_binary` vs. `v2clacfree`).

2. **Third alternative IV — expressive freedoms:** Add a fourth model, Model D, using `v2x_freexp_altinf` (V-DEM freedom of expression and alternative information index) in place of both `v2x_libdem` and `v2clacfree`, to test whether the predictive advantage of `v2clacfree` over `v2x_libdem` is specific to academic freedom or extends to any expressive-freedom index.

3. **Post-2000 restriction:** Re-estimate all three models restricting to 2000–2023, where `v2clacfree` coverage is more complete, to test whether results are sensitive to the period with thinner academic-freedom data.

4. **Dropping China and Russia:** Re-estimate Model C excluding iso3 == "CHN" and iso3 == "RUS", given that these two countries dominate the autocratic-country observations and may drive coefficient estimates disproportionately.

---

## Expected output files

All saved to `teams/team_30/analysis/`.

| File | Description |
|---|---|
| `tab_models_ABC.txt` | Three-column regression table (Models A, B, C) with coefficients, clustered SEs, within-R², RMSE, N — produced by `modelsummary` |
| `fig_scatter_ivs.png` | Scatter plot of country-year `v2clacfree` vs. `v2x_libdem` (within-transformed, i.e., after FE demeaning), annotated with Pearson r and VIF |
| `primary_results.json` | Machine-readable summary of key estimates from Models A–C for the orchestration layer |

---

Step 1 complete — ready for PI review.
