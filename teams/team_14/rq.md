# Team 14 — Research Question

## Research question

Do researchers affiliated with more autocratic countries co-author SSH publications with a smaller number of distinct co-author countries, compared to researchers from more democratic countries?

## Rationale

International collaboration in research is not politically neutral: maintaining professional contacts abroad, exchanging manuscripts across borders, and attending international conferences all expose researchers to cross-border oversight and potential regime scrutiny. In autocratic settings, these activities carry formal and informal risks — including surveillance of foreign contacts, career penalties for politically inconvenient international associations, and restricted travel. If these constraints suppress researchers' capacity or willingness to engage in broad international collaboration, the most direct observable implication is a reduction in the raw breadth of co-author country coverage: autocratic country-years should produce articles that draw co-authors from fewer distinct countries than comparable output from democratic settings.

## Theoretical mechanism

Autocratic regimes exercise control over researchers' international networks through multiple overlapping channels: exit visa requirements that limit conference attendance and research visits, formal registration or permit requirements for foreign-funded or foreign-linked research, and informal norms that stigmatize "entanglement" with foreign institutions, particularly those from liberal democracies. Researchers respond by self-censoring the range of their international collaborative contacts — concentrating links on a small number of politically safe partners (often neighbours or politically aligned states) and foregoing the wide-ranging international collaboration that characterises researchers in democratic contexts. At the country-year level, this produces a measurable contraction in the mean number of distinct co-author countries per article. The expected direction of the main coefficient is positive: higher `v2x_libdem` → higher mean number of distinct co-author countries per article.

## Theory family

`collaboration-constraint`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower mean number of distinct co-author countries per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean count of distinct co-author countries per article (for articles with at least one author affiliated with the focal country), conditional on country and year fixed effects and controls `log(e_gdppc)` and `log(e_wb_pop)`.

## Unit of analysis

Country-year (one observation per focal iso3 × year combination, restricted to country-years with at least 5 SSH articles in the corpus).

## Outcome variable

`mean_n_coauthor_countries`: constructed in two steps.

1. **Article level:** For each article (wos_id) in which the focal country (iso3_focal) appears, count the number of *distinct* iso3 values present among all author-country rows sharing that wos_id. This count equals 1 for single-country articles (the focal country alone) and > 1 for internationally co-authored articles.
2. **Country-year level:** Average the article-level distinct-country count across all articles where iso3_focal appears in focal year Y: `mean_n_coauthor_countries = mean(n_distinct_iso3)`, computed over all wos_ids associated with iso3_focal in year Y.

The outcome is a continuous count variable with a lower bound of 1 (articles can have no fewer than the focal country itself). Articles with missing iso3 values are excluded.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 11, and 15 at time of writing; no files found for teams 09–10, 12–13, or 16.

Team 14 occupies the `collaboration-constraint` sub-family alongside Team 15 and (per brief) Team 16. It is distinct from both:

- **Versus Team 15 (democratic co-authorship share):** Team 15 asks whether autocracies specifically avoid co-authors from liberal democracies (v2x_libdem > 0.5), measuring the ideological valence of co-author countries. Team 14 asks a prior, simpler question: does autocracy suppress the sheer number of distinct countries from which co-authors are drawn, regardless of those countries' regime type? The outcomes are conceptually orthogonal — a country could collaborate with many autocratic countries (high breadth, low democratic share) or concentrate links on a few liberal democracies (low breadth, high democratic share).
- **Versus Team 16 (domestic-only authorship):** Per the brief, Team 16 measures the share of articles with no international co-authors at all (binary domestic-only indicator). Team 14 measures the continuous spread of international co-authorship — not whether it occurs at all, but across how many distinct countries it extends.
- **Versus Teams 01–08, 11 (topic-avoidance and framing-neutrality families):** All of those teams measure textual content of articles (vocabulary, topics, hedging, stance, discipline). Team 14 measures co-authorship network structure — a relational, metadata-level outcome requiring no text analysis and no external API.
