# Pre-registration: team_23

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 23 — Research Question

## Research question

Does the ideological type of a regime — communist/left-authoritarian versus nationalist/right-authoritarian versus liberal-democratic — predict the political-economy ideological lean of national SSH output, and does all autocracy (regardless of type) suppress liberal or centrist political-economy framing relative to democratic baselines?

## Rationale

Self-censorship under autocracy is not ideologically neutral: researchers in communist regimes face pressure to produce scholarship consonant with statist, collectivist, and anti-market frames, while researchers in nationalist or right-authoritarian regimes face complementary pressures toward market-nationalist or traditionalist frames. Both regime types may suppress liberal-centrist political-economy framing — the framing most compatible with pluralist, rule-of-law, and open-society scholarship — but through different mechanisms. Existing teams capture topic avoidance and framing-neutrality but none test whether the ideological content of political-economy language in SSH abstracts shifts predictably with regime ideology type, which is a distinct and theoretically important form of self-censorship.

## Theoretical mechanism

Autocratic regimes exert direct and indirect pressure on academic institutions to produce scholarship consonant with their official ideology: communist regimes promote statist, redistributive, and collectivist framings and penalize market-liberal or pluralist alternatives; nationalist and right-authoritarian regimes promote market-nationalist, traditionalist, or anti-cosmopolitan framings and penalize universalist or redistributive alternatives. Researchers anticipating these pressures self-censor by framing their work within the ideologically approved vocabulary, even when their empirical subject matter does not require taking a position. Liberal-centrist or ideologically neutral framing — which does not endorse either statism or nationalism — is the framing most compatible with liberal-democratic academic norms; we therefore expect it to be suppressed under both left- and right-authoritarian regimes, but through different substitution patterns. The expected direction for the primary test is positive: higher `v2x_libdem` (more democratic) is associated with a higher share of liberal/neutral political-economy framing (`share_apolitical`) and a lower share of left-authoritarian or right-nationalist framing.

## Theory family

ideological-alignment

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH abstracts with liberal/neutral political-economy framing (NEUTRAL + NONE) and a higher share with ideologically aligned framing (LEFT or RIGHT-CONSERVATIVE), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country association between `v2x_libdem` and the country-year share of SSH abstracts classified as carrying liberal/neutral political-economy framing (`share_apolitical`), conditional on country fixed effects, year fixed effects, and standard economic controls. Secondary estimands test heterogeneity by regime ideology type via interaction with a categorical regime-ideology variable.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Construction:** For each abstract in the stratified sample, an LLM assigns one of five labels reflecting the political-economy ideological framing of the text: (1) LEFT — statist, redistributive, collectivist, or anti-capitalist framing; (2) RIGHT-CONSERVATIVE — nationalist, traditionalist, or social-conservative framing; (3) RIGHT-LIBERAL — classical liberal framing (free markets, individual rights, limited government); (4) NEUTRAL — technocratic, empiricist, or explicitly non-ideological framing; (5) NONE — the abstract does not carry discernible political-economy framing. Five country-year share variables are constructed: `share_left`, `share_right_conservative`, `share_right_liberal`, `share_neutral`, `share_none`. The primary outcome is `share_apolitical` = `share_neutral` + `share_none` (i.e., the share of abstracts that avoid ideological political-economy framing in any direction), treated as the "suppressed" category under autocracy. Secondary outcomes are `share_left`, `share_right_conservative`, and `share_right_liberal`, examined separately and in regime-ideology interaction models.

Framing is distinguished from topic coverage: an abstract that studies redistribution as a topic is classified by the framing through which it discusses it — an empiricist study of redistribution effects with no normative stance is NEUTRAL; one that frames redistribution as a social right or as correcting capitalist exploitation is LEFT; one that frames redistribution as market distortion is RIGHT-LIBERAL.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Secondary IV: a categorical regime ideology type variable constructed from V-DEM and external sources (see analysis plan).

## LLM classifier specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost model) primary; GPT-4o-mini as alternative.

