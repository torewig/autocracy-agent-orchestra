# Agent Orchestra v2 — Project Status

**Project:** How does autocracy, and type of autocracy, impact on the contents,
direction and scientific progress of the social sciences and humanities?

**Unified theory:** Self-censorship — researchers in autocracies avoid
politically sensitive topics, methods, collaborations, and framings to
minimize career risks.

**PI:** Tore Wig, University of Oslo
**Version:** 2.2 (25 active teams; Teams 26–30 dropped; Teams 23–25 form ideological-alignment family)
**Project start date:** 2026-04-21
**Last updated:** 2026-04-20 (sub-family 5 revision)

---

## Current phase: All 25 Designer sessions complete — ready for PI Review Gate B

All 25 active teams have rq.md + analysis_plan.md. Teams 23–25 form the `ideological-alignment` sub-family. Teams 26–30 dropped. Awaiting Day 7: PI Review Gate B.

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
| 01 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 02 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 03 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 04 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 05 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 06 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 07 | topic-avoidance | Y | Y | Y | – | – | – | – | – | Design complete |
| 08 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 09 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 10 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 11 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 12 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 13 | framing-neutrality | Y | Y | Y | – | – | – | – | – | Design complete |
| 14 | collaboration-constraint | Y | Y | Y | – | – | – | – | – | Design complete |
| 15 | collaboration-constraint | Y | Y | Y | – | – | – | – | – | Design complete |
| 16 | collaboration-constraint | Y | Y | Y | – | – | – | – | – | Design complete |
| 17 | collaboration-constraint | Y | Y | Y | – | – | – | – | – | Design complete |
| 18 | collaboration-constraint | Y | Y | Y | – | – | – | – | – | Design complete |
| 19 | visibility-suppression | Y | Y | Y | – | – | – | – | – | Design complete |
| 20 | visibility-suppression | Y | Y | Y | – | – | – | – | – | Design complete |
| 21 | visibility-suppression | Y | Y | Y | – | – | – | – | – | Design complete |
| 22 | visibility-suppression | Y | Y | Y | – | – | – | – | – | Design complete |
| 23 | ideological-alignment | Y | Y | Y | – | – | – | – | – | Design complete |
| 24 | ideological-alignment | Y | Y | Y | – | – | – | – | – | Design complete |
| 25 | ideological-alignment | Y | Y | Y | – | – | – | – | – | Design complete |
| 26 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 27 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 28 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 29 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |
| 30 | DROPPED | – | – | – | – | – | – | – | – | Dropped 2026-04-20 |

---

## Pipeline position

| Step | Task | Status |
|------|------|--------|
| 0 | Phase 0 data preparation | Done |
| A | Designer sessions — Teams 01–22 | **Done — 2026-04-21** |
| A' | Designer sessions — Teams 23–25 (redesigned) | **Done — 2026-04-20** |
| B | PI Review Gate B (Day 7) | Ready |
| B' | Pre-registration (Day 9) | Blocked by B |
| C | All 25 Analyst sessions (Days 10–16) | Blocked by B' |
| D | PI Review Gate D (Day 18) | Blocked by C |
| D' | Bonferroni adjustment (Day 20) | Blocked by D |
| E | All 25 Writer sessions (Days 20–22) | Blocked by D' |
| F | All 25 Reviewer sessions (Days 23–24) | Blocked by E |
| G | PI Review Gate G (Day 25) | Blocked by F |
| S | Synthesis session (Day 28) | Blocked by G |

---

## Issues

### Blockers
None — ready to begin Designer sessions (Day 2).

### Warnings
- Teams 05, 06, 10, 12, **23, 24, 25** are marked **Complex** (external API required).
  Confirm API access and budget before Analyst sessions. Teams 23–25 add ~$7–15;
  total API budget estimate: ~$32–65.
- Teams 21–22 (visibility-suppression): ideal designs require citation network
  data not in corpus. Fallback designs specified in brief.md; confirm at Gate B.

### Info
- v1 team work (teams 01–10, including rq.md files for teams 01–07) archived
  to `archive/teams_v1/`
- v1 utility scripts archived to `archive/root_scripts_v1/`

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

Teams 26–30 dropped (2026-04-20 revision). `regime-channels` family eliminated.

Bonferroni correction applied within each sub-family. Tests across sub-families are independent.

---

## Decision log

| Date | Decision | Notes |
|------|----------|-------|
| 2026-02-26 | RQ sharpened to focus on contents, direction, scientific progress | Carried from v1 |
| 2026-02-26 | SSH scope: 50 WOS categories in ssh_fields.txt | Carried from v1 |
| 2026-02-26 | Primary regime measure: v2x_libdem (continuous) | Carried from v1 |
| 2026-02-26 | Teams required to use regression; text analysis for measurement only | Carried from v1 |
| 2026-03-17 | Phase 0 complete: 2,709,224 articles; 3,189,557 rows | Carried from v1 |
| 2026-03-20 | Phase 0 validation gate signed off by PI | Carried from v1 |
| 2026-04-20 | GDP per capita (e_gdppc) and population (e_wb_pop) added to corpus | From V-DEM |
| 2026-04-21 | Project reset to v2: 30 teams, unified self-censorship theory | PI decision |
| 2026-04-21 | Six Bonferroni sub-families defined (see table above) | PI decision |
| 2026-04-21 | Teams 05, 06, 10, 12 flagged as complex (external API required) | Scheduled Day 15 |
| 2026-04-20 | Sub-family 5 revised: regime-channels eliminated; Teams 23–25 redesigned as ideological-alignment (LLM-based); Teams 26–30 dropped; project reduced to 25 active teams | PI decision |

---

## Next actions

1. Day 6 (Apr 26): Buffer + PI pre-reads all 27 rq.md drafts
2. Day 7 (Apr 27): PI Review Gate B — review all 27 RQs (Teams 01–22 + 23–27)
3. Confirm API access and budget before Day 15 Analyst sessions (Teams 05, 06, 10, 12, 23–27; ~$35–75 total)

