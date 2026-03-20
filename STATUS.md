# Agent Orchestra — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?
**PI:** Tore Wig, University of Oslo
**Last updated:** 2026-03-20 (admin audit)

---

## Current phase: Phase 1, Step A (Designer) — 7/10 complete

Seven of ten teams have completed Step A (Designer: rq.md + analysis_plan.md).
Teams 08, 09, and 10 have briefs but have not yet run their Designer sessions.

**Pipeline position (per PLAN.md ordered task sequence):**

| # | Task | Status |
|---|------|--------|
| 1 | Finalize ssh_fields.txt borderline categories | Done (PI decided 2026-03-20) |
| 2 | Decide whether to include "Review" doc_type | Done (PI decided 2026-03-20) |
| 3 | Confirm ~10 GB RAM for Phase 0 | Done |
| 4 | Run scripts/00_prepare_data.R | Done (2026-03-17) |
| 5 | Phase 0 validation gate | Done (PI signed off 2026-03-20) |
| 6 | Create data/vdem_codebook.md | Done |
| 7 | Run scaffold_teams.R | Done |
| 8 | Copy brief.md to each team | Done (all 10) |
| 9 | Run all 10 Designer sessions (Step A) | **7/10 done** |
| 10 | PI Review Gate B | Blocked by #5 and #9 |
| 11 | Step B' — Pre-registration | Not started |
| 12-18 | Steps C through Phase 2 | Not started |

---

## Phase 0 — Data preparation

**Status:** Complete — PI signed off 2026-03-20

| Output | Value |
|--------|-------|
| Total SSH articles (distinct) | **2,709,224** |
| Article-country rows | **3,189,557** |
| ISO3 country match rate | **99.98%** |
| V-DEM join rate | **99.78%** |
| Corpus file | `data/agent_corpus.rds` (1.1 GB, modified 2026-03-18) |
| N summary | `data/n_summary.txt` (generated 2026-03-17) |
| Country match log | `data/country_match_log.txt` (2026-03-17) |

### N by regime type (article-country rows)

| Regime | N rows |
|--------|--------|
| 0 = closed autocracy | 116,272 |
| 1 = electoral autocracy | 168,302 |
| 2 = electoral democracy | 212,995 |
| 3 = liberal democracy | 2,344,887 |

### Articles by decade

| Decade | N articles |
|--------|-----------|
| 1970s | 161,400 |
| 1980s | 99,262 |
| 1990s | 299,668 |
| 2000s | 494,522 |
| 2010s | 1,654,372 |

### Phase 0 validation gate (BLOCKING)

- [x] PI to spot-check `data/agent_corpus.rds` (2.7M articles)
- [x] PI to confirm N counts in `data/n_summary.txt` are plausible
- [x] PI to confirm `field_year_mean_cites` and `n_articles_country_year` are non-NA for majority of rows
- **Signed off by PI: 2026-03-20**

---

## Team progress

| Team | brief | rq | plan | prereg | analysis.R | results.json | figures | report | review | Status |
|------|-------|----|------|--------|------------|--------------|---------|--------|--------|--------|
| 01 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 02 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 03 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 04 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 05 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 06 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 07 | Y | Y | Y | - | - | - | - | - | - | Step A done |
| 08 | Y | - | - | - | - | - | - | - | - | Scaffolded only |
| 09 | Y | - | - | - | - | - | - | - | - | Scaffolded only |
| 10 | Y | - | - | - | - | - | - | - | - | Scaffolded only |

### Team RQ summary (teams 01-07)

| Team | Research Question | Theory Family | Outcome | IV |
|------|-------------------|---------------|---------|-----|
| 01 | Does political suppression of academic freedom shift SSH content away from politically engaged topics? | `self-censorship` | mean Political Content Index (country-year) | `v2clacfree` |
| 02 | Does autocracy reduce topical diversity of SSH research? | `intellectual-conformity` | keywords per article (country-year) | `v2x_libdem` |
| 03 | Does liberal democracy predict the share of SSH output in politically sensitive disciplines? | `regime-field-distortion` | share of articles in sensitive fields | `v2x_libdem` |
| 04 | Does autocracy reduce prevalence of regime-sensitive research topics? | `topical-self-censorship` | share of articles with sensitive keywords | `v2x_libdem` |
| 05 | Does democracy predict the number of distinct co-author countries? | `international-isolation` | distinct co-author countries per article | `v2x_libdem` |
| 06 | Does autocracy reduce intellectual diversity (semantic similarity of abstracts)? | `intellectual-conformity` | semantic diversity (cosine distance) | `v2x_libdem` |
| 07 | Does autocracy reduce the share of SSH research critically engaging with domestic governance? | `political-self-censorship` | binary: critical domestic engagement | `v2x_libdem` |

### RQ completeness check (all required fields per PLAN.md)

All 7 completed rq.md files contain: research question, rationale, theoretical mechanism, theory family, estimand, unit of analysis, outcome variable, key independent variable. **All pass.**

All 7 completed analysis_plan.md files contain: method (with regression), model specification (formula, FE, clustering), causal identification strategy, expected output files. **All pass.**

---

## Issues

### Blockers

1. ~~Phase 0 validation gate not signed off.~~ **Resolved 2026-03-20.**

2. **Teams 08-10 need Designer sessions.** These three teams have briefs but no rq.md or analysis_plan.md. Step B (PI Review Gate) requires all 10 teams to have completed Step A.

3. ~~PLAN.md tasks #1 and #2 still open.~~ **Resolved 2026-03-20.**

### Warnings — RQ convergence issues

