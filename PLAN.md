# AutoKnow Agent Orchestra — Project Plan (v2)

**Paper:** How does autocracy, and type of autocracy, impact on the contents, direction and scientific progress of the social sciences and humanities?
**Method:** Multi-agent research orchestra — 25 teams, each testing one implication of the self-censorship theory
**Version:** 2.2 | **Last updated:** 2026-04-20

---

## Research question

> How does autocracy, and type of autocracy, impact on the contents, direction
> and scientific progress of the social sciences and humanities?

All 25 teams investigate this overarching question through the lens of a single
unified theory: **self-censorship**. Each team tests one specific, distinct
implication of the theory using the shared bibliometric corpus.

---

## Unified theory: Self-censorship

**Core claim:**
> *Researchers in autocracies self-censor by avoiding politically sensitive
> topics, methods, collaborations, and framings to minimize career risks.*

This is the **organizing theory for all 25 teams**. Every team's RQ must state
a specific, testable implication of this theory within their assigned domain.
Every team's report must include a section (Section 8) evaluating whether their
evidence supports this theory.

### Five sub-families (Bonferroni groups)

| Sub-family label | Core claim | Teams | k | Threshold |
|-----------------|-----------|-------|---|-----------|
| `topic-avoidance` | Autocracy reduces engagement with politically sensitive topics, keywords, or disciplines | 01–07 | 7 | p < 0.0071 |
| `framing-neutrality` | Autocracy shifts the rhetorical and analytical stance of research toward neutral, technocratic, or hedged language | 08–13 | 6 | p < 0.0083 |
| `collaboration-constraint` | Autocracy limits international and cross-institutional collaboration | 14–18 | 5 | p < 0.0100 |
| `visibility-suppression` | Research from autocracies receives lower citation impact or diffusion | 19–22 | 4 | p < 0.0125 |
| `ideological-alignment` | Autocracy shapes the positive ideological content of SSH output — not just what is avoided, but what political ideas are actively present | 23–25 | 3 | p < 0.0167 |

Bonferroni correction is applied **within** each sub-family at Step D'. The
significance threshold within a family of k tests is p < 0.05/k. Teams 26–30
were dropped in the 2026-04-20 revision; their designs are archived.

### 25-team domain assignments

| Team | Domain (assigned angle) | Sub-family | Complexity |
|------|------------------------|-----------|------------|
| 01 | Political-content keyword score (PCI) in abstracts, aggregated to country-year | `topic-avoidance` | Simple |
| 02 | Topical diversity: breadth of author-supplied keyword vocabulary per country-year | `topic-avoidance` | Simple |
| 03 | Disciplinary composition: share of output in sensitive fields (pol. sci., law, sociology, IR) | `topic-avoidance` | Simple |
| 04 | Regime-sensitive keyword prevalence: democracy, human rights, corruption, protest | `topic-avoidance` | Simple |
| 05 | Critical domestic governance framing: LLM-classified share of articles examining own-country institutions | `topic-avoidance` | Complex |
| 06 | Semantic diversity: pairwise cosine distance of text embeddings within country-field-year clusters | `topic-avoidance` | Complex |
| 07 | Share of abstracts mentioning international funding agencies | `topic-avoidance` | Simple |
| 08 | Epistemic hedging: frequency of hedging language (may, might, seem, appear, suggest) per abstract | `framing-neutrality` | Simple |
| 09 | Normative language: frequency of evaluative/normative terms (should, ought, justice, rights, freedom) | `framing-neutrality` | Simple |
| 10 | Technocratic framing: share of abstracts with exclusively technical vocabulary (LLM classifier) | `framing-neutrality` | Complex |
| 11 | First-person argumentative stance: rate of "we argue / I argue / we show" per abstract | `framing-neutrality` | Simple |
| 12 | Normative conclusion claims: whether abstracts make a normative/policy claim (LLM binary label) | `framing-neutrality` | Complex |
| 13 | Journal domesticity: share of output in domestic vs. international journals | `framing-neutrality` | Medium |
| 14 | International co-authorship: distinct co-author countries per article | `collaboration-constraint` | Simple |
| 15 | Democratic co-authorship: co-authorship with liberal democracies (v2x_libdem > 0.5) | `collaboration-constraint` | Medium |
| 16 | Domestic-only authorship: share of articles with all authors from one country | `collaboration-constraint` | Simple |
| 17 | Author count: whether autocracy reduces mean team size at country-year level | `collaboration-constraint` | Simple |
| 18 | Institutional diversity: distinct author institutions per article | `collaboration-constraint` | Medium |
| 19 | Normalized citation impact: field-year adjusted citation rate from autocracies | `visibility-suppression` | Simple |
| 20 | Citation gap by topic: whether sensitive articles from autocracies are cited less | `visibility-suppression` | Medium |
| 21 | Citation-collaboration interaction: whether international co-authorship mediates the autocracy-citation gap | `visibility-suppression` | Medium |
| 22 | Citation concentration: whether autocracy predicts higher Gini of citations within country-year | `visibility-suppression` | Simple |
| 23 | Ideological lean (left–right): LLM-classified share of abstracts using left-wing vs. right-wing vs. neutral political-economy framing; tests whether regime ideology predicts ideological content of SSH output | `ideological-alignment` | Complex |
| 24 | Regime legitimation framing: LLM-classified share of abstracts endorsing or positively framing the current political system, state authority, or leadership | `ideological-alignment` | Complex |
| 25 | Anti-liberal-democracy framing: LLM-classified share of abstracts explicitly critiquing liberal democracy, Western political norms, or international democratic institutions | `ideological-alignment` | Complex |

