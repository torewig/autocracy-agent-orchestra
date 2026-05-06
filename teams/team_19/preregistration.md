# Pre-registration: team_19

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 19 — Research Question

## Research question
Do SSH articles produced in more autocratic countries receive lower normalized citation impact — measured as the field-year adjusted citation ratio — than articles from more democratic countries, after conditioning on country and year fixed effects and standard economic controls?

## Rationale
Citations are a primary indicator of scholarly influence: a paper that attracts engagement from the wider research community accumulates citations, while work that fails to resonate does not. If self-censorship systematically steers researchers in autocracies toward safer, less intellectually provocative topics and framings, the resulting work is less likely to stimulate debate and scholarly follow-up. Reduced citation impact is therefore a downstream visibility consequence of self-censorship, distinct from questions of publication volume or co-authorship patterns.

## Theoretical mechanism
Researchers in autocracies face institutional incentives to avoid politically sensitive topics, controversial methods, and critical framings that could attract state scrutiny or sanction. This risk calculus produces a portfolio of published work that is systematically biased toward safe, incremental, and domestically oriented scholarship. Such work is less likely to engage the questions and controversies driving international scholarly debate, and therefore less likely to be cited by researchers elsewhere. A second pathway runs through collaboration: self-censored scholars are less likely to form international co-authorship ties, which reduces the global dissemination and uptake of their work. The expected direction is positive — higher `v2x_libdem` (more democratic) is associated with a higher normalized citation ratio, because political freedom removes incentives for the kind of intellectual caution that suppresses citation uptake.

## Theory family
visibility-suppression

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean of log1p(cite_ratio), where cite_ratio = tot_cites / field_year_mean_cites, conditional on country and year fixed effects and controls for log GDP per capita and log population.

## Unit of analysis
Country-year

## Outcome variable
`log_cite_ratio_mean`: constructed by (1) computing `cite_ratio = tot_cites / field_year_mean_cites` for each article, (2) applying the log1p transformation to handle zero-citation articles and right-skew, then (3) averaging log1p(cite_ratio) across all articles for each country-year. Country-years with fewer than 10 articles are dropped to ensure stable means.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit a lower mean normalized citation ratio for SSH articles, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls
- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. I scanned rq.md files for teams 01–18 (files found for teams 01–12, 15). No existing team uses `visibility-suppression` as its theory family or employs normalized citation impact as its outcome. All scanned teams fall in either `topic-avoidance` or related families and use outcomes based on abstract text, keyword distributions, disciplinary composition, or publication volume. Teams 20–22 (per project brief) also use citation data but with different designs: Team 20 tests citation gap by topic sensitivity, Team 21 tests a citation × co-authorship interaction, Team 22 tests Gini concentration of citations. Team 19 is the baseline test — does autocracy reduce normalized citation impact overall, unconditional on topic or collaborator type?


---

## Analysis Plan

# Team 19 — Analysis Plan

## Outcome construction
1. Compute `cite_ratio = tot_cites / field_year_mean_cites` for each article.
   This normalizes raw citation counts against the mean for all articles in the same
   field (`subject_primary`) and publication year, removing strong variation in
   citation norms across disciplines and over time.
2. Apply `log1p(cite_ratio)` to address right-skew and preserve zero-citation articles.
3. Aggregate to country-year: compute the mean of `log1p(cite_ratio)` across all
   articles per `iso3` × `year` cell. Drop country-years with fewer than 10 articles.
4. Merge with country-year controls (`v2x_libdem`, `lied_binary`, `e_gdppc`, `e_wb_pop`).

## Controls
- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population

## Model specification

### Primary specification (pre-registered)
Two-way fixed effects (TWFE): country FE + year FE, SE clustered by `iso3`.

- **Estimator:** `feols` (fixest package)
- **Outcome:** `log_cite_ratio_mean` (country-year mean of log1p(cite_ratio))
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** country (`iso3`) + year
- **Standard errors:** clustered by `iso3`

```r
feols(log_cite_ratio_mean ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
      data = cy_panel, cluster = ~iso3)
```

### Secondary specification (descriptive)
Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

- **Estimator:** `feols` (fixest package)
- **Outcome:** `log_cite_ratio_mean`
- **Main predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year only
- **Standard errors:** clustered by `iso3`

```r
feols(log_cite_ratio_mean ~ v2x_libdem + log_gdppc + log_pop | year,
      data = cy_panel, cluster = ~iso3)
```

## Identification strategy
The design exploits within-country variation in `v2x_libdem` over time. Country fixed
effects remove time-invariant country characteristics; year fixed effects remove global
citation trends. The main identification threat is citation accumulation lag: articles
published recently have fewer citations mechanically, regardless of regime. Year FE
partially absorb this, but within-year cross-country variation in article recency remains.
The primary remedy is a robustness check restricted to articles published at least 5 years
before the corpus end year, ensuring substantial citation accumulation time for all
included articles. GDP per capita is controlled to address the confound that richer
countries both democratize and produce more internationally visible research.

## Robustness checks
- **RC1 — Exclude recent articles:** Re-estimate dropping articles published after 2018. Recent articles have had less time to accumulate citations, introducing right-censoring that may correlate with country-year patterns. This tests whether results are robust to citation maturity concerns.
- **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
- **RC3 — Alternative normalization:** Use `log1p(tot_cites)` as outcome with `subject_primary` × year fixed effects instead of the pre-computed normalization, testing robustness to the normalization procedure.
- **RC4 — Aggregation floor sensitivity:** Re-run with minimum thresholds of 5 and 25 articles per country-year (instead of 10).

## Expected output files
All files written to `teams/team_19/analysis/`:

| File | Description |
|---|---|
| `analysis/analysis.R` | Full analysis script |
| `analysis/figures/fig1_cite_ratio_by_regime.pdf` | Binned scatter of log cite_ratio mean vs. v2x_libdem, residualized on FE |
| `analysis/figures/fig2_main_coef_plot.pdf` | Coefficient plot across main model and robustness specifications |
| `analysis/figures/fig3_trend_by_regime_type.pdf` | Time-series of mean cite_ratio by broad regime category |
| `analysis/tables/tab1_main_regression.tex` | Main regression table (4 columns) |
| `analysis/primary_results.json` | Machine-readable results: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
