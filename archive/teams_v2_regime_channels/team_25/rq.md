# Team 25 — Research Question

## Research question

Does the effect of autocracy on the country-year share of regime-sensitive SSH articles vary systematically across decades, and if so, in which direction?

## Rationale

Most empirical tests in this project estimate the average autocracy effect pooled across the full time window. This pools over periods with very different international academic environments — pre- and post-Cold War, before and after mass digital surveillance, and before and after China's emergence as a dominant SSH producer. A pooled estimate may therefore mask substantial temporal heterogeneity: the self-censorship effect could have strengthened, weakened, or been stable depending on which countervailing forces dominated in each decade.

Testing for temporal heterogeneity is important for theory: if the effect is driven by surveillance capacity, it should strengthen from the 2010s onward; if it is driven by isolation from international publishing norms, it should weaken as globalization integrates researchers into international scholarly networks from the 1990s onward. An interaction model with decade dummies provides a direct test of whether the gradient is stable or evolving.

## Theoretical mechanism

Self-censorship incentives under autocracy are mediated by at least three mechanisms that change across time. First, the globalization of academic publishing from the 1990s onward exposed researchers in semi-closed systems to international norms of scholarly independence, potentially attenuating domestic censorship incentives. Second, the diffusion of digital surveillance technology from the early 2010s onward gave authoritarian states more effective tools to monitor academic output and enforce compliance, potentially intensifying self-censorship in the most recent decade. Third, the rise of China — where state control over SSH is intense and publication volumes are large — shifts the composition of the autocratic country-year sample from the 2000s onward, mechanically shaping the pooled estimate.

The expected pattern is that the negative effect of autocracy on sensitive-topic share is strongest in the 2010s, reflecting the combination of high surveillance capacity and increasingly assertive authoritarian management of universities. The effect may be weaker in earlier decades, when autocracies were more heterogeneous and surveillance less pervasive.

## Theory family

`regime-channels`

## Estimand

Decade-specific average within-country effects of a one-unit increase in `v2x_libdem` on `share_sensitive` — one coefficient per decade, estimated from a fully interacted model.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_sensitive`: the proportion of distinct articles from a given country-year for which at least one term from the regime-sensitive keyword dictionary (Team 04 specification) matches in either the `title` or `keywords` fields. Constructed as:

    share_sensitive = (# distinct ut with at least one match) / n_articles_country_year

Keyword dictionary follows Team 04: democracy/democratization, human rights, corruption, protest/contention, repression, authoritarianism, political freedom, electoral manipulation, dissent/opposition.

## Key IV

`v2x_libdem` interacted with decade dummies (1970s, 1980s, 1990s, 2000s, 2010s, 2020s), constructed as `floor(year / 10) * 10`.

## Uniqueness check

rq.md files were read for all teams with files available at time of writing: teams 01–22.

- **Team 04** estimates the pooled average effect of autocracy on the share of regime-sensitive articles — no temporal interaction. Team 25 uses the same outcome but asks whether the gradient is stable over time.
- **Team 01** constructs a Political Content Index from abstracts; no temporal interaction.
- **Teams 23–24** (no rq.md at time of writing, per prompt specification) are described as event studies around specific political transitions — distinct in design (event-time rather than calendar-decade dummies) and estimand (transition-specific rather than decade-specific effects).
- **No other team** in the set uses a decade-interaction model to test temporal heterogeneity of the main autocracy effect on sensitive-topic content. Team 25 is the only team asking whether the relationship between autocracy and sensitive-topic avoidance has changed in strength over historical time.