**Complexity ratings:** Simple = dictionary/regex/standard regression, no API. Medium = data construction required but no external API. Complex = external LLM or embedding API required. **Complex teams: 05, 06, 10, 12, 23, 24, 25** — all scheduled Day 15; estimated total API cost ~$32–65.

---

## Data

### Bibliometric corpus
- **File:** `data/agent_corpus.rds` (produced by Phase 0)
- **Source:** Web of Science, filtered to SSH articles, 1970-2023
- **Unit:** One row = one article × one author-country
- **Full WOS source:** `DATA/bibliometric/WOS_scrapes/wos_ssh_articles.rds`

Key columns available to teams:

| Column | Description |
|--------|-------------|
| `ut` | WOS article ID |
| `country` | Standardized author country |
| `iso3` | ISO3 country code |
| `year` | Publication year (1970-2023) |
| `v2x_libdem` | V-DEM liberal democracy index (0-1, continuous) — **primary regime measure** |
| `v2x_regime` | Regime type: 0=closed autocracy, 1=electoral autocracy, 2=electoral democracy, 3=liberal democracy |
| `lied_binary` | 0 = autocracy (v2x_regime ≤ 1), 1 = democracy (v2x_regime ≥ 2) |
| `v2clacfree` | Academic freedom index (V-DEM) — use for team 30 and robustness checks |
| `v2x_freexp_altinf` | Freedom of expression index (V-DEM) |
| `title` | Article title |
| `abstract` | Full abstract |
| `keywords` | Author-supplied keywords |
| `keywords_plus` | WOS KeyWords Plus |
| `subject_categories` | WOS subject categories (semicolon-separated) |
| `subject_primary` | First listed subject category |
| `journal` | Journal name |
| `tot_cites` | Raw lifetime citation count — **do not use as outcome without normalization** |
| `field_year_mean_cites` | Mean citations for articles with same subject_primary and year |
| `n_articles_country_year` | Total SSH articles from that country in that year |
| `n_articles_country_year_field` | Total SSH articles from that country, year, and subject_primary |
| `n_authors` | Number of authors |
| `institutions` | Author institutions (semicolon-separated) |
| `grant_agencies` | Funding agencies (semicolon-separated) |
| `date` | Full publication date |
| `e_gdppc` | GDP per capita (2011 USD PPP, V-DEM) — log-transform for regression; ~99.7% coverage |
| `e_wb_pop` | Population (World Bank) — log-transform for regression; ~98.6% coverage |

**Pre-1990 data:** WOS coverage before ~1990 is thin and biased toward English-language and Western journals. Treat pre-1990 estimates with caution; consider restricting to 1990-2023.

**Citations:** Always normalize `tot_cites` using `field_year_mean_cites` before cross-field comparisons.

