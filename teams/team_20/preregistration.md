# Pre-registration: team_20

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 20 — Research Question

## Research question

Do autocratic researchers receive a citation penalty specifically for politically sensitive articles, beyond any general autocracy citation disadvantage?

## Rationale

Prior work documents that researchers in autocracies publish less on sensitive topics (self-censorship in topic choice). Team 20 asks whether the work that does get published on sensitive topics from autocracies is further penalized in the citation market. This is analytically distinct from a general citation gap (Team 19): it tests whether the suppression of scientific visibility is most acute precisely where political sensitivity is highest. A significant interaction would indicate that autocracy shapes not only what is written but how much traction sensitive work gains.

## Theoretical mechanism

Autocratic researchers who publish on sensitive topics face two compounding pressures. First, to survive domestic review they likely hedge findings, soften conclusions, or frame arguments in ways that reduce political risk — producing work that is less intellectually bold and therefore less citable internationally. Second, international audiences may discount sensitive-topic articles from autocracies on credibility grounds, suspecting state-induced framing or data access constraints. Both channels predict the same direction: the autocracy penalty on citations is larger for politically sensitive articles than for non-sensitive articles. Formally, the interaction coefficient on `v2x_libdem * sensitive_flag` is expected to be positive (higher democracy score strengthens the citation advantage of sensitive-topic work), or equivalently the interaction `autocracy * sensitive_flag` is negative.

## Hypothesis

H1: The citation penalty associated with lower Liberal democracy levels will be larger for politically sensitive articles than for non-sensitive articles, as indicated by a positive coefficient on the v2x_libdem × sensitive_flag interaction term, after controlling for country fixed effects, year fixed effects, field fixed effects, log GDP per capita, and log population.

## Controls

- `log(e_gdppc)` and `log(e_wb_pop)`, merged at the country-year level
- Field fixed effects (or field-year fixed effects) are included as part of the model specification to account for differential citation norms across disciplines

## Theory family

`visibility-suppression`

## Estimand

The differential effect of autocracy on normalized citations for politically sensitive articles relative to non-sensitive articles — i.e., the interaction effect of `v2x_libdem` and `sensitive_flag` on `log1p(cite_ratio)` at the article level.

## Unit of analysis

Article (one observation per article; country-year and field controls included as covariates and fixed effects).

## Outcome variable

`log1p(cite_ratio)` where `cite_ratio = tot_cites / field_year_mean_cites`. Log-transforming the ratio normalizes across fields and cohorts with different citation norms. Articles with `field_year_mean_cites == 0` or missing are excluded.

## Key IV

`v2x_libdem` (continuous, 0–1; higher = more democratic) interacted with `sensitive_flag` (binary, 1 = article title or keywords match the Team 04 regime-sensitive keyword dictionary). The main effect of `v2x_libdem` controls for the general citation gap; the interaction isolates the additional sensitivity-specific penalty.

## Uniqueness check

Team 19 estimates the overall citation gap between autocracies and democracies (main effect only, country-year level). Team 20 is distinguished by: (1) article-level analysis rather than country-year; (2) the interaction term as the primary estimand; (3) the sensitive-topic subgroup as the mechanism through which autocracy suppresses visibility. No other team in the 01–19 range combines citation outcomes with a topic-sensitivity interaction at the article level.


---

## Analysis Plan

# Team 20 — Analysis Plan

## Method

The analysis proceeds in four stages: (1) replicate the Team 04 keyword flag at the article level; (2) construct the normalized citation outcome; (3) estimate the primary interaction model; (4) robustness checks.

### Stage 1 — Keyword flag (replicating Team 04)

Apply the Team 04 `dict_pattern` regex case-insensitively to `paste(title, keywords, sep = " | ")` (NA treated as empty string). Assign `sensitive_flag = 1` if any pattern matches, 0 otherwise. Use the exact combined `dict_pattern` from `teams/team_04/analysis_plan.md` (covers democracy, human rights, civil rights/liberties, corruption/bribery, protest/contention, repression, censorship, political prisoners, authoritarianism, political freedom, electoral fraud, dissent/opposition).

### Stage 2 — Citation outcome

`cite_ratio = tot_cites / field_year_mean_cites`. Drop articles where `field_year_mean_cites` is zero or missing. Outcome: `log1p(cite_ratio)`.

### Stage 3 — Sample restrictions

Non-missing `v2x_libdem`, `tot_cites`, `field_year_mean_cites`, `iso3`; years 1990–2023; articles published no later than 2020 to allow at least 3 years of citation accumulation.

### Stage 4 — Primary regression

```r
feols(log1p(cite_ratio) ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) |
      iso3 + year + subject_primary,
      data = df, cluster = ~iso3)
```

Coefficient of interest: `v2x_libdem:sensitive_flag` — positive expected sign.

## Model specification

**Primary specification (pre-registered):** Article-level regression with country FE + year FE + field FE, SE clustered by `iso3`.

- Outcome: `log1p(cite_ratio)`
- Predictors: `v2x_libdem * sensitive_flag` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: `iso3 + year + subject_primary`
- SE clustering: `~iso3`
- Expected sign on interaction: positive

**Secondary specification (descriptive):** Article-level regression with year FE + field FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional association, complementing the within-country primary estimate. Both specifications should be reported in the same regression table.

- Outcome: `log1p(cite_ratio)`
- Predictors: `v2x_libdem * sensitive_flag` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: `year + subject_primary`
- SE clustering: `~iso3`

## Controls

- `log(e_gdppc)` and `log(e_wb_pop)`, merged at the country-year level
- Field fixed effects (`subject_primary`) included to account for differential citation norms across disciplines; field-year fixed effects may be substituted as an alternative specification

## Causal identification strategy

Country, year, and field FEs absorb time-invariant country traits, global citation trends, and field citation norms. Identifying variation is within-country over time, interacted with article-level topic sensitivity.

Main threat: sensitive topics may attract different citations for non-regime reasons (globally hot-button topics). Field FEs partially address this. The political science/sociology subsample (Robustness 2) is the key diagnostic.

## Robustness checks

- **RC1 — Alternative sensitivity flag:** Re-estimate using Team 03's disciplinary sensitivity classification (`subject_primary` in politically sensitive WOS field) as the sensitivity indicator, instead of Team 04's keyword flag. This tests whether the interaction result is robust to how "sensitivity" is operationalized.
- **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable; interaction becomes `lied_binary * sensitive_flag`.
- Restrict to Political Science, Sociology, Law, International Relations, Area Studies.
- Narrow keyword dictionary (5 patterns: `democra`, `human rights`, `repression`, `authoritarian`, `\bcensor`).
- Title-only keyword matching (exclude `keywords` field).
- Restrict sample to 1990–2015 for longer citation accumulation window.

## Expected output files

Saved to `teams/team_20/analysis/figures/` and `teams/team_20/analysis/`:

| File | Description |
|---|---|
| `fig_interaction.png` | Predicted `log1p(cite_ratio)` by `v2x_libdem` for `sensitive_flag = 0` and `= 1`, with 95% CI bands |
| `fig_coef.png` | Interaction coefficient across primary model and robustness specs |
| `fig_citation_dist.png` | Density of `log1p(cite_ratio)` by sensitive flag and regime quartile |
| `tab_main.txt` | Regression table (primary + robustness 1–2), `modelsummary` |
| `primary_results.json` | Point estimates, SEs, N, model metadata |
