# scaffold_teams.R
# Creates the standard folder structure for all 27 research teams (v2, revised 2026-04-20).
# Teams 28-30 were dropped in the 2026-04-20 revision (old regime-channels designs archived).
# Teams 23-27 were redesigned as the ideological-alignment sub-family.
# Run to regenerate brief.md files if needed.

library(fs)

project_root <- here::here()  # run from project root
teams_dir <- file.path(project_root, "teams")

# --- Domain assignment lookup (one entry per team) ---
domains <- list(
  `01` = list(
    domain = "Share of abstract text containing political-content keywords (PCI score), aggregated to country-year",
    subfamily = "topic-avoidance",
    complexity = "Simple",
    approach = "Dictionary-based keyword counting in abstracts — no external API required"
  ),
  `02` = list(
    domain = "Topical diversity of SSH keywords: breadth of author-supplied keyword vocabulary per country-year",
    subfamily = "topic-avoidance",
    complexity = "Simple",
    approach = "Aggregate author keywords per country-year — no external API required"
  ),
  `03` = list(
    domain = "Disciplinary composition: share of SSH output in politically sensitive fields (political science, law, sociology, IR)",
    subfamily = "topic-avoidance",
    complexity = "Simple",
    approach = "Classify subject_categories into sensitive vs. neutral fields — no external API required"
  ),
  `04` = list(
    domain = "Regime-sensitive keyword prevalence: share of articles mentioning democracy, human rights, corruption, protest",
    subfamily = "topic-avoidance",
    complexity = "Simple",
    approach = "Dictionary-based regex match on title + keywords — no external API required"
  ),
  `05` = list(
    domain = "Critical domestic governance framing: LLM-classified share of articles critically examining own-country institutions",
    subfamily = "topic-avoidance",
    complexity = "Complex",
    approach = "External LLM API required (Claude Haiku or equivalent) for abstract classification; use stratified sample to manage cost"
  ),
  `06` = list(
    domain = "Semantic diversity of abstracts: pairwise cosine distance of text embeddings within country-field-year clusters",
    subfamily = "topic-avoidance",
    complexity = "Complex",
    approach = "External embedding API required (OpenAI or equivalent); use stratified sample to manage cost; estimate ~$10 for full corpus"
  ),
  `07` = list(
    domain = "Share of abstracts mentioning international funding agencies (proxy for cross-border topic permission)",
    subfamily = "topic-avoidance",
    complexity = "Simple",
    approach = "Regex/string match on acknowledgment / grant_agencies field — no external API required"
  ),
  `08` = list(
    domain = "Rhetorical hedging: frequency of epistemic hedging language (may, might, seem, appear, suggest) per abstract",
    subfamily = "framing-neutrality",
    complexity = "Simple",
    approach = "Dictionary count of hedging terms normalised by abstract length — no external API required"
  ),
  `09` = list(
    domain = "Normative language avoidance: frequency of evaluative/normative terms (should, ought, justice, rights, freedom) per abstract",
    subfamily = "framing-neutrality",
    complexity = "Simple",
    approach = "Dictionary count of normative terms normalised by abstract length — no external API required"
  ),
  `10` = list(
    domain = "Technocratic framing: share of abstracts using exclusively technical vocabulary with no political reference (LLM classifier)",
    subfamily = "framing-neutrality",
    complexity = "Complex",
    approach = "External LLM API required for binary classification; stratified sample recommended"
  ),
  `11` = list(
    domain = "First-person argumentative stance: rate of 'we argue / I argue / we show' phrases per abstract length",
    subfamily = "framing-neutrality",
    complexity = "Simple",
    approach = "Regex match on stance phrases normalised by abstract word count — no external API required"
  ),
  `12` = list(
    domain = "Normative conclusion claims: whether abstracts make a normative or policy claim vs. purely descriptive (LLM binary label)",
    subfamily = "framing-neutrality",
    complexity = "Complex",
    approach = "External LLM API required; focus on final sentence(s) of abstract; stratified sample"
  ),
  `13` = list(
    domain = "Journal domesticity: share of SSH output published in domestic (same-country) vs. international journals",
    subfamily = "framing-neutrality",
    complexity = "Medium",
    approach = "Match journal country of publication to author country — requires constructing journal-country lookup from corpus; no external API"
  ),
  `14` = list(
    domain = "International co-authorship: number of distinct co-author countries per article",
    subfamily = "collaboration-constraint",
    complexity = "Simple",
    approach = "Count distinct iso3 values per wos_id — directly from corpus; no external API required"
  ),
  `15` = list(
    domain = "Democratic co-authorship: co-authorship links to liberal democracies only (v2x_libdem > 0.5 in co-author country-year)",
    subfamily = "collaboration-constraint",
    complexity = "Medium",
    approach = "Identify co-author countries with v2x_libdem > 0.5; requires cross-joining article-country rows — no external API"
  ),
  `16` = list(
    domain = "Domestic-only authorship: share of articles where all author countries are the same country",
    subfamily = "collaboration-constraint",
    complexity = "Simple",
    approach = "Count distinct iso3 per wos_id; flag as domestic-only if n_distinct == 1 — no external API required"
  ),
  `17` = list(
    domain = "Author count per article: whether autocracy reduces mean team size at country-year level",
    subfamily = "collaboration-constraint",
    complexity = "Simple",
    approach = "Aggregate n_authors to country-year mean — directly from corpus; no external API required"
  ),
  `18` = list(
    domain = "Institutional diversity: number of distinct author institutions per article",
    subfamily = "collaboration-constraint",
    complexity = "Medium",
    approach = "Parse institutions field per article — requires string splitting; no external API required"
  ),
  `19` = list(
    domain = "Normalized citation impact: field-year adjusted citation rate for articles from autocracies",
    subfamily = "visibility-suppression",
    complexity = "Simple",
    approach = "Use field_year_mean_cites to compute cite_ratio = tot_cites / field_year_mean_cites — directly from corpus"
  ),
  `20` = list(
    domain = "Citation gap by topic sensitivity: whether politically sensitive articles (keyword flag) from autocracies are cited less",
    subfamily = "visibility-suppression",
    complexity = "Medium",
    approach = "Combine team 04 sensitive-keyword flag logic with citation outcome; interaction model; no external API"
  ),
  `21` = list(
    domain = "Citation impact and co-authorship interaction: whether international co-authorship mediates the autocracy-citation gap",
    subfamily = "visibility-suppression",
    complexity = "Medium",
    approach = "Mediation/interaction model: v2x_libdem x n_co_countries on cite_ratio — no external API required"
  ),
  `22` = list(
    domain = "Citation concentration: whether autocracy predicts higher Gini concentration of citations within country-year",
    subfamily = "visibility-suppression",
    complexity = "Simple",
    approach = "Compute Gini coefficient of tot_cites per country-year — requires ineq or custom Gini function; no external API"
  ),
  `23` = list(
    domain = "Ideological lean (left-right): LLM-classified share of abstracts using left-wing (statist, redistributive, collectivist, anti-capitalist) vs. right-wing (market, nationalist, traditionalist) vs. neutral political-economy framing",
    subfamily = "ideological-alignment",
    complexity = "Complex",
    approach = "External LLM API required (Claude Haiku or GPT-4o-mini); four-way classifier (LEFT / RIGHT / NATIONALIST / NEUTRAL) applied to stratified sample of abstracts; estimated cost $3-6"
  ),
  `24` = list(
    domain = "Regime legitimation framing: LLM-classified share of abstracts that frame the current political system, state authority, party, or leadership as effective, stable, or beneficial (positive mirror of Team 05's critical-framing test)",
    subfamily = "ideological-alignment",
    complexity = "Complex",
    approach = "External LLM API required; binary classifier (LEGITIMATING vs. NON-LEGITIMATING) on stratified abstract sample; estimated cost $2-4"
  ),
  `25` = list(
    domain = "Anti-liberal-democracy framing: LLM-classified share of abstracts that explicitly critique liberal democracy, Western political norms, international democratic institutions, or human rights as Western imposition",
    subfamily = "ideological-alignment",
    complexity = "Complex",
    approach = "External LLM API required; binary classifier (ANTI-LIBERAL vs. OTHER) on stratified abstract sample; estimated cost $2-4"
  ),
  # Teams 26-30 dropped. Folders preserved with DROPPED.md.
  # All old designs archived in archive/teams_v2_regime_channels/.
)

