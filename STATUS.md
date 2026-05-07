# Agent Orchestra v2 — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?

**Unified theory:** Self-censorship — researchers in autocracies avoid
politically sensitive topics, methods, collaborations, and framings to
minimize career risks.

**PI:** Tore Wig, University of Oslo
**Version:** 2.2 (25 active teams; Teams 26–30 dropped; Teams 23–25 form ideological-alignment family)
**Project start date:** 2026-04-21
**Today's date:** 2026-05-06
**Current day:** 16 of 30
**Last updated:** 2026-05-06 (Gate B complete; pre-registration committed; analyst sessions next)

---

## *** CURRENT PHASE: ANALYST SESSIONS — READY TO START ***

**Gate B:** Complete (2026-05-06) — all 25 teams approved by PI
**Pre-registration:** Complete (2026-05-06) — GitHub commit `960525f` (25 teams locked)
**Next step:** Run Analyst sessions — start with Simple/Medium teams; Complex teams last

> **Note on timeline:** Project is running ~9 days behind the original schedule
> (Gate B completed Day 16 instead of Day 7). Analyst sessions begin today.
> Adjusted target completion: ~May 29–31 (add ~9 days to all downstream steps).

---

## Phase 0 — Data preparation

**Status:** Complete — PI signed off 2026-03-20 (carried over from v1)

| Output | Value |
|--------|-------|
| Total SSH articles (distinct) | 2,709,224 |
| Article-country rows | 3,189,557 |
| ISO3 country match rate | 99.98% |
| V-DEM join rate | 99.78% |
| Corpus file | `data/agent_corpus.rds` (1.1 GB) |
| Control variables added | `e_gdppc` (GDP per capita, log), `e_wb_pop` (population, log) |

---

## Team progress

| Team | Sub-family | Brief | RQ | Plan | Prereg | Analysis.R | Results.json | Report | Review | Status |
|------|-----------|-------|----|------|--------|------------|--------------|--------|--------|--------|
| 01 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 02 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 03 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 04 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 05 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 06 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 07 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 08 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 09 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 10 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 11 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 12 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 13 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 14 | collaboration-constraint | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 15 | collaboration-constraint | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 16 | collaboration-constraint | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 17 | collaboration-constraint | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 18 | collaboration-constraint | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 19 | visibility-suppression | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 20 | visibility-suppression | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 21 | visibility-suppression | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 22 | visibility-suppression | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** |
| 23 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 24 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 25 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex) |
| 26 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 27 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 28 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 29 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 30 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |

---

## Pipeline position

| Step | Task | Status | Actual date |
|------|------|--------|-------------|
| 0 | Phase 0 data preparation | **Done** | 2026-03-20 |
| A | Designer sessions (Teams 01–25) | **Done** | 2026-04-21 |
| B | PI Review Gate B (revisions + approval) | **Done** | 2026-05-06 |
| B' | Pre-registration (GitHub commit `960525f`) | **Done** | 2026-05-06 |
| C | Analyst sessions — Simple/Medium (Teams 01–04, 07–09, 11, 13–22) | **NEXT** | — |
| C' | Analyst sessions — Complex (Teams 05, 06, 10, 12, 23–25) | Pending | — |
| D | PI Review Gate D (figures + results) | Blocked by C/C' | — |
| D' | Bonferroni adjustment (`bonferroni_adjust.R`) | Blocked by D | — |
| E | Writer sessions (Teams 01–25) | Blocked by D' | — |
| F | Reviewer sessions (Teams 01–25) | Blocked by E | — |
| G | PI Review Gate G (reports + peer reviews) | Blocked by F | — |
| S | Synthesis session | Blocked by G | — |

---

## Analyst session instructions

### Simple / Medium teams — run first (no external API required)

Invoke one Analyst agent session per team by pasting `agents/prompt_analyst.md`
with `[N]` replaced by the team number. Run as many in parallel as feasible.

**Batch A — topic/framing/collab (simple):**
Teams 01, 02, 03, 04, 07, 08, 09, 11, 13, 14, 16, 17

**Batch B — medium (derived variables, no API):**
Teams 15, 18, 19, 20, 21, 22

### Complex teams — run after Simple/Medium complete (external API required)

