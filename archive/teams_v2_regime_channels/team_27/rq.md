# Team 27 — Research Question

## Research question

Is the negative effect of autocracy on the country-year share of politically sensitive SSH articles significantly larger in political science than in economics?

## Rationale

Self-censorship theory predicts that researchers avoid sensitive topics to minimize career risks, but this incentive is not uniform across disciplines. The magnitude of the effect should depend on how central political content is to the discipline's core mission. A field comparison between political science and economics provides a direct scope-condition test of the self-censorship mechanism: if the mechanism is real and field-mediated, the autocracy coefficient should be substantially larger (more negative) in political science than in economics.

## Theoretical mechanism

Political science is constitutively political: the discipline's canonical questions — about power, state authority, regime legitimacy, elections, and rights — are precisely the subjects that autocratic regimes find threatening. Researchers in political science in autocracies therefore face the highest per-topic career risk of any SSH field. Economics, by contrast, can more easily present politically adjacent work in technical or welfare-neutral framings (growth models, market analysis, econometric methods) that reduce the signaling of political challenge. If self-censorship operates through field-level incentive structures, the negative association between `v2x_libdem` and `share_sensitive` should be significantly stronger among political science articles than among economics articles. The expected direction: the interaction coefficient `v2x_libdem × economics_indicator` should be positive and statistically significant, indicating that the autocracy penalty on sensitive-topic output is attenuated in economics relative to political science.

## Theory family

`regime-channels`

## Estimand

The difference in the within-country effect of `v2x_libdem` on `share_sensitive` between the political science subsample and the economics subsample — i.e., the interaction coefficient `v2x_libdem × field_economics` in a pooled regression, or the difference in `v2x_libdem` coefficients across two separate field-restricted regressions.

## Unit of analysis

Country-year, estimated separately for political science and economics articles (two subsamples) and jointly in a pooled interaction model. One observation = one country-field-year combination (country × field × year), collapsed to country-year within each field.

## Outcome variable

`share_sensitive`: the country-year share of articles in a given field (political science or economics) that match the Team 04 regime-sensitive keyword dictionary in the `title` or `keywords` fields (case-insensitive regex). Constructed as:

    share_sensitive = (# distinct articles with at least one keyword match) /
                      (# distinct articles in that field for that country-year)

The Team 04 dictionary is used directly (democracy, human rights, corruption, protest, repression, authoritarianism, political freedom, electoral manipulation, dissent). Articles from the field are identified by matching `subject_primary` against a short list of WOS subject category strings for political science and economics respectively (see analysis_plan.md for exact strings).

## Key independent variable

`v2x_libdem` (Liberal Democracy Index, 0–1, continuous; higher = more democratic), interacted with a binary indicator `field_economics` (1 = economics articles, 0 = political science articles).

## Uniqueness check

Performed. Scanned rq.md files for teams 01–26 (team_26 rq.md absent; teams with rq.md: 01–15, 17–26, 28).

- **Team 03** (most similar): uses `subject_primary` to construct the outcome — share of output in sensitive fields — and estimates the average autocracy effect pooled over all SSH. Team 27 is distinct: field is a moderator, not an outcome. Team 27 asks whether the within-field autocracy effect on sensitive-topic content (keyword-based) differs across fields.
- **Team 04**: estimates the average autocracy effect on `share_sensitive` (keyword-based) pooled over all SSH. Team 27 replicates that estimand within subfields and tests the interaction; the question is the differential, not the average.
- **Team 25**: tests temporal heterogeneity (decade interactions) of the same keyword-based outcome. Team 27 tests field-level heterogeneity (polisci vs. economics) — distinct moderator.
- **Team 23**: tests regional heterogeneity of the Team 04 estimand. Team 27 tests field heterogeneity — distinct moderator.
- No team among 01–26 tests field as a moderator of the autocracy–sensitive-topic relationship, or makes the specific political science vs. economics comparison.
