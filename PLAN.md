# AutoKnow Agent Orchestra — Project Plan

**Paper:** How does autocracy shape the social sciences and humanities?
**Method:** Multi-agent research orchestra (10 teams x 3 agents)
**Status:** Planning phase
**Last updated:** 2026-02-26

---

## Research question

> How does autocracy shape social science and the humanities?

This is the **overarching question** given to every team. Each team independently
decides how to operationalize and investigate it. No topic is pre-assigned.

---

## Data

### Bibliometric corpus
- **File:** `data/agent_corpus.rds` (produced by Phase 0)
- **Source:** Web of Science, filtered to SSH articles, 1970-2023
- **Unit:** One row = one article x one author-country
- **Full WOS source:** `DATA/bibliometric/WOS_scrapes/wos_articles.rds`
  (7,516,459 articles; ~8-10 GB RAM to load — use agent_corpus.rds instead)

Key columns available to teams:

| Column | Description |
|--------|-------------|
| `ut` | WOS article ID |
| `country` | Standardized author country |
| `iso3` | ISO3 country code |
| `year` | Publication year (1970-2023) |
| `v2x_libdem` | V-DEM liberal democracy index (0-1, continuous) — **primary regime measure** |
| `v2x_regime` | Regime type: 0=closed autocracy, 1=electoral autocracy, 2=electoral democracy, 3=liberal democracy |
| `regime_binary` | 0 = autocracy (v2x_regime <= 1), 1 = democracy (v2x_regime >= 2) |
| `title` | Article title |
| `abstract` | Full abstract |
| `keywords` | Author-supplied keywords |
| `keywords_plus` | WOS KeyWords Plus |
| `subject_categories` | WOS subject categories (semicolon-separated) |
| `subject_primary` | First listed subject category |
| `journal` | Journal name |
| `tot_cites` | Raw lifetime citation count — **do not use as outcome without normalization** |
| `field_year_mean_cites` | Mean citations for articles with same subject_primary and year — use to normalize tot_cites |
| `n_articles_country_year` | Total SSH articles from that country in that year — use as denominator for volume analyses |
| `n_articles_country_year_field` | Total SSH articles from that country, year, and subject_primary — field-specific denominator |
| `n_authors` | Number of authors |
| `institutions` | Author institutions (semicolon-separated) |
| `grant_agencies` | Funding agencies (semicolon-separated) |
| `date` | Full publication date |

**Note on pre-1990 data:** WOS coverage before ~1990 is thin and biased toward
English-language and Western-institution journals. Time-trend analyses should
treat pre-1990 estimates with caution and consider restricting to 1990-2023.

**Note on citations:** `tot_cites` reflects raw lifetime counts. Citation norms
differ by an order of magnitude across SSH fields (e.g. economics vs. history).
Always normalize using `field_year_mean_cites` before making cross-field comparisons.
Interpret citation patterns as indicators of visibility and uptake, not quality.

### V-DEM (standalone)
- **File:** `DATA/vdem/vdem_clean.rds`
- **Coverage:** 182 countries, 1970-2023 (9,170 country-year rows)
- **Variables:** `country_name`, `country_text_id`, `year`, `v2x_libdem`,
  `v2x_regime`, `regime_binary`
- **Regime distribution (country-years):** closed autocracy 2,626 /
  electoral autocracy 2,789 / electoral democracy 2,006 / liberal democracy 1,748
- **Codebook:** `data/vdem_codebook.md` — variable definitions, binary cutoff,
  guidance on which measure to use for which type of analysis

---

## Design decisions (confirmed)

| Decision | Choice |
|----------|--------|
| Scope | Social sciences and humanities (SSH) |
| SSH field list | `ssh_fields.txt` — 50 confirmed WOS subject categories |
| Country assignment | All author countries (one article-country row per unique country per article) |
| Primary democracy measure | `v2x_libdem` (continuous, 0-1) |
| Secondary measures | `v2x_regime` (0-3 ordinal) + `regime_binary` — use for robustness checks |
| Time window | 1970-2023 (treat pre-1990 with caution) |
| N estimation | Run Phase 0 before teams start; validate output before launching teams |

