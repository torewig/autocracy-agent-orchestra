# Team 02: Research Question

## Research question

Does autocracy reduce the topical diversity of SSH research, producing a narrower and more conformist set of research topics within a country's scientific output?

## Rationale

If autocratic constraints affect not only *how much* is published but *what* is studied, one observable implication is reduced topical diversity: a narrower range of research questions pursued within a country's SSH output. This captures intellectual conformity — a hallmark of constrained knowledge production — and is measurable through the diversity of author-supplied keywords at the country-year level. Unlike field-level composition measures, keyword diversity captures within-field narrowing: even within economics or psychology, researchers in autocracies may cluster on a smaller set of approved topics.

## Theoretical mechanism

Autocratic regimes constrain the range of permissible inquiry through both direct censorship and anticipatory self-censorship. Researchers facing political constraints avoid controversial, novel, or boundary-pushing topics and cluster around a smaller set of "safe" themes — those unlikely to provoke official scrutiny. University administrators and funding bodies in autocracies reinforce this by channeling resources toward regime-approved research agendas. The result is topical convergence: many researchers working on similar questions rather than the wider exploratory diversity typical of unconstrained academic environments. The expected direction is positive: higher `v2x_libdem` → greater keyword diversity.

## Theory family

`intellectual-conformity`

## Estimand

The average within-country effect of a one-unit increase in the liberal democracy index (`v2x_libdem`) on the topical diversity of SSH research, measured as the number of distinct author-supplied keywords per article in a country-year. Country and year fixed effects remove stable country-level specialization and global trends, but cannot rule out all time-varying confounders.

## Unit of analysis

Country-year (aggregated from article-country rows).

## Outcome variable

Constructed: `keywords_per_article` — total distinct author-supplied keywords (from `keywords`, split on semicolons, lowercased, trimmed) in a country-year, divided by the number of articles with non-missing `keywords` in that country-year. Higher values indicate broader topical diversity.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0-1).
