---
title: "Team 01 — Research Design"
subtitle: "AutoKnow Agent Orchestra | Pilot Team"
date: "2026-03-06"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---
# Team 01 — Research Question

*Revised 2026-03-20. Main IV switched to `v2x_libdem`; hypothesis added;
corpus updated to Phase 0 output (2,709,224 articles, 3,189,557 rows).*

---

## Research question

Does political suppression of academic freedom shift the substantive content
of SSH research away from politically engaged topics — as measured by the
political content of article abstracts — toward more politically neutral
subject matter?

## Rationale

Authoritarian regimes incentivize scholars to avoid politically sensitive
research. If this chilling effect operates, articles produced under lower
academic freedom should have systematically lower political content in their
abstracts: fewer references to governance, power, civil society, elections,
and political processes. Prior work has measured this effect through field-level
counts; the availability of full abstracts allows a more direct and continuous
measure of political content at the article level, and aggregated to
country-year panels, allows a cleaner test of within-country shifts over time.

## Theoretical mechanism

Autocratic regimes restrict academic freedom through a combination of direct
censorship, institutional control over hiring and funding, and informal
coercion that raises the personal cost of working on politically sensitive
topics. Scholars respond by self-censoring: they shift their research agenda
toward disciplines and topics with lower political risk (psychology, education,
applied economics) and away from research that directly engages questions of
political power, legitimacy, or civil rights. The key actors are the state
(controlling access and resources) and individual researchers (making topic
choices under these constraints). The expected direction is negative: higher
academic freedom → higher political content in national SSH output, a
compositional prediction distinct from a pure volume effect.

## Theory family

`self-censorship`

## Main hypothesis

Countries with higher liberal democracy scores produce SSH research with
systematically higher political content: the coefficient on `v2x_libdem` in
the main two-way FE specification is positive and statistically distinguishable
from zero. The effect is expected to be substantively meaningful — not merely
a statistical artefact of corpus size — and to hold net of country-level
development (GDP per capita) and population size.

## Estimand

The within-country, over-time effect of a one-unit increase in liberal
democracy (`v2x_libdem`) on the mean political content score of a country-year's
SSH article output. This is a partial identification estimate: country and year
fixed effects remove stable country-level specialization and global trends, but
cannot rule out all time-varying confounders.

## Unit of analysis

Country-year (primary); article-level as supplementary specification.

## Outcome variable

`mean_pci_cy`: the mean Political Content Index across all articles from a
given country-year, where PCI is computed at article level from abstract text.

**PCI construction (article level):**
PCI = (count of political dictionary terms in abstract) / (abstract word count)

Political dictionary: a pre-specified list of ~40–60 terms covering governance,
political institutions, civil society, and political conflict (e.g., *government,
state, party, election, democracy, regime, parliament, civil rights, protest,
authoritarian, political, policy, constitution, sovereignty, ministry*).
Dictionary specified and frozen before any analysis.

**Fallback for missing abstracts:** articles without abstracts are excluded
from the PCI-based outcome. The field-label-based `share_sensitive` (share of
articles in Political Science, Law, Sociology, History, Anthropology,
International Relations) is retained as a parallel, non-text outcome, enabling
comparison of the two measurement approaches and coverage of earlier years
where abstracts are sparse.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1). Captures the
full regime quality spectrum; standard in the comparative politics literature
for cross-country regression work.

`v2clacfree` (academic freedom) used in robustness checks as the more proximate
institutional mechanism.


---

# Team 01 — Analysis Plan

*Revised 2026-03-20. Main IV switched to `v2x_libdem`; `e_gdppc` and
`e_wb_pop` added as controls; `primary_results.json` output added; corpus
figures updated to Phase 0 output (2,709,224 articles, 3,189,557 rows,
1970s–2010s).*

---

## Pre-analysis data note

The analysis requires a refreshed `agent_corpus.rds` built from
`wos_ssh_articles.rds` (the new 2.7M-article corpus). Phase 0 must be re-run
before analysis begins. Key differences from the old corpus:

Phase 0 has been re-run (2026-03-17). Updated corpus stats:

| | Old corpus | New corpus |
|---|---|---|
| Articles (distinct) | 202,246 | 2,709,224 |
| Article-country rows | 207,287 | 3,189,557 |
| Abstracts | 0 | Present (coverage varies by era) |
| Keywords | ~0 | Present (sparse pre-1980s) |
| Years covered | 1970–1983 | 1970s–2010s |
| Autocracy rows (regime 0–1) | 8,508 | 284,574 |

Additional controls now available: `e_gdppc` (GDP per capita, log-transform)
and `e_wb_pop` (population, log-transform).

Year must be derived from the `date` column in all scripts.

---

## Method

Two-way FE OLS via `fixest::feols()`. Abstract text is used to construct the
primary outcome variable (PCI); the regression itself is OLS on the country-year
panel. A parallel specification using the field-label outcome (`share_sensitive`)
serves as a robustness check and covers country-years with no non-missing abstracts.

No external API calls are required. All text scoring uses a pre-specified
dictionary applied in base R or `stringr`.

---

## Step 1 — Construct the Political Content Index (PCI)

Done at article level before any aggregation.

### 1a. Political dictionary

Specify and freeze a list of ~50 political/governance terms before any analysis.
Proposed list (to be finalized before running):