---

## Phase 0 — Shared data preparation

**Goal:** Produce one analysis-ready file used by all 10 teams.
**Script:** `scripts/00_prepare_data.R`
**Output:** `data/agent_corpus.rds` + `data/n_summary.txt`

### Steps

1. **Load WOS data**
   - Read `DATA/bibliometric/WOS_scrapes/wos_articles.rds` (~10 GB RAM)
   - Check available system RAM at script start; abort with message if below 10 GB
   - Filter to `doc_type == "Article"` (exclude reviews, meeting abstracts, etc.)
   - Filter `date` to 1970-2023

2. **Filter to SSH fields**
   - Read `ssh_fields.txt` (ignoring lines starting with `#`)
   - Keep articles where any semicolon-delimited entry in `subject_categories`
     matches the SSH list (case-insensitive, trimmed whitespace)

3. **Expand to article-country rows**
   - The `countries` field is semicolon-delimited (e.g. `"USA; Germany; China"`)
   - Split on `"; "` -> one row per unique country per article (`ut` repeats)
   - Standardize country strings to ISO3 using `countrycode` package
   - Report and save the top 20 unmatched country strings to `data/country_match_log.txt`
   - If unmatched rate > 5% of article-country rows, treat as a blocker and
     do not proceed until resolved

4. **Merge V-DEM**
   - Load `DATA/vdem/vdem_clean.rds`
   - Left-join to article-country rows on `iso3` x `year`
   - Unmatched rows (small territories, etc.) retain NA regime scores

5. **Compute derived variables**
   - `field_year_mean_cites`: mean `tot_cites` grouped by `subject_primary` x `year`
   - `n_articles_country_year`: count of distinct `ut` per `country` x `year`
   - `n_articles_country_year_field`: count of distinct `ut` per `country` x `year`
     x `subject_primary`
   - Join these back to the article-country rows

6. **N estimation** — print and save to `data/n_summary.txt`:
   - Total SSH articles after filtering
   - V-DEM join rate (% of article-country rows matched)
   - Total article-country rows
   - Breakdown by `v2x_regime` category
   - Breakdown by decade
   - Top 10 subject categories by article count

7. **Save** `data/agent_corpus.rds`

### Phase 0 validation gate (mandatory before Phase 1)

Before creating any team folder or launching any session, the PI must:

- [ ] Open `data/n_summary.txt` and confirm N counts are plausible
- [ ] Open `data/country_match_log.txt` and confirm unmatched rate is < 5%
- [ ] Load `data/agent_corpus.rds` in R and spot-check 10 random rows
- [ ] Confirm `field_year_mean_cites` and `n_articles_country_year` are non-NA
      for the majority of rows
- [ ] Sign off: only then proceed to creating team folders

---

## Folder structure

The full project folder layout. Each team has its own dedicated subfolder.
Use `scripts/scaffold_teams.R` to create all 10 team directories at once.

