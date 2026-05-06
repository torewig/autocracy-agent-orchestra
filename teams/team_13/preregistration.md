# Pre-registration: team_13

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 13 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish a higher share of their SSH output in domestically dominated journals — journals where the majority of authors are from the same country — compared to researchers from more democratic countries?

## Hypothesis

H1: Countries with lower Liberal democracy levels will publish a higher share of SSH output in domestically dominated journals, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Rationale

Publishing in an international journal subjects a paper to editorial standards, reviewer networks, and professional norms anchored in liberal academic culture; publishing in a domestically dominated journal places the work in a locally controlled institutional environment where regime-aligned editorial gatekeepers have greater influence. If researchers in autocracies self-censor by selecting publication venues that reduce exposure to external scrutiny and liberal editorial norms, we should observe that autocratic country-years exhibit a systematically higher share of SSH output in journals dominated by authors from the same country. This prediction is observable from the corpus alone — no external journal registry is required.

## Theoretical mechanism

In autocratic settings, researchers and their institutions anticipate that publishing in internationally edited journals increases exposure to external evaluation: foreign reviewers and editors may flag politically sensitive findings, require comparative or regime-critical framings, or simply impose norms of academic freedom that are incompatible with state preferences. To minimize this exposure, researchers rationally prefer publication venues where editorial control is domestic — where local institutions aligned with the regime influence acceptance decisions and where the readership remains largely insulated from international academic debate. At the country-year level, this risk-minimization strategy should produce a measurably higher share of publications in domestically dominated journals under autocracy. The expected direction is negative: higher `v2x_libdem` is associated with a lower share of publications in domestic journals, because democratic environments remove the political cost of engaging with international editorial scrutiny.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles published in journals classified as domestically dominated (where the focal country contributes >60% of all articles in that journal across the full corpus), conditional on country and year fixed effects and controls for `log(e_gdppc)` and `log(e_wb_pop)`.

## Unit of analysis

Country-year (one observation per `iso3` × `year`, restricted to country-years with at least 5 SSH articles).

## Outcome variable

`share_domestic_journal`: the proportion of a country-year's SSH articles that appear in a journal classified as domestically dominated by that country. Construction:

1. Using the full corpus, for each journal (`journal` column), count the total number of article-country rows per country (iso3). Compute each country's share of total article-country rows for that journal across all years.
2. A journal is classified as **domestic to country X** if country X contributes strictly more than 60% of the journal's total article-country rows in the corpus. A journal may be domestic to at most one country under this rule (since 60% > 0.5, mutual domination is impossible).
3. A journal that does not exceed the 60% threshold for any single country is classified as **international**.
4. For each article in the corpus, assign the binary indicator `is_domestic = 1` if the journal is domestic to the author's `iso3`, else 0.
5. Aggregate to country-year: `share_domestic_journal = sum(is_domestic) / n_articles_country_year`.

The outcome is a proportion bounded in [0, 1].

**Note on large-country bias:** Large SSH producers (USA, UK, China) will mechanically have higher counts in many journals. Controlling for log population (`log_pop`) in the regression partially absorbs this. An additional robustness specification restricts the sample to country-years with `n_articles_country_year` below the 75th percentile (i.e., small and medium producers), where the mechanically-domestic effect is weaker.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 10, 11, and 15 at time of writing.

Team 13 is distinct from all existing teams on two dimensions:

- **Outcome dimension:** No other team uses journal venue choice as the outcome. The closest structural analogues are Team 15 (co-authorship with liberal democracies) and Team 16 (domestic-only authorship). Team 15 measures the regime composition of co-author countries; Team 16 measures whether all authors are from a single country. Team 13 measures a publication venue choice — whether the journal itself is controlled by a domestic author community — which is conceptually and operationally separate: a paper can have exclusively domestic authors (Team 16 = 1) but appear in an international journal (Team 13 = 0), or vice versa.

- **Theoretical mechanism:** Teams 08, 09, 10, 11 in the `framing-neutrality` family all concern the rhetorical or semantic content of what researchers write. Team 13 concerns where they choose to publish — a strategic selection of institutional venue that reflects anticipated editorial scrutiny, not a linguistic framing decision. The channel is editorial gatekeeping under domestic control, not abstract or title wording.

- **No external API required:** The journal-country classification is constructed entirely from the corpus using a count-based threshold, consistent with the Medium complexity rating.


---

## Analysis Plan

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