**Labels:**
- `LEFT`: The abstract frames its subject using statist, redistributive, collectivist, anti-capitalist, or class-struggle language as an evaluative or normative lens — including advocacy against oppression of marginalized groups and minorities — not merely as a topic under study.
- `RIGHT-CONSERVATIVE`: The abstract frames its subject using nationalist, traditionalist, anti-cosmopolitan, social-conservative, or authoritarian-order language as an evaluative or normative lens — not merely as a topic under study.
- `RIGHT-LIBERAL`: The abstract frames its subject using classical liberal language — free markets, individual rights, limited government, rule of law, or personal autonomy — as an evaluative or normative lens — not merely as a topic under study.
- `NEUTRAL`: The abstract discusses political-economy topics in an explicitly empiricist, technocratic, or non-partisan framing — describing mechanisms or measuring effects without endorsing a normative direction.
- `NONE`: The abstract does not engage with political-economy topics or ideological framing in any discernible way.

**Prompt structure:** The prompt passes the abstract text and instructs the model to identify the dominant political-economy framing, emphasizing that it should classify framing (evaluative stance, normative language, rhetorical appeal) rather than topic coverage. The model returns a single label. Ties between LEFT and RIGHT-CONSERVATIVE or RIGHT-LIBERAL default to NEUTRAL. Ties between NEUTRAL and NONE default to NONE. Full prompt text defined in `analysis_plan.md`.

**Label assignment rules:** Single-label output only. If the abstract discusses political-economy topics descriptively without normative framing, assign NEUTRAL. If the abstract does not engage with political-economy content at all, assign NONE. Default to NONE if genuinely ambiguous. Assign LEFT, RIGHT-CONSERVATIVE, or RIGHT-LIBERAL only when normative framing language is present and unmistakable.

## Sampling strategy

Target approximately **1,000,000 abstracts**, stratified by `iso3` × `v2x_regime` (4-category: 0–3) × decade, up to 10 articles per stratum. `set.seed(42)` for reproducibility. At Claude Haiku rates (~$0.00052 per abstract), the estimated cost for 1M abstracts is ~$520. **Hard cost ceiling: $500** — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500.

## Uniqueness check

Performed. Teams with most potential overlap:
- Team 05: classifies whether abstracts critically examine domestic governance (binary CRITICAL-DOMESTIC vs. NEUTRAL-DOMESTIC). Does not classify political-economy ideological lean or LEFT/RIGHT/NEUTRAL framing.
- Team 10: classifies technocratic framing (presence of depoliticizing, technocratic language). Tests suppression of political framing generally; does not distinguish LEFT from RIGHT from NEUTRAL.
- Team 12: classifies normative conclusion claims (strong vs. hedged normative claims). Does not classify ideological direction (left vs. right vs. neutral).
- Team 08: classifies hedging/epistemic uncertainty. Does not test ideological lean.

Team 23 is the only team that (a) classifies the political-economy ideological direction (LEFT / RIGHT-CONSERVATIVE / RIGHT-LIBERAL / NEUTRAL / NONE) of SSH abstracts, (b) tests whether autocracy predicts this lean, and (c) tests heterogeneity by regime ideology type to assess whether communist vs. nationalist autocracies produce predictably different lean signatures.


---

## Analysis Plan

# Team 23 — Analysis Plan

## Overview

The analysis tests whether regime type — and regime ideology type in particular — predicts the political-economy ideological lean of SSH scholarship. The pipeline proceeds in five stages: sampling, LLM classification, validation, aggregation to country-year, and regression. The primary test is whether `v2x_libdem` positively predicts `share_liberal` (liberal/neutral framing). Secondary tests use interaction models to identify whether communist autocracies shift output left and nationalist autocracies shift output right.

---

## Stage 1: Sampling

Draw a stratified random sample from `data/agent_corpus.rds`.

**Eligibility filter:**
- Non-missing abstract with `nchar(abstract) >= 50`
- Non-missing `iso3`, `year`, `v2x_libdem`

**Stratification variables:** `iso3` x `v2x_regime` (4-category: 0–3) x decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)

**Target N per stratum:** up to 10 articles per stratum

**Expected total N:** approximately 7,000–8,500 abstracts

**Seed:** `set.seed(42)`

**Exclusion after classification:** Country-years with fewer than 5 classified abstracts excluded from regression.

```r
library(tidyverse)
library(fixest)

set.seed(42)

corpus <- readRDS("data/agent_corpus.rds")

sample_df <- corpus |>
  filter(!is.na(abstract), nchar(abstract) >= 50,
         !is.na(iso3), !is.na(year), !is.na(v2x_libdem)) |>
  mutate(decade = floor(year / 10) * 10) |>
  group_by(iso3, v2x_regime, decade) |>
  slice_sample(n = 10) |>
  ungroup()
```

