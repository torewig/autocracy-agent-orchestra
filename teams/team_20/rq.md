# Team 20 — Research Question

## Research question

Do autocratic researchers receive a citation penalty specifically for politically sensitive articles, beyond any general autocracy citation disadvantage?

## Rationale

Prior work documents that researchers in autocracies publish less on sensitive topics (self-censorship in topic choice). Team 20 asks whether the work that does get published on sensitive topics from autocracies is further penalized in the citation market. This is analytically distinct from a general citation gap (Team 19): it tests whether the suppression of scientific visibility is most acute precisely where political sensitivity is highest. A significant interaction would indicate that autocracy shapes not only what is written but how much traction sensitive work gains.

## Theoretical mechanism

Autocratic researchers who publish on sensitive topics face two compounding pressures. First, to survive domestic review they likely hedge findings, soften conclusions, or frame arguments in ways that reduce political risk — producing work that is less intellectually bold and therefore less citable internationally. Second, international audiences may discount sensitive-topic articles from autocracies on credibility grounds, suspecting state-induced framing or data access constraints. Both channels predict the same direction: the autocracy penalty on citations is larger for politically sensitive articles than for non-sensitive articles. Formally, the interaction coefficient on `v2x_libdem * sensitive_flag` is expected to be positive (higher democracy score strengthens the citation advantage of sensitive-topic work), or equivalently the interaction `autocracy * sensitive_flag` is negative.

## Hypothesis

H1: The citation penalty associated with lower Liberal democracy levels will be larger for politically sensitive articles than for non-sensitive articles, as indicated by a positive coefficient on the v2x_libdem × sensitive_flag interaction term, after controlling for country fixed effects, year fixed effects, field fixed effects, log GDP per capita, and log population.

## Controls

- `log(e_gdppc)` and `log(e_wb_pop)`, merged at the country-year level
- Field fixed effects (or field-year fixed effects) are included as part of the model specification to account for differential citation norms across disciplines

## Theory family

`visibility-suppression`

## Estimand

The differential effect of autocracy on normalized citations for politically sensitive articles relative to non-sensitive articles — i.e., the interaction effect of `v2x_libdem` and `sensitive_flag` on `log1p(cite_ratio)` at the article level.

## Unit of analysis

Article (one observation per article; country-year and field controls included as covariates and fixed effects).

## Outcome variable

`log1p(cite_ratio)` where `cite_ratio = tot_cites / field_year_mean_cites`. Log-transforming the ratio normalizes across fields and cohorts with different citation norms. Articles with `field_year_mean_cites == 0` or missing are excluded.

## Key IV

`v2x_libdem` (continuous, 0–1; higher = more democratic) interacted with `sensitive_flag` (binary, 1 = article title or keywords match the Team 04 regime-sensitive keyword dictionary). The main effect of `v2x_libdem` controls for the general citation gap; the interaction isolates the additional sensitivity-specific penalty.

## Uniqueness check

Team 19 estimates the overall citation gap between autocracies and democracies (main effect only, country-year level). Team 20 is distinguished by: (1) article-level analysis rather than country-year; (2) the interaction term as the primary estimand; (3) the sensitive-topic subgroup as the mechanism through which autocracy suppresses visibility. No other team in the 01–19 range combines citation outcomes with a topic-sensitivity interaction at the article level.
