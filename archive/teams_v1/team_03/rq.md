# Team 03: Research Question

## Research question

Does the level of liberal democracy in a country predict the share of its social science and humanities output devoted to politically sensitive disciplines (political science, sociology, law, international relations, public administration)?

## Rationale

Autocratic regimes have strong incentives to suppress research that could challenge regime legitimacy or inform political opposition. If these incentives shape the composition of SSH knowledge production, we should observe systematic differences in what fields are studied — not just how much is published. This question directly addresses the "contents and direction" dimension of the overarching research question by examining whether autocracy distorts the disciplinary portfolio of SSH research toward politically safer fields.

## Theoretical mechanism

Autocratic rulers face a legitimacy dilemma: they benefit from a productive higher-education sector (for economic development and international prestige), but research in certain SSH disciplines — political science, sociology, law, international relations — can produce findings that challenge regime narratives, document repression, or provide intellectual resources for opposition movements. Regimes manage this tension through multiple channels: direct censorship and topic restrictions at universities, strategic allocation of research funding toward "safe" fields (economics, business, psychology), and the cultivation of self-censorship norms among researchers who anticipate career costs for working on sensitive topics. The net effect is a compositional shift: autocracies produce a lower share of their SSH output in politically sensitive fields and a higher share in fields that are either politically neutral or regime-compatible. The expected direction is positive — higher values of `v2x_libdem` (more democratic) should predict a higher share of output in politically sensitive disciplines.

## Theory family

`regime-field-distortion`

## Estimand

The average change in the share of a country's SSH articles published in politically sensitive fields associated with a one-unit increase in the liberal democracy index (`v2x_libdem`), holding constant country-level time-invariant characteristics and global time trends.

## Unit of analysis

Country-year (aggregated from article-country rows).

## Outcome variable

Constructed: `share_sensitive` — the proportion of a country-year's SSH articles (denominator: `n_articles_country_year`) whose `subject_primary` falls in a predefined set of politically sensitive fields (Political Science, International Relations, Sociology, Law, Public Administration, Social Issues, Ethnic Studies, Women's Studies).

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0-1).
