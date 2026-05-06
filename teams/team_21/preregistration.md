# Pre-registration: team_21

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 21 — Research Question (Redesign, 2026-05-06)

## Research question

Does autocracy predict a lower share of SSH articles that receive at least one citation, measured as the proportion of ever-cited articles within a country-year?

## Rationale

A substantial fraction of published SSH articles — roughly 29% in this corpus — are never cited at all. If self-censorship pushes researchers in autocracies toward safe, incremental, and domestically oriented work, these articles should be less likely to attract any international follow-up, not merely fewer citations on average. The share of ever-cited articles captures this participation threshold: it distinguishes countries where publication reliably enters the citation economy from those where a large share of output is invisible to the broader scholarly community. This is conceptually distinct from mean citation level (Team 19) or citation inequality (Team 22): it asks whether autocracy raises the probability that a piece of scholarship is completely ignored.

## Theoretical mechanism

Researchers in autocracies face strong incentives to avoid politically sensitive topics, controversial methods, and critical framings that could attract state scrutiny or sanction. This risk calculus produces a portfolio of published work biased toward safe, formulaic, and locally relevant scholarship. Such work — compliant rather than intellectually provocative — is less likely to engage the questions driving international scholarly debate, and therefore less likely to receive even a single citation from researchers elsewhere. The causal chain runs from regime type to self-censorship in topic and framing choice, to production of work with limited international relevance, to a lower probability of any citation uptake. The expected direction is positive: higher `v2x_libdem` (more democratic) is associated with a higher share of ever-cited articles within a country-year, because political freedom expands the intellectual space available to researchers and increases the probability that any given article generates at least one scholarly response.

## Theory family

`visibility-suppression`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH articles that receive at least one citation within a country-year, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year proportion of articles with `tot_cites >= 1`, conditional on country and year fixed effects and controls for `log(e_gdppc)` and `log(e_wb_pop)`. Country-years with fewer than 10 distinct articles are excluded to ensure stable proportions.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least 10 distinct articles after deduplication by `wos_id`).

## Outcome variable

`prop_ever_cited`: the proportion of distinct articles from a given country-year that have `tot_cites >= 1`. Constructed by (1) deduplicating articles at the `wos_id` level to prevent multi-author rows from inflating cell size, (2) computing a binary `ever_cited = as.integer(tot_cites >= 1)` for each article, then (3) taking the mean of `ever_cited` within each `iso3` × `year` cell. Bounded [0, 1]; higher values indicate a larger share of the country's SSH output enters the citation economy.

## Key independent variable

`v2x_libdem` (continuous, 0–1; higher = more democratic). Matched to each country-year observation from the V-DEM data already merged in the corpus.

## Controls

- `log(e_gdppc)` — log GDP per capita; controls for overall research infrastructure and resources
- `log(e_wb_pop)` — log population; controls for country size and potential domestic citation market

## Robustness checks

- **RC1 (sample restriction):** Repeat the main model restricting to 1990–2023 to avoid sparse pre-1990 coverage and any structural break in WOS coverage.
- **RC2 (alternative regime measure):** Replace `v2x_libdem` with `lied_binary` (0 = autocracy, 1 = democracy) to assess whether results hold under a dichotomous regime classification.

## Uniqueness check

Most similar teams: Team 19 and Team 22.

- **Team 19** estimates the effect of `v2x_libdem` on the country-year *mean* of log-normalized citation ratios — a test of average citation level, not the probability of receiving any citation. Team 21 uses a distinct outcome (the share of articles with at least one citation) that captures the lower bound of citation participation rather than central tendency.
- **Team 22** estimates the effect of `v2x_libdem` on the Gini coefficient of `tot_cites` within country-years — a distributional inequality measure. Team 21's outcome (the zero-citation margin) is conceptually and statistically separate from within-distribution inequality.
- **Team 20** operates at the article level with a topic-sensitivity interaction. Team 21 uses the country-year as the unit with a simple main effect.

No existing team uses the share of ever-cited articles as the outcome. Team 21 is the only team asking whether autocracy raises the probability that a piece of SSH scholarship is entirely absent from the citation record.


---

## Analysis Plan

# Team 21 — Analysis Plan (Redesign, 2026-05-06)

## Method

Two-way fixed-effects OLS regression (`fixest::feols`) at the country-year level. The outcome is a proportion bounded [0, 1]; a linear probability model with two-way FE is the primary specification.

---

## Data construction

### Step 1: Deduplicate and compute ever_cited

The corpus has one row per article x country. Deduplicate at `wos_id` within each country-year before computing proportions:

