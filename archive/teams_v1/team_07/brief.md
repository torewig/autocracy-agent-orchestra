# Research Team 07 -- Brief

## Your mandate

You are an independent research team. Investigate the overarching research
question below using the provided data. You decide how to approach it.
Do not coordinate with or look at other teams' folders.

## Overarching research question

> How does autocracy, and type of autocracy, impact on the contents, direction
> and scientific progress of the social sciences and humanities?

You are free to operationalize this in any way you find interesting and
tractable with the available data. The question asks about substantive and
semantic dimensions of SSH knowledge production: what topics are studied, what
directions research takes, what findings are published, how knowledge progresses.
Focus on content and direction, not only on simple volume indicators.

## Available data

- `data/agent_corpus.rds` -- SSH articles from Web of Science, 1970-2023,
  merged with V-DEM regime data. One row = one article x one author-country.
  See PLAN.md for the full variable list and usage notes.
- `DATA/vdem/vdem_clean.rds` -- V-DEM country-year data (standalone).
- `data/vdem_codebook.md` -- variable definitions and guidance.

Key data notes:
- Primary regime measure: `v2x_libdem` (continuous, 0-1). Use as your main
  independent variable. Report at least one robustness check using `v2x_regime`
  or `regime_binary`.
- Citations: Do not use `tot_cites` raw as an outcome. Use `field_year_mean_cites`
  to normalize, or restrict comparisons to within-field.
- Volume analyses: Use `n_articles_country_year` as the denominator when
  comparing counts across countries or regime types.
- Pre-1990 data: Treat estimates before 1990 with caution.
- Control variables: `e_gdppc` (GDP per capita, log-transform) and `e_wb_pop`
  (population, log-transform) are available in the corpus for regression controls.

## Your tasks -- complete in order, stop between steps for PI review

### Step 1 -- Research question (Designer role)
- Load and inspect `data/agent_corpus.rds` (use a small sample first)
- Develop a specific, answerable research question addressing the overarching question
- Write to `teams/team_07/rq.md`:
  - Your research question (one sentence)
  - Rationale (2-3 sentences)
  - Theoretical mechanism (2-4 sentences): what is the causal pathway from
    autocracy to your outcome? Name the specific actors, constraints, or
    incentives involved. State the expected direction and why.
  - Theory family (a short kebab-case label of your own choosing describing
    the theoretical root of your hypothesis — the PI will review and
    consolidate labels across teams before analysis begins)
  - Estimand, unit of analysis, outcome variable, key independent variable
- Write to `teams/team_07/analysis_plan.md`:
  - Method (regression is required for the final analysis; text analysis may
    be used to construct outcome or control measures)
  - Model specification: outcome, predictors, fixed effects, SE clustering
  - Causal identification strategy: variation exploited, confounders controlled,
    identification threats
  - List of expected output files
- STOP HERE. Wait for PI approval before proceeding.

### Step 2 -- Analysis (Analyst role)
*Begin only after PI has approved your rq.md.*
- Write R code in `teams/team_07/analysis/analysis.R` (tidyverse style)
- Your main analysis must use regression (lm, feols, or equivalent)
- Text analysis is permitted for constructing outcome/control variables but must
  feed into a regression as outcome or control
- Produce 2-4 figures or tables; save to `teams/team_07/analysis/figures/`
- Include at least one robustness check using an alternative regime measure
- Write `teams/team_07/analysis/primary_results.json` with the primary
  hypothesis test result (coefficient, SE, p-value, n, theory_family label)
- STOP HERE. Wait for PI review of your figures before writing the report.

### Step 3 -- Report (Writer role)
*Begin only after PI has approved your analysis.*
- Write a 4-5 page report to `teams/team_07/report/report.md`
- Follow the standard report template in PLAN.md
- Note: your report will be reviewed by an independent peer review agent after submission

## Constraints

- R only for data analysis (tidyverse style)
- Do not modify files outside your team folder (except reading shared data)
- Do not modify `data/agent_corpus.rds`
- Analysis approach: final analysis must use regression. Text analysis is permitted
  for constructing outcome or control variables, but the main estimand must be
  tested via regression.
- Causal inference: aim for designs supporting causal identification (country FE,
  year FE, DiD). If a fully causal design is not feasible, discuss identification
  threats explicitly in the report.
- Computationally heavy tasks: if your analysis will take more than ~5 minutes,
  or involves looping over individual abstracts at scale, ask the PI first.
- External API calls: you may call external APIs (OpenAI, Anthropic,
  HuggingFace, etc.) from your R code if it serves your analysis. Before
  doing so, briefly state what you plan to use them for. Avoid large-scale
  calls over the full corpus without checking with the PI first.

