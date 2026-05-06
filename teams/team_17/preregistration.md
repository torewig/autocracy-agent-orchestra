# Pre-registration: team_17

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 17 — Research Question

## Research question

Do SSH researchers affiliated with more autocratic countries publish articles with fewer authors on average, at the country-year level, compared to researchers from more democratic countries?

## Rationale

Collaborative research requires multiple people to share ideas, access data, and jointly produce work that may attract political scrutiny. In autocratic settings, adding collaborators multiplies the risk of exposure: each additional team member is a potential informant, a source of ideological conflict, or a witness to politically sensitive discussions. Researchers anticipating these risks have an incentive to work alone or in smaller groups, reducing the mean number of authors per article. Team size is therefore a plausible behavioral footprint of self-censorship operating through collaboration avoidance.

## Theoretical mechanism

In autocracies, regime agents, institutional supervisors, and colleagues may monitor research for politically problematic content and report infractions. Each collaborator added to a project increases the number of people with knowledge of the work-in-progress, widening the circle of potential informants and the surface area for surveillance. Researchers rationally minimize this risk by working in smaller teams, avoiding the coordination costs and exposure that come with larger groups. Institutional resource constraints and disciplinary norms also shape team size, so any autocracy effect is expected to be modest and is a weaker test of the self-censorship mechanism than direct measures of collaboration structure (e.g., avoidance of international or democratic partners). The expected direction is positive: higher `v2x_libdem` → higher mean author count per article, because democratic environments reduce the personal risk of collaborative exposure.

**Important limitation:** Team size is heavily determined by disciplinary norms (e.g., natural sciences vs. humanities) and resource availability (lab infrastructure, grant funding). Because the corpus is restricted to SSH articles, disciplinary confounding is partially attenuated, but variation in field mix across country-years must still be controlled. This outcome is therefore a noisy proxy for the self-censorship mechanism and should be interpreted cautiously alongside direct collaboration-structure tests (Teams 14–16).

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower mean number of authors per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean number of authors per article, conditional on country and year fixed effects, discipline (subject field) composition, and standard economic controls.

## Unit of analysis

Country-year

## Outcome variable

`mean_n_authors`: the mean number of authors per article, aggregated to the country-year level. Constructed by (1) computing `n_authors` at the article level — either directly from a pre-existing column or, if absent, by counting the number of distinct author entries per `wos_id` — and (2) taking the unweighted mean across all articles attributed to each country-year. Country-years with fewer than 10 article-author rows are excluded.

Note: The corpus is structured with one row per article-author-country affiliation. If `n_authors` does not exist as a column, it must be derived as `n_distinct(author_id)` or equivalent per `wos_id` before aggregation.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Existing rq.md files cover Teams 01, 02, 03, 04, 05, 06, and 11. Brief files reviewed for Teams 14, 15, and 16 (the other `collaboration-constraint` teams).

Team 17 is distinct from all prior teams on the following grounds:

- **Versus Teams 14–16 (collaboration-constraint sub-family):** Team 14 measures the number of distinct co-author *countries* per article (geographic breadth of collaboration). Team 15 measures whether any co-author country is a liberal democracy (v2x_libdem > 0.5). Team 16 measures the share of articles that are purely domestic (all author countries identical). All three operationalize the *structure and origin* of collaborators. Team 17 measures the *total number of authors* regardless of their national origin — a distinct quantity that can vary independently: a purely domestic article may have two authors or twenty.
- **Versus Teams 01–06 and 11 (topic-avoidance and framing-neutrality sub-families):** These teams measure what is written (abstract content, political keywords, disciplinary field, argumentative stance) rather than who writes it or how many do.
- No other team tests whether autocracy predicts a lower mean author count per article at the country-year level.


---

## Analysis Plan

# Team 17 — Analysis Plan

## Hypothesis

Higher liberal democracy (`v2x_libdem`) is associated with a higher mean number of authors per article at the country-year level (positive coefficient), after controlling for country fixed effects, year fixed effects, and economic confounders.

---

## Data construction

### Step 1 — Derive article-level author count

The corpus has one row per article x author-country affiliation. Check whether `n_authors` already exists as a column. If not, construct it by counting distinct author entries per `wos_id`. Identify the correct author identifier column by inspecting `names(corpus)` for columns matching `author|n_auth`.

### Step 2 — Aggregate to country-year

Aggregate to country-year mean, filtering to country-years with at least 10 articles. Compute both `mean_n_authors` and `log_mean_authors = log(mean_n_authors + 1)` for use in robustness checks.

