# Agent Orchestra — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?
**PI:** Tore Wig, University of Oslo
**Last updated:** 2026-03-09

---

## Current phase: Phase 0 updated (new WOS corpus) — awaiting PI sign-off before Phase 1

---

## Phase 0 — Data preparation

**Status:** Complete — PI validation gate open

| Step | Description | Status | Notes |
|------|-------------|--------|-------|
| 0.1 | SSH field list finalized | Done | 69 categories in ssh_fields.txt |
| 0.2 | V-DEM downloaded | Done | 182 countries, 1970-2023 |
| 0.3 | V-DEM extended with type-of-autocracy variables | Done | v2clacfree, v2x_freexp_altinf, v2csreprss, v2xnp_regcorr |
| 0.4 | **New WOS corpus added** | **Done (2026-03-09)** | wos_ssh_articles.rds: 2,744,129 SSH articles from all 3 WOS pulls |
| 0.5 | 00_prepare_data.R updated and run | Done | 4.9 min runtime; reads wos_ssh_articles.rds |
| 0.6 | Country matching fixed | Done | UK sub-nations now matched in both upper and title case |
| 0.7 | **PI validation gate** | **Open — sign-off needed** | See findings and !! WARNING !! below |

### Phase 0 outputs (2026-03-09 run)

| Output | Value |
|--------|-------|
| Total SSH articles (distinct) | **1,404,400** |
| Article-country rows | **1,641,210** |
| ISO3 country match rate | **99.96%** (586 unmatched) |
| V-DEM join rate | **99.61%** |
| Corpus file size | 0.57 GB on disk |
| Columns in corpus | 31 |

### N by regime type (article-country rows, V-DEM matched)

| Regime | N rows | % |
|--------|--------|---|
| 0 = closed autocracy | 67,302 | 4.1% |
| 1 = electoral autocracy | 106,868 | 6.5% |
| 2 = electoral democracy | 130,411 | 7.9% |
| 3 = liberal democracy | 1,171,318 | 71.4% |
| NA (unmatched) | 65,311 | 4.0% |

### Articles by decade

| Decade | N articles |
|--------|-----------|
| 1970s | 161,294 |
| 1980s | 98,710 |
| 1990s | 248,939 |
| **2000s** | **7,542** ← GAP (see below) |
| 2010s | 887,915 |

### Top 10 countries

United States (595,823), United Kingdom (147,776), Canada (75,178),
Germany (63,538), Australia (61,727), Spain (54,017), China (45,642),
France (41,639), Italy (35,249), Netherlands (34,576)

### Top 10 SSH subject categories

Education & Educational Research (116,727), Economics (108,315),
Psychology Clinical (60,836), Business (54,563), History (43,270),
Psychology Multidisciplinary (43,054), Law (41,646), Management (40,539),
Business Finance (37,782), Political Science (36,913)

### v2clacfree (academic freedom): mean=2.30, sd=1.40, range=-3.4 to 3.7

---

## !! WARNING: GAP IN 2000s COVERAGE !!

**The corpus has only 7,542 articles from 2000–2009 (vs. 249K in the 1990s and 888K in the 2010s).**

- This appears to be a gap between WOS Pull2 (ends ~late 1990s) and Pull3 (starts ~2010)
- The 2000–2009 decade is effectively missing from the corpus
- This will create a discontinuity in any time-series analysis spanning 2000–2009

**Implication for analysis:** Teams should be warned to treat the 2000s as a gap. Analyses that use time as a running variable should either:
  (a) Exclude the 2000s decade, or
  (b) Restrict to two separate periods: pre-2000 and post-2010

**PI decision needed:** Is an additional WOS pull to fill the 2000–2009 gap feasible? Or should teams work around the gap?

---

## Phase 1 — Team workflow

**Status:** Not started — awaiting PI sign-off on Phase 0 (including time coverage decision)

| Step | Description | Status |
|------|-------------|--------|
| 1.0 | scaffold_teams.R run (10 folders created) | Pending |
| 1.1 | brief.md files filled in | Pending |
| A | Designer sessions (x10): rq.md + analysis_plan.md | Pending |
| B | **PI Review Gate B**: RQ convergence, causal logic | Pending |
| C | Analyst sessions (x10): analysis.R + figures | Pending |
| D | **PI Review Gate D**: methodology check | Pending |
| E | Writer sessions (x10): report.md | Pending |
| F | Peer Review sessions (x10): peer_review.md | Pending |
| G | **PI Review Gate G**: reports + reviews | Pending |

---

## Phase 2 — Synthesis paper

**Status:** Not started

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
| 2026-02-27 | Country matching fixed: ENGLAND→GBR, FED REP GER→DEU, GER DEM REP→DDR, etc. | Match rate now 99.78% |
| 2026-02-27 | WOS data initially only covered 1970–1983 | PI chose Option B: obtain modern extract |
| **2026-03-09** | **New WOS corpus added: 2,744,129 SSH articles from all 3 pulls** | **Now covers 1970–2023 but with a gap in 2000–2009. PI decision pending on gap.** |
| 2026-03-09 | Country matching extended: title-case UK sub-nations added | Match rate 99.96% |

---

## Open items (prioritized)

1. **[BLOCKER]** PI to decide on 2000–2009 gap: obtain a fill pull, or instruct teams to work around it
2. **[GATE]** PI to validate updated corpus: spot-check agent_corpus.rds (1.4M articles, regime distribution above)
3. Update team brief templates (teams/team_02 – team_10) to reflect actual coverage and 2000s gap warning
4. Confirm borderline SSH fields (Architecture, Hospitality, Nursing, etc. — currently included via ssh_fields.txt)
5. Decide whether to include "Review" doc_type alongside "Article" (currently Article only)