**Control variables:** Include `e_gdppc` and `e_wb_pop` (log-transformed) as standard controls in all regression models.

### V-DEM (standalone)
- **File:** `DATA/vdem/vdem_clean.rds`
- **Coverage:** 182 countries, 1970-2023
- **Codebook:** `data/vdem_codebook.md`

---

## Design decisions (confirmed)

| Decision | Choice |
|----------|--------|
| Scope | Social sciences and humanities (SSH) |
| SSH field list | `ssh_fields.txt` — 50 confirmed WOS subject categories |
| Country assignment | All author countries (one article-country row per unique country per article) |
| Primary democracy measure | `v2x_libdem` (continuous, 0-1) |
| Secondary measures | `v2x_regime` (0-3 ordinal) + `lied_binary` — use for robustness checks |
| Time window | 1970-2023 (treat pre-1990 with caution; restrict to 1990-2023 where appropriate) |
| Unified theory | Self-censorship (see Theory section above) |
| Analysis approach | Final analysis must use regression; text analysis permitted for measurement only |
| Causal inference | Aim for designs supporting causal identification (country FE, year FE, DiD, event study) |
| Theoretical justification | Each team must state causal mechanism and expected direction in rq.md before any analysis |
| Pre-registration | Hypotheses committed to GitHub (timestamped) after PI approval and before any Analyst session |
| Multiple testing | Bonferroni correction within sub-families; PI confirms labels at Gate B; script at Step D' |
| Control variables | `e_gdppc` and `e_wb_pop` (log-transformed) included in all regression models |
| External APIs | Permitted for teams 05, 06, 10, 12, 23, 24, 25 (Complex); all others Simple/Medium — no external API needed |
| Report format | Standardized 8-section structure; all teams use same template (see Report template below) |

---

## Phase 0 — Shared data preparation

**Goal:** Produce one analysis-ready file used by all 25 teams.
**Script:** `scripts/00_prepare_data.R`
**Output:** `data/agent_corpus.rds` + `data/n_summary.txt`

**Status:** Complete — PI signed off 2026-03-20

| Output | Value |
|--------|-------|
| Total SSH articles (distinct) | 2,709,224 |
| Article-country rows | 3,189,557 |
| ISO3 country match rate | 99.98% |
| V-DEM join rate | 99.78% |
| Control variables | e_gdppc and e_wb_pop added from V-DEM (2026-04-20) |

Phase 0 validation checklist (all checked):
- [x] N counts plausible (data/n_summary.txt)
- [x] Unmatched country rate < 5% (data/country_match_log.txt)
- [x] Spot-checked 10 random rows in R
- [x] field_year_mean_cites and n_articles_country_year non-NA for majority of rows
- [x] PI sign-off: 2026-03-20

---

## Folder structure

