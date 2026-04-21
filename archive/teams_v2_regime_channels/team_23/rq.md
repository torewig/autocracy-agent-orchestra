# Team 23 — Research Question

## Research question

Do countries that undergo a democratic transition (moving from autocratic to democratic regime status in `v2x_regime`) exhibit a measurable increase in the country-year share of SSH articles with regime-sensitive keywords in the 1–3 years following the transition, relative to pre-transition trends and to non-transitioning countries over the same period?

## Rationale

Self-censorship theory predicts that the incentive to avoid politically sensitive topics is a direct function of the regime's sanctioning capacity. When a country democratizes, the credible threat of career costs for publishing on sensitive topics — state surveillance, funding withdrawal, dismissal, harassment — diminishes rapidly because new political authorities have weaker means and motivation to punish academics for their topic choices. If self-censorship was operating pre-transition, removing its cause should produce a measurable behavioral response: researchers should shift output toward sensitive topics within a short adjustment window. The event-study design disciplines this prediction by requiring that the post-transition increase emerge from periods that were not already on a divergent pre-trend.

## Theoretical mechanism

Under authoritarian rule, researchers who study democracy, human rights, repression, electoral fraud, or dissent face individually rational incentives to redirect their work toward politically safer topics. The regime's sanctioning capacity — rooted in control of universities, funding agencies, and security services — is the proximate cause of this behavior. Democratic transition rapidly changes this incentive structure: new governments withdraw regime-loyal administrators from universities, reduce surveillance of academic output, and signal tolerance for political research, causing the expected cost of sensitive-topic publication to drop sharply. Researchers who had suppressed or redirected work under autocracy now face a lower threshold for publication on sensitive topics, generating a short-run surge in the sensitive-topic share of national output. The expected direction is positive: the country-year share of regime-sensitive articles increases after democratization, with the effect expected to materialize within 1–3 years of the transition.

## Theory family

`regime-channels`

## Estimand

The average effect of democratic transition on the country-year share of SSH articles with at least one regime-sensitive keyword match, estimated via an event-study (leads-and-lags) design. The primary estimand is the set of post-transition coefficients (event times t+1, t+2, t+3) relative to the reference period t-1, pooled across all democratizing country-events. The pre-transition coefficients (t-3, t-2) serve as a pre-trend test; if these are indistinguishable from zero, the parallel trends assumption is credible.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least five SSH articles in the corpus and at least partial V-DEM regime coverage).

## Outcome variable

`share_sensitive`: the country-year proportion of distinct SSH articles (identified by `wos_id`) for which at least one term in the regime-sensitive keyword dictionary matches in the concatenated `title` and `keywords` fields (case-insensitive regex). Constructed replicating Team 04's dictionary and matching logic:

    share_sensitive = (# distinct wos_id with at least one keyword match) / n_articles_country_year

The regex dictionary is applied to `paste(title, keywords, sep = " | ")` with `ignore.case = TRUE`, using Team 04's combined `dict_pattern` covering clusters: democracy, human rights, civil rights/liberties, corruption, bribery, protest/contention, repression, censorship, political prisoners, authoritarianism, political freedom, electoral fraud, and dissent/opposition.

## Key IV

Democratic transition indicator interacted with event-time dummies. A **democratization event** is defined as the first year in which `v2x_regime` increases from {0, 1} (closed or electoral autocracy) to {2, 3} (electoral or liberal democracy) for a given country, following at least two consecutive years at autocratic status. Event time `k` (for k ∈ {-3, -2, -1, 0, +1, +2, +3}) is constructed as the number of years relative to the transition year (t=0). The reference category is t-1. The key IV is therefore the vector of event-time dummy coefficients, with t+1 through t+3 constituting the primary hypothesis test.

## Uniqueness check

Performed. rq.md files reviewed for Teams 01–12, 14–17, 19–20.

- **Versus all teams using panel regression on `v2x_libdem` (Teams 01–12, 14–17, 19–20):** Every existing team estimates a continuous within-country effect of `v2x_libdem` on outcomes. Team 23 is the only team that uses a discrete event-study design centered on the year of democratic transition. The unit of identification is the transition episode, not the country-year level of democracy; the estimand is a time-path of effects relative to a base period, not a level effect. This is a fundamentally different identification strategy from any existing rq.md.
- **Versus Team 04 (regime-sensitive keyword share, panel regression):** Team 04 uses the same outcome variable but estimates its level association with `v2x_libdem` in a panel regression. Team 23 constructs the same outcome but identifies its causal effect using discrete democratization events and a leads-and-lags event-study specification. The designs are complementary, not duplicative.
- **Versus Team 24 (mirror design for autocratization):** Team 24 is the direct mirror of Team 23 — it applies the same event-study logic to autocratization episodes (regime decreases from {2, 3} to {0, 1}). Team 23 is restricted to democratization events and tests for a positive increase in sensitive-topic output; Team 24 tests for the symmetric decline. The two teams share a methodological approach but test opposite directional predictions on non-overlapping sets of regime events.
