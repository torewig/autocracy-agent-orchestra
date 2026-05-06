# Team 24 — Research Question

## Research question

Does higher authoritarianism predict a higher share of SSH scholarship that actively legitimizes or endorses the current political system, state authority, ruling party, or leadership in the author's country?

## Rationale

Self-censorship theories have largely focused on what researchers avoid; yet autocratic regimes do not merely suppress dissent — they actively incentivize, fund, and reward scholarship that validates state power and ideology. If career rewards flow disproportionately toward work that positively frames the regime, we should observe not just an absence of critical framing but a measurable elevation in the share of SSH output that endorses or legitimizes the political status quo. This is the active, productive dimension of scholarly self-censorship — distinct from silence — and it has received little systematic empirical attention.

## Theoretical mechanism

In autocracies, researchers face strong incentives to produce scholarship that is not merely inoffensive but affirmatively supportive of the regime: state-funded research programs, publication outlets controlled by party or state bodies, and promotion criteria that reward ideological alignment all channel scholarly output toward legitimating framings. At the individual level, anticipating these incentive structures, scholars may adopt legitimating frames proactively even without explicit instruction, as a rational career strategy. At the aggregate level, this produces a higher country-year share of SSH abstracts that characterize the political system, state authority, or leadership as effective, stable, or beneficial. The expected direction is negative: higher authoritarianism (lower v2x_libdem) is associated with a higher share of actively legitimating scholarship (share_legitimating).

## Theory family

ideological-alignment

## Estimand

The average within-country association between a country-year's level of liberal democracy (v2x_libdem) and the share of that country-year's SSH articles whose abstracts actively legitimize or endorse the current political system, state authority, ruling party, or leadership, conditional on country fixed effects, year fixed effects, and standard economic controls.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Name:** `share_legitimating`

**Construction:** For each abstract in the stratified sample, an LLM assigns one of two labels: LEGITIMATING or NON-LEGITIMATING. The outcome is the share of classified articles receiving the LEGITIMATING label, computed per country-year. This is a proportion bounded [0, 1].

The outcome is constructed from the `abstract` and `iso3` fields. The "own country" reference is the author's country identified by `iso3`.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Expected sign on v2x_libdem: negative (more autocracy → higher share_legitimating).

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model) or GPT-4o-mini as alternative.

**Binary label scheme:**

- **LEGITIMATING:** The abstract explicitly endorses, positively frames, or validates the current political system, state authority, ruling party, government institutions, or national leadership of [COUNTRY] as effective, beneficial, legitimate, stable, or necessary. This includes: praise of the political system's achievements or governance capacity; framing state intervention or authority as solving social problems; positive characterization of political stability under the current system; endorsement of ideological frameworks that justify the political order. The endorsement must be explicit and attributable to the article's own argument — not merely reported as a position held by others.

- **NON-LEGITIMATING:** All other abstracts. This includes: neutral or descriptive analysis of the political system; comparative work that includes [COUNTRY] without evaluating its political order positively; critical analysis; historical description; policy analysis without political endorsement; and any abstract that does not discuss domestic governance or politics at all. If there is any doubt, classify as NON-LEGITIMATING.

**Rationale for binary (not three-class) scheme:** The outcome of interest is the presence of active legitimation, which is a distinct and detectable act. A three-class scheme (legitimating / neutral / critical) would replicate Team 05's design rather than test the positive mirror. Binary classification also reduces ambiguity and improves inter-rater reliability in validation.

**Handling non-English abstracts:** The model classifies based on content regardless of language.

**Handling abstracts without regime reference:** If the abstract does not reference domestic politics, governance, or state authority, classify as NON-LEGITIMATING (the default).

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH abstracts that actively legitimize or endorse the current political system, state authority, or leadership, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Sampling strategy

Stratified random sample to manage API cost:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 articles (fewer if stratum is smaller)
- **Eligibility:** non-missing abstract with `nchar(abstract) >= 50`
- **Seed:** `set.seed(42)`
- **Target total N:** ~1,000,000 abstracts
- **Cost estimate:** ~$0.00052 per abstract (~$520 for 1M abstracts at Claude Haiku rates)
- **Hard cost ceiling:** $500 — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500

## Uniqueness check

**Most similar team:** Team 05 (critical domestic governance framing, LLM-based, topic-avoidance family).

**Why Team 24 is distinct:** Team 05 tests whether autocracy *suppresses* critical framing of own-country governance — the absence of negative evaluation. Team 24 tests whether autocracy *produces* positive/legitimating framing — the presence of active endorsement. These are not logical complements: a country could show low critical framing simply due to silence (researchers avoiding domestic governance entirely), without any elevation in legitimating content; conversely, a regime could reward legitimating scholarship while also tolerating some neutral descriptive work, producing both low critical framing AND high legitimating shares. Distinguishing suppression-through-silence from active production of legitimating content is theoretically important for understanding the mechanisms of autocratic influence over scholarship. Team 24 is the only team testing the active/positive dimension.

No other team in the orchestra tests the share of actively legitimating SSH scholarship as the primary outcome.