Join regime and control variables from the corpus (already merged at article level; take the first non-missing value per country-year for regime/economic variables).

### Step 3 — Log-transform controls

Construct `log_gdppc = log(e_gdppc)` and `log_pop = log(e_wb_pop)`.

---

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

---

## Model specification

**Primary specification (pre-registered — M1):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

- Outcome: `mean_n_authors` (country-year mean author count per article)
- Key predictor: `v2x_libdem` (continuous, 0-1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: country (`iso3`) + year
- SE clustering: by country (`iso3`)
- Estimator: `fixest::feols`

**Secondary specification (descriptive — M1b):**

- Outcome: `mean_n_authors`
- Key predictor: `v2x_libdem`
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: year only (no country FE)
- SE clustering: by country (`iso3`)
- Estimator: `fixest::feols`
- Purpose: estimates the cross-sectional level association between regime type and author count, complementing the within-country estimate from M1. Both M1 and M1b should be reported in the same regression table.

**Discipline-composition model (M2 — preferred):**

Discipline mix is a major confounder: SSH fields differ sharply in typical team size (e.g., humanities vs. economics), and field composition varies across country-years. Address this by disaggregating to country-year-field cells and adding `subject_primary` as a third fixed effect. This is the preferred specification given the limitation noted in `rq.md`.

---

## Identification strategy

**Variation exploited:** Within-country, within-year variation in `v2x_libdem`, leveraging democratic transitions and backsliding episodes across the 1970-2023 panel.

- Country FE absorb time-invariant country characteristics (geography, baseline research culture, team-size norms).
- Year FE absorb global secular trends in author counts (the well-documented rise in multi-author publishing since the 1980s).
- Economic controls absorb variation in research investment and country size.
- Subject field FE in M2 absorb discipline-specific team-size norms.

**Identification threats:**

1. Discipline composition shift: autocratic country-years may shift toward smaller-team disciplines (humanities, solo-author theory). M2 addresses this directly.
2. Publication selection bias: autocracies may suppress publication of small solo-author papers, biasing the observed mean upward in autocracies and attenuating the true negative effect (conservative-bias direction).
3. Secular authorship inflation: year FE absorb the common global trend; country-specific adoption rates of large-team practices may introduce residual confounding, especially pre-1990.
4. Reverse causality: unlikely (team size does not plausibly cause democratization); country FE reduce spurious omitted-variable correlation.

---

## Robustness checks

| Check | Description |
|---|---|
| RC1: Field fixed effects | Re-estimate at the country × subject_primary × year level, adding `subject_primary` fixed effects (or `subject_primary × year` FE) to control for disciplinary norms that strongly correlate with team size. This is the critical robustness check: if the result disappears after absorbing field composition, it is likely driven by disciplinary mix rather than self-censorship. |
| RC2: Alternative regime measure | Replace `v2x_libdem` with `lied_binary` as the main independent variable. |
| R1: Alternative IV | Replace `v2x_libdem` with `lied_binary`; same model structure |
| R2: Log outcome | Replace `mean_n_authors` with `log(mean_n_authors + 1)` to reduce skew |
| R3: Control for international co-authorship rate | Add share of articles with authors from more than one country as a control; isolates team-size effect from international-network effect |
| R4: Restrict to post-1990 | Drop observations before 1990 to address sparse coverage |
| R5: Raise minimum article threshold | Increase country-year floor from 10 to 25 articles |

---

## Expected output files

All outputs saved to `teams/team_17/analysis/`:

| File | Description |
|---|---|
| `analysis/analysis.R` | Main analysis script (tidyverse + fixest) |
| `analysis/figures/fig1_regime_authors_scatter.pdf` | Binned scatter: v2x_libdem vs. mean_n_authors, residualized on FEs |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: M1 and M2 point estimates with 95% CIs |
| `analysis/figures/fig3_trends_by_regime.pdf` | Time trend of mean_n_authors by regime tercile (low/medium/high libdem) |
| `analysis/tables/table1_main_results.tex` | Main regression table (M1, M2, R1, R2) via modelsummary |
| `analysis/primary_results.json` | Machine-readable primary result: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |

---

## Notes for analyst

- Check `n_authors` column existence before aggregation; `names(corpus)` output should clarify whether it is pre-computed or must be derived.
- If the corpus has multiple rows per article x country (one row per author x country), deduplicate to article level before computing `n_authors` to avoid double-counting.
- Do not use `n_articles_country_year` as the denominator for `mean_n_authors`; it is the article count, not author count.
- Flag in `analysis.R` comments whether `n_authors` was pre-existing or derived, and which author-identifier column was used.
