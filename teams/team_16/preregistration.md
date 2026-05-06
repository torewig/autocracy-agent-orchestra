# Pre-registration: team_16

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 16 — Research Question

## Research question

Do researchers in more autocratic countries produce a higher share of SSH articles with exclusively domestic authorship — defined as articles where every contributing author is affiliated with the same country — compared to researchers in more democratic countries?

## Rationale

Self-censorship theory predicts that researchers in autocracies constrain their collaboration choices to minimize exposure to foreign oversight, documentation of foreign contacts, and the transmission of liberal academic norms. International co-authorship is a publicly traceable institutional tie that autocratic regimes can scrutinize; researchers who anticipate this scrutiny will avoid it by confining their collaborations to domestic partners. If this mechanism operates at scale, autocratic country-years should exhibit a systematically higher share of articles in which all authors are affiliated with the same country.

## Theoretical mechanism

In autocratic settings, researchers face career costs — dismissal, loss of funding, denial of travel permits, or harassment — for maintaining documented institutional relationships with foreign scholars, particularly those in liberal democracies. International co-authorship creates a paper trail of foreign contacts and exposes researchers to the norms, expectations, and potential political influence of foreign academic communities, all of which autocratic regimes may perceive as threatening. Anticipating these risks, researchers self-censor their collaboration strategies: they preferentially seek domestic co-authors, allow international collaborations to lapse, or avoid initiating them in the first place. The expected direction is negative: higher `v2x_libdem` is associated with a lower share of domestically-only authored articles, because greater political freedom removes the incentive to confine collaboration to domestic partners.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH articles with exclusively domestic authorship, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the share of country-year SSH articles in which all author-country affiliations belong to the same country (domestic-only articles), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_domestic_only`: constructed by (1) counting the number of distinct values of `iso3` per `wos_id` (i.e., distinct author-country affiliations per article); (2) flagging each article as `domestic_only = TRUE` if `n_distinct(iso3) == 1` for that `wos_id`; (3) aggregating to country-year: `share_domestic_only = (# domestic_only articles) / n_articles_country_year`. The outcome is a proportion bounded in [0, 1].

**Note on corpus structure:** The corpus contains one row per article × author-country combination. Each `wos_id` may therefore appear in multiple rows. Deduplication to the article level is performed before computing `n_articles_country_year` as the denominator to avoid double-counting.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. rq.md files exist for Teams 01–08, 10, and 11 (Teams 09, 12–15 have no rq.md at time of writing). The most relevant comparisons within the `collaboration-constraint` sub-family are Teams 14 and 15, as described in the project design.

- **Team 14** (mean number of distinct co-author countries per article, continuous): Team 14 measures the *degree* of international collaboration on a continuous scale — a country-year with many articles involving 2–3 foreign countries will score differently from one dominated by bilateral collaborations. Team 16 uses a binary indicator (any international co-author present vs. not) that captures the *extensive margin* — the decision to engage in any cross-border co-authorship at all — rather than the depth of collaboration. A country that systematically avoids international co-authorship will produce a high `share_domestic_only` even if its few internationally co-authored articles involve many partner countries.
- **Team 15** (share of articles with at least one co-author from a liberal democracy, v2x_libdem > 0.5): Team 15 identifies co-authorship links to specifically democratic partners and asks whether autocracies avoid those particular collaborations. Team 16 asks a more fundamental prior question: do autocracies avoid *any* international collaboration, regardless of the political character of the partner country? The two outcomes can diverge — a country could co-author with other autocracies without ever co-authoring with democracies, registering a low domestic-only share (Team 16) but a low democracy-collaboration rate (Team 15).
- **Teams 01–11** (topic-avoidance and framing-neutrality families): all are conceptually distinct — they measure what researchers write about or how they write, not with whom they collaborate.


---

## Analysis Plan

# Team 16 — Analysis Plan

## Hypothesis

Higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of SSH articles in which all author-country affiliations belong to the same country (domestic-only articles) at the country-year level.

---

## Outcome variable construction

The corpus has one row per article x author-country. Construction proceeds in three steps:

1. **Compute article-level country count:** Group by `wos_id` and count `n_distinct(iso3)`. Flag `domestic_only = (n_countries == 1)`.
2. **Deduplicate to article level:** For each `wos_id`, retain one row (e.g., `slice(1)` after grouping by `wos_id`) carrying the `domestic_only` flag, plus `iso3`, `year`, and country-year controls.
3. **Aggregate to country-year:** `share_domestic_only = sum(domestic_only) / n()` per country-year, where the denominator is the count of distinct articles for that country-year (not the raw row count from the corpus).

The constructed outcome is a proportion in [0, 1].

---

## Method

Panel regression with two-way fixed effects, estimated via `fixest::feols`. The unit of observation is the country-year. The outcome is treated as a linear probability model on the proportion to allow two-way FE and straightforward coefficient interpretation.

---

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

---

## Model specification

### Primary model (pre-registered): Two-way fixed effects

```
share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

- **Outcome:** `share_domestic_only` (proportion, country-year)
- **Main predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `iso3` + `year`
- **Standard errors:** Clustered by `iso3`

Expected sign: negative (higher democracy -> lower domestic-only share).

### Secondary model (descriptive): Pooled OLS with year FE only

```
share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year
```

- **Outcome:** `share_domestic_only` (proportion, country-year)
- **Main predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** `year` only (no country FE)
- **Standard errors:** Clustered by `iso3`

This specification estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Country FE are omitted so that between-country variation is retained. Both the primary and secondary specifications are reported in the same regression table.

### RC1 — Restrict to multi-author articles

Re-estimate computing `share_domestic_only` only over articles with `n_authors > 1`. Single-author papers always score as domestic-only regardless of self-censorship; this restriction isolates the collaboration avoidance effect from single-authorship rates.

```
share_domestic_only_multi ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

where `share_domestic_only_multi` is computed using only articles with `n_authors > 1` in both numerator and denominator.

### RC2 — Alternative regime measure

Replace `v2x_libdem` with `lied_binary` as the main independent variable:

```
share_domestic_only ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```

Expected sign: positive (autocracy = 1 -> higher domestic-only share).

---

## Identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem`. Country FE absorb all time-invariant cross-country confounders (geography, language, historical ties, research infrastructure). Year FE absorb global shocks to international collaboration norms (internet diffusion, growth of international conferences, global funding programs).

**Key confounders controlled:**
- Country size (`log(e_wb_pop)`): larger countries have deeper domestic labor markets for collaboration.
- Development level (`log(e_gdppc)`): richer countries have stronger international linkages for non-political reasons.
- Global trends: absorbed by year FE.

**Identification threats:**
1. *Reverse causality:* Countries with isolated scientific communities may be more susceptible to autocratic consolidation. Within-country FE reduce but do not eliminate this.
2. *Time-varying confounders:* Economic shocks, sanctions, or language policy changes could jointly affect regime type and collaboration patterns. Log GDP per capita partially addresses this.
3. *Selection into WOS corpus:* WOS over-represents internationally connected researchers regardless of regime, likely attenuating the estimated effect toward zero (conservative bias).
4. *Small-country mechanical bias:* Microstates may have structurally high domestic-only rates. Sensitivity analyses excluding very small countries may be reported.

---

## Expected output files

All outputs written to `teams/team_16/analysis/`:

| File | Content |
|---|---|
| `analysis/analysis.R` | Full analysis script (tidyverse + fixest) |
| `analysis/figures/fig1_domestic_share_by_regime.pdf` | Binned scatter: mean domestic-only share by v2x_libdem decile, loess smoother |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: primary model + robustness checks |
| `analysis/figures/fig3_trend_by_regime.pdf` | Time series of mean domestic-only share by regime category, 1970-2023 |
| `analysis/primary_results.json` | JSON: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/tables/reg_table.tex` | Regression table: primary model + three robustness specs (modelsummary or stargazer) |

---

## Sample restrictions

- Country-years with zero articles are dropped by construction.
- Articles with missing `iso3` are excluded before computing the domestic-only flag.
- Pre-1990 data retained but flagged; sensitivity excluding pre-1990 observations noted in the report.
