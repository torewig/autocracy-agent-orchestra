# Team 12 — Research Question

## Research question

Do researchers affiliated with more autocratic countries produce SSH abstracts that end with an explicit normative or policy conclusion — a recommendation, "should" claim, or call to action — at a lower rate than researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that researchers under autocratic constraints avoid signaling political engagement. Making an explicit normative or policy conclusion is one of the most legible signals of political engagement available in academic writing: it tells readers, censors, and employers not only what the researcher found, but what the researcher thinks should be done about it. Researchers who anticipate political scrutiny should therefore systematically strip normative conclusions from their published work, presenting findings descriptively even when the implications would warrant a recommendation. Because normative conclusions are concentrated in the final sentence(s) of an abstract — where authors conventionally summarize implications — this signal is detectable with high precision from abstract text using LLM classification.

## Theoretical mechanism

In autocracies, the act of recommending a policy or asserting that an outcome "should" change is potentially more dangerous than the underlying empirical finding, because it constitutes a public political position attributable to the researcher. Regime actors, institutional gatekeepers, and self-appointed informants scan academic output for precisely this kind of normative exposure; a researcher who concludes "the government should reform X" has staked a position that can be quoted, reported, and used to deny grants, block promotions, or trigger legal consequences. Anticipating these risks, researchers in autocratic settings learn to end their abstracts with factual summaries or statements of contribution rather than normative conclusions, substituting constructions such as "our findings suggest that X affects Y" for "policymakers should consider Z." This behavioral adaptation is selective and tractable: researchers do not need to suppress the entire research agenda — they need only to trim the final normative step from their public presentation. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher country-year share of abstracts that end with an explicit normative or policy conclusion.

## Theory family

`framing-neutrality`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH abstracts ending with an explicit normative or policy conclusion, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH abstracts classified as ending with an explicit normative or policy conclusion, conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least 5 sampled abstracts with non-missing text).

## Outcome variable

`share_normative_conclusion`: the proportion of classified abstracts in a country-year stratum that receive the label NORMATIVE (see LLM classification specification below), computed as:

```
share_normative_conclusion = (# abstracts labelled NORMATIVE) / (# abstracts successfully classified)
```

Construction steps:

1. Draw a stratified random sample from the corpus (see Sampling strategy).
2. For each sampled abstract, extract the last two sentences using a sentence-boundary regex or `str_extract(abstract, "[^.!?]+[.!?]\\s*[^.!?]+[.!?]?\\s*$")`.
3. Submit the extracted text to the LLM classifier (see prompt below); record the returned label.
4. Aggregate to country-year: `share_normative_conclusion = mean(label == "NORMATIVE", na.rm = TRUE)`.
5. Exclude country-years with fewer than 5 successfully classified abstracts.

The outcome is a proportion bounded [0, 1].

## LLM classification specification

**Model:** `claude-haiku-4-5` (Anthropic API, low-cost tier) or `claude-haiku-3-5` as fallback; alternatively `gpt-4o-mini` if Anthropic API is unavailable.

**Input:** The last two sentences of the abstract (extracted as described above). If sentence extraction fails or yields fewer than 20 characters, use the full abstract as the primary fallback.

**Full prompt (verbatim — use exactly this in the API call):**

```
You are a scientific text classifier. Read the following excerpt from the end of an academic abstract in the social sciences or humanities.

Classify this excerpt using EXACTLY ONE of the following labels:

NORMATIVE — The excerpt contains an explicit normative or policy conclusion: a recommendation, a "should" or "ought" claim, a call to action, a statement that a policy should be adopted or reformed, or a judgment that a particular outcome is desirable or undesirable. Examples: "Governments should invest in X", "We recommend that policymakers adopt Y", "These findings suggest that Z ought to be reformed", "Our results have implications for improving W".

DESCRIPTIVE — The excerpt does not make any normative or policy recommendation. It summarizes empirical findings, states the contribution of the paper, identifies limitations, suggests future research directions, or presents implications in factual terms without prescribing what should be done. Examples: "Our results show that X predicts Y", "This paper contributes to the literature on Z", "Future research should examine W" (a research-process suggestion, not a policy claim).

Output ONLY the label (NORMATIVE or DESCRIPTIVE). Do not add any explanation, punctuation, or other text.

Abstract excerpt:
{ABSTRACT_EXCERPT}
```