# --- Brief template ---
brief_template <- function(n) {
  nn  <- sprintf("%02d", n)
  key <- nn
  d   <- domains[[key]]

  sprintf('# Research Team %s -- Brief

## Your mandate

You are an independent research team. Your domain assignment below specifies
the angle you will investigate. The Designer will develop the specific research
question and analysis plan within that domain. Do not drift into other teams\' domains.

## Domain assignment

**Your domain:** %s
**Sub-family label (use exactly this for theory_family):** `%s`
**Complexity:** %s
**Permitted measurement approach:** %s

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
- Write to `teams/team_%s/rq.md`:
  - Your research question (one sentence)
  - Rationale (2-3 sentences)
  - Theoretical mechanism (2-4 sentences): causal pathway, named actors/incentives,
    expected direction
  - Theory family: use exactly the sub-family label from your domain assignment
  - Estimand, unit of analysis, outcome variable (exact column name), key IV
  - Uniqueness check note (see Designer prompt for instructions)
- Write to `teams/team_%s/analysis_plan.md`:
  - Method (regression required; text analysis may construct outcome/control variables)
  - Model specification: outcome, predictors, fixed effects, SE clustering
  - Causal identification strategy: variation exploited, confounders controlled,
    identification threats
  - List of expected output files
- STOP HERE. Wait for PI approval before proceeding.

### Step 2 -- Analysis (Analyst role)
*Begin only after PI has approved your rq.md and analysis_plan.md.*
- Write R code in `teams/team_%s/analysis/analysis.R` (tidyverse style)
- Your main analysis must use regression (lm, feols, or equivalent)
- Text analysis is permitted for constructing outcome/control variables
- Produce 2-4 figures or tables; save to `teams/team_%s/analysis/figures/`
- Save a `teams/team_%s/analysis/primary_results.json` with fields:
  team, hypothesis_label, theory_family, predictor, outcome,
  coefficient, SE, p_value, n_obs
- Include at least one robustness check using an alternative regime measure
- STOP HERE. Wait for PI review of your figures before writing the report.

### Step 3 -- Report (Writer role)
*Begin only after PI has approved your analysis.*
- Write a 4-5 page report to `teams/team_%s/report/report.md`
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
- You must scan other teams\' rq.md files before finalising your own -- see
  uniqueness check instructions in your Designer prompt.
', nn, d$domain, d$subfamily, d$complexity, d$approach,
     nn, nn, nn, nn, nn, nn)
}

# --- Scaffold all 25 teams (Teams 26-30 dropped 2026-04-20) ---
for (i in 1:25) {
  team_dir <- file.path(teams_dir, sprintf("team_%02d", i))
  dir_create(file.path(team_dir, "analysis", "figures"), recurse = TRUE)
  dir_create(file.path(team_dir, "report"), recurse = TRUE)
  writeLines(brief_template(i), file.path(team_dir, "brief.md"))
  cat(sprintf("Created: teams/team_%02d/\n", i))
}

cat("\nDone. All 25 team folders created with brief.md.\n")
cat("Teams 26-30 are dropped; their folders have DROPPED.md.\n")
cat("Next: run Designer sessions for teams 23-25 (ideological-alignment, all Complex).\n")
cat("See TIMELINE.md for the full schedule.\n")

