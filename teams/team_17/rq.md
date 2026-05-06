# Team 17 — Research Question

## Research question

Do SSH researchers affiliated with more autocratic countries publish articles with fewer authors on average, at the country-year level, compared to researchers from more democratic countries?

## Rationale

Collaborative research requires multiple people to share ideas, access data, and jointly produce work that may attract political scrutiny. In autocratic settings, adding collaborators multiplies the risk of exposure: each additional team member is a potential informant, a source of ideological conflict, or a witness to politically sensitive discussions. Researchers anticipating these risks have an incentive to work alone or in smaller groups, reducing the mean number of authors per article. Team size is therefore a plausible behavioral footprint of self-censorship operating through collaboration avoidance.

## Theoretical mechanism

In autocracies, regime agents, institutional supervisors, and colleagues may monitor research for politically problematic content and report infractions. Each collaborator added to a project increases the number of people with knowledge of the work-in-progress, widening the circle of potential informants and the surface area for surveillance. Researchers rationally minimize this risk by working in smaller teams, avoiding the coordination costs and exposure that come with larger groups. Institutional resource constraints and disciplinary norms also shape team size, so any autocracy effect is expected to be modest and is a weaker test of the self-censorship mechanism than direct measures of collaboration structure (e.g., avoidance of international or democratic partners). The expected direction is positive: higher `v2x_libdem` → higher mean author count per article, because democratic environments reduce the personal risk of collaborative exposure.

**Important limitation:** Team size is heavily determined by disciplinary norms (e.g., natural sciences vs. humanities) and resource availability (lab infrastructure, grant funding). Because the corpus is restricted to SSH articles, disciplinary confounding is partially attenuated, but variation in field mix across country-years must still be controlled. This outcome is therefore a noisy proxy for the self-censorship mechanism and should be interpreted cautiously alongside direct collaboration-structure tests (Teams 14–16).

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower mean number of authors per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean number of authors per article, conditional on country and year fixed effects, discipline (subject field) composition, and standard economic controls.

## Unit of analysis

Country-year

## Outcome variable

`mean_n_authors`: the mean number of authors per article, aggregated to the country-year level. Constructed by (1) computing `n_authors` at the article level — either directly from a pre-existing column or, if absent, by counting the number of distinct author entries per `wos_id` — and (2) taking the unweighted mean across all articles attributed to each country-year. Country-years with fewer than 10 article-author rows are excluded.

Note: The corpus is structured with one row per article-author-country affiliation. If `n_authors` does not exist as a column, it must be derived as `n_distinct(author_id)` or equivalent per `wos_id` before aggregation.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Existing rq.md files cover Teams 01, 02, 03, 04, 05, 06, and 11. Brief files reviewed for Teams 14, 15, and 16 (the other `collaboration-constraint` teams).

Team 17 is distinct from all prior teams on the following grounds:

- **Versus Teams 14–16 (collaboration-constraint sub-family):** Team 14 measures the number of distinct co-author *countries* per article (geographic breadth of collaboration). Team 15 measures whether any co-author country is a liberal democracy (v2x_libdem > 0.5). Team 16 measures the share of articles that are purely domestic (all author countries identical). All three operationalize the *structure and origin* of collaborators. Team 17 measures the *total number of authors* regardless of their national origin — a distinct quantity that can vary independently: a purely domestic article may have two authors or twenty.
- **Versus Teams 01–06 and 11 (topic-avoidance and framing-neutrality sub-families):** These teams measure what is written (abstract content, political keywords, disciplinary field, argumentative stance) rather than who writes it or how many do.
- No other team tests whether autocracy predicts a lower mean author count per article at the country-year level.
