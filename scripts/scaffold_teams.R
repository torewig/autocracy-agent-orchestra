# scaffold_teams.R
# Creates the standard folder structure for all 10 research teams.
# Run once after Phase 0 validation is complete.
# Writes brief.md (with team number filled in) to each team folder.

library(fs)

project_root <- here::here()  # run from project root
teams_dir <- file.path(project_root, "teams")

brief_template <- function(n) {
  sprintf('# Research Team %02d -- Brief

## Your mandate

You are an independent research team. Investigate the overarching research
question below using the provided data. You decide how to approach it.
Do not coordinate with or look at other teams\' folders.

## Overarching research question

> How does autocracy shape social science and the humanities?

You are free to operationalize this in any way you find interesting and
tractable with the available data. Choose your own angle, variables, and method.

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

## Your tasks -- complete in order, stop between steps for PI review

### Step 1 -- Research question (Designer role)
- Load and inspect `data/agent_corpus.rds` (use a small sample first)
- Develop a specific, answerable research question addressing the overarching question
- Write to `teams/team_%02d/rq.md`:
  - Your research question (one sentence)
  - Rationale (2-3 sentences)
  - Estimand, unit of analysis, outcome variable, key independent variable
- Write to `teams/team_%02d/analysis_plan.md`:
  - Method, model specification, list of expected output files
- STOP HERE. Wait for PI approval before proceeding.

### Step 2 -- Analysis (Analyst role)
*Begin only after PI has approved your rq.md.*
- Write R code in `teams/team_%02d/analysis/analysis.R` (tidyverse style)
- Produce 2-4 figures or tables; save to `teams/team_%02d/analysis/figures/`
- Include at least one robustness check using an alternative regime measure
- STOP HERE. Wait for PI review of your figures before writing the report.

### Step 3 -- Report (Writer role)
*Begin only after PI has approved your analysis.*
- Write a 4-5 page report to `teams/team_%02d/report/report.md`
- Follow the standard report template in PLAN.md

## Constraints

- R only for data analysis (tidyverse style)
- Do not modify files outside your team folder (except reading shared data)
- Do not modify `data/agent_corpus.rds`
- Computationally heavy tasks: if your analysis will take more than ~5 minutes,
  or involves looping over individual abstracts at scale, ask the PI first.
- External API calls: do not call any external APIs (OpenAI, Anthropic,
  HuggingFace, etc.) from your R code without explicit PI approval.
', n, n, n, n, n, n)
}

for (i in 1:10) {
  team_dir <- file.path(teams_dir, sprintf("team_%02d", i))
  dir_create(file.path(team_dir, "analysis", "figures"), recurse = TRUE)
  dir_create(file.path(team_dir, "report"), recurse = TRUE)
  writeLines(brief_template(i), file.path(team_dir, "brief.md"))
  cat(sprintf("Created: teams/team_%02d/\n", i))
}

cat("\nDone. All 10 team folders created with brief.md.\n")
cat("Next: run all Designer sessions (Step A), then review rq.md files.\n")
