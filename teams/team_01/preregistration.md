# Pre-registration: team_01

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 01 — Research Question

## Research question
Do SSH researchers in more autocratic countries produce abstracts with a lower share of political-content keywords — as measured by the Political-Content Index (PCI) score — than researchers in more democratic countries, after controlling for country, year, GDP per capita, and population?

## Rationale
Researchers working under autocratic rule face institutional incentives to avoid topics that may attract state scrutiny, including explicitly political subject matter. If self-censorship operates through topic avoidance, we should observe that the textual content of published abstracts from autocratic contexts is systematically depleted of political vocabulary. The abstract is the first and most visible signal of a paper's political content, making it a plausible site of strategic softening or omission.

## Theoretical mechanism
In autocracies, researchers anticipate that using political vocabulary in published work — terms such as "democracy," "repression," "protest," or "human rights" — increases the probability of institutional sanction, loss of funding, or career setback. Facing this risk, researchers either self-select out of politically sensitive topics or reframe their work to minimize explicitly political language at the stage of writing up and publishing. This behavioral response reduces the aggregate share of political-content keywords in abstracts from autocratic country-years. The expected direction is negative: higher `v2x_libdem` → higher PCI score (more political content), because greater political freedom removes the self-censorship incentive.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit lower mean PCI scores in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family
topic-avoidance

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean PCI score (share of abstract word tokens matching a political-content keyword dictionary), conditional on country and year fixed effects.

## Unit of analysis
Country-year

## Outcome variable
`pci_mean`: constructed by (1) tokenizing each article abstract, (2) computing the share of tokens matching a political-content keyword dictionary (PCI score per article), then (3) averaging PCI scores to the country-year level, weighted by article count. The PCI dictionary covers terms in the clusters: democracy/autocracy, repression/rights, governance/corruption, protest/conflict, elections/parties (approximately 80–120 stems; full list defined in analysis.R).

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no other team rq.md files exist yet for teams 02–06).
Distinction: Teams 02–04 are assigned to topical diversity, disciplinary composition, and a specific four-keyword set respectively; Team 01 is the only team using a broad multi-cluster PCI dictionary applied to raw abstract text aggregated to country-year mean share.


---

## Analysis Plan

# Team 01 — Analysis Plan

## Method

### Outcome construction (PCI score)
1. **Dictionary definition.** Define a political-content keyword (PCI) dictionary of approximately 80–120 word stems grouped into five thematic clusters: (a) democracy/autocracy (e.g., *democrat*, *autocrat*, *authoritar*, *regime*, *dictator*), (b) repression/rights (e.g., *repres*, *censor*, *human right*, *civil libert*, *freedom*), (c) governance/corruption (e.g., *corrupt*, *govern*, *bureaucra*, *institution*, *rule of law*), (d) protest/conflict (e.g., *protest*, *revolt*, *upris*, *dissent*, *civil war*), (e) elections/parties (e.g., *election*, *ballot*, *party*, *parliament*, *vote*). Stems are matched case-insensitively using `stringr::str_detect()` or a regex alternation pattern.
2. **Article-level PCI.** For each article with a non-missing abstract, tokenize by whitespace (removing punctuation), count the number of tokens matching any PCI stem, and divide by total token count. Result: `pci_article` in [0, 1] — the share of abstract text that is political content.
3. **Country-year aggregation.** Collapse to country-year by taking the mean of `pci_article` across all articles from that country-year (unweighted mean; sensitivity check with `n_articles_country_year`-weighted mean). Result: `pci_mean` — the country-year PCI score, which is the regression outcome.
4. **Sample restriction.** Restrict to 1990–2023 (sparse pre-1990 WOS coverage). Drop country-years with fewer than 5 articles (unstable mean). Drop rows where `v2x_libdem`, `e_gdppc`, or `e_wb_pop` are missing.

### Regression models

The main regression table includes two models estimated side by side. Both use `feols()` from the `fixest` package with SEs clustered by country (`iso3`).

**Model 1 — TWFE (primary):**
```
pci_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year
```
- **Fixed effects:** country (`iso3`) + year
- **Variation exploited:** within-country, over-time changes in `v2x_libdem` (after absorbing time-invariant country characteristics and global year trends)
- **Interpretation:** causal identification via within-country democratization/autocratization episodes

