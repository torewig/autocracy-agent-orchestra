# Team 10 — Research Question

## Research question

Does higher authoritarianism increase the share of SSH article abstracts that use exclusively technical, methodological, or administrative vocabulary with no political references, as classified by a large language model?

## Rationale

Self-censorship theory predicts that researchers in autocracies will actively reframe their work to minimize the risk of regime scrutiny — not only by avoiding sensitive topics altogether, but by stripping politically referential language from work they do publish, presenting it instead in purely technical or administrative terms. Technocratic framing is a lower-cost adaptation than topic abandonment: the researcher retains the research but sanitizes its presentation. If this mechanism is widespread, autocratic country-years should exhibit a systematically higher share of abstracts that are purely technocratic in vocabulary and carry no political signal.

## Theoretical mechanism

Researchers in autocracies face institutional incentives — denial of employment, grant funding, or publication access, or in extreme cases legal sanction — when their published work is perceived as politically relevant or threatening to the regime. Even when a researcher's underlying question has political implications, they can reduce their exposure by presenting findings in vocabulary that invokes only technical processes, measurement instruments, statistical methods, or administrative categories, without ever naming political actors, outcomes, institutions, or values. This strategic adoption of technocratic framing makes the abstract appear politically inert to regime surveillance, thereby lowering the personal cost of publication. The expected direction is positive: higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of technocratically framed abstracts, as researchers systematically adopt neutral, apolitical language as a survival strategy.

## Theory family

`framing-neutrality`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH abstracts classified as purely technocratic (no political references), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country association between a country-year's level of liberal democracy (`v2x_libdem`) and the share of that country-year's SSH abstracts classified as TECHNOCRATIC (exclusively technical/methodological/administrative vocabulary, no political references), conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM binary classifications to the country-year level.

## Outcome variable

**`share_technocratic`**: For each abstract in the stratified sample, an LLM assigns one of two labels — TECHNOCRATIC or NOT-TECHNOCRATIC (see LLM classification specification below). The outcome is the share of classified articles receiving the TECHNOCRATIC label, computed per country-year. This is a proportion bounded [0, 1], constructed from the `abstract` field and aggregated using the `iso3` and `year` fields.

Country-years with fewer than 5 sampled and classified abstracts are excluded from regression analysis.

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model); GPT-4o-mini as fallback.

**Task:** Binary classification of each abstract into TECHNOCRATIC or NOT-TECHNOCRATIC.

**Full classification prompt (to be used verbatim in analysis.R):**

```
You are a scientific text classifier. Your task is to classify the following article abstract according to whether it uses exclusively technical, methodological, or administrative vocabulary — with no political references of any kind — or whether it contains at least some political vocabulary.

TECHNOCRATIC means ALL of the following are true:
1. The abstract uses only technical, statistical, methodological, scientific, or administrative terminology.
2. The abstract contains NO references to political actors (e.g., governments, parties, leaders, regimes, states as political entities), political processes (e.g., elections, democratization, governance quality, repression, protest, civil society), political values (e.g., democracy, freedom, human rights, civil liberties, accountability), or politically charged social categories (e.g., ethnic conflict, political prisoners, political opposition).
3. The framing is purely about data, methods, measurement, technical processes, or administrative/managerial outcomes.

NOT-TECHNOCRATIC means AT LEAST ONE of the following is true:
1. The abstract mentions any political actor, institution, process, or outcome.
2. The abstract uses vocabulary that signals a political frame, even if the core methodology is technical (e.g., a study of "protest event detection using machine learning" is NOT-TECHNOCRATIC because it explicitly references protest).
3. The abstract evaluates or discusses governance, state capacity, policy effectiveness, or similar politically loaded concepts.

Instructions:
- Output only the label: TECHNOCRATIC or NOT-TECHNOCRATIC. No explanation.
- If the abstract is borderline, default to NOT-TECHNOCRATIC.
- If the abstract is very short (fewer than 20 words), classify based on what is present, not what is absent.
- Language: classify based on content regardless of the abstract's language.

Abstract:
[ABSTRACT TEXT]
```

**Label scheme:**
- `TECHNOCRATIC` — exclusively technical/methodological/administrative vocabulary, zero political references
- `NOT-TECHNOCRATIC` — contains at least one political reference, actor, institution, process, or politically framed concept

**Handling ambiguous cases:** The prompt instructs the model to default to NOT-TECHNOCRATIC in borderline cases, creating a conservative classifier that minimizes false positives for technocratic framing. The Analyst will validate classification quality by manually reviewing a random sample of 50 abstracts per label after classification.

## Sampling strategy

API cost is managed through stratified random sampling:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 abstracts per stratum (fewer if the stratum is smaller)
- **Eligibility:** articles with non-missing abstracts of at least 50 characters; all SSH fields included
- **Estimated total N:** ~7,000–8,000 abstracts (depending on stratum coverage)
- **Estimated cost:** ~$0.001–0.002 per abstract for Claude Haiku → ~$8–10 total
- **Aggregation:** country-year `share_technocratic` is computed from sampled articles; a weighted estimator adjusts for unequal sampling rates. Country-years with fewer than 5 classified abstracts are excluded from regression.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance.

## Uniqueness check

Performed. Existing teams with completed rq.md files: Teams 01–07.

Most similar team: **Team 05** (critical domestic governance framing — LLM classifying whether abstracts critically examine the author's own country's institutions).

Distinction from Team 05: Team 05 asks whether an abstract *critiques own-country institutions* — a question about the target and evaluative stance of an article toward a specific national context. Team 10 asks a categorically different question: whether an abstract uses *any political vocabulary at all*, regardless of country focus, evaluative direction, or whether the author's own country is mentioned. A comparative study of democratization in twenty countries would be NOT-TECHNOCRATIC for Team 10 (political vocabulary present) but NOT-DOMESTIC for Team 05 (does not focus on own country). A purely methods paper on survey design contains no political reference and is therefore TECHNOCRATIC for Team 10, while it would be NOT-DOMESTIC for Team 05. The two constructs are orthogonal.

Distinction from Team 01: Team 01 constructs a continuous Political Content Index (PCI) score based on the share of abstract word tokens matching a political-content dictionary; Team 10 uses LLM binary classification to identify abstracts with *zero* political reference of any kind. The PCI captures degree of political content; Team 10 captures the presence or absence of a political register in the full semantic sense, including framings and usages that would not be captured by a fixed-vocabulary dictionary.

Distinction from Team 04: Team 04 detects regime-sensitive terms (democracy, human rights, corruption, protest) via regex on titles and author keywords. Team 10 uses LLM classification of full abstract text to detect the complete absence of political vocabulary — a holistic semantic judgment about framing that a regex approach cannot make.

No other existing team measures the technocratic/apolitical framing dimension using LLM classification of full abstract text.