```r
article_level <- corpus |>
  group_by(iso3, year, wos_id) |>
  slice(1) |>
  ungroup() |>
  mutate(ever_cited = as.integer(tot_cites >= 1))
```

### Step 2: Collapse to country-year

```r
cy <- article_level |>
  group_by(iso3, year) |>
  summarise(
    prop_ever_cited = mean(ever_cited, na.rm = TRUE),
    n_articles      = n(),
    v2x_libdem      = first(v2x_libdem),
    lied_binary     = first(lied_binary),
    log_gdppc       = log(first(e_gdppc) + 1),
    log_pop         = log(first(e_wb_pop) + 1),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10, !is.na(v2x_libdem), !is.na(prop_ever_cited))
```

Country-years with fewer than 10 distinct articles are dropped.

---

## Model specification

### Primary model (pre-registered)

Two-way fixed effects: country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)

m1 <- feols(
  prop_ever_cited ~ v2x_libdem + log_gdppc + log_pop |
    iso3 + year,
  data    = cy,
  cluster = ~iso3
)
```

- **Outcome:** `prop_ever_cited` — proportion of articles with `tot_cites >= 1` in a country-year
- **Key IV:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log_gdppc`, `log_pop`
- **Fixed effects:** country (`iso3`) + year
- **SE clustering:** by `iso3` (country-level, to account for within-country serial correlation)
- **Coefficient of interest:** the coefficient on `v2x_libdem` — interpreted as the average within-country change in the share of ever-cited articles associated with a one-unit increase in the liberal democracy index

---

### Secondary model (descriptive)

Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

```r
m2 <- feols(
  prop_ever_cited ~ v2x_libdem + log_gdppc + log_pop |
    year,
  data    = cy,
  cluster = ~iso3
)
```

- **Outcome:** `prop_ever_cited`
- **Key IV:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log_gdppc`, `log_pop`
- **Fixed effects:** year only (no country FE)
- **SE clustering:** by `iso3`
- **Coefficient of interest:** the coefficient on `v2x_libdem` — interpreted as the cross-sectional association between regime type and the share of ever-cited articles, averaging across all country-years within a given calendar year

---

## Causal identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem`. Country fixed effects absorb all time-invariant country characteristics correlated with both regime type and the share of ever-cited articles (e.g., language, research infrastructure baseline, WOS coverage of domestic journals). Year fixed effects absorb global trends in citation practices and WOS database growth.

**Confounders controlled:** `log(e_gdppc)` controls for economic development, which affects research investment and citation uptake through channels other than regime type. `log(e_wb_pop)` controls for country size, which determines the potential domestic citation market.

**Identification threats:**
1. *Reverse causality:* Unlikely — the share of cited articles in a country does not plausibly cause regime change.
2. *Time-varying WOS coverage:* Country-specific changes in WOS journal coverage over time could shift `prop_ever_cited` mechanically. Year FE absorbs global coverage trends; country-specific shifts are a residual threat to be flagged in the report.
3. *Citation lag:* Year FE absorbs the global maturation trend for citation accumulation; within-country compositional shifts in article age are a minor residual concern.

---

## Robustness checks

**RC1 (sample restriction — 1990–2023):** Repeat the main model restricting to `year >= 1990` to avoid sparse pre-1990 WOS coverage. This is the primary substantive robustness check.

**RC2 (alternative regime measure):** Replace `v2x_libdem` with `lied_binary` (0 = autocracy, 1 = democracy) in the identical model specification. Tests whether results are robust to a dichotomous rather than continuous operationalization of regime type.

---

## Expected output files

All outputs written to `teams/team_21/analysis/` and `teams/team_21/report/`:

| File | Contents |
|---|---|
| `analysis/analysis.R` | Full script: data construction, primary model, robustness checks, figure and table export |
| `analysis/figures/fig_scatter.pdf` | Scatter plot of country-year mean `v2x_libdem` vs. `prop_ever_cited`, with regression line |
| `analysis/figures/fig_coef.pdf` | Coefficient plot for `v2x_libdem` across primary model and robustness specifications |
| `analysis/figures/fig_trend.pdf` | Time-series of mean `prop_ever_cited` for democracies vs. autocracies (1990-2023) |
| `analysis/primary_results.json` | Fields: `team`, `hypothesis_label`, `theory_family`, `predictor`, `outcome`, `coefficient`, `SE`, `p_value`, `n_obs` |
| `report/tab_main.tex` | LaTeX regression table: primary model + RC1 + RC2 |