```
Autocracy and science_Agent Orchestra/
|
|-- PLAN.md                      <- this file
|-- PLAN.pdf                     <- rendered version of this file
|-- ssh_fields.txt               <- SSH WOS subject category list
|-- render_plan.ps1              <- renders PLAN.md to PLAN.pdf
|
|-- scripts/
|   |-- 00_prepare_data.R        <- Phase 0 data prep (run once)
|   `-- scaffold_teams.R         <- creates all team folder structures
|
|-- data/
|   |-- agent_corpus.rds         <- shared analysis dataset (Phase 0 output)
|   |-- n_summary.txt            <- N counts by regime, decade (Phase 0 output)
|   |-- country_match_log.txt    <- unmatched country strings (Phase 0 output)
|   `-- vdem_codebook.md         <- V-DEM variable definitions and guidance
|
|-- teams/
|   |-- team_01/
|   |   |-- brief.md             <- PI-written mandate (copy template, fill N)
|   |   |-- rq.md                <- team's RQ (Designer output; PI reviews before Analyst)
|   |   |-- analysis_plan.md     <- method plan (Designer output; PI reviews before Analyst)
|   |   |-- pi_notes.md          <- optional PI feedback at any point
|   |   |-- analysis/
|   |   |   |-- analysis.R       <- R script (Analyst output)
|   |   |   `-- figures/         <- plots and tables (Analyst output)
|   |   `-- report/
|   |       `-- report.md        <- 4-5 page report (Writer output; PI reviews)
|   |-- team_02/ ... team_10/
|   |   `-- [same structure]
|
`-- synthesis/
    |-- outline.md               <- paper structure + team summaries (agent output)
    |-- synthesis_paper.md       <- joint paper (PI-written, agent-assisted)
    `-- figures/                 <- figures used in synthesis paper
```

---

## Phase 1 — Team workflow

### Revised invocation sequence

Teams are **not** run fully in parallel from start to finish. The workflow
has two mandatory PI review gates:

```
Step A  All 10 Designers run (produce rq.md + analysis_plan.md)
           |
Step B  PI reviews all 10 rq.md files
        -> check for convergence (redirect duplicates)
        -> check for coverage gaps
        -> approve or redirect each team
           |
Step C  All 10 Analysts run (produce analysis.R + figures)
           |
Step D  PI reviews each team's figures and a numeric summary
        -> confirm analysis is methodologically sound
        -> approve or redirect
           |
Step E  All 10 Writers run (produce report.md)
           |
Step F  PI reads all 10 reports -> proceed to Phase 2
```

This structure catches RQ convergence before any computation is wasted,
and catches analytic errors before they are embedded in a report.

### How to invoke each step

**Step A — Designer (all teams):**
Open a Claude Code session per team (can be parallel). Say:
> "You are research team [N]. Read `teams/team_[N]/brief.md`. Complete
> Step 1 only (Designer role): write `rq.md` and `analysis_plan.md`.
> Stop after that and wait for PI approval."

**Step B — PI review gate:**
Read all `teams/team_##/rq.md` and `teams/team_##/analysis_plan.md`.
If two teams have converged, open one session and redirect it.
When satisfied, proceed to Step C.

**Step C — Analyst (all teams):**
Resume or open each team session. Say:
> "Your `rq.md` is approved. Proceed to Step 2 (Analyst role):
> write and run `analysis/analysis.R`, save figures to `analysis/figures/`.
> Stop after that and wait for PI review."

**Step D — PI review gate:**
Open each team's `analysis/figures/` folder and review outputs.
If the analysis has a methodological error, open the session and redirect.
When satisfied, proceed to Step E.

**Step E — Writer (all teams):**
Resume or open each team session. Say:
> "Your analysis is approved. Proceed to Step 3 (Writer role):
> write `report/report.md` using the standard report template."

### PI communication channels

| Channel | When | Purpose |
|---------|------|---------|
| `brief.md` | Before Step A | Initial mandate; the only pre-run instruction |
| Chat input | Any step | Direct correction or guidance during a live session |
| `pi_notes.md` | Any step | PI drops a note file in the team folder; agent checks for it |
| Step B gate | After Designer | Review rq.md + analysis_plan.md; approve or redirect before any computation |
| Step D gate | After Analyst | Review figures; approve or redirect before report is written |
| `report/report.md` | After Step E | Final output review |

### Team brief template

Copy this to `teams/team_[N]/brief.md` before invoking the team.
Fill in the team number wherever `[N]` appears.