4. **Teams 02 and 06 share the same theory family (`intellectual-conformity`).** Both study conformity/diversity of research output under autocracy, but with different operationalizations:
   - Team 02: keyword diversity (topical narrowing)
   - Team 06: semantic similarity of abstracts (intellectual homogeneity)

   PI should decide at Step B whether these are sufficiently distinct or whether one should be redirected. If kept, they will be in the same Bonferroni correction family.

5. **Teams 01, 04, and 07 all study self-censorship/avoidance of political content.** They use different theory family labels (`self-censorship`, `topical-self-censorship`, `political-self-censorship`) but the causal mechanism is essentially the same: autocracy suppresses politically sensitive research. PI should consolidate these into one or two theory families at Step B — this has major implications for Bonferroni correction.

6. **Team 01 uses `v2clacfree` as the key IV, not `v2x_libdem`.** All other teams use `v2x_libdem`. This is not necessarily wrong (academic freedom is more proximate), but it deviates from the PLAN.md design decision that `v2x_libdem` is the "primary regime measure." PI should confirm this is acceptable.

7. **Thematic coverage gap.** All 7 completed teams focus on either (a) content suppression/self-censorship or (b) intellectual diversity. No team yet addresses:
   - Citation impact / visibility of autocracy-origin research
   - Scientific progress / methodological quality
   - International knowledge flows (beyond co-authorship counts)
   - Temporal dynamics (how transitions affect research)

   Teams 08-10 could fill these gaps if the PI provides steering via `pi_notes.md`.

### Info — Housekeeping

8. **Loose files in root directory:**
   `check_env.ps1`, `check_wos_size.ps1`, `check_years.R`, `check_years.ps1`,
   `peek_wos.R`, `pilot_sample.R`, `run_peek.ps1`, `run_phase0.ps1`,
   `run_pilot_sample.ps1`, `run_scaffold.ps1`
   These are utility/debugging scripts. Consider moving to `scripts/` or `.gitignore`.

9. **Extra files in team folders** (session artifacts, not in expected structure):
   - team_01: `compile_plan.ps1`, `inspect_err.txt`, `inspect_out.txt`, `inspect_sample.R`, `plan.pdf`, `plan_combined.md`, `run_inspect.ps1`
   - team_02: `plan_team02.pdf`, `plan_team02_v2.pdf`
   - team_03: `analysis_plan.pdf`, `plan.pdf`, `plan_combined.md`
   - team_04: `plan.pdf`, `plan_combined.md`
   - team_05: `analysis_plan.pdf`, `plan.pdf`, `plan_combined.md`
   - team_06: `plan.pdf`, `plan_combined.md`, `team_06_plan.pdf`
   - team_07: `compile_plan.ps1`, `plan.pdf`, `plan_combined.md`

10. **Git tracking notes:**
    - `.claude/` is properly in `.gitignore`
    - `teams/` is entirely gitignored (all team output excluded from tracking)
    - `data/agent_corpus.rds` and other large data files are gitignored
    - No wildcard `*.pdf` or `*.rds` pattern — only specific files are ignored
    - Working tree is clean (no uncommitted changes)

11. **`synthesis/` folder does not yet exist** (expected — Phase 2).

12. **Empty directories** (expected at this stage):
    All 10 `analysis/figures/` and all 10 `report/` are empty.

---

## Decision log

| Date | Decision | Notes |
|------|----------|-------|
| 2026-02-26 | RQ sharpened to focus on contents, direction, scientific progress | Not just volume/count indicators |
| 2026-02-26 | SSH scope: 69 WOS categories in ssh_fields.txt (50 confirmed + borderline) | Includes Sci & Tech Studies, Business, Business Finance |
| 2026-02-26 | Primary regime measure: v2x_libdem | Robustness with v2x_regime and regime_binary |
| 2026-02-26 | Teams required to use regression; text analysis for measurement only | Causal ID designs preferred |
| 2026-02-26 | Peer review step added (Step F) | Independent reviewer agent per team report |
| 2026-02-27 | V-DEM extended: v2clacfree, v2x_freexp_altinf, v2csreprss, v2xnp_regcorr | All confirmed present in vdemdata |
| 2026-02-27 | Country matching fixed: ENGLAND->GBR, FED REP GER->DEU, GER DEM REP->DDR, etc. | Match rate now 99.78% |
| 2026-02-27 | WOS data initially only covered 1970-1983 | PI chose Option B: obtain modern extract |
| 2026-03-09 | New WOS corpus added: 2,744,129 SSH articles from all 3 pulls | Now covers 1970-2023; 2000s gap flagged |
| 2026-03-09 | Country matching extended: title-case UK sub-nations added | Match rate 99.96% |
| 2026-03-17 | Phase 0 re-run with updated corpus | 2,709,224 articles; 2000s gap resolved (494,522 articles); match rate 99.98% |

---

## Next actions (priority order)

1. **Sign off on Phase 0 validation gate** — spot-check the updated corpus in R; check the three items above
2. **Decide on PLAN.md open items #1-2** — borderline SSH categories and Review doc_type (if changed, Phase 0 must be re-run)
3. **Run Designer sessions for teams 08-10** — consider using pi_notes.md to steer toward uncovered themes (citations, scientific progress, temporal dynamics)
4. **Review RQ convergence (Step B preview):**
   - Decide whether teams 02/06 (both `intellectual-conformity`) should both proceed
   - Consolidate theory family labels for teams 01/04/07 (all study self-censorship variants)
   - Confirm team 01's use of `v2clacfree` instead of `v2x_libdem`
5. **Proceed to PI Review Gate B** — once all 10 RQs are in and convergence issues are resolved
6. **Housekeeping** — move loose root scripts to `scripts/`, clean up extra team folder artifacts
