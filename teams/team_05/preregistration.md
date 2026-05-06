# Pre-registration: team_05

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 05 — Research Question

## Research question

Does higher levels of authoritarianism reduce the share of social science and humanities articles that critically examine the author's own country's governance and institutions, as classified by a large language model applied to article abstracts?

## Rationale

Self-censorship theories predict that researchers operating under authoritarian constraints avoid producing work that could be perceived as threatening to the regime. Critiquing domestic governance — examining failures of one's own state's institutions, political processes, or ruling actors — is among the most politically exposed scholarly activities a researcher can undertake. If self-censorship operates through avoidance of such critical domestic framing, we should observe a lower share of such articles in more authoritarian country-years. Dictionary-based keyword approaches used by other teams capture the presence of politically sensitive terms but cannot distinguish between an article that critiques domestic governance and one that merely studies democracy or institutions in a neutral or comparative frame; LLM classification addresses this gap.

## Theoretical mechanism

In autocracies, researchers face career sanctions — including denial of employment, funding, publication opportunities, or in extreme cases legal consequences — if their work is interpreted as critical of the ruling regime or its institutions. Anticipating these risks, individual researchers self-censor by reframing or abandoning research questions that involve evaluating or critiquing their own country's governance, even when the scholarly question is legitimate. Over time, this selective avoidance should produce a measurable deflation in the share of a country's SSH output that critically examines domestic institutions. The expected direction is negative: higher authoritarianism (lower v2x_libdem) is associated with a lower share of critical domestic governance framing.

## Theory family

topic-avoidance

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH articles critically examining their own governance and institutions, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country association between a country-year's level of liberal democracy (v2x_libdem) and the share of that country-year's SSH articles whose abstracts critically examine own-country governance and institutions, conditional on country fixed effects, year fixed effects, and standard economic controls.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Construction:** For each abstract in the stratified sample, an LLM assigns one of three labels: (1) critically examines own-country governance/institutions, (2) discusses own country but not critically, (3) does not focus on own country. The outcome is the share of classified articles receiving label (1), computed per country-year and denoted `share_critical_domestic`. This is a proportion variable bounded [0, 1].

The outcome is constructed from the `abstract` and `iso3` fields. The "own country" reference for each abstract is the author's country identified by `iso3`. For articles with multiple author countries, each article-country row is classified independently using the respective `iso3` as the "own country" reference — a paper co-authored by Chinese and American researchers is classified twice, once asking about China and once about the US. The unit of analysis is the article-country observation.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance.

## Controls

`log(e_gdppc)` (log GDP per capita) and `log(e_wb_pop)` (log population), both from V-DEM/World Bank.

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost model from Anthropic API) or GPT-4o-mini as alternative.

**Prompt design:** Each API call passes (a) the article abstract and (b) the author's country name (derived from `iso3`) and asks for a single-label classification. The prompt is reproduced in full in `analysis_plan.md`.

**Label scheme:**
- Label 1: "CRITICAL-DOMESTIC" — the abstract critically examines, evaluates, or critiques the governance, political institutions, policies, or political processes of [country name]. "Critical" requires that the article not merely describe or study these institutions but evaluates their performance, failures, accountability deficits, or democratic/rule-of-law shortcomings.
- Label 2: "NEUTRAL-DOMESTIC" — the abstract discusses [country name] as a case or context but in a neutral, descriptive, or comparative manner without critical evaluation of institutions or governance.
- Label 3: "NOT-DOMESTIC" — the abstract does not primarily focus on [country name]; it may be comparative, theoretical, or focused on another country.

**Ambiguous cases:** The prompt instructs the model to output a single label only (no explanations), to default to Label 2 if the framing is mixed or unclear, and to use Label 3 if the country is mentioned only incidentally (e.g., as one case among many in a comparative study). The Analyst will validate classification quality by manually reviewing a random sample of 70 abstracts per label (70 × 3 = 210 abstracts total).

**Handling non-English abstracts:** The LLM can handle multilingual text. The prompt instructs the model to classify based on content regardless of language.

## Sampling strategy

Classification is performed on up to 2,000,000 article-country rows from the corpus:

- **Eligibility:** Non-missing abstracts of at least 50 characters; all SSH fields included.
- **Scale:** Classify all eligible article-country rows up to 2,000,000. If the eligible pool exceeds 2,000,000, draw a random sample of exactly 2,000,000 with `set.seed(42)`.
- **Co-authorship:** Each article-country row is classified independently (see Outcome variable section above).
- **Cost estimate:** ~$800–900 total at ~$0.80/million input tokens for Claude Haiku 3.5 (approximately 500 tokens per abstract × 2,000,000 abstracts). Log actual cost and halt if it exceeds $1,500.
- **Exclusion:** Country-years with fewer than 5 classified abstracts are excluded from regression analysis.

## Uniqueness check

Performed. Most similar existing team: Team 04 (regime-sensitive keyword prevalence: democracy, human rights, corruption, protest — regex on title + keywords).

Distinction: Team 04 detects the presence of politically sensitive vocabulary via regex but cannot determine whether the article is critically evaluating the author's own country's institutions, which requires semantic understanding of the abstract's framing relative to a country reference — a judgment that LLM classification is designed to handle.


---

## Analysis Plan

# Team 05 - Analysis Plan

## Method

The analysis proceeds in four sequential stages:

1. Sampling. Classify up to 2,000,000 article-country rows from data/agent_corpus.rds, restricting to abstracts with at least 50 characters. If the eligible pool exceeds 2,000,000 rows, draw a random sample of exactly 2,000,000 with set.seed(42). For articles with multiple author countries, each article-country row is included and classified independently.

2. LLM classification. For each article-country row, call the Claude Haiku API with the prompt below. Each call receives the abstract text and the country name for that row (mapped from iso3). The model returns one label: CRITICAL-DOMESTIC, NEUTRAL-DOMESTIC, or NOT-DOMESTIC. For articles with multiple author countries, each iso3 is passed separately as the "own country" reference. Results stored with wos_id, iso3, and year in teams/team_05/analysis/llm_classifications.csv.

3. Aggregation to country-year. Merge LLM labels back to corpus metadata. Compute share_critical_domestic = count of CRITICAL-DOMESTIC articles divided by total classified articles, per country-year. Exclude country-years with fewer than 5 sampled abstracts.

4. Regression. Regress share_critical_domestic on v2x_libdem with country FE, year FE, and controls, using fixest::feols.

## LLM classification prompt

The following prompt is sent to the API for each abstract. [COUNTRY] is replaced with the country name; [ABSTRACT] is replaced with the abstract text.

---
You are a research assistant classifying academic abstracts. Determine whether the abstract critically examines governance or institutions of [COUNTRY].

Critical examination means the article evaluates, critiques, or assesses performance failures, accountability deficits, rule-of-law problems, or democratic shortcomings of [COUNTRY] political institutions or processes. Neutral or descriptive analysis, historical description, or use of [COUNTRY] only as a comparative case does NOT qualify.

Classify into exactly one category:

CRITICAL-DOMESTIC: The abstract critically examines governance, institutions, policies, or political processes of [COUNTRY], focusing on failures, deficits, or problems.

NEUTRAL-DOMESTIC: The abstract discusses [COUNTRY] as a setting or case but without critical evaluation of governance.

NOT-DOMESTIC: The abstract does not primarily focus on [COUNTRY].

Rules: Output only the label. No explanation. No punctuation. If ambiguous between critical and neutral, output NEUTRAL-DOMESTIC. If [COUNTRY] is mentioned only incidentally, output NOT-DOMESTIC.

Abstract: [ABSTRACT]
---

Validation: After classification, manually review 70 randomly drawn abstracts per label (70 × 3 = 210 total). If precision for CRITICAL-DOMESTIC falls below 0.70, revise the prompt before regression.

## Sampling strategy

- Eligibility: non-missing abstract with nchar(abstract) >= 50; all SSH fields included
- Scale: classify all eligible article-country rows up to 2,000,000; if pool exceeds 2,000,000, draw random sample with set.seed(42)
- Co-authorship: each article-country row classified independently; multi-country papers yield one row per author country
- Exclusion: country-years with fewer than 5 classified abstracts dropped before regression
- Cost estimate: approximately 2,000,000 abstracts at ~500 tokens each at USD 0.80/million input tokens (Claude Haiku 3.5) = approximately USD 800-900 total; halt if actual cost exceeds USD 1,500

## Model specification

Two specifications are estimated and reported side by side in the same regression table.

### Primary specification (pre-registered)