```
P02_autocracy-science-agent-orchestra/
|
|-- PLAN.md                      <- this file
|-- TIMELINE.md                  <- 30-day project schedule
|-- STATUS.md                    <- current progress tracker
|-- ssh_fields.txt               <- SSH WOS subject category list
|-- render_plan.ps1              <- renders PLAN.md to PLAN.pdf
|
|-- scripts/
|   |-- 00_prepare_data.R        <- Phase 0 data prep (done)
|   |-- scaffold_teams.R         <- creates all 25 team folder structures
|   |-- plot_pipeline.R          <- generates figures/pipeline.png
|   |-- preregister.ps1          <- Step B': creates preregistration.md + git commit/push
|   |-- bonferroni_adjust.R      <- Step D': reads primary_results.json, applies Bonferroni
|   `-- add_controls.R           <- utility: merges GDP/pop controls from V-DEM
|
|-- agents/
|   |-- README.md                <- agent overview and quick reference
|   |-- HOWTO_INVOKE.md          <- step-by-step invocation guide
|   |-- prompt_designer.md       <- Designer session prompt (Step A)
|   |-- prompt_analyst.md        <- Analyst session prompt (Step C)
|   |-- prompt_writer.md         <- Writer session prompt (Step E)
|   |-- prompt_reviewer.md       <- Peer Reviewer session prompt (Step F)
|   |-- prompt_overseer.md       <- Daily overseer prompt (any day)
|   `-- prompt_synthesizer.md    <- Theory synthesis prompt (Step S)
|
|-- figures/
|   `-- pipeline.png             <- pipeline visualization
|
|-- data/
|   |-- agent_corpus.rds         <- shared analysis dataset (Phase 0 output)
|   |-- n_summary.txt            <- N counts by regime, decade
|   |-- country_match_log.txt    <- unmatched country strings
|   |-- vdem_codebook.md         <- V-DEM variable definitions and guidance
|   |-- adjusted_pvalues.rds     <- Bonferroni-adjusted p-values (Step D' output)
|   `-- adjusted_pvalues_report.md <- Human-readable adjustment table (Step D' output)
|
|-- teams/
|   |-- team_01/ ... team_25/ (teams 26-30 dropped; folders preserved with DROPPED.md)
|   |   |-- brief.md             <- domain assignment + mandate (scaffold output)
|   |   |-- rq.md                <- team's RQ (Designer output; PI reviews before Analyst)
|   |   |-- analysis_plan.md     <- method plan (Designer output; PI reviews before Analyst)
|   |   |-- preregistration.md   <- timestamped pre-reg (Step B' output; do not edit)
|   |   |-- pi_notes.md          <- optional PI feedback at any point
|   |   |-- analysis/
|   |   |   |-- analysis.R       <- R script (Analyst output)
|   |   |   |-- primary_results.json <- primary test result (Analyst output)
|   |   |   `-- figures/         <- plots and tables (Analyst output)
|   |   `-- report/
|   |       |-- report.md        <- 4-5 page report (Writer output; 8-section format)
|   |       `-- peer_review.md   <- structured peer review (Reviewer output)
|
|-- synthesis/
|   `-- theory_evaluation.md     <- theory synthesis report (Synthesizer output, Step S)
|
`-- archive/
    |-- teams_v1/                <- v1 teams 01-10 (archived 2026-04-21)
    `-- root_scripts_v1/         <- v1 utility scripts (archived 2026-04-21)
```

---

## Phase 1 — Team workflow

### Pipeline

```
Step A   All 25 Designer sessions (Days 2-5) — COMPLETE 2026-04-20
         Each Designer reads brief.md, loads corpus sample, develops specific
         RQ within assigned domain, checks uniqueness against other teams' rq.md,
         writes rq.md + analysis_plan.md, stops
              |
Step B   PI Review Gate B (Day 7)
         Read all 25 rq.md; check uniqueness, self-censorship framing, domain
         compliance, theory family labels; approve or redirect
              |
Step B'  Pre-registration (Day 9)
         Run scripts/preregister.ps1; commits hypotheses to GitHub (timestamped)
              |
Step C   All 25 Analyst sessions (Days 10-16)
         Analyst reads rq.md + analysis_plan.md; writes analysis.R; runs it;
         saves figures; saves primary_results.json; stops
         [Complex teams 05,06,10,12,23,24,25 scheduled Day 15]
              |
Step D   PI Review Gate D (Day 18)
         Review all 25 figures + primary_results.json; approve or redirect
              |
Step D'  Bonferroni adjustment (Day 20)
         Run scripts/bonferroni_adjust.R; produces adjusted_pvalues.rds
         PI reviews adjusted_pvalues_report.md
              |
Step E   All 25 Writer sessions (Days 20-22)
         Writer reads all files; writes report.md in 8-section format
              |
Step F   All 25 Reviewer sessions (Days 23-24)
         Reviewer reads report.md + rq.md; writes peer_review.md
              |
Step G   PI Review Gate G (Day 25)
         Read all 25 reports + peer reviews; flag issues; approve
              |
Step S   Theory Synthesis (Day 28)
         Synthesizer reads all 25 rq.md + report.md + peer_review.md +
         adjusted_pvalues; writes synthesis/theory_evaluation.md
```

See `TIMELINE.md` for the full day-by-day schedule and `agents/HOWTO_INVOKE.md` for invocation instructions.

### PI communication channels

| Channel | When | Purpose |
|---------|------|---------|
| `brief.md` | Before Step A | Domain assignment and mandate |
| Chat input | Any step | Direct guidance during a live session |
| `pi_notes.md` | Any step | PI drops a note in team folder; agent checks for it |
| Gate B (Day 7) | After Designer | Review 25 RQs; confirm theory families; pre-reg authorisation |
| Gate D (Day 18) | After Analyst | Review figures + results.json; Bonferroni authorisation |
| Gate G (Day 25) | After Reviewer | Read all reports + reviews; synthesis authorisation |

---

## Report template

All 25 teams follow this exact 8-section structure. Writers must not merge,
rename, or skip sections. Section 8 verdict must use one of the four exact
phrases specified.

```markdown
# Team [N]: [Short title — 6 words max]

## 1. Research question
[50-80 words]
One sentence RQ + 2-3 sentences of rationale connecting to the
self-censorship theory.

## 2. Theoretical mechanism
[100-150 words]
Specific causal pathway from autocracy (via self-censorship incentives)
to the outcome variable. Name actors, constraints, behavioral responses.
Expected direction and why the corpus provides relevant evidence.

## 3. Data and operationalization
[150-200 words]
Analytic sample (filtering, final N). Precise definition of outcome variable
(exact column name or construction steps). Key independent variable. Any
intermediate variables constructed. Deviations from pre-registered plan if any.

## 4. Methods
[150-200 words]
Regression model specification, unit of analysis, fixed effects, SE clustering,
causal identification strategy. Text analysis approach if used (2-3 sentences).
One sentence noting Bonferroni adjustment within the [sub-family] family of k tests.

## 5. Main findings
[250-350 words]
3-5 key results in plain language. Primary hypothesis: direction, coefficient,
adjusted p-value, significance. Reference each figure by filename. Describe what
figures show. At least one robustness check result.

## 6. Figures and tables
[50-100 words for captions]
`figures/fig_main.png` — [description]
`figures/fig_robustness.png` — [description]

## 7. Discussion
[300-400 words]
Para 1: Interpret findings in relation to self-censorship theory.
Para 2: Limitations — confounders, alternative explanations, what the
observational design cannot establish.
Para 3 (optional): Connection to other teams' angles.

## 8. Self-censorship theory verdict
[50-80 words]
Verdict (use exactly one): Supports / Partially supports /
Mixed evidence / Does not support
One-sentence justification. This section is read directly by the synthesis agent.
```

**Total target length:** 1,100-1,560 words (approximately 4-5 pages).

---

## rq.md and analysis_plan.md schema

**`rq.md` must contain:**
- Research question (one sentence)
- Rationale (2-3 sentences)
- Theoretical mechanism (2-4 sentences): causal pathway, actors, incentives, expected direction
- Theory family: exactly one of the five approved sub-family labels
- Estimand
- Unit of analysis
- Outcome variable (exact column name or construction description)
- Key independent variable (exact column name)
- Uniqueness check note

**`analysis_plan.md` must contain:**
- Method (regression required for final analysis)
- Model specification (formula, fixed effects, SE clustering)
- Causal identification strategy (variation exploited, confounders controlled, threats)
- List of expected output files

**`primary_results.json` must contain:**
```json
{
  "team": "[N]",
  "hypothesis_label": "[short description]",
  "theory_family": "[one of the five sub-family labels]",
  "predictor": "v2x_libdem",
  "outcome": "[exact column name or description]",
  "coefficient": [number],
  "SE": [number],
  "p_value": [number],
  "n_obs": [integer]
}
```

---

## Phase 2 — Theory synthesis

After all 25 teams complete Steps A-G, run the **Synthesizer agent** (Step S, Day 28).

The Synthesizer reads all 25 rq.md + report.md + peer_review.md files plus the
Bonferroni-adjusted results table. It produces `synthesis/theory_evaluation.md`:
a structured evaluation of the self-censorship theory across all 25 studies, with
vote counts by sub-family, narrative synthesis, quality assessment, and an overall
theory verdict. See `agents/prompt_synthesizer.md` for full specification.

The PI then uses this evaluation as the foundation for the synthesis paper.

---

## Daily oversight

Invoke the **Overseer agent** each morning (any day) to get a prioritised task
list calibrated to the 30-day timeline. Paste `agents/prompt_overseer.md` into
a new Claude Code session. It scans all 25 team folders, reads the timeline, and
outputs a structured daily report. See `agents/HOWTO_INVOKE.md` for details.

