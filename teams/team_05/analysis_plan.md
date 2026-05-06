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

