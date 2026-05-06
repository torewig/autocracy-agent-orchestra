# Pre-registration: team_09

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 09 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use normative and prescriptive language — terms such as "rights," "justice," "freedom," and "accountability" — at a lower rate in their SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that scholars in autocracies strategically minimise language that could be read as a political or moral claim against the regime. Normative vocabulary — terms that assert what ought to be or that invoke universal values such as human rights, justice, and freedom — is especially exposed because it signals evaluative intent that autocratic authorities may interpret as implicit criticism. If this mechanism operates, we should observe that the density of normative terms per abstract word is systematically lower in more autocratic country-years, even after controlling for economic development, population, and stable country and year characteristics.

## Theoretical mechanism

Researchers operating under authoritarian rule face credible career risks — dismissal, loss of funding, publication bans, or in extreme cases legal consequences — if their work is perceived as making normative claims against the state. Normative vocabulary (words like "should," "ought," "rights," "justice," "freedom," "accountability," "dignity," "equality," "fairness," "liberty") is particularly hazardous because it frames social and political arrangements as unjust or illegitimate, even when embedded in otherwise descriptive academic prose. Anticipating this risk, rational authors self-censor by omitting or replacing normative terms with descriptive substitutes — writing, for example, "the state controls" rather than "the state should be accountable." This avoidance is distinct from epistemic hedging (avoidance of uncertainty language) and from topic avoidance (choosing not to study democracy or rights at all): an author may study political institutions in entirely empirical terms while systematically stripping normative framings. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher normative term rate per abstract word.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit lower mean normative language rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean normative term rate per abstract word, conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least one SSH article with a non-missing abstract).

## Outcome variable

`mean_norm_rate`: constructed as follows.

1. For each article with a non-missing abstract, compute:
   - `norm_count` = count of case-insensitive whole-word matches in the abstract for the normative term dictionary (see analysis_plan.md for the full dictionary).
   - `word_count` = total word count of the abstract (all whitespace-delimited tokens).
   - `norm_rate` = `norm_count / word_count` (set to NA if `word_count == 0`).
2. Aggregate to country-year: `mean_norm_rate = mean(norm_rate, na.rm = TRUE)` across all articles from the same `iso3` × `year` cell.

The outcome is a continuous variable bounded in [0, 1]; typical values are in the range 0.005–0.030 based on exploratory analysis of the specified dictionary.

**Normative term dictionary (core set):**

| Cluster | Terms |
|---|---|
| Obligation / prescription | should, ought |
| Rights | rights |
| Justice | justice, fairness |
| Freedom / liberty | freedom, liberty |
| Equality / dignity | equality, dignity |
| Accountability | accountability |
| Democracy (normative use) | democracy |

Full regex patterns (word-boundary anchored, case-insensitive) are defined in `analysis_plan.md`.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic). Use as the primary regime measure.

## Uniqueness check

Performed. Existing rq.md files inspected: teams 01–07 (team 08 has no rq.md at time of writing).

**Distinction from most similar teams:**

- **Team 01 (PCI score on abstracts):** Team 01 constructs a Political-Content Index measuring the share of abstract tokens matching a broad multi-cluster dictionary of politically sensitive topic terms (democracy, repression, governance, protest, elections). Team 09 measures normative/prescriptive language — terms that assert value judgments or obligations — not political topic terms. A paper about electoral autocracy that uses entirely empirical, descriptive language scores high on Team 01's PCI but zero on Team 09's normative rate; conversely, an economics paper arguing what policy "should" achieve scores zero on PCI but positive on Team 09.
- **Team 04 (regime-sensitive keywords in title/keywords):** Team 04 detects politically sensitive topic vocabulary in title and author-keyword fields; Team 09 measures evaluative-prescriptive vocabulary in the abstract body. Distinct text field, distinct vocabulary, distinct theoretical mechanism (framing avoidance vs. topic avoidance).
- **Team 05 (LLM classification of critical domestic framing):** Team 05 classifies whether abstracts critically evaluate own-country governance — a semantic judgment about the target and stance of critique. Team 09 uses a transparent dictionary count with no LLM and does not require a domestic-country reference.
- **Team 06 (semantic diversity via embeddings):** Team 06 measures holistic semantic convergence via cosine distance of dense embeddings; Team 09 measures the surface-form rate of a specific vocabulary class.
- **Team 08 (epistemic hedging — uncertainty language):** Team 08's domain (assigned but not yet filed) is uncertainty/hedging language (e.g., "may," "might," "perhaps," "appears to") — words that soften epistemic claims. Team 09 targets normative/prescriptive language — words that assert value claims or obligations. These are conceptually orthogonal dimensions: a sentence can hedge normatively ("these policies may undermine rights") or state empirical claims without hedging ("the policy reduced freedom"). The expected direction under self-censorship theory is also different: epistemic hedging could plausibly increase or decrease under autocracy depending on the mechanism invoked, while normative avoidance has a clear downward prediction.


---

## Analysis Plan

# Team 09 — Analysis Plan

## Hypothesis

Researchers from more autocratic countries use normative and prescriptive language at a lower rate in SSH article abstracts. Formally: the coefficient on `v2x_libdem` in a regression of country-year mean normative term rate on regime score, country fixed effects, year fixed effects, and standard economic controls is positive and statistically significant.

---

## Step 1 — Data inspection (to be run before analysis)

