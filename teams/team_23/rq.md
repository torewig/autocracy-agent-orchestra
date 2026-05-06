# Team 23 — Research Question

## Research question

Does the ideological type of a regime — communist/left-authoritarian versus nationalist/right-authoritarian versus liberal-democratic — predict the political-economy ideological lean of national SSH output, and does all autocracy (regardless of type) suppress liberal or centrist political-economy framing relative to democratic baselines?

## Rationale

Self-censorship under autocracy is not ideologically neutral: researchers in communist regimes face pressure to produce scholarship consonant with statist, collectivist, and anti-market frames, while researchers in nationalist or right-authoritarian regimes face complementary pressures toward market-nationalist or traditionalist frames. Both regime types may suppress liberal-centrist political-economy framing — the framing most compatible with pluralist, rule-of-law, and open-society scholarship — but through different mechanisms. Existing teams capture topic avoidance and framing-neutrality but none test whether the ideological content of political-economy language in SSH abstracts shifts predictably with regime ideology type, which is a distinct and theoretically important form of self-censorship.

## Theoretical mechanism

Autocratic regimes exert direct and indirect pressure on academic institutions to produce scholarship consonant with their official ideology: communist regimes promote statist, redistributive, and collectivist framings and penalize market-liberal or pluralist alternatives; nationalist and right-authoritarian regimes promote market-nationalist, traditionalist, or anti-cosmopolitan framings and penalize universalist or redistributive alternatives. Researchers anticipating these pressures self-censor by framing their work within the ideologically approved vocabulary, even when their empirical subject matter does not require taking a position. Liberal-centrist or ideologically neutral framing — which does not endorse either statism or nationalism — is the framing most compatible with liberal-democratic academic norms; we therefore expect it to be suppressed under both left- and right-authoritarian regimes, but through different substitution patterns. The expected direction for the primary test is positive: higher `v2x_libdem` (more democratic) is associated with a higher share of liberal/neutral political-economy framing (`share_apolitical`) and a lower share of left-authoritarian or right-nationalist framing.

## Theory family

ideological-alignment

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower share of SSH abstracts with liberal/neutral political-economy framing (NEUTRAL + NONE) and a higher share with ideologically aligned framing (LEFT or RIGHT-CONSERVATIVE), after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country association between `v2x_libdem` and the country-year share of SSH abstracts classified as carrying liberal/neutral political-economy framing (`share_apolitical`), conditional on country fixed effects, year fixed effects, and standard economic controls. Secondary estimands test heterogeneity by regime ideology type via interaction with a categorical regime-ideology variable.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Construction:** For each abstract in the stratified sample, an LLM assigns one of five labels reflecting the political-economy ideological framing of the text: (1) LEFT — statist, redistributive, collectivist, or anti-capitalist framing; (2) RIGHT-CONSERVATIVE — nationalist, traditionalist, or social-conservative framing; (3) RIGHT-LIBERAL — classical liberal framing (free markets, individual rights, limited government); (4) NEUTRAL — technocratic, empiricist, or explicitly non-ideological framing; (5) NONE — the abstract does not carry discernible political-economy framing. Five country-year share variables are constructed: `share_left`, `share_right_conservative`, `share_right_liberal`, `share_neutral`, `share_none`. The primary outcome is `share_apolitical` = `share_neutral` + `share_none` (i.e., the share of abstracts that avoid ideological political-economy framing in any direction), treated as the "suppressed" category under autocracy. Secondary outcomes are `share_left`, `share_right_conservative`, and `share_right_liberal`, examined separately and in regime-ideology interaction models.

Framing is distinguished from topic coverage: an abstract that studies redistribution as a topic is classified by the framing through which it discusses it — an empiricist study of redistribution effects with no normative stance is NEUTRAL; one that frames redistribution as a social right or as correcting capitalist exploitation is LEFT; one that frames redistribution as market distortion is RIGHT-LIBERAL.

## Controls

`log(e_gdppc)` and `log(e_wb_pop)`

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Secondary IV: a categorical regime ideology type variable constructed from V-DEM and external sources (see analysis plan).

## LLM classifier specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost model) primary; GPT-4o-mini as alternative.

**Labels:**
- `LEFT`: The abstract frames its subject using statist, redistributive, collectivist, anti-capitalist, or class-struggle language as an evaluative or normative lens — including advocacy against oppression of marginalized groups and minorities — not merely as a topic under study.
- `RIGHT-CONSERVATIVE`: The abstract frames its subject using nationalist, traditionalist, anti-cosmopolitan, social-conservative, or authoritarian-order language as an evaluative or normative lens — not merely as a topic under study.
- `RIGHT-LIBERAL`: The abstract frames its subject using classical liberal language — free markets, individual rights, limited government, rule of law, or personal autonomy — as an evaluative or normative lens — not merely as a topic under study.
- `NEUTRAL`: The abstract discusses political-economy topics in an explicitly empiricist, technocratic, or non-partisan framing — describing mechanisms or measuring effects without endorsing a normative direction.
- `NONE`: The abstract does not engage with political-economy topics or ideological framing in any discernible way.

**Prompt structure:** The prompt passes the abstract text and instructs the model to identify the dominant political-economy framing, emphasizing that it should classify framing (evaluative stance, normative language, rhetorical appeal) rather than topic coverage. The model returns a single label. Ties between LEFT and RIGHT-CONSERVATIVE or RIGHT-LIBERAL default to NEUTRAL. Ties between NEUTRAL and NONE default to NONE. Full prompt text defined in `analysis_plan.md`.

**Label assignment rules:** Single-label output only. If the abstract discusses political-economy topics descriptively without normative framing, assign NEUTRAL. If the abstract does not engage with political-economy content at all, assign NONE. Default to NONE if genuinely ambiguous. Assign LEFT, RIGHT-CONSERVATIVE, or RIGHT-LIBERAL only when normative framing language is present and unmistakable.

## Sampling strategy

Target approximately **1,000,000 abstracts**, stratified by `iso3` × `v2x_regime` (4-category: 0–3) × decade, up to 10 articles per stratum. `set.seed(42)` for reproducibility. At Claude Haiku rates (~$0.00052 per abstract), the estimated cost for 1M abstracts is ~$520. **Hard cost ceiling: $500** — implement a pre-flight cost estimate before calling the API and halt with an informative error if the projected cost exceeds $500.

## Uniqueness check

Performed. Teams with most potential overlap:
- Team 05: classifies whether abstracts critically examine domestic governance (binary CRITICAL-DOMESTIC vs. NEUTRAL-DOMESTIC). Does not classify political-economy ideological lean or LEFT/RIGHT/NEUTRAL framing.
- Team 10: classifies technocratic framing (presence of depoliticizing, technocratic language). Tests suppression of political framing generally; does not distinguish LEFT from RIGHT from NEUTRAL.
- Team 12: classifies normative conclusion claims (strong vs. hedged normative claims). Does not classify ideological direction (left vs. right vs. neutral).
- Team 08: classifies hedging/epistemic uncertainty. Does not test ideological lean.

Team 23 is the only team that (a) classifies the political-economy ideological direction (LEFT / RIGHT-CONSERVATIVE / RIGHT-LIBERAL / NEUTRAL / NONE) of SSH abstracts, (b) tests whether autocracy predicts this lean, and (c) tests heterogeneity by regime ideology type to assess whether communist vs. nationalist autocracies produce predictably different lean signatures.
