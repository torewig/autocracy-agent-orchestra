# Team 08 — Research Question

## Research question

Do researchers affiliated with more autocratic countries produce SSH abstracts with higher rates of epistemic hedging language — as measured by the frequency of hedging terms (may, might, seem, appear, suggest, perhaps, possibly, likely, probably, could, would) normalised by abstract word count — compared to researchers in more democratic countries?

## Rationale

Researchers working under autocratic constraints face institutional incentives not only to avoid politically sensitive topics outright, but also to hedge and soften any claims they do make, deflecting regime scrutiny by rendering findings provisional rather than declarative. If self-censorship operates through rhetorical defensiveness, the language of published abstracts in autocratic contexts should systematically exhibit more hedged epistemic commitments than comparable output from democratic settings. Epistemic hedging is detectable at scale without any external API using a closed dictionary of modal and evidential markers, making it a tractable and reproducible operationalization.

## Theoretical mechanism

Researchers in autocracies anticipate reputational and career sanctions — grant denial, employment loss, harassment, or legal exposure — for work that is interpreted as making confident, politically contestable claims. The self-protective response is not only to avoid sensitive topics but also to weaken the epistemic force of assertions, deploying modal hedges ("may suggest," "could appear," "might indicate") to signal that findings are tentative and non-threatening rather than authoritative and politically actionable. This defensive framing strategy should be most pronounced under more autocratic conditions, where the penalty for asserting inconvenient truths is highest. The expected direction of the main coefficient is negative: higher `v2x_libdem` (more democracy) is associated with lower hedging rates per abstract word, because democratic researchers face fewer incentives to soften their epistemic commitments rhetorically.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit higher mean epistemic hedging rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean hedging rate per abstract word, conditional on country and year fixed effects and controls for `log(e_gdppc)` (log GDP per capita) and `log(e_wb_pop)` (log population).

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article carrying a non-missing abstract in the corpus).

## Outcome variable

`hedge_rate_mean`: constructed at the article level as the count of hedging-term tokens divided by total word count of the abstract, then aggregated to the country-year mean. Formally:

1. For each article with a non-missing abstract, compute `hedge_count` = `str_count(tolower(abstract), "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would)\\b")`.
2. Compute `word_count` = `str_count(abstract, "\\w+")`.
3. Compute article-level `hedge_rate` = `hedge_count / word_count`. Articles with `word_count < 20` are excluded (too short for a stable rate).
4. Aggregate to country-year: `hedge_rate_mean` = arithmetic mean of `hedge_rate` across all qualifying articles in that country-year.

The denominator normalisation ensures that the outcome reflects the *intensity* of hedging language per word, not the absolute count, and is therefore comparable across abstracts of different lengths.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, 0–1, continuous; higher = more democratic).

## Uniqueness check

Performed. Teams 01–06 have rq.md files; teams 07, 09, and 11 do not yet exist.

- **Teams 01–04** (topic-avoidance family): all measure *what* topics or keywords appear — political content index, keyword entropy, sensitive disciplinary share, or regime-sensitive term prevalence in titles/keywords. None measure *how* claims are linguistically hedged.
- **Team 05** (LLM critical-framing classification): classifies whether an abstract critically evaluates domestic governance. This captures *framing direction*, not *epistemic hedging intensity*.
- **Team 06** (semantic diversity via embeddings): measures convergence in semantic content across abstracts. Conceptually related to framing but uses dense continuous embeddings rather than a targeted hedging dictionary.
- **Teams 09 and 11** (normative language; argumentative stance): not yet specified, but per the orchestra assignment these concern normative vocabulary and stance respectively — distinct in that normative language measures value-laden terminology (Team 09) and argumentative stance measures assertive/critical orientation (Team 11), while Team 08 specifically targets epistemic uncertainty markers that soften factual claims regardless of their political valence.

**Distinction summary:** Team 08 is the only team measuring the linguistic hedging of epistemic commitment as a defensive framing strategy, operationalised via a closed dictionary of modal and evidential hedging markers normalised by abstract length — requiring no API, no embedding, and no semantic classification.