```markdown
# Research Team [N] — Brief

## Your mandate

You are an independent research team. Investigate the overarching research
question below using the provided data. You decide how to approach it.
Do not coordinate with or look at other teams' folders.

## Overarching research question

> How does autocracy shape social science and the humanities?

You are free to operationalize this in any way you find interesting and
tractable with the available data. Choose your own angle, variables, and method.

## Available data

- `data/agent_corpus.rds` — SSH articles from Web of Science, 1970-2023,
  merged with V-DEM regime data. One row = one article x one author-country.
  See PLAN.md for the full variable list and usage notes.
- `DATA/vdem/vdem_clean.rds` — V-DEM country-year data (standalone).
- `data/vdem_codebook.md` — variable definitions and guidance.

Key data notes:
- **Primary regime measure:** `v2x_libdem` (continuous, 0-1). Use this as
  your main independent variable. Report at least one robustness check using
  `v2x_regime` or `regime_binary`.
- **Citations:** Do not use `tot_cites` raw as an outcome. Use
  `field_year_mean_cites` to normalize, or restrict comparisons to within-field.
- **Volume analyses:** Use `n_articles_country_year` as the denominator when
  comparing counts across countries or regime types.
- **Pre-1990 data:** Treat estimates before 1990 with caution — WOS coverage
  is thin and biased toward English-language and Western journals.

## Your tasks — complete in order, stop between steps for PI review

### Step 1 — Research question (Designer role)
- Load and inspect `data/agent_corpus.rds` (use a small sample first)
- Develop a specific, answerable research question addressing the overarching question
- Write to `teams/team_[N]/rq.md`:
  - Your research question (one sentence)
  - Rationale (2-3 sentences)
  - Estimand: what quantity are you trying to estimate?
  - Unit of analysis
  - Outcome variable (exact column name)
  - Key independent variable (exact column name)
- Write to `teams/team_[N]/analysis_plan.md`:
  - Method (regression, tabulation, text analysis, etc.)
  - Model specification (if regression: outcome, predictors, fixed effects,
    standard error clustering)
  - Expected output files (list each figure/table you plan to produce)
- **Stop here. Wait for PI approval before proceeding.**

### Step 2 — Analysis (Analyst role)
*Begin only after PI has approved your rq.md.*
- Write R code in `teams/team_[N]/analysis/analysis.R` (tidyverse style)
- Produce 2-4 figures or tables; save to `teams/team_[N]/analysis/figures/`
- Include at least one robustness check using an alternative regime measure
- If data cannot adequately address your RQ, revise `rq.md` first, then analyze
- **Stop here. Wait for PI review of your figures before writing the report.**

### Step 3 — Report (Writer role)
*Begin only after PI has approved your analysis.*
- Write a 4-5 page report to `teams/team_[N]/report/report.md`
- Follow the standard report template (see PLAN.md)

## Constraints

- R only for data analysis (tidyverse style)
- Do not modify files outside your team folder (except reading shared data)
- Do not modify `data/agent_corpus.rds`
- **Computationally heavy tasks:** If your planned analysis will take more than
  ~5 minutes to run, or involves looping over individual abstracts/keywords at
  scale, describe what you plan to do and ask the PI before starting.
- **External API calls:** Do not make any calls to external APIs from your R
  code (OpenAI, Anthropic, HuggingFace, or any other service) without explicit
  PI approval. This includes embedding APIs, classification APIs, and LLMs.
```

### Handoff document schemas

**`rq.md` must contain:**
- Research question (one sentence)
- Rationale (2-3 sentences)
- Estimand
- Unit of analysis
- Outcome variable (exact column name from corpus schema)
- Key independent variable (exact column name)

**`analysis_plan.md` must contain:**
- Method
- Model specification (if regression: formula, fixed effects, SE clustering)
- List of expected output files (each figure/table by name)

If either file is missing required fields, the PI will redirect before Step C.

### Report template

Each team's `report/report.md` must follow this structure:

