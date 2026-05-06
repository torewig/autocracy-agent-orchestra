# Team 01 — Research Question

## Research question
Do SSH researchers in more autocratic countries produce abstracts with a lower share of political-content keywords — as measured by the Political-Content Index (PCI) score — than researchers in more democratic countries, after controlling for country, year, GDP per capita, and population?

## Rationale
Researchers working under autocratic rule face institutional incentives to avoid topics that may attract state scrutiny, including explicitly political subject matter. If self-censorship operates through topic avoidance, we should observe that the textual content of published abstracts from autocratic contexts is systematically depleted of political vocabulary. The abstract is the first and most visible signal of a paper's political content, making it a plausible site of strategic softening or omission.

## Theoretical mechanism
In autocracies, researchers anticipate that using political vocabulary in published work — terms such as "democracy," "repression," "protest," or "human rights" — increases the probability of institutional sanction, loss of funding, or career setback. Facing this risk, researchers either self-select out of politically sensitive topics or reframe their work to minimize explicitly political language at the stage of writing up and publishing. This behavioral response reduces the aggregate share of political-content keywords in abstracts from autocratic country-years. The expected direction is negative: higher `v2x_libdem` → higher PCI score (more political content), because greater political freedom removes the self-censorship incentive.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit lower mean PCI scores in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family
topic-avoidance

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean PCI score (share of abstract word tokens matching a political-content keyword dictionary), conditional on country and year fixed effects.

## Unit of analysis
Country-year

## Outcome variable
`pci_mean`: constructed by (1) tokenizing each article abstract, (2) computing the share of tokens matching a political-content keyword dictionary (PCI score per article), then (3) averaging PCI scores to the country-year level, weighted by article count. The PCI dictionary covers terms in the clusters: democracy/autocracy, repression/rights, governance/corruption, protest/conflict, elections/parties (approximately 80–120 stems; full list defined in analysis.R).

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no other team rq.md files exist yet for teams 02–06).
Distinction: Teams 02–04 are assigned to topical diversity, disciplinary composition, and a specific four-keyword set respectively; Team 01 is the only team using a broad multi-cluster PCI dictionary applied to raw abstract text aggregated to country-year mean share.
