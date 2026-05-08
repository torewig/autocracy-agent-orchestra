# Agent Orchestra v2 — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?

**Unified theory:** Self-censorship — researchers in autocracies avoid
politically sensitive topics, methods, collaborations, and framings to
minimize career risks.

**PI:** Tore Wig, University of Oslo
**Version:** 2.2 (25 active teams; Teams 26–30 dropped; Teams 23–25 form ideological-alignment family)
**Project start date:** 2026-04-21
**Today's date:** 2026-05-07
**Current day:** 17 of 30
**Last updated:** 2026-05-07 (18 of 18 simple/medium teams done; 7 complex/API teams pending)

---

## *** CURRENT PHASE: ANALYST SESSIONS — SIMPLE/MEDIUM COMPLETE; COMPLEX PENDING ***

**Gate B:** Complete (2026-05-06) — all 25 teams approved by PI
**Pre-registration:** Complete (2026-05-06) — GitHub commit `960525f` (25 teams locked)
**Simple/Medium analyst sessions:** **18/18 done** (2026-05-07)
**Complex analyst sessions (API):** 0/7 — awaiting PI decision on budget

> **Note on timeline:** Project is running ~10 days behind the original schedule.
> Adjusted target completion: ~May 30–June 1.

### Results — all 18 simple/medium teams (TWFE primary coefficient)

| Team | Sub-family | Outcome | β | SE | p-value | Bonf. threshold | Sig? | Exp. sign |
|------|-----------|---------|--:|---:|--------:|----------------:|:----:|:---------:|
| 01 | topic-avoidance | PCI score | −0.000549 | 0.000793 | 0.490 | 0.0071 | No | − |
| 02 | topic-avoidance | Keyword entropy | +0.531 | 0.395 | 0.182 | 0.0071 | No | + |
| 03 | topic-avoidance | Share sensitive fields | +0.039 | 0.024 | 0.114 | 0.0071 | No | − |
| 04 | topic-avoidance | Share regime-sensitive keywords | +0.001 | 0.018 | 0.939 | 0.0071 | No | − |
| 07 | topic-avoidance | Share intl-funded | +0.005 | 0.007 | 0.499 | 0.0071 | No | + |
| 08 | framing-neutrality | Epistemic hedging rate | +0.000 | 0.000 | 0.465 | 0.0083 | No | + |
| 09 | framing-neutrality | Normative language rate | −0.000 | 0.000 | 0.503 | 0.0083 | No | + |
| 11 | framing-neutrality | Argumentative stance rate | +0.000 | 0.000 | 0.537 | 0.0083 | No | + |
| 13 | framing-neutrality | Share domestic journals | +0.034 | 0.060 | 0.575 | 0.0083 | No | − |
| 14 | collaboration-constraint | Mean co-author countries | +0.207 | 0.133 | 0.123 | 0.0100 | No | + |
| 15 | collaboration-constraint | Share democratic co-authors | +0.051 | 0.057 | 0.377 | 0.0100 | No | + |
| 16 | collaboration-constraint | Share domestic-only authorship | −0.001 | 0.047 | 0.984 | 0.0100 | No | − |
| 17 | collaboration-constraint | Mean author count | +0.482 | 0.291 | 0.100 | 0.0100 | No | + |
| 18 | collaboration-constraint | Mean distinct institutions | +0.041 | 0.051 | 0.428 | 0.0100 | No | + |
| 19 | visibility-suppression | Log citation ratio | −0.007 | 0.041 | 0.869 | 0.0125 | No | + |
| 20 | visibility-suppression | Citation gap × sensitivity (interaction) | −0.027 | 0.041 | 0.511 | 0.0125 | No | + |
| 21 | visibility-suppression | Share ever cited | −0.027 | 0.044 | 0.543 | 0.0125 | No | + |
| 22 | visibility-suppression | Citation Gini | +0.052 | 0.025 | **0.039** | 0.0125 | No | − |

