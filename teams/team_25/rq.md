# Team 25 — Research Question

## Research question
Do SSH researchers in more autocratic countries produce a higher share of abstracts that actively frame liberal democracy, Western political institutions, or international human rights frameworks as fundamentally flawed, illegitimate, or harmful — as measured by LLM-classified `share_anti_liberal` — than researchers in more democratic countries, after controlling for country, year, GDP per capita, and population?

## Rationale
Self-censorship theory predicts that researchers in autocracies avoid politically sensitive topics to minimize career risk, but the same logic of regime alignment generates an additional prediction: where states actively promote counter-liberal ideologies, researchers face positive incentives to produce scholarship consonant with those ideologies. Autocratic regimes — particularly those advancing civilizational, sovereigntist, or anti-Western narratives — reward ideologically aligned scholarship and create structural pressure toward active ideological production, not merely passive avoidance. This team tests the positive production side of the self-censorship mechanism: not whether autocracy silences liberal discourse, but whether it actively generates anti-liberal counter-discourse.

## Theoretical mechanism
Autocratic regimes that derive legitimacy from anti-liberal ideological frameworks (sovereignty norms, civilizational conservatism, anti-Western hegemony arguments) have material incentives to fund, publish, and reward scholarship that delegitimizes liberal democratic norms and international human rights institutions. Researchers operating under such regimes face career incentives that are the mirror image of the avoidance incentive: producing ideologically aligned anti-liberal content can confer safety and advancement, while conspicuously pro-liberal framings attract sanction. This dynamic is distinct from ordinary topic avoidance — it implies active ideological production under state direction or anticipatory compliance. The expected direction is negative: lower `v2x_libdem` → higher `share_anti_liberal`. The effect is likely non-linear: strongest in closed autocracies (where state ideological pressure is greatest and independent scholarship most constrained), weaker in electoral autocracies, and near-zero in democracies where academic norms of analytical pluralism prevail.

## Theory family
`ideological-alignment`

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit a higher share of SSH abstracts that actively frame liberal democracy, Western political institutions, or international human rights norms as fundamentally flawed or illegitimate, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls
`log(e_gdppc)` and `log(e_wb_pop)`

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean share of abstracts classified as anti-liberal, conditional on country and year fixed effects.

## Unit of analysis
Country-year

## Outcome variable
`share_anti_liberal`: constructed by (1) drawing a stratified sample of ~1,000,000 abstracts from the full corpus, stratified by `iso3` × `v2x_regime` (4-category) × decade, up to 10 articles per stratum, `set.seed(42)`, estimated cost ~$0.00052 per abstract (~$520 for 1M); a pre-flight cost estimate is computed before calling the API and the run halts with an informative error if the projected cost exceeds the hard ceiling of $500; (2) classifying each abstract as ANTI-LIBERAL (1) or NOT (0) using an LLM binary classifier (see specification below), then (3) aggregating to the country-year level as the share of classified abstracts labeled ANTI-LIBERAL. Country-years not represented in the sample are excluded from the regression; country-years with fewer than 5 sampled abstracts are also excluded as unstable.

## Key independent variable
`v2x_libdem`

## LLM classifier specification

**Task:** Binary classification of each abstract as ANTI-LIBERAL (1) or NOT ANTI-LIBERAL (0).

**Label definition — ANTI-LIBERAL (code 1):**
An abstract receives code 1 if and only if it frames liberal democracy, Western political institutions, or international human rights norms as fundamentally flawed, illegitimate, or harmful. The framing must invoke regime-aligned anti-liberal arguments — such as appeals to national sovereignty against Western interference, civilizational or cultural-relativist arguments against universal human rights, characterizations of liberal democracy as a tool of Western hegemony or imperialism, delegitimization of international democratic institutions (e.g., the EU, ICC, or UN human rights mechanisms) as biased instruments of Western power, or explicit advocacy for alternative political orders (Confucian governance, Islamic governance, sovereign democracy) as superior to liberal democracy.

**Label definition — NOT ANTI-LIBERAL (code 0):**
An abstract receives code 0 in all other cases, including:
- Abstracts that identify specific failings or limitations of liberal institutions from within a broadly liberal framework (e.g., critiques of neoliberal economic policy, procedural deficits, democratic backsliding, minority exclusion, or imperial applications of liberal norms) — these represent internal critique, not rejection of liberal democracy as such.
- Abstracts drawing on post-liberal or agonistic democratic theory (Mouffe, Schmitt, Laclau) that engage critically with liberalism as a scholarly tradition without endorsing authoritarian alternatives.
- Abstracts that are neutral, descriptive, or analytical in framing without making normative claims about liberal democracy.
- Abstracts on unrelated topics.

**Critical distinction:** The key diagnostic is whether the abstract frames liberal democracy and Western institutions as externally harmful and illegitimate (anti-liberal) versus identifying internal problems within a normative framework that remains broadly liberal (critical liberal). Scholarly critique of liberalism on its own terms does not count; only abstracts that advocate for the rejection or replacement of liberal democratic norms, or that instrumentalize anti-Western frames in line with authoritarian regime discourse, are coded ANTI-LIBERAL.

**Model:** Claude Haiku (claude-haiku-3-5) or GPT-4o-mini. Classification in batches of 50 abstracts per API call. Temperature = 0. Return only "0" or "1" per abstract, no explanation.

**Prompt template:**

```
You are classifying academic abstracts. For each abstract, output exactly "1" if the abstract frames liberal democracy, Western political institutions, or international human rights norms as fundamentally flawed, illegitimate, or harmful using regime-aligned anti-liberal arguments (e.g., sovereignty arguments against Western interference, civilizational alternatives to universal human rights, characterizations of liberal democracy as Western hegemony). Output "0" for all other abstracts, including those that critique liberalism from within a liberal framework, engage with post-liberal theory as a scholarly tradition, or are descriptive/neutral. Output only 0 or 1. No explanation.

Abstract: {abstract_text}
```

## Uniqueness check note
Team 09 (framing-neutrality sub-family) counts the frequency of normative language in abstracts but does not assess the direction of that normativity toward or against liberal democratic norms. No other team tests active production of ideologically anti-liberal content. Team 25 is the only team in the orchestra testing whether autocracy predicts the positive generation of counter-liberal discourse, as opposed to avoidance or omission of politically sensitive material.
