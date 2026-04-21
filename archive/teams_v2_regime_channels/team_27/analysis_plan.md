# Team 27 — Analysis Plan

## Hypothesis

The negative effect of autocracy (`v2x_libdem`) on the country-year share of politically sensitive SSH articles is significantly larger (more negative) in political science than in economics.

---

## Data construction

### Step 1 — Identify WOS subject categories

From `agent_corpus.rds`, inspect `subject_primary` to identify the exact string labels for political science and economics. Expected WOS values:

- **Political science:** `"Political Science"`, `"International Relations"` (include both; sensitivity robustness uses political science only)
- **Economics:** `"Economics"`, `"Economics, Finance"` (treated as one group)

Verify with `count(subject_primary, sort = TRUE)` before proceeding. Adjust strings if WOS uses non-standard labels in the corpus.

### Step 2 — Construct keyword flag (replicating Team 04)

For each article, create `sensitive_flag` (1/0) based on whether any term from the Team 04 regime-sensitive dictionary matches in the concatenated `title` and `keywords` fields (case-insensitive regex):

| Cluster | Regex pattern |
|---|---|
| Democracy | `democrat` |
| Human rights | `human rights\|civil rights\|civil liberties` |
| Corruption | `corrupt\|bribery\|kleptocracy` |
| Protest | `protest\|demonstrat\|uprising\|riot\|rebellion\|civil unrest` |
| Repression | `repression\|repressive\|censorship\|censor\|political prisoner` |
| Authoritarianism | `authoritarian\|autocra\|dictatorship` |
| Political freedom | `political freedom\|political liberty\|free speech\|freedom of expression\|freedom of press` |
| Electoral manipulation | `election fraud\|electoral fraud\|vote rigging\|vote buying` |
| Dissent | `dissent\|dissident\|political opposition\|regime critic` |

Deduplicate by `ut` before constructing `sensitive_flag` (one row per article), then re-merge with country-year identifiers.

### Step 3 — Collapse to country-field-year

For each `iso3 × field × year` combination, compute:

    share_sensitive = sum(sensitive_flag) / n_articles_in_field_country_year

where `field` takes values `"polisci"` or `"economics"`. Drop country-field-years with fewer than 5 articles. Add binary indicator `field_economics` (1 = economics, 0 = political science).

Controls: `log_gdppc = log(e_gdppc)`, `log_pop = log(e_wb_pop)`. Restrict to 1990–2023.

---

## Model specification

### Primary model — pooled interaction (feols)

```
share_sensitive ~ v2x_libdem * field_economics + log_gdppc + log_pop | iso3 + year
```

- **Estimator:** `fixest::feols`
- **Fixed effects:** country (`iso3`) + year (`year`)
- **SE clustering:** by country (`iso3`)
- **Key coefficient:** `v2x_libdem:field_economics` — the differential autocracy effect in economics relative to political science. A positive, significant coefficient supports the hypothesis.

### Subsample models — separate regressions by field

```
share_sensitive ~ v2x_libdem + log_gdppc + log_pop | iso3 + year
```

Run separately on the political science and economics subsamples. Report coefficients side-by-side. Test coefficient equality using a country-level cluster bootstrap (1000 iterations) or a Seemingly Unrelated Regression (SUR) framework.

---

## Identification strategy

**Variation exploited:** Within-country, within-year variation in `v2x_libdem` from democratic transitions and autocratization episodes. Country FE absorb time-invariant country characteristics; year FE absorb global shocks affecting both fields simultaneously.

**Confounders controlled:** `log_gdppc` (research system size and internationalization), `log_pop` (country size), country and year FE.

**Identification threats:**

1. *Endogenous field selection:* Researchers in autocracies may shift from political science into economics (the Team 03 mechanism), changing who remains in each field. This would likely attenuate the economics coefficient, biasing against finding the hypothesized difference. Acknowledged as a limitation; direction of bias discussed.

2. *Differential WOS coverage by field:* Economics journals may be more systematically indexed in autocratic countries than political science journals, inducing differential selection. Probed by adding log field-country-year article count as an interaction term in a robustness model.

3. *Dictionary applicability:* The Team 04 dictionary was designed for pooled SSH. In economics, sensitive work may use technical framings that escape the dictionary, producing attenuation in the economics coefficient independent of self-censorship. Acknowledged as a measurement limitation.

4. *Reverse causality:* Unlikely to dominate given two-way FE and the stock-flow nature of publication; standard caveat.

---

## Robustness checks

1. **Alternative regime measure:** Replace `v2x_libdem` with `lied_binary`. Re-run pooled interaction and subsample regressions.
2. **Expanded field comparison:** Add law and sociology to the analysis for a monotonicity test across a field-sensitivity spectrum.
3. **Narrow political science definition:** Political science only (exclude `"International Relations"`) to check sensitivity to field definition.
4. **Weighted OLS:** Weight observations by `n_articles_in_field_country_year`.
5. **Restricted time period:** 2000–2023, to probe robustness to the sparse early-1990s period.

---

## Expected output files

All saved to `teams/team_27/analysis/figures/` and `teams/team_27/analysis/`:

| File | Description |
|---|---|
| `figures/fig1_coef_comparison.pdf` | Coefficient plot: `v2x_libdem` estimates in polisci vs. economics subsamples with 95% CI |
| `figures/fig2_interaction_model.pdf` | Table or coefficient plot for pooled interaction model |
| `figures/fig3_share_sensitive_trends.pdf` | Time series of mean `share_sensitive` by field and regime type, illustrating raw patterns |
| `figures/fig4_robustness.pdf` | Coefficient plot across robustness specifications (lied_binary, extended fields, restricted period) |
| `primary_results.json` | JSON with fields: `team`, `hypothesis_label`, `theory_family`, `predictor`, `outcome`, `coefficient` (polisci), `SE` (polisci), `p_value` (polisci), `coefficient_econ`, `SE_econ`, `p_value_econ`, `interaction_coef`, `interaction_SE`, `interaction_p`, `n_obs` |
| `analysis.R` | Full analysis script (tidyverse + fixest style) |

---

## Feasibility notes

- No external API required; all construction uses string matching on existing corpus fields
- `subject_primary` is pre-coded in `agent_corpus.rds`; no text classification needed
- Computationally light: collapse to country-field-year before regression
- Report coverage statistics (n articles per field, n country-years per field) at the top of `analysis.R` to flag any sparsity issues
