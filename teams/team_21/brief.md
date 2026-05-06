# Research Team 21 -- Brief

## Your mandate

You are an independent research team. Your domain assignment below specifies
the angle you will investigate. The Designer will develop the specific research
question and analysis plan within that domain. Do not drift into other teams' domains.

## Domain assignment

**Your domain:** Citation impact and co-authorship interaction: whether international co-authorship mediates the autocracy-citation gap
**Sub-family label (use exactly this for theory_family):** `visibility-suppression`
**Complexity:** Medium
**Permitted measurement approach:** Mediation/interaction model: v2x_libdem x n_co_countries on cite_ratio — no external API required

## Self-censorship theory (shared by all 27 teams)

All teams in this project test implications of the same unified theory:

> *Researchers in autocracies self-censor by avoiding politically sensitive
> topics, methods, collaborations, and framings to minimize career risks.*

Your job is to develop and test one specific, testable implication of this
theory within your assigned domain. Your RQ must state how your specific angle
connects to this self-censorship mechanism.

## Overarching research question

> How does autocracy, and type of autocracy, impact on the contents, direction
> and scientific progress of the social sciences and humanities?

## Available data

- `data/agent_corpus.rds` -- SSH articles from Web of Science, 1970-2023,
  merged with V-DEM regime data. One row = one article x one author-country.
  See PLAN.md for the full variable list and usage notes.
- `DATA/vdem/vdem_clean.rds` -- V-DEM country-year data (standalone).
- `data/vdem_codebook.md` -- variable definitions and guidance.

Key data notes:
- Primary regime measure: `v2x_libdem` (continuous, 0-1). Use as your main
  independent variable. Report at least one robustness check using `v2x_regime`
  or `lied_binary`.
- Control variables: `e_gdppc` (log GDP per capita) and `e_wb_pop` (log population)
  are available and should be included in regression models as standard controls.
- Citations: Do not use `tot_cites` raw as an outcome. Use `field_year_mean_cites`
  to normalize, or restrict comparisons to within-field.
- Volume analyses: Use `n_articles_country_year` as the denominator when
  comparing counts across countries or regime types.
- Pre-1990 data: Treat estimates before 1990 with caution (sparse coverage).

## Your tasks -- complete in order, stop between steps for PI review

### Step 1 -- Research question (Designer role)
- Load and inspect `data/agent_corpus.rds` (use a small sample first)
- Develop a specific, answerable RQ within your domain assignment
- The RQ must connect to the self-censorship theory (see above)
- Write to `teams/team_21/rq.md`:
  - Your research question (one sentence)
  - Rationale (2-3 sentences)
  - Theoretical mechanism (2-4 sentences): causal pathway, named actors/incentives,
    expected direction
  - Theory family: use exactly the sub-family label from your domain assignment
  - Estimand, unit of analysis, outcome variable (exact column name), key IV
  - Uniqueness check note (see Designer prompt for instructions)
- Write to `teams/team_21/analysis_plan.md`:
  - Method (regression required; text analysis may construct outcome/control variables)
  - Model specification: outcome, predictors, fixed effects, SE clustering
  - Causal identification strategy: variation exploited, confounders controlled,
    identification threats
  - List of expected output files
- STOP HERE. Wait for PI approval before proceeding.

### Step 2 -- Analysis (Analyst role)
*Begin only after PI has approved your rq.md and analysis_plan.md.*
- Write R code in `teams/team_21/analysis/analysis.R` (tidyverse style)
- Your main analysis must use regression (lm, feols, or equivalent)
- Text analysis is permitted for constructing outcome/control variables
- Produce 2-4 figures or tables; save to `teams/team_21/analysis/figures/`
- Save a `teams/team_21/analysis/primary_results.json` with fields:
  team, hypothesis_label, theory_family, predictor, outcome,
  coefficient, SE, p_value, n_obs
- Include at least one robustness check using an alternative regime measure
- STOP HERE. Wait for PI review of your figures before writing the report.

### Step 3 -- Report (Writer role)
*Begin only after PI has approved your analysis.*
- Write a 4-5 page report to `teams/team_21/report/report.md`
- Follow the standard 8-section report template in PLAN.md exactly
- Note: your report will be reviewed by an independent peer review agent

## Constraints

- R only for data analysis (tidyverse style)
- Do not modify files outside your team folder (except reading shared data)
- Do not modify `data/agent_corpus.rds`
- Final analysis must use regression. Text analysis is permitted for constructing
  outcome or control variables, but the main estimand must be tested via regression.
- Causal inference: aim for designs supporting causal identification (country FE,
  year FE, DiD, event study). Discuss identification threats explicitly.
- Computationally heavy tasks: if your analysis will take more than ~5 minutes,
  or involves looping over individual abstracts at scale, flag this to the PI first.
- External API calls: permitted if your complexity rating is Medium or Complex.
  Disclose the API used, estimated cost, and sample strategy. Flag actual cost
  incurred in analysis.R comments.
- You must scan other teams' rq.md files before finalising your own -- see
  uniqueness check instructions in your Designer prompt.

