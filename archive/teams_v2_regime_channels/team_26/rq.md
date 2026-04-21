# Team 26 — Research Question

## Research question

Does the duration of uninterrupted autocratic rule — years since the last democratic-to-autocratic transition — suppress the share of politically sensitive research topics beyond what the current regime score alone captures?

## Rationale

Existing tests of the autocracy–self-censorship link use contemporaneous regime scores (e.g., `v2x_libdem`) that measure current political openness. Duration captures something the level score cannot: the accumulated weight of an entrenched autocratic institutional environment. Academic cultures, career incentive structures, editorial norms, and individual researchers' internalized risk calculi all adapt over time, so a researcher operating 20 years into autocratic rule is embedded in a qualitatively different professional environment than one experiencing only the second year of the same regime. Testing duration as a moderator therefore directly addresses whether socialization and institutional lock-in deepen self-censorship beyond what current repressiveness predicts.

## Theoretical mechanism

The core mechanism is accumulated socialization under autocratic constraints. In the short run after a democratic breakdown, many researchers still carry the norms and risk tolerances formed under democracy; they may continue to publish on sensitive topics out of habit or because the new regime has not yet fully reorganized research institutions. Over time, however, the population of active researchers increasingly comprises individuals who were trained and socialized entirely under autocratic norms, institutions are reorganized to reward safe topics and penalize politically inconvenient work, and self-censorship becomes automatic rather than effortful. Longer autocratic tenure thus compresses the share of sensitive-topic research through a ratchet-like socialization process. The expected direction is negative: conditional on `v2x_libdem`, longer `autocracy_duration` is associated with a lower share of sensitive-topic articles. If duration has no independent effect, the coefficients on `autocracy_duration` (or its interaction with `v2x_libdem`) will be indistinguishable from zero.

## Theory family

`regime-channels`

## Estimand

The marginal effect of an additional year of uninterrupted autocratic rule on the country-year share of politically sensitive articles, conditional on the contemporaneous liberal democracy score, country fixed effects, year fixed effects, and economic controls. In the interaction specification, the estimand is the coefficient on `v2x_libdem × autocracy_duration`, which captures whether the autocracy–sensitivity association strengthens as the spell lengthens.

## Unit of analysis

Country-year (one observation per `iso3 × year` combination), restricted to country-years with at least 10 articles to ensure stable share estimates.

## Outcome variable

`share_sensitive`: the proportion of articles from a given country-year whose title or keywords match the Team 04 regime-sensitive keyword flag (i.e., `mean(sensitive_flag)` within `iso3 × year`). Bounded [0, 1]; higher values indicate more sensitive-topic research. The sensitive_flag replicates Team 04's keyword-based classification applied to the same corpus.

## Key IV

`autocracy_duration`: constructed as follows — within each country, identify spells where `v2x_regime <= 1` (non-democratic) in consecutive years; `autocracy_duration` equals the count of consecutive years with `v2x_regime <= 1` up to and including the current year; the variable resets to 0 in any year where `v2x_regime > 1`. Primary specification uses `autocracy_duration` as a continuous moderator alongside `v2x_libdem`. A log transformation (`log(autocracy_duration + 1)`) is used as robustness check given the right-skewed distribution of spell lengths.

The primary estimand is the coefficient on `autocracy_duration` in the additive model, and the coefficient on the interaction `v2x_libdem × autocracy_duration` in the interaction model.

## Uniqueness check

rq.md files were read for all teams with files available at time of writing (teams 01–22). No team uses regime duration, autocratic spell length, or time-since-transition as a variable. All existing regime-IV teams use contemporaneous level scores (`v2x_libdem`, `lied_binary`, or `v2x_regime`). Teams 23–25 have no rq.md files at time of writing; per project brief they address transition timing and decade variation — Team 26 is distinct in testing within-spell duration as a socialization moderator rather than transition events or period trends. Team 26 is the only team in the `regime-channels` sub-family and the only team whose primary theoretical claim is about the accumulation of autocratic socialization over time.
