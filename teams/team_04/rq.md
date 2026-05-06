# Team 04 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish SSH articles that use regime-sensitive terms — specifically words denoting democracy, human rights, corruption, and political protest — at lower rates in their titles and author-supplied keywords, compared to researchers from more democratic countries?

## Hypothesis

H1: Countries with lower Liberal democracy levels will have a lower share of SSH articles containing regime-sensitive terms in titles, author keywords, and abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Rationale

Self-censorship theory predicts that researchers in autocracies avoid topics that could draw state scrutiny or threaten their careers. Regime-sensitive concepts such as democracy, human rights, and corruption are precisely the topics most likely to alarm authoritarian authorities, making them high-cost subjects for scholars in non-democratic settings. The explicit topic labels that researchers attach to their work — titles and author keywords — are the most visible signals of what a paper is "about," and are therefore the most plausible site of anticipatory avoidance behavior.

## Theoretical mechanism

Researchers in autocracies operate under surveillance and face credible risks — loss of funding, dismissal, harassment, or detention — if they are perceived as challenging the regime. This generates incentives to avoid producing and publicly labeling research using terms that are politically dangerous in their national context. The behavioral response is anticipatory self-censorship: scholars steer clear of regime-sensitive topics at the point of topic selection, and avoid explicitly flagging sensitive content in the most visible metadata fields (title and keywords) even when related work is conducted. Because these incentives scale with the degree of autocratic repression, we expect the share of articles bearing regime-sensitive labels to be monotonically decreasing in the level of autocracy (i.e., decreasing in `v2x_libdem`): the less democratic the country, the lower the prevalence of regime-sensitive keywords.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles that contain at least one match from the regime-sensitive keyword dictionary in the article title, author-supplied keywords (`keywords` field), or abstract.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_regime_sensitive`: the proportion of distinct articles from a given country-year for which at least one term in the regime-sensitive dictionary matches in the `title`, `keywords`, OR `abstract` fields (case-insensitive regex). Constructed as:

    share_regime_sensitive = (# distinct ut with at least one match in title OR keywords OR abstract) / n_articles_country_year

**Regime-sensitive keyword dictionary (see analysis_plan.md for full regex patterns):**

| Term cluster | Representative terms |
|---|---|
| Democracy / democratization | democrat, democratiz, democratis |
| Human rights | human rights, civil rights, civil liberties |
| Corruption / accountability | corruption, corrupt, bribery, kleptocracy |
| Protest / contention | protest, demonstration, uprising, riot, rebellion, civil unrest |
| Political repression | repression, repressive, censorship, censor, political prisoner |
| Authoritarianism | authoritarian, autocra, dictatorship |
| Political freedom | political freedom, political liberty, free speech, freedom of expression, freedom of press |
| Electoral manipulation | election fraud, electoral fraud, vote rigging, vote buying |
| Dissent / opposition | dissent, dissident, political opposition, regime critic |

## Key independent variable

`v2x_libdem` (Liberal Democracy Index, 0–1, continuous; higher = more democratic)

## Controls

`log(e_gdppc)` (log GDP per capita, V-Dem/World Bank) and `log(e_wb_pop)` (log total population). Both included in all primary and robustness specifications alongside country and year fixed effects.

## Uniqueness check

Performed. Most similar existing team: none (no other rq.md files exist at time of writing; closest by design would be Team 01).
Distinction: Team 01 constructs a Political Content Index (PCI) score from abstracts using a broader keyword list; Team 04 uses a curated dictionary of specifically regime-sensitive terms matched on title, author keywords, AND abstract, and measures prevalence as a country-year share rather than a scored index.
