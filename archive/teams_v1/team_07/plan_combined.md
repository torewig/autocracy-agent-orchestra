---
title: "Team 07 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-19"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---
# Team 07: Research Question

## Research question

Does autocracy reduce the share of SSH research that critically engages with domestic governance and political institutions?

## Rationale

The overarching question asks how autocracy shapes the *contents and direction* of SSH research. Simple keyword counts show that articles from autocracies and democracies mention politically sensitive terms at nearly identical rates (~7%). But qualitative inspection of abstracts reveals a subtler pattern: researchers in autocracies tend to study *other countries'* politics or adopt descriptive/technocratic framings, rather than critically examining domestic political institutions. Capturing this distinction requires classifying the *stance and focus* of research -- a content dimension that keyword matching cannot reliably detect. We use LLM-based classification of abstracts to measure whether articles critically engage with the governance and political institutions of the author's own country.

## Theoretical mechanism

Autocratic regimes create strong incentives for SSH researchers to avoid critical scrutiny of domestic political institutions. State authorities control university appointments, research funding, and publication permissions, and can sanction scholars whose work challenges regime legitimacy or exposes governance failures. Researchers respond through anticipatory self-censorship: they shift toward studying foreign countries, adopt descriptive or technocratic framings of domestic topics, or avoid governance-related research entirely. The result is not that politically relevant *words* disappear from the literature, but that the *critical analytical stance toward domestic power* is suppressed. Democratization relaxes these constraints by protecting academic freedom and reducing the personal cost of politically inconvenient findings. We therefore expect higher levels of liberal democracy to be associated with a higher share of research that critically examines domestic governance.

## Theory family

`political-self-censorship`

## Estimand

The average effect of a one-unit increase in `v2x_libdem` on the probability that an SSH article critically engages with the governance and political institutions of the author's country, controlling for country and year fixed effects.

## Unit of analysis

Article-country (from a stratified random sample of ~6,000 abstracts, classified via LLM).

## Outcome variable

`critical_domestic` -- a binary indicator (0/1) constructed via LLM classification of abstracts. An article is coded 1 if it critically examines domestic governance, political institutions, state power, or accountability in the author's country; 0 otherwise. This variable is constructed during the analysis phase using the Claude API (Haiku) for cost-efficient classification.

## Key independent variable

`v2x_libdem`


---

# Team 07: Analysis Plan

## Method

Two-stage approach combining LLM-based text classification with regression analysis.

**Stage 1 -- Abstract classification (measurement):**
Use the Claude API (Haiku model for cost efficiency) to classify a stratified random sample of ~6,000 abstracts. Each abstract is classified on whether the article *critically engages with domestic governance and political institutions* in the author's country. The classification prompt provides the author's country and asks the LLM to assess:
1. Does the article focus on the author's own country or domestic context?
2. Does it critically examine political institutions, governance, accountability, or state power?

Articles are coded `critical_domestic = 1` if both conditions are met; 0 otherwise. This goes beyond keyword detection by capturing analytical stance and domestic focus -- dimensions that keywords cannot reliably detect (exploratory keyword analysis showed ~7% sensitive-topic prevalence in both autocracies and democracies, masking the real content differences visible in qualitative abstract inspection).

**Stage 2 -- Regression:**
OLS/logit regression of `critical_domestic` on `v2x_libdem` with country and year fixed effects.

## Sampling strategy

Draw a stratified random sample of ~6,000 article-country rows (with non-missing abstracts):
- Stratify by `regime_binary` (0/1): ~3,000 per stratum
- Within each stratum, proportionally sample across `subject_primary` categories
- Restrict to articles with non-missing abstracts (92% of autocracy articles, 80% of democracy articles have abstracts)
- This yields enough observations for regression with country and year FE

Estimated API cost: ~6,000 abstracts x ~300 tokens average input + prompt ≈ 3M input tokens. With Haiku pricing this is very modest (<$5).

## Model specification