**Model 2 — Pooled OLS / cross-sectional (descriptive):**
```
pci_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year
```
- **Fixed effects:** year only (no country FE)
- **Variation exploited:** cross-sectional (between-country) level differences in regime type, net of common year trends
- **Interpretation:** descriptive/correlational; identifies whether more autocratic countries have systematically lower PCI on average

Both models appear in the main regression table with a table note specifying what identifying variation each exploits. The TWFE model is the primary causal estimate; the pooled OLS model is reported alongside it as a descriptive complement showing the cross-sectional pattern.

- **Outcome (both):** `pci_mean` (country-year mean PCI score)
- **Primary predictor (both):** `v2x_libdem`
- **Controls (both):** `log(e_gdppc)`, `log(e_wb_pop)`
- **SE clustering (both):** by country (`iso3`)
- **Package:** `fixest::feols()`

## Model specification

**Primary specification (pre-registered):** Two-way fixed effects — country FE (`iso3`) + year FE, SE clustered by `iso3`.

- **Outcome:** `pci_mean` (constructed as described above)
- **Predictors:** `v2x_libdem + log(e_gdppc) + log(e_wb_pop)`
- **Fixed effects:** country FE (`iso3`) + year FE
- **SE clustering:** by `iso3`
- **Package:** `fixest::feols()`

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate.

- **Outcome:** `pci_mean`
- **Predictors:** `v2x_libdem + log(e_gdppc) + log(e_wb_pop)`
- **Fixed effects:** year FE only (no country FE)
- **SE clustering:** by `iso3`
- **Package:** `fixest::feols()`

Both specifications are reported in the same regression table.

## Causal identification strategy

**Variation exploited.** The main identification comes from within-country, over-time variation in `v2x_libdem`: countries that democratize or autocratize across the 1990–2023 window generate the primary identifying variation after absorbing country and year fixed effects.

**Confounders controlled.** Country FE controls for all stable cross-national factors (language, geographic region, dominant research tradition, field composition). Year FE controls for global secular trends in the use of political vocabulary in published research. Log GDP per capita and log population control for development-level and size effects on research infrastructure and scope.

**Main threats to identification.**
1. *Reverse causality:* It is unlikely that country-level PCI drives regime type, but the design does not rule out that democratization simultaneously causes both more political publishing and more democracy (measurement-driven correlation). An event-study design (team 23/24) would sharpen this; the present design is descriptive within-country association.
2. *Compositional change:* The country-year composition of fields may shift with regime change (e.g., post-communist countries entering political science). The `subject_primary` distribution is not controlled in the main model; a robustness check stratified by field, or adding field x year FE, would address this.
3. *Selection into publishing:* The corpus captures only published articles; self-censorship may suppress submission entirely rather than only vocabulary. This would attenuate the estimated effect toward zero, so a significant negative effect provides a conservative lower bound on the true censorship effect.
4. *Dictionary validity:* The PCI dictionary is constructed by the analyst and is not externally validated. An additional robustness check using the narrower four-keyword set from team 04 (democracy, human rights, corruption, protest) will test sensitivity to dictionary scope.

## Robustness checks

1. **Alternative regime measure (binary):** Replicate the main model replacing `v2x_libdem` with `lied_binary`. Tests whether results hold under a discrete operationalization of regime type.
2. **Alternative regime measure (ordinal):** Replicate using `v2x_regime` (0–3 ordinal) as an ordered predictor to test for heterogeneity across regime subtypes.
3. **Weighted aggregation:** Re-run the country-year collapse using `n_articles_country_year`-weighted means and re-estimate the main model.
4. **Narrow dictionary:** Recompute PCI using only the four regime-sensitive keywords from team 04's domain (democracy, human rights, corruption, protest) to assess sensitivity to dictionary breadth.

## Expected output files

| File | Description |
|------|-------------|
| `figures/fig_main_coef.png` | Coefficient plot: `v2x_libdem` coefficient from main TWFE model with 95% CI |
| `figures/fig_trend.png` | Line plot of mean PCI score by regime quartile over time (1990–2023) |
| `figures/fig_scatter.png` | Scatter plot of country-year PCI mean against `v2x_libdem` (raw, labeled by country/region) |
| `figures/fig_robustness.png` | Coefficient plot comparing main model and robustness specifications (lied_binary, v2x_regime, weighted aggregation) |
| `primary_results.json` | Main model result: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
