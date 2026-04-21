# Team 04: Research Question

## Research question

Does autocracy reduce the prevalence of regime-sensitive research topics in a country's social science and humanities output?

## Rationale

Autocratic constraints on academic freedom need not operate only at the level of entire disciplines. Even where politically relevant fields like political science and sociology exist, scholars may strategically avoid topics that could attract state scrutiny — studying public administration rather than democratization, urbanization rather than protest movements. If self-censorship is a primary mechanism through which autocracy shapes SSH knowledge, it should be detectable as a systematic reduction in the share of articles engaging with regime-sensitive topics such as democracy, human rights, corruption, and political contention.

## Theoretical mechanism

Scholars in autocracies face career risks — denied funding, blocked publication, surveillance, job loss — for producing research that challenges state narratives or exposes governance failures. These risks are imposed by political appointees in university leadership, state-controlled funding bodies, and censorship of domestic outlets. Scholars respond by strategically selecting "safe" research topics, a process of anticipatory self-censorship. This is reinforced by editorial gatekeeping at domestic journals and by international co-authors who may steer collaborations toward less politically fraught topics. The expected direction is that lower levels of liberal democracy are associated with a lower share of SSH articles containing regime-sensitive keywords (democracy, human rights, corruption, protest, etc.), even after conditioning on the discipline in which the article is published.

## Theory family

`topical-self-censorship`

## Estimand

The average effect of a one-unit change in the liberal democracy index (`v2x_libdem`) on the share of a country-year's SSH articles that contain at least one regime-sensitive keyword, conditional on country and year fixed effects.

## Unit of analysis

Country-year (aggregated from article-country rows).

## Outcome variable

Constructed: share of articles per country-year in which `keywords` or `keywords_plus` contains at least one term from a predefined regime-sensitive dictionary. Dictionary terms include: democracy, democratization, human rights, civil liberties, press freedom, censorship, corruption, protest, social movement, revolution, political opposition, dissent, repression, political violence, regime change, election fraud, civil society.

## Key independent variable

`v2x_libdem`