**Primary model (linear probability model):**

```
critical_domestic_ij = alpha_i + gamma_t + beta * v2x_libdem_it + delta1 * log(e_gdppc_it) + delta2 * log(e_wb_pop_it) + epsilon_ij
```

- `critical_domestic_ij`: binary, 1 if article *j* from country *i* in year *t* critically engages with domestic governance
- `alpha_i`: country fixed effects
- `gamma_t`: year fixed effects
- `v2x_libdem_it`: liberal democracy index (primary predictor)
- `log(e_gdppc_it)`: log GDP per capita (economic development control)
- `log(e_wb_pop_it)`: log population (country size control)
- Standard errors clustered at the country level

**Alternative:** Logit with country and year FE (conditional logit) as robustness check if the LPM estimates are close to 0 or 1.

**Sample restriction:** Articles with non-missing abstracts. Country-years with at least 5 articles in the sample (to ensure FE estimation is stable).

**Robustness specifications:**
1. Replace `v2x_libdem` with `regime_binary`
2. Restrict to 1990-2019 (avoiding pre-1990 WOS coverage issues)
3. Restrict to political fields only (`subject_primary` in Political Science, Sociology, Law, History) -- tests whether the effect is driven by selection across vs. within fields
4. Add `subject_primary` fixed effects to the main model (within-field variation only)
5. Validate LLM classification: manually review a random 100-abstract subsample and report agreement rate

## Classification prompt design

The LLM classification prompt will:
- Provide the abstract text and the author's country
- Ask two structured questions: (a) does this article study the author's own country/domestic context? (b) does it critically examine governance, political institutions, state power, or political accountability?
- Request a structured JSON response with binary indicators for each dimension
- Include 3-4 few-shot examples (hand-coded by the analyst) to calibrate classification

The classification is performed once, saved as a data file, and used in all subsequent regressions.

## Causal identification strategy

**Variation exploited:** Within-country changes in `v2x_libdem` over time. Country FE absorb time-invariant country characteristics (academic traditions, language, historical research infrastructure). Year FE absorb global trends (growth of governance studies, WOS indexing expansion, changes in SSH research norms). The identifying variation comes from countries experiencing democratization or autocratization episodes.

**Confounders controlled:**
- Country FE: academic traditions, language, institutional legacies
- Year FE: global trends in SSH, WOS coverage changes
- log(e_gdppc): economic development, which co-moves with democratization and research capacity
- log(e_wb_pop): country size, which affects research system scale

**Threats to identification:**
1. **Time-varying confounders:** University expansion, internationalization, and R&D investment may correlate with both democratization and critical research capacity. GDP and population are controlled but do not fully capture higher-education expansion.
2. **Reverse causality:** Critical governance research could contribute to democratization rather than (or in addition to) resulting from it. The design cannot settle directionality.
3. **WOS selection:** The corpus includes only WOS-indexed journals. Democratization may change which domestic journals are indexed, affecting the observed composition of research. This is a measurement issue, not a true confounder, but it complicates interpretation.
4. **LLM classification noise:** Measurement error in the outcome introduces attenuation bias (toward zero), making estimates conservative. Validation against hand-coding quantifies this concern.
5. **Sampling:** The analysis uses a stratified sample, not the full corpus. Sampling weights may be needed if the stratification proportions differ substantially from the population.

## Expected output files

| File | Description |
|------|-------------|
| `figures/fig1_critical_share_by_regime.png` | Bar chart: share of `critical_domestic = 1` articles by `v2x_regime` category (4 groups) |
| `figures/fig2_critical_vs_libdem.png` | Binned scatter: share of critical-domestic articles against `v2x_libdem` (country-year averages) |
| `figures/tab1_main_regression.png` | Regression table: LPM with country + year FE, main model + robustness checks |
| `figures/fig3_critical_by_field_regime.png` | Faceted bar chart: critical-domestic share by field (polsci, sociology, law, history, economics) x regime type |

