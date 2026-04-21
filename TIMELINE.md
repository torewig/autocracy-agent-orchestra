# Agent Orchestra v2 — 30-Day Timeline

**Project start date: 2026-04-21**
**Project end date: 2026-05-20**
**Teams:** 25 (Teams 26–30 dropped 2026-04-20) | **Theory:** Self-censorship

This file is read by the daily Overseer agent to determine the current
project day and today's scheduled tasks.

---

## Day-by-day schedule

| Day | Date | Phase | Tasks |
|-----|------|-------|-------|
| 1 | Apr 21 | **Setup** | Archive v1; rewrite all prompts; update scaffold; run scaffold; write TIMELINE.md + STATUS.md |
| 2 | Apr 22 | **Designer batch 1** | Teams 01–06 — run Designer sessions |
| 3 | Apr 23 | **Designer batch 2** | Teams 07–13 — run Designer sessions |
| 4 | Apr 24 | **Designer batch 3** | Teams 14–20 — run Designer sessions |
| 5 | Apr 25 | **Designer batch 4** | Teams 21–25 — run Designer sessions |
| 6 | Apr 26 | **Buffer / catch-up** | Re-run any failed Designer sessions; PI pre-reads all 25 rq.md drafts |
| 7 | Apr 27 | **PI Review Gate B** | PI reviews all 25 rq.md + analysis_plan.md; checks uniqueness, self-censorship framing, domain compliance; confirms theory family labels |
| 8 | Apr 28 | **Revision day** | Re-run Designer sessions for redirected teams (~2–4 expected) |
| 9 | Apr 29 | **Pre-registration** | Run `scripts/preregister.ps1`; verify GitHub commit; hypotheses locked |
| 10 | Apr 30 | **Analyst batch 1** | Teams 01–05 (simple, no API) — run Analyst sessions |
| 11 | May 1 | **Analyst batch 2** | Teams 07–11 (simple/medium) — run Analyst sessions |
| 12 | May 2 | **Analyst batch 3** | Teams 13–17 (simple/medium) — run Analyst sessions |
| 13 | May 3 | **Analyst batch 4** | Teams 18–22 (simple/medium) — run Analyst sessions |
| 14 | May 4 | **Analyst batch 5** | Team 06 (embeddings API) — run Analyst session |
| 15 | May 5 | **Analyst complex** | Teams 05, 10, 12, 23, 24, 25 (external LLM API required) — run in parallel; confirm API budget first |
| 16 | May 6 | **Buffer / catch-up** | Re-run any failed or slow Analyst sessions |
| 17 | May 7 | **Buffer** | Re-run any remaining Analyst sessions; verify all 25 primary_results.json exist |
| 18 | May 8 | **PI Review Gate D** | Review all 25 figures + primary_results.json; approve or redirect |
| 19 | May 9 | **Analyst revisions** | Re-run Analyst for any redirected teams (~2–4 expected); PI re-confirms |
| 20 | May 10 | **Bonferroni + Writer batch 1** | Run `scripts/bonferroni_adjust.R`; review adjusted_pvalues_report.md; Writer sessions teams 01–10 |
| 21 | May 11 | **Writer batch 2** | Teams 11–20 — run Writer sessions |
| 22 | May 12 | **Writer batch 3** | Teams 21–25 — run Writer sessions |
| 23 | May 13 | **Reviewer batch 1** | Teams 01–13 — run Peer Review sessions |
| 24 | May 14 | **Reviewer batch 2** | Teams 14–25 — run Peer Review sessions |
| 25 | May 15 | **PI Review Gate G** | PI reads all 25 reports + peer reviews; flags quality issues |
| 26 | May 16 | **Writer revisions** | Targeted revisions for any reports flagged at Gate G |
| 27 | May 17 | **Buffer** | Complete remaining sessions; PI final confirmation of all 25 reports |
| 28 | May 18 | **Synthesis** | Run Synthesizer agent; writes `synthesis/theory_evaluation.md` |
| 29 | May 19 | **PI synthesis review** | PI reads theory_evaluation.md; requests any corrections |
| 30 | May 20 | **Complete** | Final revisions if needed; commit all files; project ready for paper writing |

---

## Gate days (dedicated PI review — no new agent sessions on these days)

| Gate | Day | Description |
|------|-----|-------------|
| Gate B | Day 7 (Apr 27) | All 25 RQs reviewed; theory families confirmed; pre-registration authorised |
| Gate D | Day 18 (May 8) | All 25 analyses reviewed; Bonferroni run authorised |
| Gate G | Day 25 (May 15) | All 25 reports + peer reviews reviewed; synthesis authorised |

---

## Batch sizes and daily time estimates

| Phase | Teams/day | Session duration | Daily time |
|-------|-----------|-----------------|------------|
| Designer | 5–6 | ~20–30 min each | 2–3 hrs |
| Analyst (simple) | 4–5 | ~60–90 min each | 4–6 hrs (parallel) |
| Analyst (complex) | 3–6 | ~90–120 min each | run in parallel |
| Writer | 10 | ~30–45 min each | 3–4 hrs (parallel) |
| Reviewer | 12–13 | ~20–30 min each | 3–4 hrs (parallel) |

---

## Complex teams (external API required)

| Team | Sub-family | API type | Est. cost | Scheduled day |
|------|-----------|----------|-----------|---------------|
| 05 | topic-avoidance | LLM classification (Claude Haiku) | ~$5–10 | Day 15 |
| 06 | topic-avoidance | Text embeddings (OpenAI) | ~$10–20 | Day 14 |
| 10 | framing-neutrality | LLM classification | ~$5–10 | Day 15 |
| 12 | framing-neutrality | LLM classification | ~$5–10 | Day 15 |
| 23 | ideological-alignment | LLM classification (4-way) | ~$3–6 | Day 15 |
| 24 | ideological-alignment | LLM classification (binary) | ~$2–4 | Day 15 |
| 25 | ideological-alignment | LLM classification (binary) | ~$2–4 | Day 15 |

**Total estimated API cost: ~$32–65.** Confirm access and budget before Day 14/15.

---

## Step A status note

Designer sessions for Teams 01–22 were completed on Day 1 (2026-04-21). Designer sessions for Teams 23–25 (ideological-alignment redesign) were completed on 2026-04-20. All 25 teams have rq.md + analysis_plan.md. Project is currently at Gate B (Day 7).
