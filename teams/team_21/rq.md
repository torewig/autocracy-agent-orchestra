# Team 21 — Research Question (Redesign, 2026-05-06)

## Research question

Does autocracy predict a lower share of SSH articles that receive at least one citation, measured as the proportion of ever-cited articles within a country-year?

## Rationale

A substantial fraction of published SSH articles — roughly 29% in this corpus — are never cited at all. If self-censorship pushes researchers in autocracies toward safe, incremental, and domestically oriented work, these articles should be less likely to attract any international follow-up, not merely fewer citations on average. The share of ever-cited articles captures this participation threshold: it distinguishes countries where publication reliably enters the citation economy from those where a large share of output is invisible to the broader scholarly community. This is conceptually distinct from mean citation level (Team 19) or citation inequality (Team 22): it asks whether autocracy raises the probability that a piece of scholarship is completely ignored.

## Theoretical mechanism

Researchers in autocracies face strong incentives to avoid politically sensitive topics, controversial methods, and critical framings that could attract state scrutiny or sanction. This risk calculus produces a portfolio of published work biased toward safe, formulaic, and locally relevant scholarship. Such work — compliant rather than intellectually provocative — is less likely to engage the questions driving international scholarly debate, and therefore less likely to receive even a single citation from researchers elsewhere. The causal chain runs from regime type to self-censorship in topic and framing choice, to production of work with limited international relevance, to a lower probability of any citation uptake. The expected direction is positive: higher `v2x_libdem` (more democratic) is associated with a higher share of ever-cited articles within a country-year, because political freedom expands the intellectual space available to researchers and increases the probability that any given article generates at least one scholarly response.

## Theory family

`visibility-suppression`

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH articles that receive at least one citation within a country-year, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year proportion of articles with `tot_cites >= 1`, conditional on country and year fixed effects and controls for `log(e_gdppc)` and `log(e_wb_pop)`. Country-years with fewer than 10 distinct articles are excluded to ensure stable proportions.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least 10 distinct articles after deduplication by `wos_id`).

## Outcome variable

`prop_ever_cited`: the proportion of distinct articles from a given country-year that have `tot_cites >= 1`. Constructed by (1) deduplicating articles at the `wos_id` level to prevent multi-author rows from inflating cell size, (2) computing a binary `ever_cited = as.integer(tot_cites >= 1)` for each article, then (3) taking the mean of `ever_cited` within each `iso3` × `year` cell. Bounded [0, 1]; higher values indicate a larger share of the country's SSH output enters the citation economy.

## Key independent variable

`v2x_libdem` (continuous, 0–1; higher = more democratic). Matched to each country-year observation from the V-DEM data already merged in the corpus.

## Controls

- `log(e_gdppc)` — log GDP per capita; controls for overall research infrastructure and resources
- `log(e_wb_pop)` — log population; controls for country size and potential domestic citation market

## Robustness checks

- **RC1 (sample restriction):** Repeat the main model restricting to 1990–2023 to avoid sparse pre-1990 coverage and any structural break in WOS coverage.
- **RC2 (alternative regime measure):** Replace `v2x_libdem` with `lied_binary` (0 = autocracy, 1 = democracy) to assess whether results hold under a dichotomous regime classification.

## Uniqueness check

Most similar teams: Team 19 and Team 22.

- **Team 19** estimates the effect of `v2x_libdem` on the country-year *mean* of log-normalized citation ratios — a test of average citation level, not the probability of receiving any citation. Team 21 uses a distinct outcome (the share of articles with at least one citation) that captures the lower bound of citation participation rather than central tendency.
- **Team 22** estimates the effect of `v2x_libdem` on the Gini coefficient of `tot_cites` within country-years — a distributional inequality measure. Team 21's outcome (the zero-citation margin) is conceptually and statistically separate from within-distribution inequality.
- **Team 20** operates at the article level with a topic-sensitivity interaction. Team 21 uses the country-year as the unit with a simple main effect.

No existing team uses the share of ever-cited articles as the outcome. Team 21 is the only team asking whether autocracy raises the probability that a piece of SSH scholarship is entirely absent from the citation record.