| Team | API | Est. cost | Notes |
|------|-----|-----------|-------|
| 05 | Claude Haiku | ~$5–10 | LLM: critical framing classifier |
| 06 | Text embeddings | ~$10–20 | Cosine distance of abstract embeddings |
| 10 | Claude Haiku | ~$5–10 | LLM: technocratic framing classifier |
| 12 | Claude Haiku | ~$5–10 | LLM: normative conclusion classifier |
| 23 | Claude Haiku | ~$500 ceiling | LLM: 5-label ideology classifier; ~1M abstracts |
| 24 | Claude Haiku | ~$500 ceiling | LLM: regime legitimation binary; ~1M abstracts |
| 25 | Claude Haiku | ~$500 ceiling | LLM: anti-liberal framing binary; ~1M abstracts |

**Run cost preflight check before Teams 23–25**: each has a hard $500 ceiling
built into the analysis plan. Confirm API key and Anthropic billing limits first.

### What each Analyst session should produce

Each team's `teams/team_NN/analysis/` folder should contain:
- `analysis.R` — complete analysis script, self-contained
- `primary_results.json` — machine-readable results (coef, SE, p-values, N)
- `figures/fig_main.png` — main result figure
- `figures/fig_robustness.png` — robustness check figure(s)

### Estimation specs (all teams)

**Primary:** `feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)`
**Secondary (pooled OLS):** `feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year, cluster = ~iso3)`

Team-specific additional controls and model specs are in each team's `preregistration.md`.

---

## Issues

### Blockers
None — analyst sessions can begin immediately.

### Warnings
- **Complex teams 23–25**: each may cost up to $500 in API calls. Verify Anthropic
  billing ceiling before starting. Cost estimate preflight is built into analysis plans.
- **Team 06**: requires text embedding API (OpenAI or similar). Check access separately.
- **Team 20**: article-level regression (not country-year) — largest dataset; may be slow.

---

## Bonferroni sub-families

| Sub-family | Teams | k (tests) | Threshold |
|-----------|-------|-----------|-----------|
| topic-avoidance | 01–07 | 7 | p < 0.0071 |
| framing-neutrality | 08–13 | 6 | p < 0.0083 |
| collaboration-constraint | 14–18 | 5 | p < 0.0100 |
| visibility-suppression | 19–22 | 4 | p < 0.0125 |
| ideological-alignment | 23–25 | 3 | p < 0.0167 |
| **Total active teams** | **25** | | |

Bonferroni correction applied within each sub-family. Computed by `scripts/bonferroni_adjust.R`
after all Analyst sessions complete.

---

## Decision log

| Date | Decision | Notes |
|------|----------|-------|
| 2026-02-26 | RQ sharpened to focus on contents, direction, scientific progress | Carried from v1 |
| 2026-02-26 | SSH scope: 50 WOS categories in ssh\_fields.txt | Carried from v1 |
| 2026-02-26 | Primary regime measure: v2x\_libdem (continuous) | Carried from v1 |
| 2026-02-26 | Teams required to use regression; text analysis for measurement only | Carried from v1 |
| 2026-03-17 | Phase 0 complete: 2,709,224 articles; 3,189,557 rows | Carried from v1 |
| 2026-03-20 | Phase 0 validation gate signed off by PI | Carried from v1 |
| 2026-04-20 | GDP per capita (e\_gdppc) and population (e\_wb\_pop) added to corpus | From V-DEM |
| 2026-04-21 | Project reset to v2: 30 teams, unified self-censorship theory | PI decision |
| 2026-04-21 | Six Bonferroni sub-families defined | PI decision |
| 2026-04-20 | Sub-family 5 revised: regime-channels → ideological-alignment; Teams 26–30 dropped | PI decision |
| 2026-05-06 | Gate B complete: all 25 teams approved; some redesigned (Team 21 fully replaced) | PI review |
| 2026-05-06 | Pre-registration committed to GitHub: commit `960525f` | 25 teams locked |
| 2026-05-06 | Pooled OLS added as universal secondary specification for all 25 teams | PI decision |
| 2026-05-06 | Hypothesis wording standardized: "Liberal democracy levels" (not v2x\_libdem scores) | PI decision |
| 2026-05-06 | LaTeX draft created: `draft.tex` / `draft.pdf` (skeleton, 14 pages) | Setup for paper |

---

## Next actions (Day 16, 2026-05-06)

1. **Run Analyst sessions** — start with Simple/Medium batch (Teams 01–04, 07–09, 11, 13–22)
   - Invoke `agents/prompt_analyst.md` with `[N]` = team number
   - Run multiple sessions in parallel where possible
2. **Confirm API access** before starting Complex teams (05, 10, 12, 06, 23–25)
3. **After all 25 Analyst sessions:** run `scripts/bonferroni_adjust.R` → review adjusted p-values
4. **Gate D** (PI review of figures + results) before Writer sessions

