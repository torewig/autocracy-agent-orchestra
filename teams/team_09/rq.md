# Team 09 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use normative and prescriptive language — terms such as "rights," "justice," "freedom," and "accountability" — at a lower rate in their SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that scholars in autocracies strategically minimise language that could be read as a political or moral claim against the regime. Normative vocabulary — terms that assert what ought to be or that invoke universal values such as human rights, justice, and freedom — is especially exposed because it signals evaluative intent that autocratic authorities may interpret as implicit criticism. If this mechanism operates, we should observe that the density of normative terms per abstract word is systematically lower in more autocratic country-years, even after controlling for economic development, population, and stable country and year characteristics.

## Theoretical mechanism

Researchers operating under authoritarian rule face credible career risks — dismissal, loss of funding, publication bans, or in extreme cases legal consequences — if their work is perceived as making normative claims against the state. Normative vocabulary (words like "should," "ought," "rights," "justice," "freedom," "accountability," "dignity," "equality," "fairness," "liberty") is particularly hazardous because it frames social and political arrangements as unjust or illegitimate, even when embedded in otherwise descriptive academic prose. Anticipating this risk, rational authors self-censor by omitting or replacing normative terms with descriptive substitutes — writing, for example, "the state controls" rather than "the state should be accountable." This avoidance is distinct from epistemic hedging (avoidance of uncertainty language) and from topic avoidance (choosing not to study democracy or rights at all): an author may study political institutions in entirely empirical terms while systematically stripping normative framings. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher normative term rate per abstract word.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit lower mean normative language rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean normative term rate per abstract word, conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least one SSH article with a non-missing abstract).

## Outcome variable

`mean_norm_rate`: constructed as follows.

1. For each article with a non-missing abstract, compute:
   - `norm_count` = count of case-insensitive whole-word matches in the abstract for the normative term dictionary (see analysis_plan.md for the full dictionary).
   - `word_count` = total word count of the abstract (all whitespace-delimited tokens).
   - `norm_rate` = `norm_count / word_count` (set to NA if `word_count == 0`).
2. Aggregate to country-year: `mean_norm_rate = mean(norm_rate, na.rm = TRUE)` across all articles from the same `iso3` × `year` cell.

The outcome is a continuous variable bounded in [0, 1]; typical values are in the range 0.005–0.030 based on exploratory analysis of the specified dictionary.

**Normative term dictionary (core set):**

| Cluster | Terms |
|---|---|
| Obligation / prescription | should, ought |
| Rights | rights |
| Justice | justice, fairness |
| Freedom / liberty | freedom, liberty |
| Equality / dignity | equality, dignity |
| Accountability | accountability |
| Democracy (normative use) | democracy |

Full regex patterns (word-boundary anchored, case-insensitive) are defined in `analysis_plan.md`.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic). Use as the primary regime measure.

## Uniqueness check

Performed. Existing rq.md files inspected: teams 01–07 (team 08 has no rq.md at time of writing).

**Distinction from most similar teams:**

- **Team 01 (PCI score on abstracts):** Team 01 constructs a Political-Content Index measuring the share of abstract tokens matching a broad multi-cluster dictionary of politically sensitive topic terms (democracy, repression, governance, protest, elections). Team 09 measures normative/prescriptive language — terms that assert value judgments or obligations — not political topic terms. A paper about electoral autocracy that uses entirely empirical, descriptive language scores high on Team 01's PCI but zero on Team 09's normative rate; conversely, an economics paper arguing what policy "should" achieve scores zero on PCI but positive on Team 09.
- **Team 04 (regime-sensitive keywords in title/keywords):** Team 04 detects politically sensitive topic vocabulary in title and author-keyword fields; Team 09 measures evaluative-prescriptive vocabulary in the abstract body. Distinct text field, distinct vocabulary, distinct theoretical mechanism (framing avoidance vs. topic avoidance).
- **Team 05 (LLM classification of critical domestic framing):** Team 05 classifies whether abstracts critically evaluate own-country governance — a semantic judgment about the target and stance of critique. Team 09 uses a transparent dictionary count with no LLM and does not require a domestic-country reference.
- **Team 06 (semantic diversity via embeddings):** Team 06 measures holistic semantic convergence via cosine distance of dense embeddings; Team 09 measures the surface-form rate of a specific vocabulary class.
- **Team 08 (epistemic hedging — uncertainty language):** Team 08's domain (assigned but not yet filed) is uncertainty/hedging language (e.g., "may," "might," "perhaps," "appears to") — words that soften epistemic claims. Team 09 targets normative/prescriptive language — words that assert value claims or obligations. These are conceptually orthogonal dimensions: a sentence can hedge normatively ("these policies may undermine rights") or state empirical claims without hedging ("the policy reduced freedom"). The expected direction under self-censorship theory is also different: epistemic hedging could plausibly increase or decrease under autocracy depending on the mechanism invoked, while normative avoidance has a clear downward prediction.
