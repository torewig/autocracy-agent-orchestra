# Team 13 — Analysis Plan

## Hypothesis

Higher autocracy (lower `v2x_libdem`) is associated with a higher share of SSH publications in domestically dominated journals (`share_domestic_journal`).

Expected coefficient sign: **negative** on `v2x_libdem` (more democracy → lower domestic journal share).

---

## Step 1 — Journal domesticity classification

**Algorithm (no external API):**

1. Load `data/agent_corpus.rds`. Each row is one article × one author-country.
2. For each unique value of the journal column, count the number of article-country rows contributed by each `iso3` across all years in the corpus. Divide by the journal's total row count to get each country's share.
3. Apply the **60% threshold**: a journal is classified as domestic to country X if country X's share > 0.60. At most one country can exceed the threshold for any given journal. Journals where no country exceeds 0.60 are classified as international.
4. Store the resulting lookup as a two-column table: `journal` → `domestic_iso3` (NA = international).
5. Join the lookup back to the full corpus on `journal`. Compute article-level indicator: `is_domestic = (iso3 == domestic_iso3)`, with NA → 0 (international).
6. Aggregate to country-year: `share_domestic_journal = sum(is_domestic) / n_articles_country_year`. Country-years with fewer than 5 SSH articles are excluded.

**Rationale for 60% threshold:** 60% provides a conservative, unambiguous definition of dominance. Alternative thresholds (50%, 70%) are tested in robustness checks.

---

## Step 2 — Regression model

**Primary specification (pre-registered):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop)
      | iso3 + year,
      data = cy_data,
      cluster = ~iso3)
```

- Fixed effects: country (`iso3`) + year
- Standard errors: clustered by country (`iso3`)
- Controls: `log(e_gdppc)`, `log(e_wb_pop)`
- Sample: country-years 1990–2023, ≥ 5 SSH articles, non-missing controls

**Why log population is essential:** Large SSH producers contribute more articles to more journals, mechanically raising their domestic journal share. Log population absorbs this size-driven variation.

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

```r
feols(share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop)
      | year,
      data = cy_data,
      cluster = ~iso3)
```

- Fixed effects: year only (no country FE)
- Standard errors: clustered by country (`iso3`)
- Controls: `log(e_gdppc)`, `log(e_wb_pop)`
- Sample: same as primary specification

---

## Identification strategy

**Variation exploited:** Within-country over-time variation in `v2x_libdem`. Country FE absorb all time-invariant country characteristics (language, academic system). Year FE absorb global trends in journal publishing patterns.

**Identification threats:**
1. *Reverse causality / regime-driven journal expansion:* An autocratic regime may actively expand the domestic journal ecosystem, producing a correlation that reflects infrastructure investment, not self-censorship. Robustness check R4 restricts to 1990–2005 to probe this.
2. *Mechanical large-producer effect:* Addressed by log population control and robustness check RC2.
3. *WOS indexing bias:* WOS underrepresents domestic journals in developing and autocratic countries, creating attenuating bias.

---

## Robustness checks

| Check | Specification change |
|---|---|
| RC1 | Vary domesticity threshold: re-estimate using 50% and 70% thresholds in addition to the primary 60% threshold. Tests sensitivity to the arbitrary cut-point. |
| RC2 | Restrict to small and medium SSH producers: exclude country-years above the 75th percentile of `n_articles_country_year`. Large producers (USA, UK, China) mechanically dominate many journals; this restriction reduces that confound. |
| RC3 | Alternative regime measure: replace `v2x_libdem` with `lied_binary` as the main independent variable. |
| R4 | Restrict to 1990–2005 (limit confounding from post-2000 journal expansion) |

---

## Expected output files

| File | Content |
|---|---|
| `analysis/analysis.R` | Full R script: classification, aggregation, regression, figures |
| `analysis/journal_lookup.rds` | Journal → domestic_iso3 lookup (60% threshold) |
| `analysis/cy_data.rds` | Country-year analysis dataset |
| `analysis/primary_results.json` | Coefficient, SE, p-value for main hypothesis |
| `analysis/figures/fig1_domestic_share_by_regime.pdf` | Binned scatter: `v2x_libdem` vs `share_domestic_journal` |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: main spec + robustness checks |
| `analysis/figures/fig3_top_domestic_journals.pdf` | Bar chart of journals with highest domestic concentration |