---

## Stage 2: LLM Classification

For each sampled abstract, call Claude Haiku (GPT-4o-mini as fallback). Returns exactly one label: LEFT, RIGHT, NEUTRAL, or NONE. Stored in `teams/team_23/analysis/llm_classifications.csv` with columns: wos_id, iso3, year, label, abstract_nchar.

### Classification prompt

```
You are a research assistant classifying the political-economy ideological
framing of academic abstracts in social science and humanities.

Your task is to identify the dominant ideological framing -- if any -- through
which the abstract discusses its subject matter. Focus on framing, not topic:
an abstract that studies inequality as a phenomenon is not necessarily
left-leaning; an abstract that frames inequality as the result of capitalist
exploitation or advocates redistribution as a social right IS left-leaning.

Classify the abstract into exactly one of the following four categories:

LEFT: The abstract uses statist, redistributive, collectivist, anti-capitalist,
or class-struggle framing as a normative or evaluative lens. This includes
language presenting state intervention, wealth redistribution, worker solidarity,
or anti-market positions as desirable, natural, or correct -- not merely as a
topic under investigation.

RIGHT: The abstract uses market-efficiency, market-freedom, nationalist,
traditionalist, anti-redistributive, or anti-cosmopolitan framing as a normative
or evaluative lens. This includes language presenting free markets, national
identity, traditional values, or anti-immigration positions as desirable,
natural, or correct -- not merely as a topic under investigation.

NEUTRAL: The abstract discusses political-economy topics (inequality, markets,
redistribution, capitalism, governance, economic policy, class, etc.) in an
empiricist, technocratic, or explicitly non-partisan framing. The abstract
measures, describes, or analyzes these topics without endorsing a normative
ideological direction.

NONE: The abstract does not engage with political-economy or ideological content
in any discernible way. This includes purely historical, linguistic, cultural,
or scientific subject matter with no political-economy dimension.

Rules:
- Output only the label (LEFT, RIGHT, NEUTRAL, or NONE). No explanation.
  No punctuation.
- If ambiguous between LEFT and RIGHT, output NEUTRAL.
- If ambiguous between NEUTRAL and NONE, output NONE.
- Assign LEFT or RIGHT only when normative framing language is present and
  unmistakable.
- Do not be influenced by the country of origin or the author's name.

Abstract: [ABSTRACT]
```

### Batching and cost control

Process in batches of 500. Log cumulative cost after each batch. Halt if cost exceeds $30; proceed with classified subset. Expected cost: $3–6 for ~7,500 abstracts at $0.0004–0.0008/abstract (Claude Haiku pricing).

---

## Stage 3: Validation

Manually review 75 abstracts (~25 per label for LEFT, RIGHT, NEUTRAL). Compute precision per label. If precision for LEFT or RIGHT falls below 0.65, revise prompt and re-classify a 500-abstract test batch before proceeding.

Output: `teams/team_23/analysis/validation_sample.csv` — columns: wos_id, iso3, year, llm_label, human_label, match

---

## Stage 4: Aggregation to country-year

```r
cy_shares <- llm_df |>
  group_by(iso3, year) |>
  summarise(
    n_classified  = n(),
    n_left        = sum(label == "LEFT"),
    n_right       = sum(label == "RIGHT"),
    n_neutral     = sum(label == "NEUTRAL"),
    n_none        = sum(label == "NONE"),
    share_left    = n_left    / n_classified,
    share_right   = n_right   / n_classified,
    share_neutral = n_neutral / n_classified,
    share_none    = n_none    / n_classified,
    share_liberal = (n_neutral + n_none) / n_classified,
    .groups = "drop"
  ) |>
  filter(n_classified >= 5)

reg_df <- cy_shares |>
  left_join(vdem_covs, by = c("iso3", "year")) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  mutate(log_gdppc = log(e_gdppc), log_pop = log(e_wb_pop))
```

`share_liberal` = `share_neutral` + `share_none`: the primary outcome — share of abstracts avoiding directional political-economy framing.

---

## Stage 5: Regression

### Model specification

