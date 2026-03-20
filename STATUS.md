# Agent Orchestra — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?
**PI:** Tore Wig, University of Oslo
**Last updated:** 2026-03-20

---

## Current phase: Phase 0 complete — awaiting PI sign-off before Phase 1

---

## Phase 0 — Data preparation

**Status:** Complete — PI validation gate open

| Step | Description | Status | Notes |
|------|-------------|--------|-------|
| 0.1 | SSH field list finalized | Done | 69 categories loaded (50 confirmed + borderline included in ssh_fields.txt) |
| 0.2 | V-DEM downloaded | Done | 182 countries, 1970-2023 |
| 0.3 | V-DEM extended with type-of-autocracy variables | Done | v2clacfree, v2x_freexp_altinf, v2csreprss, v2xnp_regcorr |
| 0.4 | 00_prepare_data.R written and run | Done | 2.3 min runtime |
| 0.5 | Country matching fixed | Done | Added historical WOS strings (ENGLAND, FED REP GER, GER DEM REP, etc.) |
| 0.6 | **PI validation gate** | **Open — sign-off needed** | Data covers 1970-2023 as planned |

### Phase 0 outputs

| Output | Value |
|--------|-------|
| Total SSH articles (distinct) | 202,246 |
| Article-country rows | 207,287 |
| ISO3 country match rate | **99.78%** (454 unmatched) |
| V-DEM join rate | **98.21%** |
| Corpus file size | ~0.01 GB (compressed RDS) |
| Columns in corpus | 30 |

### N by regime type (article-country rows, V-DEM matched)

| Regime | N rows | % |
|--------|--------|---|
| 0 = closed autocracy | 5,078 | 2.5% |
| 1 = electoral autocracy | 3,410 | 1.6% |
| 2 = electoral democracy | 3,634 | 1.8% |
| 3 = liberal democracy | 187,728 | 90.7% |
| NA (unmatched) | 7,437 | 3.6% |

### Top 10 countries

United States (134,976), United Kingdom (16,794), Canada (12,151),
Germany (6,090), France (4,964), Australia (3,808), Japan (2,307),
Israel (2,243), Soviet Union (1,630), India (1,572)

### Top 10 SSH subject categories

Education & Educational Research (15,160), Economics (12,965),
Psychology Clinical (10,781), Political Science (7,561), Business (7,500),
Psychology Multidisciplinary (6,663), History (6,579), Law (6,137),
Literature (5,854), Anthropology (4,664)

### v2clacfree (academic freedom): mean=2.87, sd=1.08, range=-3.4 to 3.5

---

## ~~RESOLVED: Data scope confirmed as 1970–2023~~

~~Previous note (2026-02-27) incorrectly stated the WOS data covered only 1970–1983.~~
The WOS data file covers **1970–2023** as planned. This blocker is cleared.

---

## Phase 1 — Team workflow

**Status:** Not started — awaiting PI sign-off on Phase 0

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
| 2026-02-27 | ~~WOS data scope: initially reported as 1970–1983 only~~ | Resolved 2026-03-20: data confirmed as 1970–2023 |

---

## Open items (prioritized)

1. ~~**[BLOCKER]** PI to decide on time coverage~~ — **Resolved:** data covers 1970–2023 as planned
2. Confirm borderline SSH fields (Architecture, Hospitality, Nursing, etc. — currently included via ssh_fields.txt)
3. Decide whether to include "Review" doc_type alongside "Article"
4. Phase 0 validation gate: PI to spot-check agent_corpus.rds before Phase 1
