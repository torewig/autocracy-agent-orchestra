---
title: "Team 04 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-18"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---
# Team 04 — Research Question

---

## Research question

Does autocracy reduce the prevalence of regime-sensitive research topics in a
country's social science and humanities output?

## Rationale

Autocratic constraints on academic freedom need not operate only at the level
of entire disciplines. Even where politically relevant fields like political
science and sociology exist, scholars may strategically avoid topics that could
attract state scrutiny — studying public administration rather than
democratization, urbanization rather than protest movements. If self-censorship
is a primary mechanism through which autocracy shapes SSH knowledge, it should
be detectable as a systematic reduction in the share of articles engaging with
regime-sensitive topics such as democracy, human rights, corruption, and
political contention.

## Theoretical mechanism

Scholars in autocracies face career risks — denied funding, blocked
publication, surveillance, job loss — for producing research that challenges
state narratives or exposes governance failures. These risks are imposed by
political appointees in university leadership, state-controlled funding bodies,
and censorship of domestic outlets. Scholars respond by strategically selecting
"safe" research topics, a process of anticipatory self-censorship. This is
reinforced by editorial gatekeeping at domestic journals and by international
co-authors who may steer collaborations toward less politically fraught topics.
The expected direction is that lower levels of liberal democracy are associated
with a lower share of SSH articles containing regime-sensitive keywords
(democracy, human rights, corruption, protest, etc.), even after conditioning
on the discipline in which the article is published.

## Theory family

`topical-self-censorship`

## Estimand

The within-country, over-time effect of a one-unit increase in liberal
democracy (`v2x_libdem`) on the share of a country-year's SSH articles that
contain at least one regime-sensitive keyword. This is a partial identification
estimate: country and year fixed effects remove stable country-level
specialization and global trends, but cannot rule out all time-varying
confounders.

## Unit of analysis

Country-year (primary); article-level as supplementary specification.

## Outcome variable

`share_sensitive_topic`: the share of articles per country-year in which
`keywords` or `keywords_plus` contains at least one term from a predefined
regime-sensitive dictionary.

**Dictionary construction:**

A pre-specified list of regime-sensitive terms covering four domains:

- **Political accountability:** democracy, democratization, democratic
  transition, election fraud, electoral integrity, political opposition,
  dissent, authoritarian, autocracy
- **Rights and freedoms:** human rights, civil liberties, press freedom,
  freedom of expression, censorship, civil society
- **State critique:** corruption, governance failure, repression, political
  violence, state violence, police brutality
- **Contention:** protest, social movement, revolution, uprising, regime
  change, political mobilization

Pattern: case-insensitive, whole-word matching in `keywords` and
`keywords_plus` fields. Dictionary specified and frozen before any analysis.

## Key independent variable

`v2x_libdem` — V-Dem liberal democracy index (continuous, 0–1).

`regime_binary` and `v2x_regime` used in robustness checks.

---

# Team 04 — Analysis Plan

---

## Method

Two-way FE OLS via `fixest::feols()`. The outcome is a country-year-level
measure of regime-sensitive topic prevalence constructed from keyword matching
against a predefined dictionary. No external API calls are required. All text
scoring uses a pre-specified dictionary applied in base R or `stringr`.

---

## Step 1 — Construct the regime-sensitive topic indicator

Done at article-country level before any aggregation.

### 1a. Keyword dictionary

Specify and freeze the dictionary before any analysis. Proposed list:

```
Political accountability: democracy, democratization, democratic transition,
  election fraud, electoral integrity, political opposition, dissent,
  authoritarian, autocracy, dictatorship
Rights and freedoms: human rights, civil liberties, press freedom,
  freedom of expression, censorship, civil society, political rights,
  freedom of speech
State critique: corruption, governance failure, repression, political violence,
  state violence, police brutality, rule of law, judicial independence
Contention: protest, social movement, revolution, uprising, regime change,
  political mobilization, collective action, resistance
```

Pattern: case-insensitive, whole-word matching in keyword fields.

### 1b. Article-level coding

```r
d <- d |>
  mutate(
    kw_combined = paste(
      coalesce(tolower(keywords), ""),
      coalesce(tolower(keywords_plus), "")
    ),
    sensitive_topic = str_detect(
      kw_combined,
      paste0("\\b(", paste(dict_terms, collapse = "|"), ")\\b")
    ) |> as.integer(),
    sensitive_topic = if_else(
      is.na(keywords) & is.na(keywords_plus),
      NA_integer_,
      sensitive_topic
    )
  )
```

