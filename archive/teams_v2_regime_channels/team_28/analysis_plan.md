# Team 28 — Analysis Plan

## Hypothesis
Closed autocracies (v2x_regime == 0) exhibit a lower country-year share of sensitive-topic articles than electoral autocracies (v2x_regime == 1), conditional on country and year fixed effects and continuous regime-quality controls.

## Sample construction
- Restrict to autocratic country-years: keep observations where v2x_regime <= 1 (i.e., v2x_regime == 0 or v2x_regime == 1).
- Drop country-years with missing values on share_sensitive, v2x_libdem, e_gdppc, or e_wb_pop.
- Construct log_gdppc = log(e_gdppc) and log_pop = log(e_wb_pop).
- Construct closed_autocracy = as.integer(v2x_regime == 0).

## Model specification
Primary model estimated with fixest::feols:

  share_sensitive ~ closed_autocracy + v2x_libdem + log_gdppc + log_pop | iso3 + year

- Fixed effects: country (iso3) and year (year), absorbing time-invariant country characteristics and global time trends.
- Standard errors: clustered by country (iso3) to account for within-country serial correlation.
- v2x_libdem control: included to partial out continuous variation in democratic quality within each regime type; ensures closed_autocracy captures the discrete categorical contrast rather than the underlying liberal-democracy gradient.
- Expected sign: coefficient on closed_autocracy is expected to be negative (closed autocracies produce a smaller sensitive-topic share).

## Identification strategy
Identification relies primarily on within-country variation: countries that transition between closed and electoral autocracy over the sample period contribute the cleanest comparison. Country fixed effects absorb structural differences between countries (geography, academic traditions, language). Year fixed effects absorb global shocks. The residual variation in closed_autocracy is driven by regime-type changes within the same country over time. The coefficient is interpreted as a conditional within-country difference; causal interpretation requires assuming no unobserved time-varying confounders correlated with both regime transitions and sensitive-topic publishing beyond those controlled for.

## Robustness checks

1. Alternative regime measure: Replace closed_autocracy with lied_binary as the binary authoritarian-type indicator; re-estimate the same model.
2. Full sample with interaction: Extend sample to include democracies (v2x_regime >= 2); add an interaction term to test whether the closed-vs-electoral difference holds relative to democratic baseline.
3. Ordinal IV: Replace the binary closed_autocracy indicator with the full ordinal v2x_regime variable (0-3) in a linear specification to test whether the effect scales monotonically across regime categories.
4. Continuous proxy: Replace closed_autocracy with v2x_libdem alone (dropping the binary indicator) as a pure continuous robustness check confirming direction of the gradient.
5. Unweighted vs. weighted: Re-estimate with and without weighting by n_articles_country_year to check whether results are driven by high-output countries.

## Expected output files

All outputs written to teams/team_28/analysis/:

| File | Content |
|---|---|
| team28_main_model.rds | Fitted feols object, primary specification |
| team28_robustness_models.rds | List of fitted objects for robustness checks 1-4 |
| team28_descriptive_stats.csv | Group means and SDs for share_sensitive by v2x_regime category |
| team28_coef_plot.pdf | Coefficient plot: closed_autocracy estimate with 95% CI, primary and robustness specs |
| team28_regression_table.tex | LaTeX regression table (primary + robustness), formatted for journal submission |
| team28_event_study.pdf | (Optional) Event-study plot for countries transitioning between regime types |

---

Step 1 complete -- ready for PI review.
