# Team 19 — Research Question

## Research question
Do SSH articles produced in more autocratic countries receive lower normalized citation impact — measured as the field-year adjusted citation ratio — than articles from more democratic countries, after conditioning on country and year fixed effects and standard economic controls?

## Rationale
Citations are a primary indicator of scholarly influence: a paper that attracts engagement from the wider research community accumulates citations, while work that fails to resonate does not. If self-censorship systematically steers researchers in autocracies toward safer, less intellectually provocative topics and framings, the resulting work is less likely to stimulate debate and scholarly follow-up. Reduced citation impact is therefore a downstream visibility consequence of self-censorship, distinct from questions of publication volume or co-authorship patterns.

## Theoretical mechanism
Researchers in autocracies face institutional incentives to avoid politically sensitive topics, controversial methods, and critical framings that could attract state scrutiny or sanction. This risk calculus produces a portfolio of published work that is systematically biased toward safe, incremental, and domestically oriented scholarship. Such work is less likely to engage the questions and controversies driving international scholarly debate, and therefore less likely to be cited by researchers elsewhere. A second pathway runs through collaboration: self-censored scholars are less likely to form international co-authorship ties, which reduces the global dissemination and uptake of their work. The expected direction is positive — higher `v2x_libdem` (more democratic) is associated with a higher normalized citation ratio, because political freedom removes incentives for the kind of intellectual caution that suppresses citation uptake.

## Theory family
visibility-suppression

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean of log1p(cite_ratio), where cite_ratio = tot_cites / field_year_mean_cites, conditional on country and year fixed effects and controls for log GDP per capita and log population.

## Unit of analysis
Country-year

## Outcome variable
`log_cite_ratio_mean`: constructed by (1) computing `cite_ratio = tot_cites / field_year_mean_cites` for each article, (2) applying the log1p transformation to handle zero-citation articles and right-skew, then (3) averaging log1p(cite_ratio) across all articles for each country-year. Country-years with fewer than 10 articles are dropped to ensure stable means.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit a lower mean normalized citation ratio for SSH articles, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls
- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. I scanned rq.md files for teams 01–18 (files found for teams 01–12, 15). No existing team uses `visibility-suppression` as its theory family or employs normalized citation impact as its outcome. All scanned teams fall in either `topic-avoidance` or related families and use outcomes based on abstract text, keyword distributions, disciplinary composition, or publication volume. Teams 20–22 (per project brief) also use citation data but with different designs: Team 20 tests citation gap by topic sensitivity, Team 21 tests a citation × co-authorship interaction, Team 22 tests Gini concentration of citations. Team 19 is the baseline test — does autocracy reduce normalized citation impact overall, unconditional on topic or collaborator type?