### 1c. Country-year aggregation

```r
cy <- d |>
  filter(!is.na(sensitive_topic), !is.na(v2x_libdem)) |>
  group_by(country, iso3, year) |>
  summarise(
    share_sensitive_topic = mean(sensitive_topic, na.rm = TRUE),
    n_articles            = n(),
    v2x_libdem            = first(v2x_libdem),
    v2x_regime            = first(v2x_regime),
    regime_binary         = first(regime_binary),
    .groups = "drop"
  ) |>
  filter(n_articles >= 20, year >= 1990)
```

---

## Model specification

**Model 1 (main):**

```
share_sensitive_topic ~ v2x_libdem + log(n_articles) | country + year
```

- SE clustered at country level via `feols()`

**Model 2 (robustness — binary regime measure):**

```
share_sensitive_topic ~ regime_binary + log(n_articles) | country + year
```

**Model 3 (robustness — 4-category regime type):**

```
share_sensitive_topic ~ i(v2x_regime) + log(n_articles) | country + year
```

**Model 4 (within-field — article level, linear probability model):**

```
sensitive_topic ~ v2x_libdem + log(n_articles_country_year) |
  country + year + subject_primary
```

- Tests whether the effect holds within disciplines, not just across them

**Model 5 (transitioner sample):**

```
share_sensitive_topic ~ v2x_libdem + log(n_articles) | country + year
```

- Restricted to countries that experienced a change in `v2x_regime` category
  during 1990–2019

All models: `cluster = ~country` via `feols()`

---

## Causal identification strategy

**Variation exploited:** Within-country over-time changes in liberal democracy,
1990–2019. Country fixed effects absorb all time-invariant country
characteristics (language, academic traditions, historical disciplinary
structure, WOS indexing patterns). Year fixed effects absorb global trends in
keyword usage (e.g., the post-2010 rise of "corruption" research worldwide).
The identifying variation comes from countries whose regime type changes —
democratization or autocratization episodes — and whether those political
changes coincide with shifts in the prevalence of regime-sensitive keywords.

**Confounders controlled:**

- Country FE: stable country specialization, language/cultural factors,
  research infrastructure, WOS coverage patterns
- Year FE: global trends in topic popularity, keyword norms, WOS expansion
- Log total articles: scale effects on keyword composition
- In Model 4: field FE for baseline topic prevalence by discipline

**Threats:**

1. *Keyword measurement error:* The dictionary is English-language and may miss
   regime-sensitive research published with non-English keywords. This would
   attenuate the estimated effect (bias toward zero). Acknowledged as a
   conservative bias.
2. *WOS selection bias:* WOS disproportionately indexes international,
   English-language journals. Regime-sensitive research in autocracies may
   appear in domestic outlets not indexed by WOS. This would inflate the
   estimated effect. Acknowledged as a key limitation.
3. *Reverse causality:* A thriving human rights research community could
   contribute to democratization, rather than democracy enabling such
   research. Partially addressed by checking results with lagged `v2x_libdem`
   (t-1, t-2).
4. *Omitted time-varying confounders:* Economic development,
   internationalization, and university expansion could jointly affect both
   democracy and topic selection. GDP is not available in the corpus;
   acknowledged as a limitation.
5. *Dictionary sensitivity:* Results could depend on the specific keywords
   chosen. Addressed by reporting results with (a) a narrower "core"
   dictionary (democracy, human rights, corruption, protest only) and (b) the
   full dictionary.

---

## Expected output files

All saved to `teams/team_04/analysis/figures/`:

| File | Description |
|---|---|
| `fig1_share_by_regime.png` | Bar chart: mean share of regime-sensitive topics by `v2x_regime` category with CIs |
| `fig2_timeseries.png` | Time series: mean `share_sensitive_topic` for autocracies vs. democracies, 1990–2019 |
| `tab1_main_results.png` | Regression table: Models 1–3 (main + binary + 4-category) via `modelsummary` |
| `tab2_robustness.png` | Regression table: Models 4–5 (within-field + transitioner sample) via `modelsummary` |
