# Team 28 — Research Question

## Research question
Do researchers in closed autocracies (v2x_regime == 0) produce a lower share of sensitive-topic articles than researchers in electoral autocracies (v2x_regime == 1)?

## Rationale
The degree of authoritarian control over academic institutions is not uniform across regime types. Closed autocracies abolish competitive elections entirely and typically exercise direct, coercive control over universities and research funding. Electoral autocracies, by contrast, must maintain at least a nominal veneer of institutional pluralism — including some academic freedom — to secure electoral legitimacy and international credibility. This creates a structural incentive for electoral autocracies to tolerate more open scholarly inquiry than their closed counterparts, predicting a systematic difference in self-censorship levels across the two types.

## Theoretical mechanism
Closed autocracies face fewer domestic accountability constraints and can directly punish scholars who work on politically sensitive topics without risking the legitimacy costs that electoral autocracies incur. Scholars in closed autocracies therefore anticipate higher costs of non-compliance and self-censor more aggressively. In electoral autocracies, the partial openness of the political arena — even if elections are manipulated — signals some tolerance for dissent, reducing the subjective probability of punishment for sensitive research. The net prediction is that the share of sensitive-topic articles will be lower in closed autocracies than in electoral autocracies, holding other country characteristics constant.

## Theory family
`regime-channels`

## Estimand
Average difference in country-year share of sensitive-topic articles between closed autocracies (v2x_regime == 0) and electoral autocracies (v2x_regime == 1), conditional on country and year fixed effects and continuous regime-quality controls.

## Unit of analysis
Country-year, restricted to autocratic country-years (v2x_regime ≤ 1).

## Outcome variable
`share_sensitive` — country-year share of articles flagged as covering politically sensitive topics (keyword flag replicating Team 04 procedure).

## Key independent variable
`closed_autocracy` — binary indicator equal to 1 when v2x_regime == 0 (closed autocracy) and 0 when v2x_regime == 1 (electoral autocracy).

## Uniqueness check
Team 25 examines temporal trends in self-censorship; Team 26 examines regime duration effects. Team 28 is distinct in testing a cross-sectional typological contrast — whether the categorical type of authoritarianism (closed vs. electoral) predicts self-censorship above and beyond continuous variation in democratic quality (v2x_libdem). No other team in the 01–27 range focuses on the v2x_regime 0 vs. 1 comparison as the primary estimand.
