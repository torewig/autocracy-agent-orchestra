# Team 24 — Research Question

## Research question

Does the onset of autocratization — a country's transition from a democratic to an autocratic regime type — produce a measurable decrease in the country-year share of politically sensitive SSH articles in the three years following the transition?

## Rationale

Self-censorship theory predicts that the degree of political constraint researchers face tracks the degree of autocratic control in their country. If this mechanism operates, autocratization — the shift from relatively open to relatively closed political conditions — should produce a detectable behavioral response: researchers anticipating or experiencing increased sanctioning capacity will steer their work away from politically sensitive topics. The event-study design exploits the timing of autocratization episodes to identify this effect while controlling for stable country characteristics and common time trends.

The autocratization test is analytically distinct from the cross-sectional correlation between regime type and sensitive-topic output (Teams 01, 04): it asks whether the within-country *change* in regime type produces a within-country *change* in research behavior, offering stronger causal leverage by exploiting temporal variation rather than cross-sectional differences.

## Theoretical mechanism

When a country autocratizes, regime sanctioning capacity increases: security services expand surveillance of public institutions, universities come under tighter political control, and the perceived cost of producing research critical of the state rises. Researchers respond to this shift by anticipating penalties — dismissal, loss of funding, publication bans, or more severe sanctions — and self-censor accordingly, avoiding politically sensitive topics at the point of topic selection. Because autocratization is often gradual rather than abrupt, the behavioral response is expected to accumulate over the post-transition period, with the largest decreases in sensitive-topic share occurring 2–3 years after the transition year rather than immediately. The expected direction is unambiguously negative: the share of sensitive-topic articles declines following autocratization, with the effect strengthening as the new political constraints consolidate.

## Theory family

`regime-channels`

## Estimand

The average dynamic treatment effect of autocratization on the country-year share of politically sensitive SSH articles, estimated via an event-study regression that traces the effect from 3 years before to 3 years after the transition year, relative to the year immediately before the transition (t−1).

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_sensitive`: the proportion of distinct articles from a given country-year for which at least one term from the Team 04 regime-sensitive keyword dictionary matches in either the `title` or `keywords` field (case-insensitive regex). Constructed as:

    share_sensitive = (# distinct wos_id with at least one regime-sensitive match) / n_articles_country_year

The keyword dictionary is replicated exactly from Team 04 (democracy/democratization, human rights, corruption/accountability, protest/contention, political repression, authoritarianism, political freedom, electoral manipulation, dissent/opposition).

## Key independent variable

Autocratization event indicator interacted with time-to/from-event dummies. An autocratization event is defined as a country transitioning from `v2x_regime ∈ {2, 3}` (electoral or liberal democracy) to `v2x_regime ∈ {0, 1}` (closed or electoral autocracy) in a given year. The event year t is the first year in which `v2x_regime` falls to {0, 1} following a spell of {2, 3}. Dummies for relative years t−3, t−2, t+0, t+1, t+2, t+3 are included; t−1 is the reference period.

## Uniqueness check

Performed against rq.md files for all available teams at time of writing: Teams 01–12, 14–17, 19–22.

- **Team 23** is the direct mirror: it tests democratization episodes (regime → democracy transitions) and expects a positive post-transition effect on sensitive-topic share. Team 24 tests the opposite direction — autocratization episodes (regime → autocracy transitions) with an expected negative post-transition effect. The two teams share the event-study design but differ in transition direction, expected sign, and transitional dynamics (autocratization is typically more gradual than democratization, implying potentially slower onset of effect and greater risk of pre-trends).
- **Teams 01 and 04** estimate the cross-sectional (within-country) association between regime level (`v2x_libdem`, continuous) and sensitive-topic output. Team 24 is distinguished by exploiting *discrete transition events* in `v2x_regime` rather than continuous variation, using a leads-and-lags design that directly addresses reverse causality and pre-trend concerns.
- **No other team** among those reviewed uses an event-study design anchored on autocratization onset. Teams using regime measures (01, 04, 05, 06, 08, 10, 11, 12, 14, 15, 16, 17, 19, 20, 21, 22) all treat regime as a continuous or time-varying covariate, not as an event to be centered on.
