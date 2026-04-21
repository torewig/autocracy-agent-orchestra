---
title: "Team 03 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-18"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---

# Team 03 — Research Question

---

## Research question

Does the level of liberal democracy in a country predict the share of its
social science and humanities output devoted to politically sensitive
disciplines (political science, sociology, law, international relations,
public administration)?

## Rationale

Autocratic regimes have strong incentives to suppress research that could
challenge regime legitimacy or inform political opposition. If these incentives
shape the composition of SSH knowledge production, we should observe systematic
differences in what fields are studied — not just how much is published. This
question directly addresses the "contents and direction" dimension of the
overarching research question by examining whether autocracy distorts the
disciplinary portfolio of SSH research toward politically safer fields.

## Theoretical mechanism

Autocratic rulers face a legitimacy dilemma: they benefit from a productive
higher-education sector (for economic development and international prestige),
but research in certain SSH disciplines — political science, sociology, law,
international relations — can produce findings that challenge regime narratives,
document repression, or provide intellectual resources for opposition movements.
Regimes manage this tension through multiple channels: direct censorship and
topic restrictions at universities, strategic allocation of research funding
toward "safe" fields (economics, business, psychology), and the cultivation of
self-censorship norms among researchers who anticipate career costs for working
on sensitive topics. The net effect is a compositional shift: autocracies
produce a lower share of their SSH output in politically sensitive fields and a
higher share in fields that are either politically neutral or regime-compatible.
The expected direction is positive — higher values of `v2x_libdem` (more
democratic) should predict a higher share of output in politically sensitive
disciplines.

## Theory family

`regime-field-distortion`

## Estimand

The within-country, over-time effect of a one-unit increase in liberal
democracy (`v2x_libdem`) on the share of a country-year's SSH articles
published in politically sensitive fields. This is a partial identification
estimate: country and year fixed effects remove stable country-level
specialization and global trends, but cannot rule out all time-varying
confounders.

## Unit of analysis

Country-year (aggregated from article-country rows).

## Outcome variable

`share_sensitive`: the proportion of a country-year's SSH articles whose
`subject_primary` falls in a predefined set of politically sensitive fields.

**Sensitive field classification:**

```
Political Science, International Relations, Sociology, Law,
Public Administration, Social Issues, Ethnic Studies, Women's Studies
```

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0-1). Captures
gradations in regime quality and avoids the arbitrariness of binary splits.

`regime_binary` and `v2x_regime` used in robustness checks.

---

# Team 03 — Analysis Plan

---

## Method

Two-way FE OLS via `fixest::feols()`. The outcome is a country-year-level
proportion constructed from the structured `subject_primary` variable — no
text analysis is required. The regression exploits within-country variation
in `v2x_libdem` over time.

---

## Step 1 — Construct the outcome variable

### 1a. Sensitive field classification (article level)

```r
sensitive_fields <- c(
  "Political Science", "International Relations", "Sociology",
  "Law", "Public Administration", "Social Issues",
  "Ethnic Studies", "Women's Studies"
)
d <- d |> mutate(sensitive = as.integer(subject_primary %in% sensitive_fields))
```

### 1b. Country-year aggregation

```r
cy <- d |>
  filter(!is.na(v2x_libdem)) |>
  group_by(country, iso3, year) |>
  summarise(
    share_sensitive          = mean(sensitive, na.rm = TRUE),
    n_articles               = n_distinct(ut),
    v2x_libdem               = first(v2x_libdem),
    v2x_regime               = first(v2x_regime),
    regime_binary             = first(regime_binary),
    .groups = "drop"
  ) |>
  filter(n_articles >= 20, year >= 1990)
```

Minimum 20 articles per country-year avoids noisy proportions. Restricted to
1990-2023 per PLAN.md guidance on pre-1990 WOS coverage.

---

## Model specification

**Model 1 (main):**

```
share_sensitive ~ v2x_libdem + log(n_articles) | country + year
```

**Model 2 (robustness — binary regime measure):**

```
share_sensitive ~ regime_binary + log(n_articles) | country + year
```

**Model 3 (robustness — ordinal regime categories):**

```
share_sensitive ~ i(v2x_regime) + log(n_articles) | country + year
```

**Model 4 (narrow sensitive fields — Political Science, Sociology, Law only):**

```
share_sensitive_narrow ~ v2x_libdem + log(n_articles) | country + year
```

**Model 5 (minimum 50 articles threshold):**

```
share_sensitive ~ v2x_libdem + log(n_articles) | country + year,
  subset = (n_articles >= 50)
```

- SE clustered at country level throughout: `cluster = ~country` via `feols()`

---

## Causal identification strategy

**Variation exploited:** Within-country over-time changes in `v2x_libdem`,
1990-2023. The identifying variation comes from countries that experience
democratization or autocratization episodes — regime transitions that shift
the liberal democracy score while country and year fixed effects hold stable
characteristics and global trends constant.

**Confounders controlled:**

- Country FE: stable country specialization, language/cultural factors,
  research infrastructure, colonial history, geographic factors
- Year FE: global trends in SSH field composition, WOS indexing expansion,
  worldwide growth of political science as a discipline
- `log(n_articles)`: controls for the possibility that countries with larger
  research systems mechanically have different field distributions

**Threats:**

1. *Time-varying economic development:* GDP growth may correlate with both
   democratization and expansion of specific SSH fields. Not directly
   controlled (GDP is not in the corpus), but country FE absorb baseline
   development and year FE absorb global growth trends.
2. *Internationalization of higher education:* Countries that democratize may
   simultaneously integrate into global academic networks, which could
   independently shift field composition toward Western-norm disciplines
   (where political science is prominent). This is a plausible confounder
   that cannot be fully separated from the regime effect.
3. *WOS indexing bias:* WOS may start indexing more journals from a country
   as it democratizes, and newly indexed journals may disproportionately
   cover political science or sociology. Controlling for total output volume
   partially addresses this, and restricting to post-1990 reduces the
   severity.
4. *Reverse causality:* A vibrant political science community could
   contribute to democratization. Unlikely to drive results at the
   country-year level given the slow-moving nature of both academic field
   composition and regime change, but cannot be ruled out.

---

## Expected output files

All saved to `teams/team_03/analysis/figures/`:

| File | Description |
|---|---|
| `fig1_shares_by_regime.png` | Bar chart: mean share of sensitive fields by `v2x_regime` category |
| `fig2_trend_by_regime.png` | Time series: share of sensitive fields over time, by regime type |
| `fig3_main_regressions.png` | Regression table: Models 1-5 via `modelsummary` |
| `fig4_coefplot_robustness.png` | Coefficient plot comparing estimates across specifications |
