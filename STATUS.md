# Agent Orchestra — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?
**PI:** Tore Wig, University of Oslo
**Last updated:** 2026-03-19

---

## Current phase: Phase 1, Step A (Designer) — partially complete

Seven of ten teams have completed Step A (Designer: rq.md + analysis_plan.md).
Teams 08, 09, and 10 have been scaffolded but have not yet run their Designer
sessions. **Next action:** run Designer sessions for teams 08-10, then proceed
to PI Review Gate B.

---

## Phase 0 — Data preparation

**Status:** Complete (last run: 2026-03-17)

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

**Note:** The 2000s gap flagged in the 2026-03-09 status is now resolved.
The 2026-03-17 Phase 0 run shows 494,522 articles in the 2000s decade.

### Phase 0 validation gate

- [ ] PI to spot-check `data/agent_corpus.rds` (updated 2026-03-17 corpus: 2.7M articles)
- [ ] PI to confirm N counts in `data/n_summary.txt` are plausible
- [ ] PI to confirm `field_year_mean_cites` and `n_articles_country_year` are non-NA for majority of rows

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
| 08 | Y | - | - | - | - | - | - | - | - | Scaffolded |
| 09 | Y | - | - | - | - | - | - | - | - | Scaffolded |
| 10 | Y | - | - | - | - | - | - | - | - | Scaffolded |

---

## Issues

### Blockers

- **Teams 08-10 have not completed Step A.** Designer sessions must be run for
  these three teams before proceeding to PI Review Gate B.
- **Phase 0 validation gate still open.** The corpus was re-run on 2026-03-17
  with updated numbers (2.7M articles, 2000s gap resolved), but PI has not
  formally signed off on the new data. The old STATUS.md validation gate items
  remain unchecked.

### Warnings

- **STATUS.md was stale.** Previous STATUS.md was dated 2026-03-09 and still
  referenced the 2000s gap (7,542 articles) which has been resolved in the
  2026-03-17 Phase 0 run (494,522 articles).
- **N counts differ from old STATUS.md.** The 2026-03-09 status reported
  1,404,400 articles; the 2026-03-17 n_summary.txt reports 2,709,224. This
  is a large change — likely reflects a re-run with the full 3-pull WOS corpus.
  PI should confirm this is expected.
- **PLAN.md has been modified but not committed.** Git shows `M PLAN.md`.
- **Several agent prompts modified but not committed:** `agents/HOWTO_INVOKE.md`,
  `agents/prompt_analyst.md`, `agents/prompt_designer.md`, `agents/prompt_writer.md`,
  `data/vdem_codebook.md`.

### Info

- **Loose files in root** (not in expected folder structure):
  `check_env.ps1`, `check_wos_size.ps1`, `check_years.R`, `check_years.ps1`,
  `peek_wos.R`, `pilot_sample.R`, `run_peek.ps1`, `run_phase0.ps1`,
  `run_pilot_sample.ps1`, `run_scaffold.ps1`
  These appear to be utility/debugging scripts. Consider moving to `scripts/`
  or adding to `.gitignore`.
- **Extra files in team folders** (session artifacts, not in expected structure):
  - team_01: `compile_plan.ps1`, `inspect_err.txt`, `inspect_out.txt`,
    `inspect_sample.R`, `plan.pdf`, `plan_combined.md`, `run_inspect.ps1`
  - team_02: `plan_team02.pdf`
  - team_03: `analysis_plan.pdf`, `plan.pdf`, `plan_combined.md`
  - team_04: `plan.pdf`, `plan_combined.md`
  - team_05: `analysis_plan.pdf`, `plan.pdf`, `plan_combined.md`
  - team_06: `team_06_plan.md`, `team_06_plan.pdf`
- **Empty directories:** All 10 `analysis/figures/` and all 10 `report/` are
  empty (expected at this stage — they will be populated by Analyst and Writer).
- **`synthesis/` folder does not exist** (expected — it is created in Phase 2).
- **Untracked scripts in `scripts/`:** `add_controls.R`, `admin_audit.ps1`,
  `bonferroni_adjust.R`, `check_abstracts.R`, `check_missing_countries.R`,
  `preregister.ps1`
- **`.claude/` directory is untracked** (should be added to `.gitignore`).

---

## Loose files in root

| File | Likely purpose | Suggestion |
|------|---------------|------------|
| `check_env.ps1` | Environment check | Move to `scripts/` or `.gitignore` |
| `check_wos_size.ps1` | WOS data inspection | Move to `scripts/` |
| `check_years.R` | Year coverage check | Move to `scripts/` |
| `check_years.ps1` | Runner for above | Move to `scripts/` |
| `peek_wos.R` | WOS data peek | Move to `scripts/` |
| `pilot_sample.R` | Pilot sampling | Move to `scripts/` |
| `run_peek.ps1` | Runner for peek_wos | Move to `scripts/` |
| `run_phase0.ps1` | Runner for Phase 0 | Move to `scripts/` |
| `run_pilot_sample.ps1` | Runner for pilot | Move to `scripts/` |
| `run_scaffold.ps1` | Runner for scaffold | Move to `scripts/` |

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

## Next actions

1. **Run Designer sessions for teams 08, 09, 10** (Step A) — these are scaffolded but have no rq.md or analysis_plan.md yet
2. **Sign off on Phase 0 validation gate** — spot-check the updated corpus (2.7M articles, 2000s gap resolved)
3. **Commit modified files to git** — PLAN.md, agent prompts, and vdem_codebook.md have uncommitted changes
4. **Proceed to PI Review Gate B** — once all 10 teams have rq.md + analysis_plan.md, review for RQ convergence and consolidate theory family labels
5. **Consider cleanup** — move loose root scripts to `scripts/`, add `.claude/` to `.gitignore`
