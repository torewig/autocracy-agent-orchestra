# Team 11 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use first-person argumentative stance phrases — such as "we argue," "I argue," "we show," or "we demonstrate" — at lower rates in SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Making an explicit attributed claim in academic writing ("we argue that X") exposes the author as the source of an assertion, increasing personal accountability for the content of a paper. In autocratic settings, where the costs of being identified as the author of politically problematic arguments are non-trivial, researchers have an incentive to avoid constructions that anchor claims directly to their own authorial voice. An observable symptom of this risk-management strategy is a reduced rate of first-person argumentative stance phrases in published abstracts, as researchers substitute passive, impersonal, or institutional constructions ("it is found that," "the results suggest," "this paper examines") that diffuse accountability.

## Theoretical mechanism

In autocracies, the personal attribution of intellectual claims generates career risk: a researcher who writes "we argue that the state is responsible for X" has publicly staked a position that can be scrutinized, quoted, and used against them by regime actors, employers, or colleagues acting as informants. Researchers anticipate this risk and learn — through direct experience or social observation — to write in ways that reduce personal exposure, which includes replacing first-person argumentative constructions with impersonal or passive voice equivalents that are harder to attribute to the author's own convictions. This defensive rhetorical strategy would be practiced selectively and rationally: researchers in sensitive fields or under more repressive regimes would depress their argumentative stance rate more than researchers in safe contexts. The expected direction is positive: higher `v2x_libdem` → higher mean argumentative-stance phrase rate per abstract word, because democratic environments reduce the cost of explicit personal attribution.

## Hypothesis

**H1:** Countries with lower Liberal democracy levels will exhibit lower mean rates of first-person argumentative stance phrases in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean argumentative-stance phrase rate (stance phrase count per abstract word), conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis

Country-year

## Outcome variable

`stance_rate_mean`: constructed at the article level as the count of matches to the stance-phrase regex divided by the abstract word count (producing a rate bounded [0, ∞)); then averaged across all articles with non-missing abstracts within each country-year. Construction steps:

1. Lowercase the `abstract` field.
2. Count matches of the following regex pattern (all boundaries are word-level):
   `\b(we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim)\b`
3. Count abstract words as the number of whitespace-delimited tokens (`\w+` matches).
4. Compute `stance_rate = n_matches / n_words` for each article. Articles with fewer than 20 words or missing abstracts are excluded.
5. Aggregate to country-year: `stance_rate_mean = mean(stance_rate, na.rm = TRUE)`, restricted to country-years with at least 5 qualifying articles.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. rq.md files exist for teams 01–06; teams 07–10 have no rq.md files at time of writing. The brief for this project specifies that Team 08 covers **hedging** (epistemic uncertainty softeners such as "may," "might," "possibly") and Team 09 covers **normative language** (evaluative and prescriptive phrasing).

Team 11 is distinct on all three dimensions:

- **Versus Teams 01, 02, 04 (topic-avoidance family):** Those teams measure what researchers write *about* (political keywords, sensitive topics, disciplinary field); Team 11 measures *how* researchers write — the rhetorical stance adopted toward their own claims, not the content of those claims.
- **Versus Team 08 (hedging):** Hedging measures epistemic diffidence — the softening of truth claims through modal verbs and uncertainty markers. Team 11 measures argumentative assertion — the explicit attribution of a conclusion to the authors' own reasoning. These are complementary and can move in the same or opposite directions; they tap different self-censorship mechanisms (reducing exposure to uncertainty vs. reducing personal accountability for claims).
- **Versus Team 09 (normative language):** Normative language covers evaluative judgment ("should," "ought," "it is important that"), which is thematically distinct from the first-person argumentative framing targeted here. A paper can be normative without using first-person assertions, and vice versa.
- **No overlap with Teams 03, 05, 06:** These measure disciplinary composition, LLM-classified governance critique, and semantic diversity of embeddings, respectively — all structurally different from a regex count of first-person stance phrases.
