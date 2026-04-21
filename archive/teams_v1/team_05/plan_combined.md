---
title: "Team 05 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-18"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---

# Team 05 — Research Question

---

## Research question

Does the level of democracy in a country predict the number of distinct
co-author countries on social science and humanities articles affiliated with
that country?

## Rationale

International research collaboration is a key driver of knowledge diffusion and
scientific progress. Autocratic regimes may constrain cross-border collaboration
through restrictions on academic travel, foreign funding, and international
partnerships — or indirectly through the chilling effects of surveillance and
political control over universities. If autocracy limits the internationalization
of research, we should observe that articles affiliated with less democratic
countries involve fewer distinct co-author countries.

## Theoretical mechanism

Autocratic regimes reduce international co-authorship through three reinforcing
channels. First, **mobility restrictions**: visa regulations, travel bans, and
foreign-exchange controls raise the cost of establishing and maintaining
international research networks. Second, **institutional isolation**: state
control over universities and funding bodies limits participation in
international consortia, joint grants, and researcher exchange programs,
particularly with Western democracies. Third, **trust and self-censorship**:
researchers in autocracies face surveillance risks when collaborating with
foreign scholars, especially on politically sensitive topics, which deters the
formation of cross-border partnerships. The expected direction is negative:
lower levels of liberal democracy lead to fewer co-author countries per article.

## Theory family

`international-isolation`

## Estimand

The within-country, over-time effect of a one-unit increase in the liberal
democracy index (`v2x_libdem`, 0--1) on the number of distinct co-author
countries per article, holding constant time-invariant country characteristics,
common year shocks, and field composition.

## Unit of analysis

Article-country (one row per article × author-affiliation country, as structured
in the corpus). The outcome — number of distinct co-author countries — is an
article-level property that is constant across rows of the same article. Standard
errors are clustered at the country level to account for this.

## Outcome variable

`n_co_countries` — the number of distinct values of `country` per `ut` (article
identifier). Computed during analysis and merged back onto each article-country
row.

**Descriptive baseline (from data inspection):**

| Regime type | Mean n_co_countries |
|---|---|
| Autocracy (`regime_binary == 1`) | 1.17 |
| Democracy (`regime_binary == 0`) | 1.25 |
| Overall | 1.17 |

About 14% of articles involve authors from more than one country.

## Key independent variable

`v2x_libdem` — V-Dem liberal democracy index (continuous, 0--1).

---

# Team 05 — Analysis Plan

---

## Method

Two-way FE OLS via `fixest::feols()`. The outcome is the number of distinct
co-author countries per article — a count variable concentrated at low integers
(mean ~1.17, most values 1--3). OLS on the raw count is the primary
specification. A Poisson model is reported as a robustness check.

No external API calls or text analysis required. The outcome is constructed
directly from the article × country structure of the corpus.

---

## Step 1 — Construct the outcome variable

Done at article level before regression.

### 1a. Count distinct co-author countries per article

```r
n_countries <- d |>
  group_by(ut) |>
  summarise(n_co_countries = n_distinct(country), .groups = "drop")

d <- d |> left_join(n_countries, by = "ut")
```

### 1b. Sample restrictions

- Years: 1990--2019 (pre-1990 data unreliable per brief; post-2019 may have
  COVID artifacts)
- Country-years with at least 20 SSH articles (avoids noise from tiny research
  systems)

---

## Model specification

**Model 1 (main):**

```
n_co_countries ~ v2x_libdem + n_authors + log(n_articles_country_year)
                 | country + year + subject_primary
```

**Model 2 (robustness — binary regime measure):**

```
n_co_countries ~ regime_binary + n_authors + log(n_articles_country_year)
                 | country + year + subject_primary
```

**Model 3 (robustness — 4-category regime):**

```
n_co_countries ~ i(v2x_regime) + n_authors + log(n_articles_country_year)
                 | country + year + subject_primary
```

**Model 4 (robustness — Poisson):**

```
fepois(n_co_countries ~ v2x_libdem + n_authors + log(n_articles_country_year)
                        | country + year + subject_primary)
```

**Model 5 (robustness — restricted to >= 50 articles per country-year):**

Same as Model 1, on the restricted sample.

- SE clustered at country level throughout
- All models: `cluster = ~country` via `feols()` / `fepois()`

---

## Causal identification strategy

**Variation exploited:** Within-country over-time changes in `v2x_libdem`,
1990--2019. Country fixed effects absorb all stable country characteristics.
Identification comes from countries that experience meaningful changes in their
democracy level — democratic transitions, backsliding episodes — and asks
whether those changes predict shifts in the internationalization of their
research output.

**Confounders controlled:**

- Country FE: language, geography, colonial history, research system size and
  maturity, cultural attitudes toward collaboration
- Year FE: global trends in internationalization, growth of digital
  communication, expansion of international funding programs
- Field FE (`subject_primary`): discipline-specific collaboration norms (e.g.,
  economics vs. history)
- `n_authors`: mechanical relationship between team size and country count
- `n_articles_country_year`: scale of national research output

**Threats:**

1. *Economic development:* GDP growth may drive both democratization and
   internationalization of research independently. A robustness check adding GDP
   per capita (if available in V-DEM) or using within-country variation that nets
   out smooth trends would help.
2. *Reverse causality:* International collaboration could promote
   democratization rather than the other way around. The large volume of articles
   and slow-moving nature of regime change makes this less concerning at the
   article level, but it cannot be fully ruled out.
3. *Sanctions and geopolitical isolation:* Some autocracies face international
   sanctions that restrict collaboration independently of the domestic democracy
   level. This is a genuine confounder for specific countries (Iran, North Korea,
   Cuba).
4. *WOS selection bias:* WOS indexes a non-random subset of journals. If
   internationally co-authored papers from autocracies are more likely to appear
   in WOS-indexed journals, the effect could be attenuated. Country FE partially
   address this.

---

## Expected output files

All saved to `teams/team_05/analysis/figures/`:

| File | Description |
|---|---|
| `fig1_descriptive_trends.png` | Line plot: mean n_co_countries over time by regime type (autocracy vs. democracy) |
| `fig2_coefficient_plot.png` | Coefficient plot from the primary regression and key robustness checks |
| `fig3_robustness_regime_binary.png` | Coefficient plot using `regime_binary` and `v2x_regime` as alternative IVs |
| `tab1_regression_table.tex` | Models 1--5 via `modelsummary` |