**Primary specification (pre-registered):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`. Identifies within-country, over-time variation in regime type after absorbing stable cross-national differences and global trends.

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications are reported in the same regression table.

### Primary model (H1: autocracy suppresses liberal/neutral framing)

```r
# Primary specification (pre-registered): TWFE — country FE + year FE
m1 <- feols(
  share_liberal ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data = reg_df, cluster = ~iso3
)

# Secondary specification (descriptive): Pooled OLS — year FE only
m1_ols <- feols(
  share_liberal ~ v2x_libdem + log_gdppc + log_pop | year,
  data = reg_df, cluster = ~iso3
)
```

Outcome: `share_liberal`. Primary predictor: `v2x_libdem`. Controls: `log(e_gdppc)`, `log(e_wb_pop)`. SE: clustered by `iso3` in both specifications. Expected direction: positive (more democracy → more liberal/neutral framing). Both `m1` and `m1_ols` are reported together in `tab1_main_results.tex`.

### Secondary models (H2/H3: regime ideology heterogeneity)

```r
m2_left <- feols(share_left ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
                 data = reg_df, cluster = ~iso3)

m3_right <- feols(share_right ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
                  data = reg_df, cluster = ~iso3)

m4_interact <- feols(
  share_left ~ v2x_libdem * regime_ideo + log_gdppc + log_pop | iso3 + year,
  data = reg_df |> filter(!is.na(regime_ideo)), cluster = ~iso3
)
```

H2: communist autocracies elevate `share_left`; interaction `v2x_libdem x communist` is negative.
H3: nationalist autocracies elevate `share_right`; interaction `v2x_libdem x nationalist_right` is negative.

---

## Causal identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem` after country and year FE.

**Confounders addressed:** Country FE absorbs stable cross-national factors. Year FE absorbs global ideological trends (including post-1991 Marxist decline). Log GDP and log population control for development-level differences.

**Main threats:**

1. *Global ideological shocks.* 1989–1991 transitions conflate regime change and ideological shift. Year FE absorb common component; post-2000 robustness check tests whether results survive.
2. *LLM classification error (random).* Attenuates toward zero; significant findings are conservative.
3. *LLM classification error (systematic).* Language-driven misclassification addressed by validation sample and English-only robustness check.
4. *Compositional field shift.* Post-communist expansion of political science departments may confound outcomes. Robustness check adds `subject_primary x year` interactions.
5. *Reverse causality.* Implausible direction. Design is explicitly descriptive-associational.

---

## Robustness checks

1. **Alternative regime measure (binary):** Replace `v2x_libdem` with `lied_binary`.
2. **Alternative regime measure (ordinal):** Replace with `v2x_regime` (0–3 factor, liberal democracy as reference).
3. **Post-2000 restriction:** Re-estimate on 2000–2023 to rule out post-communist transition confounding.
4. **Fractional logit:** Re-estimate primary model with `feglm(family = quasibinomial)`.
5. **Exclude NONE category:** Recompute shares using only LEFT/RIGHT/NEUTRAL abstracts.

---

## Expected output files

| File | Description |
|------|-------------|
| `analysis/llm_classifications.csv` | Article-level LLM labels |
| `analysis/country_year_shares.csv` | Country-year aggregated shares |
| `analysis/validation_sample.csv` | 75-abstract validation subsample with human labels |
| `analysis/analysis.R` | Full reproducible pipeline |
| `analysis/primary_results.json` | team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |
| `analysis/figures/fig1_share_by_regime.pdf` | Distribution of share_liberal and share_left by v2x_regime |
| `analysis/figures/fig2_binscatter_liberal.pdf` | Binscatter of share_liberal on v2x_libdem (residualized) |
| `analysis/figures/fig3_coef_plot.pdf` | Coefficient plot: main model and robustness specifications |
| `analysis/figures/fig4_hetero_interact.pdf` | Interaction plot: share_left and share_right by v2x_libdem x regime_ideo |
| `analysis/tables/tab1_main_results.tex` | Regression table for primary + secondary models |
| `analysis/tables/tab2_robustness.tex` | Robustness table |

---

## API cost disclosure

| Item | Value |
|------|-------|
| Primary API | Claude Haiku (Anthropic) |
| Fallback | GPT-4o-mini (OpenAI) |
| Target sample | ~7,500 abstracts |
| Estimated cost | ~$3–6 |
| Hard ceiling | $30 — halt if exceeded |
| Actual cost | Record in analysis.R and primary_results.json |
