# Team 16 — Research Question

## Research question

Do researchers in more autocratic countries produce a higher share of SSH articles with exclusively domestic authorship — defined as articles where every contributing author is affiliated with the same country — compared to researchers in more democratic countries?

## Rationale

Self-censorship theory predicts that researchers in autocracies constrain their collaboration choices to minimize exposure to foreign oversight, documentation of foreign contacts, and the transmission of liberal academic norms. International co-authorship is a publicly traceable institutional tie that autocratic regimes can scrutinize; researchers who anticipate this scrutiny will avoid it by confining their collaborations to domestic partners. If this mechanism operates at scale, autocratic country-years should exhibit a systematically higher share of articles in which all authors are affiliated with the same country.

## Theoretical mechanism

In autocratic settings, researchers face career costs — dismissal, loss of funding, denial of travel permits, or harassment — for maintaining documented institutional relationships with foreign scholars, particularly those in liberal democracies. International co-authorship creates a paper trail of foreign contacts and exposes researchers to the norms, expectations, and potential political influence of foreign academic communities, all of which autocratic regimes may perceive as threatening. Anticipating these risks, researchers self-censor their collaboration strategies: they preferentially seek domestic co-authors, allow international collaborations to lapse, or avoid initiating them in the first place. The expected direction is negative: higher `v2x_libdem` is associated with a lower share of domestically-only authored articles, because greater political freedom removes the incentive to confine collaboration to domestic partners.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH articles with exclusively domestic authorship, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the share of country-year SSH articles in which all author-country affiliations belong to the same country (domestic-only articles), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_domestic_only`: constructed by (1) counting the number of distinct values of `iso3` per `wos_id` (i.e., distinct author-country affiliations per article); (2) flagging each article as `domestic_only = TRUE` if `n_distinct(iso3) == 1` for that `wos_id`; (3) aggregating to country-year: `share_domestic_only = (# domestic_only articles) / n_articles_country_year`. The outcome is a proportion bounded in [0, 1].

**Note on corpus structure:** The corpus contains one row per article × author-country combination. Each `wos_id` may therefore appear in multiple rows. Deduplication to the article level is performed before computing `n_articles_country_year` as the denominator to avoid double-counting.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. rq.md files exist for Teams 01–08, 10, and 11 (Teams 09, 12–15 have no rq.md at time of writing). The most relevant comparisons within the `collaboration-constraint` sub-family are Teams 14 and 15, as described in the project design.

- **Team 14** (mean number of distinct co-author countries per article, continuous): Team 14 measures the *degree* of international collaboration on a continuous scale — a country-year with many articles involving 2–3 foreign countries will score differently from one dominated by bilateral collaborations. Team 16 uses a binary indicator (any international co-author present vs. not) that captures the *extensive margin* — the decision to engage in any cross-border co-authorship at all — rather than the depth of collaboration. A country that systematically avoids international co-authorship will produce a high `share_domestic_only` even if its few internationally co-authored articles involve many partner countries.
- **Team 15** (share of articles with at least one co-author from a liberal democracy, v2x_libdem > 0.5): Team 15 identifies co-authorship links to specifically democratic partners and asks whether autocracies avoid those particular collaborations. Team 16 asks a more fundamental prior question: do autocracies avoid *any* international collaboration, regardless of the political character of the partner country? The two outcomes can diverge — a country could co-author with other autocracies without ever co-authoring with democracies, registering a low domestic-only share (Team 16) but a low democracy-collaboration rate (Team 15).
- **Teams 01–11** (topic-avoidance and framing-neutrality families): all are conceptually distinct — they measure what researchers write about or how they write, not with whom they collaborate.
