# Pre-registration: team_02

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 02 — Research Question

## Research question
Does higher autocracy reduce the topical breadth of author-supplied keywords in SSH publications, as measured by the Shannon entropy of the keyword distribution aggregated to the country-year level?

## Rationale
Author-supplied keywords are the researcher's own signal of what a paper is about; in autocratic settings, researchers who self-censor will gravitate toward safer, institutionally approved topics, causing keyword vocabularies to concentrate around a narrower range of terms. If self-censorship operates systematically, this compression should be visible in the aggregate diversity of keywords produced by a country in a given year. Topical entropy is a direct, interpretable summary of how broadly or narrowly distributed scholarly attention is across the keyword space, making it well-suited to detecting this compression.

## Theoretical mechanism
Autocratic regimes impose career costs — through dismissal, grant denial, publication rejection, or informal social sanctioning — on scholars who study politically sensitive subjects such as governance, civil liberties, protest, or regime critique. Faced with these costs, individual researchers rationally avoid risky topic choices, shifting instead toward politically neutral subjects (economic history, linguistics, natural resource management, etc.). When this avoidance is widespread across a country's research community, the aggregate keyword distribution becomes more concentrated: fewer distinct keywords are used, and a smaller set of dominant terms accounts for a larger share of total keyword tokens. The expected direction is negative — higher `v2x_libdem` (more democracy) is associated with higher keyword entropy (wider topical spread).

## Theory family
topic-avoidance

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the Shannon entropy of the country-year author-keyword distribution, conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis
Country-year

## Outcome variable
`keyword_entropy_cy` — constructed variable: for each country-year, parse `author_keywords` into individual keyword tokens (split on `";"` or `"|"`), strip whitespace, lowercase; compute Shannon entropy H = -sum(p_k * log(p_k)) over the empirical keyword frequency distribution for that country-year (p_k = relative frequency of keyword k among all keyword tokens for that country-year). Articles without author keywords are excluded from the keyword pool for that country-year. Denominator check: country-years with fewer than 10 keyword-bearing articles are dropped to ensure stable entropy estimates.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit lower Shannon entropy of author-supplied keyword distributions at the country-year level, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no rq.md files found for teams 01–06 at time of writing).
Distinction: Team 01 counts political-content keywords in abstracts (a sensitivity/prevalence measure); Team 04 counts specific sensitive terms (democracy, human rights) in titles and keywords; Team 06 measures semantic diversity via costly text embeddings. This team measures the topical breadth of the author-supplied keyword vocabulary using Shannon entropy — a structural diversity measure applied specifically to the keyword field, requiring no API and no predefined dictionary.


---

## Analysis Plan

# Team 02 — Analysis Plan

## Method

**Outcome construction (keyword entropy):**
1. Load `data/agent_corpus.rds`. Filter to rows where `author_keywords` is non-missing.
2. Parse `author_keywords` into individual tokens by splitting on `";"` (primary WOS separator) and `"|"` (alternative separator); trim whitespace; convert to lowercase.
3. Aggregate to the country-year level: for each `iso3` x `year` cell, collect all keyword tokens across all articles, compute token frequencies, and calculate Shannon entropy:
   H = -sum(p_k * log(p_k + 1e-10)) where p_k is the relative frequency of keyword k among all tokens for that country-year.
4. Drop country-years with fewer than 10 keyword-bearing articles (entropy is unreliable for very small samples).
5. Join to country-year level controls: `v2x_libdem`, `lied_binary`, `v2x_regime`, `log(e_gdppc)`, `log(e_wb_pop)`, `n_articles_country_year`.

**Regression model:**
OLS with two-way fixed effects (country FE + year FE), estimated via `fixest::feols`. The outcome is `keyword_entropy_cy`. Regression controls are `log(e_gdppc)` and `log(e_wb_pop)`. Country-years are the unit of observation; each observation is weighted by `log(n_articles_country_year)` to down-weight country-years with very few articles (optional sensitivity check: unweighted model as robustness).

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects (TWFE):

- Outcome: `keyword_entropy_cy` (Shannon entropy of author keywords, country-year level)
- Predictors: `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: country FE + year FE
- SE clustering: by `iso3`
- Sample restriction: country-years with >= 10 keyword-bearing articles; years 1990-2023 (pre-1990 data sparse and less reliable)

### Secondary specification (descriptive)

Pooled OLS with year FE only (no country FE):

- Outcome: `keyword_entropy_cy`
- Predictors: `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- Fixed effects: year FE only
- SE clustering: by `iso3`
- Sample restriction: same as primary specification

This estimates the cross-sectional level association between regime type and keyword entropy, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

## Causal identification strategy

The key identifying variation is within-country change in `v2x_libdem` over time. Country fixed effects absorb all time-invariant country characteristics (geographic, cultural, structural); year fixed effects absorb global trends in keyword practices and WOS coverage expansion. The coefficient on `v2x_libdem` is therefore identified from within-country democratization and autocratization episodes.

Main threats to identification:
1. **Economic confounding:** Wealthier countries may produce more diverse research and also tend to be more democratic. Addressed by including `log(e_gdppc)` as a control.
2. **WOS coverage changes:** WOS may expand coverage in countries at particular regime moments, inflating keyword counts and entropy. Partially addressed by `n_articles_country_year` weighting and year FE.
3. **Reverse causality:** Unlikely at the country-year level, but possible if regimes selectively restrict publication in fields with diverse keywords.
4. **Composition effects:** Country-level keyword diversity partly reflects which WOS journals cover that country; journal composition shifts may be driven by regime-independent factors. Addressed by including subject field as a robustness check (model with subject FE or restricting to a single broad SSH field).

## Robustness checks

1. **Binary regime measure:** Replicate main model replacing `v2x_libdem` with `lied_binary`. Coefficient should be positive and significant if the main result is robust.
2. **Unweighted model:** Drop `log(n_articles_country_year)` weights; check if results hold.
3. **Full sample (1970-2023):** Extend to pre-1990 years; check coefficient stability.
4. **Type-token ratio alternative:** Replace Shannon entropy with the number of unique keywords divided by total keyword tokens as an alternative diversity measure. This is less sensitive to rare keywords.
5. **Subject-field restricted sample:** Restrict to political science and related fields (`subject_primary` matching political science, sociology, law, IR) to sharpen theoretical focus and reduce noise from fields where self-censorship expectations are weaker.

## Expected output files

All saved to `teams/team_02/analysis/figures/`:

- `fig1_entropy_by_regime.pdf` -- Box plots of `keyword_entropy_cy` by `v2x_regime` category (descriptive; four regime types on x-axis)
- `fig2_entropy_trend.pdf` -- Mean keyword entropy over time by broad regime category (democratic vs. autocratic, `lied_binary`), 1990-2023
- `fig3_main_coef.pdf` -- Coefficient plot for main model and robustness checks (at minimum: main model, `lied_binary` robustness, unweighted robustness)
- `tab1_main_results.tex` -- Main regression table (2-3 columns: baseline OLS no FE, main TWFE model, model with additional controls), formatted with `modelsummary`

`teams/team_02/analysis/primary_results.json` -- standard fields: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs
