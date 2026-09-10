# P02: How Autocracy Shapes the Social Sciences: Synthesized Evidence from an Agent Orchestra

## Core argument
Multi-agent ("agent orchestra") computational design that uses LLM-based agents in a structured pipeline to study how autocratic regime characteristics shape scientific output. Combines bibliometric corpus with regime/political indicators to identify regime-channel effects on knowledge production.

## Data and methods
- **Corpus:** Web of Science SSH articles (`DATA/bibliometric/WOS_scrapes/wos_ssh_articles.rds`, filtered by `scripts/00_prepare_data.R` into `data/agent_corpus.rds`). The registered tests use country-years from 1990 onward (filters: year ≥ 1990, ≥ 5 articles per country-year, non-missing V-Dem, GDP, population and abstract). Corrected 2026-09-10: this line previously described the corpus as a "Cold War-era subset (1945–1983)", which was never what the pipeline built (see `CRITICAL_REVIEW_2026-07-03.md`, section 4.5)
- **Data correction 2026-09-10:** `00_prepare_data.R` mapped USSR, Czechoslovakia and Yugoslavia to codes absent from `vdem_clean.rds`, so 5,049 article-country rows silently lost their regime scores. Now mapped to V-Dem's continuous units (RUS, CZE, SRB). No registered test touches those rows (all pre-1990), but the correction must be reported in the paper and the V-Dem join rate re-checked on the next Phase 0 run. Code change not yet re-run or human-reviewed (see `AI_LOG.md`)
- **Regime indicators:** V-Dem (`DATA/vdem/vdem_clean.rds`)
- **Methods:** LLM-based agent pipeline; 25-team redesign with ideological-alignment family
- **Architecture:** see `PLAN.md`, `STATUS.md`, `TIMELINE.md` in this folder

## Current phase
**Analysis — closing the confirmatory record.** 21/25 pre-registered teams done, 0 significant after Bonferroni. Target BJPS (decided 2026-09-08); task list in `TASKS_publication_BJPS.md`. Stopping-rule memo for Teams 05/10/12 drafted 2026-09-10 (`STOPPING_RULE_MEMO_2026-09-10.md`), awaiting the PI's decision. Gate B review document in `gate_b_review.md` / `.pdf`.

## Key findings (so far)
- [Add as Phase 1 progresses]

## Open questions
- [ ] **Sign the stopping-rule memo** (`STOPPING_RULE_MEMO_2026-09-10.md`): decide Teams 05/10/12 on budget grounds only, before any further results contact. Finish Team 06 regardless (~$0.30)
- [ ] Re-run Phase 0 after the 2026-09-10 country-code correction and confirm the V-Dem join rate; human-review the code change
- [ ] Outstanding items from Gate B review
- [ ] Confirm SSH borderline field inclusions
- [ ] Decide on "Review" doc_type handling

## Timeline
- [x] Phase 0 complete
- [ ] Phase 1 (Gate B review) complete
- [ ] First draft
- [ ] Submission

## Submission log
| Date | Journal | Outcome |
|---|---|---|
| — | — | — |