```r
library(tidyverse)
corpus <- readRDS("data/agent_corpus.rds")
set.seed(42); s <- corpus |> slice_sample(n = 3000)

s |> summarise(
  has_abstract = mean(!is.na(abstract)),
  mean_words   = mean(str_count(abstract, "\\w+"), na.rm = TRUE)
)

s |> filter(!is.na(abstract)) |>
  mutate(
    norm_count = str_count(tolower(abstract),
      "\\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\\b"),
    word_count = str_count(abstract, "\\w+"),
    norm_rate  = norm_count / word_count
  ) |>
  summarise(mean_rate = mean(norm_rate, na.rm = TRUE))
```

---

## Step 2 — Normative term dictionary

All matches are whole-word (`\b`), case-insensitive, applied to the `abstract` field.

| Cluster | Regex pattern |
|---|---|
| Obligation / prescription | `\b(should|ought)\b` |
| Rights | `\brights\b` |
| Justice | `\b(justice|fairness)\b` |
| Freedom / liberty | `\b(freedom|liberty)\b` |
| Equality / dignity | `\b(equality|dignity)\b` |
| Accountability | `\baccountability\b` |
| Democracy (normative register) | `\bdemocracy\b` |

Combined pattern: `\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\b`

Notes:
- `democracy` included because it is used predominantly normatively in SSH abstracts. Robustness check R2 excludes `democracy` and `rights` (closest overlap with Team 01 PCI) to confirm results are not overlap-driven.
- Terms not stemmed; whole-word matching avoids false positives ("right" as direction, "free" as adjective).

---

## Step 3 — Outcome variable construction

```r
corpus_norm <- corpus |>
  filter(!is.na(abstract), str_count(abstract, "\\w+") >= 20) |>
  mutate(
    norm_count = str_count(tolower(abstract),
      "\\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\\b"),
    word_count = str_count(abstract, "\\w+"),
    norm_rate  = norm_count / word_count
  )

cy <- corpus_norm |>
  group_by(iso3, year) |>
  summarise(
    mean_norm_rate          = mean(norm_rate, na.rm = TRUE),
    median_norm_rate        = median(norm_rate, na.rm = TRUE),
    n_abstracts             = n(),
    v2x_libdem              = first(v2x_libdem),
    lied_binary             = first(lied_binary),
    e_gdppc                 = first(e_gdppc),
    e_wb_pop                = first(e_wb_pop),
    .groups = "drop"
  ) |>
  mutate(log_gdppc = log(e_gdppc), log_pop = log(e_wb_pop)) |>
  filter(!is.na(v2x_libdem), !is.na(mean_norm_rate), n_abstracts >= 5)
```

---

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
library(fixest)
m1 <- feols(
  mean_norm_rate ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = cy,
  vcov = ~iso3
)
```

- Outcome: `mean_norm_rate`
- Primary IV: `v2x_libdem` (continuous 0–1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: `iso3` + `year`
- SE: clustered by `iso3`
- Expected sign: positive

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. This estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

```r
m2 <- feols(
  mean_norm_rate ~ v2x_libdem + log_gdppc + log_pop | year,
  data = cy,
  vcov = ~iso3
)
```

- Outcome: `mean_norm_rate`
- Primary IV: `v2x_libdem` (continuous 0–1)
- Controls: `log_gdppc`, `log_pop`
- Fixed effects: `year` only
- SE: clustered by `iso3`
- Interpretation: cross-sectional association between regime type and normative language use, net of global year trends

---

## Causal identification strategy

Variation exploited: within-country variation in `v2x_libdem` over 1970–2023, purged of global year shocks and time-invariant country characteristics.

Confounders controlled: country FE (research culture, language, institutions); year FE (global normative vocabulary trends); log GDP per capita; log population.

Identification threats:
1. Selection into publishing: pre-publication suppression attenuates estimates toward zero — positive findings are conservative.
2. Compositional confounding: disciplinary mix changes may drive normative rate changes. Addressed by R3.
3. English-language bias: flag share of non-English abstracts by regime quartile in descriptive statistics.
4. Reverse causality: implausible at country-year resolution.

---

## Robustness checks

| ID | Description |
|---|---|
| RC1 | Restricted dictionary: re-estimate the primary model using a version of the normative term dictionary that excludes "democracy" and "rights", as these terms overlap with dictionaries used by Teams 01 and 04. This isolates the result to normative vocabulary unique to this team's theoretical claim. |
| R1 | Replace `v2x_libdem` with `lied_binary` |
| R2 | Restrict dictionary to terms with minimal PCI overlap (exclude `democracy`, `rights`) |
| R3 | Restrict corpus to politically sensitive disciplines (Political Science, Sociology, Law, International Relations, Public Administration) |
| R4 | One-year within-country lag of `v2x_libdem` |
| R5 | Replace `mean_norm_rate` with `median_norm_rate` |

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | Coefficient, SE, p-value, N |
| `analysis/figures/fig1_raw_scatter.pdf` | Binned scatter: mean normative rate vs. v2x_libdem |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot: M1 and R1–R5 |
| `analysis/figures/fig3_within_country.pdf` | Within-country time series for 6–8 illustrative countries |
| `analysis/tables/tab1_descriptives.txt` | Descriptive statistics by regime quartile |
| `analysis/tables/tab2_main_results.txt` | Regression table: M1 + R1–R3 |