```
Core governance: government, state, policy, ministry, parliament, legislation,
  constitution, sovereignty, regime, administration, bureaucracy
Political competition: election, party, vote, campaign, candidate, coalition,
  democracy, democratic, authoritarian, autocracy
Civil society & rights: civil rights, civil society, protest, dissent, freedom,
  censorship, repression, opposition, human rights, collective action
International/geopolitical: foreign policy, diplomacy, sanctions, alliance,
  ideology, communism, capitalism, cold war, colonialism
```

Pattern: case-insensitive, whole-word matching in abstract text.

### 1b. PCI formula (article level)

```r
# after loading corpus with abstracts:
d <- d |>
  mutate(
    abstract_words = str_count(abstract, "\\S+"),
    pci_raw = str_count(
      tolower(abstract),
      paste0("\\b(", paste(dict_terms, collapse="|"), ")\\b")
    ),
    pci = if_else(abstract_words > 0, pci_raw / abstract_words, NA_real_)
  )
```

### 1c. Country-year aggregation

```r
cy <- d |>
  filter(!is.na(pci), !is.na(v2x_libdem)) |>
  group_by(country, year) |>
  summarise(
    mean_pci        = mean(pci, na.rm = TRUE),
    share_sensitive = mean(is_sensitive, na.rm = TRUE),
    n_articles      = n(),
    v2x_libdem      = first(v2x_libdem),
    v2clacfree      = first(v2clacfree),
    regime_binary   = first(regime_binary),
    log_gdppc       = first(log(e_gdppc)),
    log_pop         = first(log(e_wb_pop)),
    .groups = "drop"
  ) |>
  filter(n_articles >= 5)
```

---

## Sensitive field classification (parallel outcome)

For articles without abstracts and as a robustness outcome:

```r
sensitive_fields <- c(
  "Political Science", "Law", "Sociology", "History",
  "Anthropology", "International Relations", "Area Studies",
  "Government & Law"
)
d <- d |> mutate(is_sensitive = subject_primary %in% sensitive_fields)
```

---

## Model specification

**Model 1 (main):**

```
mean_pci_cy ~ v2x_libdem | country + year
```

**Model 2 (add economic controls):**

```
mean_pci_cy ~ v2x_libdem + log_gdppc + log_pop | country + year
```

**Model 3 (robustness — academic freedom measure):**

```
mean_pci_cy ~ v2clacfree | country + year
```

**Model 4 (field-label outcome — coverage incl. no-abstract years):**

```
share_sensitive_cy ~ v2x_libdem | country + year
```

**Model 5 (exclude USA — robustness for corpus dominance):**

```
mean_pci_cy ~ v2x_libdem | country + year,  subset = (country != "USA")
```

**Model 6 (article-level, supplementary):**

```
pci ~ v2x_libdem | country + year + subject_primary
```

- SE clustered at country level throughout: `cluster = ~country` via `feols()`
- Model 2 is the preferred specification for the main table; Model 1 is the
  stripped baseline.

---

## Causal identification strategy

**Variation exploited:** Within-country over-time changes in liberal democracy,
1970s–2010s. The expanded corpus (284,574 autocratic article-country rows vs.
8,508 previously) greatly improves coverage of non-democratic country-years,
including Cold War Eastern Europe, Latin America in the 1970s, post-Soviet
states in the 1990s, and contemporary autocracies in the 2000s–2010s.

**Confounders controlled:**
- Country FE: stable country specialization, language/cultural factors, research infrastructure
- Year FE: global trends in SSH topic coverage and abstract availability
- `log_gdppc`, `log_pop`: time-varying economic and size controls (Model 2)
- In Model 6: field FE for baseline political content by discipline

**Threats:**
1. *Reverse causality*: politically active research → regime represses academic
   freedom. Biases toward zero; our estimate is a lower bound on the chilling
   effect.
2. *Abstract availability bias*: abstracts are less common for early years and
   poorer countries. If abstract coverage correlates with regime type, PCI
   estimates could be noisy; the field-label outcome in Model 3 provides a
   check not dependent on abstract availability.
3. *Dictionary validity*: PCI depends on dictionary coverage and word choice.
   Test sensitivity with an expanded and a restricted dictionary.
4. *Corpus composition*: with 2.7M articles, ~92% still come from democracies
   (V-DEM join rates TBC after Phase 0 re-run). Country FE addresses this
   structurally.

---

## Expected output files

Figures and tables saved to `teams/team_01/analysis/figures/`.
Machine-readable result saved to `teams/team_01/analysis/`.

| File | Description |
|---|---|
| `fig1_pci_vs_libdem.pdf` | Scatter: country-year mean PCI vs. v2x_libdem; colour by regime category; regression line |
| `fig2_pci_trend_by_regime.pdf` | Time series: mean PCI by v2x_regime category, 1970s–2010s |
| `fig3_event_study.pdf` | Event-study: PCI around major democratic transitions and coups; ±5 years |
| `fig4_abstract_coverage.pdf` | Diagnostic: abstract coverage (% non-NA) by year and regime type |
| `tab1_descriptives.tex` | Country-year descriptives by regime category |
| `tab2_main_regressions.tex` | Models 1–6 via modelsummary |
| `tab3_dict_robustness.tex` | Models 1 & 2 repeated with expanded/restricted dictionary |
| `primary_results.json` | Primary hypothesis test: `{ "coef": ..., "se": ..., "pval": ..., "n": ..., "theory_family": "self-censorship" }` — from Model 2 |

