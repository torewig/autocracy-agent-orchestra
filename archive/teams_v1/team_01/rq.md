# Team 01 — Research Question

*Revised 2026-03-20. Main IV switched to `v2x_libdem`; hypothesis added;
corpus updated to Phase 0 output (2,709,224 articles, 3,189,557 rows).*

---

## Research question

Does political suppression of academic freedom shift the substantive content
of SSH research away from politically engaged topics — as measured by the
political content of article abstracts — toward more politically neutral
subject matter?

## Rationale

Authoritarian regimes incentivize scholars to avoid politically sensitive
research. If this chilling effect operates, articles produced under lower
academic freedom should have systematically lower political content in their
abstracts: fewer references to governance, power, civil society, elections,
and political processes. Prior work has measured this effect through field-level
counts; the availability of full abstracts allows a more direct and continuous
measure of political content at the article level, and aggregated to
country-year panels, allows a cleaner test of within-country shifts over time.

## Theoretical mechanism

Autocratic regimes restrict academic freedom through a combination of direct
censorship, institutional control over hiring and funding, and informal
coercion that raises the personal cost of working on politically sensitive
topics. Scholars respond by self-censoring: they shift their research agenda
toward disciplines and topics with lower political risk (psychology, education,
applied economics) and away from research that directly engages questions of
political power, legitimacy, or civil rights. The key actors are the state
(controlling access and resources) and individual researchers (making topic
choices under these constraints). The expected direction is negative: higher
academic freedom → higher political content in national SSH output, a
compositional prediction distinct from a pure volume effect.

## Theory family

`self-censorship`

## Main hypothesis

Countries with higher liberal democracy scores produce SSH research with
systematically higher political content: the coefficient on `v2x_libdem` in
the main two-way FE specification is positive and statistically distinguishable
from zero. The effect is expected to be substantively meaningful — not merely
a statistical artefact of corpus size — and to hold net of country-level
development (GDP per capita) and population size.

## Estimand

The within-country, over-time effect of a one-unit increase in liberal
democracy (`v2x_libdem`) on the mean political content score of a country-year's
SSH article output. This is a partial identification estimate: country and year
fixed effects remove stable country-level specialization and global trends, but
cannot rule out all time-varying confounders.

## Unit of analysis

Country-year (primary); article-level as supplementary specification.

## Outcome variable

`mean_pci_cy`: the mean Political Content Index across all articles from a
given country-year, where PCI is computed at article level from abstract text.

**PCI construction (article level):**
PCI = (count of political dictionary terms in abstract) / (abstract word count)

Political dictionary: a pre-specified list of ~40–60 terms covering governance,
political institutions, civil society, and political conflict (e.g., *government,
state, party, election, democracy, regime, parliament, civil rights, protest,
authoritarian, political, policy, constitution, sovereignty, ministry*).
Dictionary specified and frozen before any analysis.

**Fallback for missing abstracts:** articles without abstracts are excluded
from the PCI-based outcome. The field-label-based `share_sensitive` (share of
articles in Political Science, Law, Sociology, History, Anthropology,
International Relations) is retained as a parallel, non-text outcome, enabling
comparison of the two measurement approaches and coverage of earlier years
where abstracts are sparse.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1). Captures the
full regime quality spectrum; standard in the comparative politics literature
for cross-country regression work.

`v2clacfree` (academic freedom) used in robustness checks as the more proximate
institutional mechanism.