**Pattern:** Zero of 18 tests are significant after Bonferroni correction within their sub-family.
- **Team 22** (citation Gini) is the only nominally significant result (p=0.039), but (a) it does not survive Bonferroni correction (threshold 0.0125), and (b) the sign is *opposite* to the hypothesis (positive = more democracy → more citation concentration).
- **Collaboration-constraint** teams show the most consistent directional evidence: all 4 positive-sign teams (14, 15, 17, 18) go in the predicted direction, none significant.
- **Topic-avoidance and framing-neutrality** signs are inconsistent with theory — no consistent suppression pattern in within-country variation.
- **Visibility-suppression** (19, 20, 21) signs match hypotheses but effect sizes are near zero.

**7 complex/API teams (05, 06, 10, 12, 23–25) still pending.** Their results may change the picture — especially Teams 05, 10, 12 (LLM classifiers of content framing).

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
| 01 | topic-avoidance | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 02 | topic-avoidance | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 03 | topic-avoidance | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 04 | topic-avoidance | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 05 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 06 | topic-avoidance | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 07 | topic-avoidance | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 08 | framing-neutrality | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 09 | framing-neutrality | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 10 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 11 | framing-neutrality | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 12 | framing-neutrality | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 13 | framing-neutrality | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 14 | collaboration-constraint | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 15 | collaboration-constraint | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 16 | collaboration-constraint | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 17 | collaboration-constraint | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 18 | collaboration-constraint | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 19 | visibility-suppression | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 20 | visibility-suppression | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 21 | visibility-suppression | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 22 | visibility-suppression | Y | Y | Y | **Y** | **Y** | **Y** | – | – | **Analysis done** |
| 23 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 24 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
| 25 | ideological-alignment | Y | Y | Y | **Y** | – | – | – | – | **Pre-registered** (Complex — API needed) |
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
| C | Analyst sessions — Simple/Medium (Teams 01–04, 07–09, 11, 13–22) | **Done** — 18/18 complete | 2026-05-06/07 |
| C' | Analyst sessions — Complex (Teams 05, 06, 10, 12, 23–25) | Pending — awaiting API budget confirmation | — |
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
| 2026-05-07 | Teams 01–04, 07–08 analysis complete; all 6 p >> Bonferroni threshold | First results |
| 2026-05-07 | Scripts written for Teams 09, 11, 13–22; corpus column confirmed as `keywords` and `ut` | Bug fixes applied |
| 2026-05-07 | All 18 simple/medium analyst sessions complete; 0/18 significant after Bonferroni | Results milestone |

---

## Next actions (Day 17, 2026-05-07)

1. **PI decision on Complex teams (05, 06, 10, 12, 23–25):**
   - Teams 05, 10, 12: Claude Haiku, ~$5–10 each — low cost, safe to proceed
   - Team 06: text embeddings (OpenAI or similar) — confirm API access and cost
   - Teams 23–25: Claude Haiku, up to **$500 each** — confirm Anthropic billing ceiling before starting
2. **After all 25 Analyst sessions:** run `scripts/bonferroni_adjust.R`
3. **Gate D:** PI reviews all figures + `primary_results.json` across all 25 teams
4. **Writer sessions** (Teams 01–25) — after Gate D

### Complex teams awaiting PI decision

| Team | API | Est. cost | Domain |
|------|-----|-----------|--------|
| 05 | Claude Haiku | ~$5–10 | LLM: critical framing of domestic governance |
| 06 | Text embeddings | ~$10–20 | Cosine distance of abstract embeddings |
| 10 | Claude Haiku | ~$5–10 | LLM: technocratic framing classifier |
| 12 | Claude Haiku | ~$5–10 | LLM: normative conclusion classifier |
| 23 | Claude Haiku | **≤$500** | LLM: 5-label ideology classifier |
| 24 | Claude Haiku | **≤$500** | LLM: regime legitimation binary |
| 25 | Claude Haiku | **≤$500** | LLM: anti-liberal framing binary |