```markdown
# Team [N]: [Short title]

## Research question
One sentence stating the specific RQ.

## Data and operationalization
Describe what you measured and how: which variables, what filtering, how the
regime variable was operationalized. State the final analytic sample size (N
articles or N article-country rows). Note any deviations from the data schema.

## Methods
Specify the method, model, unit of analysis, outcome variable, key independent
variable, any fixed effects, and how standard errors are handled. If text
analysis: describe the dictionary or classification approach. 2-4 sentences.

## Main findings
2-4 key results stated in plain language. Reference each figure or table by
filename (e.g. "Figure 1: `figures/cites_by_regime.png`"). Include the
direction, magnitude, and statistical significance of the main estimate.
Report at least one robustness check.

## Figures and tables
List each output file with a one-line caption.

## Discussion
Interpret the findings in relation to the overarching research question.
Note the main limitations of this analysis: what confounders are unaddressed,
what the data cannot establish, what causal claims are and are not supported.
1-2 paragraphs.
```

---

## Phase 2 — Synthesis paper

**The PI writes the synthesis paper.** The agent's role is to assist with
structure and drafting only — all drafts are treated as raw material.

**Invocation:**
> "Read all files in `teams/team_*/rq.md` and `teams/team_*/report/report.md`.
> Produce `synthesis/outline.md` containing: (1) a 1-2 sentence summary of
> each team's RQ and key finding, (2) a proposed paper outline with section
> headers and bullet-point content for each section, (3) a list of cross-cutting
> themes you identify across the 10 reports."

| Section | Content |
|---------|---------|
| Abstract | 150-word summary |
| Introduction | Overall RQ, motivation, what the agent orchestra method contributes |
| Data and method | Data sources; Phase 0 pipeline; agent team structure and workflow |
| Findings | One subsection per team (~1 page each): RQ, approach, key result |
| Synthesis | Cross-cutting themes; aggregate picture of autocracy and SSH |
| Conclusion | What we learn; what this method can and cannot establish |
| Appendix A | N summary from `data/n_summary.txt` |
| Appendix B | All 10 team RQs |

---

## Status and pending tasks

### Done
- [x] SSH field list (`ssh_fields.txt`) — 50 confirmed categories
- [x] V-DEM data downloaded (`DATA/vdem/vdem_clean.rds`)
- [x] Plan written and rendered to PDF

### Ordered task sequence (do not skip steps)

1. [ ] Finalize `ssh_fields.txt` borderline categories (Architecture, Hospitality,
       Nursing, Rehabilitation, Substance Abuse, Transportation)
2. [ ] Decide whether to include "Review" doc_type alongside "Article"
3. [ ] Confirm ~10 GB RAM available for Phase 0
4. [ ] Run `scripts/00_prepare_data.R`
5. [ ] **Phase 0 validation gate** — check n_summary.txt, country_match_log.txt,
       spot-check agent_corpus.rds (see validation checklist above)
6. [ ] Create `data/vdem_codebook.md` (done — see data folder)
7. [ ] Run `scripts/scaffold_teams.R` to create all team folders
8. [ ] Copy `brief.md` template to each team folder, fill in team number
9. [ ] Run all 10 Designer sessions (Step A)
10. [ ] **PI review gate B** — review all rq.md files, check convergence, approve
11. [ ] Run all 10 Analyst sessions (Step C)
12. [ ] **PI review gate D** — review all figures, approve methodology
13. [ ] Run all 10 Writer sessions (Step E)
14. [ ] Read all 10 reports; proceed to Phase 2

---

## Open questions (deferred)

- Should the synthesis paper treat this as primarily a methodological or
  substantive contribution? Likely both; the method section should be prominent.
- If two teams converge on the same RQ at Step B, redirect one — the PI
  can suggest a different angle without specifying a full topic.
- Estimated session time per team: roughly 45-90 minutes per team
  (Designer ~15 min, Analyst ~45-60 min, Writer ~15-20 min). Plan accordingly.
