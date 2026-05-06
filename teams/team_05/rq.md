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