- Outcome: share_critical_domestic (proportion, 0-1), computed per country-year from LLM classifications
- Predictors: v2x_libdem + log(e_gdppc) + log(e_wb_pop)
- Fixed effects: country FE + year FE (two-way)
- SE clustering: by iso3 (cluster-robust SEs via fixest::feols)
- Estimator: OLS with two-way FE (fixest::feols); fractional logit as robustness check

Primary estimating equation:
  share_critical_domestic_it = alpha_i + gamma_t + beta * v2x_libdem_it + delta_1 * log(e_gdppc_it) + delta_2 * log(e_wb_pop_it) + epsilon_it

The coefficient of interest is beta, expected to be positive (higher democracy -> higher critical domestic framing share).

### Secondary specification (descriptive)

- Outcome: share_critical_domestic (same as primary)
- Predictors: v2x_libdem + log(e_gdppc) + log(e_wb_pop)
- Fixed effects: year FE only (no country FE)
- SE clustering: by iso3 (cluster-robust SEs via fixest::feols)
- Estimator: Pooled OLS with year FE (fixest::feols)

Secondary estimating equation:
  share_critical_domestic_it = gamma_t + beta * v2x_libdem_it + delta_1 * log(e_gdppc_it) + delta_2 * log(e_wb_pop_it) + epsilon_it

This specification estimates the cross-sectional level association between regime type and the outcome. It complements the within-country TWFE estimate by showing how democratic and autocratic countries differ on average in critical domestic framing, rather than how a given country changes as its regime type shifts. Both specifications are reported in the same regression table.

## Causal identification strategy

Identifying variation: Within-country, over-time variation in v2x_libdem. Country FE absorb time-invariant country characteristics. Year FE absorb global publishing shocks.

Main threats:

1. Reverse causality: democratization driven partly by scholarly pressure could introduce simultaneity bias, likely attenuating the estimated effect.

2. LLM classification error (random): noise attenuates beta toward zero; null findings less informative but no false positives.

3. LLM classification error (systematic): language or region-driven misclassification detected via 210-abstract validation subsample (70 per class); English-only robustness check also addresses this.

4. Sampling bias: stratified design ensures regime and decade coverage; country FE absorb volume differences.

5. Confounders: GDP per capita and population controlled; field composition addressed in robustness check.

## Robustness checks

1. Alternative regime measure: replace v2x_libdem with lied_binary (e_lexical_index >= 4).
2. Regime-type heterogeneity: replace v2x_libdem with v2x_regime (4-category factor); report marginal effects relative to liberal democracies.
3. Field restriction: restrict to political science, sociology, law, and area studies (subject_primary filter).
4. English-only abstracts: test for language-driven classification bias.
5. Fractional logit: re-estimate using glm(family = quasibinomial).
6. Alternative threshold: define CRITICAL-DOMESTIC more permissively (include NEUTRAL-DOMESTIC where iso3 country is the primary subject).

## Expected output files

- teams/team_05/analysis/llm_classifications.csv: Article-level LLM labels (wos_id, iso3, year, label, abstract_nchar)
- teams/team_05/analysis/country_year_shares.csv: Country-year aggregated outcome (iso3, year, n_classified, n_critical, share_critical_domestic)
- teams/team_05/analysis/figures/fig1_share_by_regime.pdf: Distribution of share_critical_domestic by regime type
- teams/team_05/analysis/figures/fig2_binscatter.pdf: Binscatter of share_critical_domestic on v2x_libdem (residualized on country + year FE)
- teams/team_05/analysis/figures/fig3_coef_plot.pdf: Coefficient plot, main model + robustness
- teams/team_05/analysis/figures/tab1_main_results.tex: Regression table (main + robustness), modelsummary output
- teams/team_05/analysis/primary_results.json: Structured output (team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs)
- teams/team_05/analysis/validation_sample.csv: 210-abstract validation subsample with human labels (70 per class)

## API cost disclosure

- API: Claude Haiku 3.5 (Anthropic) primary; GPT-4o-mini (OpenAI) as alternative
- Estimated cost: approximately USD 800-900 for up to 2,000,000 article-country rows at ~500 tokens each at USD 0.80/million input tokens
- Sample strategy: all eligible article-country rows (nchar(abstract) >= 50) up to 2,000,000; random sample with set.seed(42) if pool exceeds 2,000,000
- Halt condition: stop classification and alert PI if actual cost exceeds USD 1,500
- Actual cost incurred: to be recorded in analysis.R comments after classification run

