# Team 15 — Research Question

## Research question

Do researchers in more autocratic countries co-author a lower share of their SSH publications with researchers from liberal democracies (countries with v2x_libdem > 0.5 in the co-author's country-year), compared to researchers in more democratic countries?

## Rationale

Collaboration with scholars in liberal democracies is not politically neutral for researchers in autocracies: democratic co-authors operate under editorial and professional norms that may encourage politically sensitive research agendas, and democratic-country affiliations may trigger regime suspicion toward the collaboration and its outputs. If the self-censorship mechanism extends to strategic avoidance of potentially risky collaborative relationships, we should observe that researchers in more autocratic settings systematically under-represent liberal democracies in their co-authorship networks. This prediction is more theoretically specific than a general reduction in international collaboration: it targets the ideological valence of co-author countries, not collaboration volume per se.

## Theoretical mechanism

Researchers in autocracies face institutional surveillance of their professional networks, and collaboration with scholars from liberal democracies may carry reputational or political costs — such as association with foreign "hostile" research agendas, exposure to cross-border academic freedom norms, or heightened scrutiny from university administrators and state security actors. Anticipating these risks, scholars in autocratic settings self-censor by selectively avoiding or limiting co-authorship links with researchers in liberal democracies, while more readily collaborating with authors from non-democratic or politically aligned countries. The expected direction is positive: higher `v2x_libdem` of the focal country is associated with a higher share of articles co-authored with at least one researcher from a country with `v2x_libdem > 0.5`, because democratic environments reduce the political costs of connecting to liberal-democratic scholarly networks.

## Theory family

`collaboration-constraint`

## Hypothesis

H1: Countries with lower Liberal democracy levels will have a lower share of SSH articles co-authored with researchers from liberal democracies (v2x_libdem > 0.5), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

- `log(e_gdppc)`: log GDP per capita
- `log(e_wb_pop)`: log population

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` (focal country) on the country-year share of SSH articles that include at least one co-author from a country with `v2x_libdem > 0.5` in the relevant year, conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per focal iso3 × year combination, restricted to country-years with at least 5 SSH articles in the corpus).

## Outcome variable

`share_dem_coauthor`: the proportion of distinct articles by authors affiliated with a focal country-year that have at least one co-author row (different iso3, same wos_id) where that co-author country's `v2x_libdem` in the same year exceeds 0.5. Formally:

1. For each article (wos_id) in the corpus, collect all author-country rows sharing that wos_id.
2. For a given focal country (iso3_focal), an article is a "democratic co-author article" if (a) iso3_focal appears among that article's rows and (b) at least one other iso3 in the same article has v2x_libdem > 0.5 in that article's year.
3. Articles where iso3_focal is the only author country (no co-authors at all) are retained as zeros in the numerator (they do not have a democratic co-author), ensuring the denominator equals the full output of the focal country-year.
4. Aggregate to country-year: `share_dem_coauthor = n_articles_with_dem_coauthor / n_articles_country_year`.

The outcome is a proportion bounded [0, 1].

## Key independent variable

`v2x_libdem` of the focal author country (continuous, 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08 and 11 at time of writing; no rq.md files found for teams 09–10 and 12–14.

The team most similar in domain is Team 14, which (per the brief) measures the raw count or share of co-author countries generally. Team 15 is distinct in the following respects:

- **Versus Team 14 (raw co-author country count / general international collaboration):** Team 14 tests whether autocracy suppresses the breadth of the co-authorship network regardless of co-author regime type. Team 15 tests a more theoretically specific prediction: that autocratic researchers selectively avoid collaboration with authors from *liberal democracies* specifically, because these connections carry distinct political costs. The outcome is not the overall collaboration rate but the ideological composition of the co-author network.
- **Versus Teams 01–04 (topic-avoidance family):** Those teams measure what topics, keywords, or disciplines researchers choose; Team 15 measures who they collaborate with — a structural network outcome, not a textual content outcome.
- **Versus Teams 05–06 (LLM classification, semantic diversity):** Both use text analysis of abstract content; Team 15 requires no text analysis and no external API — only a cross-join on the article × country row structure using existing `v2x_libdem` values.
- **Versus Teams 08 and 11 (hedging, argumentative stance):** Both measure rhetorical features of writing; Team 15 measures collaborative network structure.
