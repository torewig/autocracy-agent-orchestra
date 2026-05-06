# Pre-registration: team_03

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 03 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish a lower share of their SSH output in politically sensitive disciplines (political science, international relations, law, sociology, social issues, ethnic studies, and women's studies)?

## Rationale

Self-censorship does not operate only within disciplines — it also operates across them. A researcher aware that political science or law carries regime risk may shift their career into a less exposed field (economics, psychology, linguistics) where sensitive topics are peripheral. If this mechanism operates at scale, autocracies should exhibit a structurally different disciplinary profile of SSH output — one systematically tilted away from fields in which engagement with power, rights, and governance is constitutive. This outcome is observable in WOS subject category data without any text analysis, making it a direct, low-noise test of disciplinary-level self-censorship.

## Theoretical mechanism

Autocratic regimes constrain academic freedom through formal mechanisms (restricted research agendas, surveillance of university departments, politically appointed deans) and informal ones (career penalties for scholars whose work embarrasses the regime). Researchers and graduate students respond by self-selecting into disciplines where politically sensitive inquiry is marginal — economics, psychology, linguistics, or the arts — rather than fields where engagement with state power, rights, or governance is disciplinary core. At the country-year level, this produces a lower share of SSH output in politically sensitive disciplines in more autocratic settings. The expected direction of the main coefficient is negative: higher liberal democracy scores predict a higher share of output in sensitive fields, because democratic environments permit and even reward scholarship that scrutinizes power.

## Theory family

topic-avoidance

## Hypothesis

H1: Countries with lower Liberal democracy levels will produce a lower share of SSH output in politically sensitive disciplines, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in v2x_libdem on the share of country-year SSH output assigned to politically sensitive WOS subject categories.

## Unit of analysis

Country-year

## Outcome variable

**Construction:** For each article-country-year row, classify `subject_primary` as sensitive (1) or neutral (0) using the list below. Aggregate to country-year: `share_sensitive = n_sensitive_articles / n_total_articles` (where n_total = `n_articles_country_year`). The outcome is a proportion bounded in [0, 1].

**Politically sensitive WOS subject categories (classified as 1) — primary specification (7 fields):**

| Category | Justification |
|---|---|
| Political Science | Core discipline of state, power, governance |
| International Relations | Power, conflict, foreign policy — direct political content |
| Law | Legal rights, state authority, constitutional order |
| Sociology | Social inequality, social movements, institutions |
| Social Issues | Social problems, inequality, marginalization — politically charged |
| Ethnic Studies | Minority rights, ethnic conflict, identity politics |
| Women's Studies | Gender rights, feminist critique of power |

**Note on excluded borderline fields:** Public Administration, Area Studies, and Criminology & Penology are excluded from the primary classification as conceptually borderline. They are included in the RC1 robustness check (expanded field list).

All other SSH fields (`Economics`, `Psychology` variants, `Education` variants, `Geography`, `History`, `Communication`, `Demography`, `Linguistics`, `Language & Linguistics`, `Management`, `Information Science & Library Science`, `Planning & Development`, `Anthropology`, `Ergonomics`, `Family Studies`, `Health Policy & Services`, `History & Philosophy of Science`, `Industrial Relations & Labor`, `Regional & Urban Planning`, `Social Sciences, Biomedical`, `Social Sciences, Interdisciplinary`, `Social Sciences, Mathematical Methods`, `Social Work`, `Urban Studies`, all Arts & Humanities categories) are classified as neutral (0).

**Note on borderline cases:** `History` is classified as neutral in the primary specification because its sensitivity depends on political context in ways that are not consistent across countries; sensitivity robustness check uses a "History-included" classification.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Most similar existing teams: 01 (keyword-based PCI score), 04 (regime-sensitive keyword prevalence in titles/keywords).

Distinction: Team 03 uses WOS journal-assigned subject categories — a structural, metadata-level indicator of disciplinary composition — rather than any text content of titles, abstracts, or keywords. The outcome reflects field choice, not word choice.


---

## Analysis Plan

# Team 03 — Analysis Plan

## Method

### Step 1: Classify subject_primary into sensitive vs. neutral

Assign a binary indicator `is_sensitive` to each row using `subject_primary`. Matching is exact (string equality). The 7 sensitive categories in the primary specification are listed below. All other SSH categories receive 0. Articles where `subject_primary` is missing are dropped from the outcome construction (note to analyst: inspect missingness rate before dropping).

### Step 2: Aggregate to country-year

Collapse the article-level data to country-year:

```r
country_year <- corpus |>
  filter(!is.na(subject_primary), !is.na(v2x_libdem)) |>
  mutate(is_sensitive = subject_primary %in% sensitive_fields) |>
  group_by(iso3, year) |>
  summarise(
    share_sensitive = mean(is_sensitive),
    n_articles      = n_articles_country_year[1],
    v2x_libdem      = v2x_libdem[1],
    lied_binary     = lied_binary[1],
    v2x_regime      = v2x_regime[1],
    log_gdppc       = log(e_gdppc[1]),
    log_pop         = log(e_wb_pop[1]),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10)
```

The denominator is the number of articles in the country-year. Verify that this matches `n_articles_country_year` with an assertion.

### Step 3: Regression

Two-way fixed effects model with country and year FE, standard errors clustered by country.

---

## Sensitive field classification

**Classified as politically sensitive (is_sensitive = 1) — primary specification (7 fields):**

| WOS subject category | Justification |
|---|---|
| Political Science | Core discipline of power, state, and governance |
| International Relations | Foreign policy, conflict, international order |
| Law | Legal rights, constitutionalism, state authority |
| Sociology | Social structure, inequality, institutions, movements |
| Social Issues | Social problems, poverty, inequality, marginalization |
| Ethnic Studies | Minority rights, ethnic politics, identity |
| Women's Studies | Gender rights, feminist critique of power structures |

**Classified as neutral (is_sensitive = 0):** All remaining SSH categories from `ssh_fields.txt`, including all Psychology variants, Education variants, Economics, Geography, History, Demography, Communication, Linguistics, Language & Linguistics, Management, Anthropology, Public Administration, Area Studies, Criminology & Penology, and all Arts & Humanities categories.

**Note on borderline fields:** Public Administration, Area Studies, and Criminology & Penology are classified as neutral in the primary specification. They are included in the expanded field list used in RC1.

**Borderline classification note:** `History` is classified neutral in the primary specification. The politically sensitive character of History varies greatly by country and period; including it would introduce systematic measurement error correlated with the regime variable itself. A robustness check includes History in the sensitive set.

---

## Model specification

Two specifications are estimated and reported in the same regression table.

### Primary specification (pre-registered)

Two-way fixed effects: country FE + year FE, SE clustered by `iso3`.

- **Outcome:** `share_sensitive` (proportion, bounded in [0, 1])
- **Predictors:** `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- **Fixed effects:** country FE + year FE (two-way FE using `fixest::feols`)
- **SE clustering:** by country (`cluster = ~iso3`)
- **Estimator:** OLS with two-way FE (linear probability model on proportion outcome); a fractional logit robustness check is also run

```r
feols(share_sensitive ~ v2x_libdem + log_gdppc + log_pop |
        iso3 + year,
      data = country_year,
      cluster = ~iso3)
```

### Secondary specification (descriptive)

Pooled OLS: year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate.

- **Outcome:** `share_sensitive`
- **Predictors:** `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- **Fixed effects:** year FE only (no country FE)
- **SE clustering:** by country (`cluster = ~iso3`)

```r
feols(share_sensitive ~ v2x_libdem + log_gdppc + log_pop |
        year,
      data = country_year,
      cluster = ~iso3)
```

Both specifications are reported side by side in `tables/tab1_main_regression.tex`.

---

## Causal identification strategy

**Variation exploited:** Within-country over-time variation in v2x_libdem. Country FE absorbs all time-invariant country-level confounders (colonial history, legal tradition, language, cultural norms about discipline choice). Year FE absorbs global secular trends in disciplinary composition (e.g., expansion of political science internationally, growth of area studies post-Cold War).

**Confounders controlled:** GDP per capita (captures modernization, resources for social science infrastructure) and population (captures absolute research capacity).

**Identification threats:**

1. *WOS coverage bias:* Changes in WOS indexing of journals from specific countries may differentially affect which disciplines are represented. If sensitive-discipline journals from autocracies are systematically under-indexed in WOS, this would attenuate the estimated effect. The direction of this bias works against finding the expected result, so the estimate is conservative.

2. *Reverse causality:* High-quality social science in sensitive fields could itself contribute to democratization. Country and year FE partially address this. A robustness check uses a one-year lag of `v2x_libdem`.

3. *Economic development:* Richer countries may have more specialized universities independently of regime type. Log GDP per capita is included as a control; the correlation between v2x_libdem and log GDP per capita should be reported.

4. *Anticipation effects:* Researchers may adjust disciplinary choices in anticipation of regime change. This is a minor concern at the annual level given the gradual nature of most regime shifts.

---

## Robustness checks

**RC1 — Expanded field list:** Re-estimate the primary model adding back the three borderline fields (Public Administration, Area Studies, Criminology & Penology) to the sensitive category, for a total of 10 sensitive fields. Tests whether narrowing to the 7-field primary list drives the result.

**RC2 — History-included:** Re-estimate adding `History` to the sensitive category list (in addition to the 7 primary fields). History is classified as neutral in the primary specification because its political sensitivity varies by country and period; this check tests the robustness of that classification boundary.

3. **Alternative regime measure:** Replicate the primary model substituting `lied_binary` for `v2x_libdem`. Binary coding tests whether the effect is concentrated at the democracy/autocracy threshold rather than operating continuously.

4. **Fractional logit:** Re-estimate using `glm(..., family = quasibinomial(link = "logit"))` with country and year dummies, compare marginal effects to OLS coefficients.

5. **Lagged IV:** Substitute `lag(v2x_libdem, 1)` as the main predictor to partially address reverse causality.

6. **Restricted time window:** Re-estimate on 1990–2023 only, given sparse pre-1990 WOS coverage.

---

## Expected output files

All files saved to `teams/team_03/analysis/figures/` and `teams/team_03/analysis/`:

| File | Description |
|---|---|
| `figures/fig1_share_by_regime.png` | Scatter: mean share_sensitive by country-year, coloured by v2x_regime category; with smoothed trend lines |
| `figures/fig2_coef_main.png` | Coefficient plot for primary model: v2x_libdem estimate with 95% CI |
| `figures/fig3_trend_over_time.png` | Time-series of mean share_sensitive by democracy/autocracy group (lied_binary), 1970–2023 |
| `tables/tab1_main_regression.tex` | Main regression table (primary model + robustness checks 1–4), modelsummary output |
| `primary_results.json` | Standard JSON: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