**Ambiguous cases:** If the excerpt is entirely missing, garbled, or in a non-standard script that yields no classifiable content, the API call should be skipped and the abstract flagged as `NA` (excluded from the denominator). The prompt instructs the model to output a single label with no explanation; any response that does not match "NORMATIVE" or "DESCRIPTIVE" exactly is treated as `NA`.

**Label scheme:**
- `NORMATIVE`: abstract concludes with an explicit normative or policy claim
- `DESCRIPTIVE`: abstract concludes descriptively, without normative prescription

**Note:** Research-process recommendations ("future research should examine X") are coded DESCRIPTIVE, not NORMATIVE, because they make no claim about what policymakers, governments, or society should do — they are methodological calls to action addressed to the scientific community. The prompt specifies this explicitly.

**Language:** LLMs handle multilingual input adequately for this binary distinction; no language restriction is applied.

## Sampling strategy

Classification is performed on a random sample sized to stay within a $500 API budget:

- **No per-stratum cap.** Draw a simple random sample (after deduplication and minimum-length filtering).
- **Minimum abstract length:** 50 characters; abstracts shorter than this are excluded before sampling
- **Estimated total N:** ~1,000,000–1,250,000 abstracts at Claude Haiku 3.5 pricing (~$0.80/million input tokens, ~500 tokens per abstract). The Analyst calculates the exact maximum N at current pricing before running.
- **Cost cap:** Halt and notify PI if actual cost exceeds $700.
- **Deduplication:** sample on unique abstracts (by `wos_id`) before API submission
- `set.seed(42)`

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 10 (based on Glob search), 11 (confirmed). Team 09 has no rq.md at the time of writing; per Team 11's uniqueness note, Team 09's domain is **normative language frequency** — a rate/count measure of evaluative and prescriptive vocabulary (e.g., "should", "ought") appearing anywhere in the abstract.

**Team 12 is distinct from Team 09 on three dimensions:**

1. **Operationalization:** Team 09 measures how *much* normative vocabulary appears throughout the abstract (a continuous rate, likely computed via regex count/word count). Team 12 classifies whether the abstract *concludes with* an explicit normative or policy recommendation — a binary classification of the abstract's rhetorical endpoint, not an aggregate vocabulary count. A paper can use high normative vocabulary in the body of the abstract while ending descriptively; Team 12 captures the strategic suppression of the normative endpoint specifically.

2. **Measurement method:** Team 09 uses a dictionary/regex approach (no API required). Team 12 uses LLM binary classification, which can distinguish a genuine policy recommendation from incidental normative vocabulary (e.g., "this is an important issue") or research-process recommendations ("future studies should examine X") that Team 09's regex would count but Team 12 does not.

3. **Theoretical mechanism:** Team 09's mechanism concerns general normative vocabulary avoidance throughout the text. Team 12's mechanism targets the *conclusory normative step* — the act of publicly prescribing what should be done — as a distinct act of political signaling that is concentrated in the final sentence(s) of an abstract and subject to its own strategic suppression logic.

**Distinction from Team 05 (LLM critical framing):** Team 05 classifies whether an abstract *critically examines domestic governance*; this is a topic/framing judgment about what the article is about. Team 12 classifies whether the abstract *ends with a normative prescription*; this is a rhetorical-endpoint judgment independent of topic. An article can critically examine governance without prescribing anything, and can prescribe policy in a purely technical domain.

**Distinction from Teams 08 and 11:** Team 08 measures epistemic hedging (softening of truth claims via modal verbs). Team 11 measures first-person argumentative stance phrases ("we argue", "we show"). Neither captures the presence or absence of a normative conclusion in the abstract's final sentences.
