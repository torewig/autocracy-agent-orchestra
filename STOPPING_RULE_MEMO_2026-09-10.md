# P02 — Stopping-rule memo for the unfinished pre-registered teams

**Paper:** How Autocracy Shapes the Social Sciences: Synthesized Evidence from an Agent Orchestra
**Memo drafted:** 2026-09-10 (skeleton prepared by Claude Code at the PI's request; decision fields left blank for the PI)
**Decision by:** Tore Wig (PI)
**Decision date:** ____________
**Basis:** `CRITICAL_REVIEW_2026-07-03.md` §4.6 and §5.A.2; `TASKS_publication_BJPS.md` item A1; `STATUS.md` (2026-06-23) cost table

---

## 1. Why this memo exists

The pre-registration commits the paper to 25 confirmatory tests. Four teams are unfinished: 05, 06, 10 and 12. Deciding their fate after having seen the other results, without a written rule, would make the confirmatory set conditional on those results (the mirror image of p-hacking). This memo records a decision that is taken on **budget grounds only**, states what was known when it was taken, and fixes the disclosure language for the paper in advance.

This memo does not change any registered hypothesis, specification, or classifier. It only decides whether the remaining registered tests are run.

## 2. What was known when this memo was written

Stated for the record, because the decision cannot be made blind to it:

- 21 of 25 teams complete (2026-06-23). 0 of 21 significant after Bonferroni correction. The one nominal hit (Team 22) is wrong-signed.
- The four unfinished teams are the LLM content classifiers and the embedding-distance test, which `STATUS.md` describes as the family where any self-censorship effect is most plausible.
- No result from Teams 05, 10 or 12 exists. Team 06 is paused at about 65% with preprocessing cached; no test statistic has been computed.
- Time since the last results contact: results last inspected 2026-06-23. This memo is written 2026-09-10.

## 3. The remaining teams and their cost

| Team | Method | Est. cost | Pre-registered ceiling | Sample cap | State |
|---|---|---|---|---|---|
| 05 | Claude Haiku classifier: critical framing of domestic governance | ~$800–900 | $1,500 | 2,000,000 rows | not started |
| 06 | OpenAI text-embedding-3-small: cosine distance of abstract embeddings | ~$0.30 | none | ~100,000 abstracts | paused ~65%, preprocessing cached |
| 10 | Claude Haiku classifier: technocratic framing | ~$400–450 | $800 | 1,000,000 abstracts | not started |
| 12 | Claude Haiku classifier: normative conclusion | ~$500 | $700 | 1,250,000 abstracts | not started |

Total to complete all four: roughly $1,700–1,850 at estimate, $3,000 at ceiling. (Figures from `STATUS.md`; the 2026-09-08 briefing quotes the same range.)

Reference point: Teams 23–25 (the ideological-alignment family) cost about $367 in total against a $400 family ceiling.

## 4. Decision rule

The rule below is fixed before the decision is entered. The decision must follow from it and from budget facts alone.

- **Team 06 is finished regardless.** Cost is negligible and the work is two-thirds done. Leaving it unfinished cannot be justified on any ground.
- **Teams 05, 10, 12 are run if, and only if,** the project can commit the estimated cost (about $1,700–1,850, ceiling $3,000) from the ERC budget line for computational services without displacing a planned expenditure. The relevant constraint is: ________________________________ (PI to state the budget line, the amount available, and any competing commitment).
- If the budget test passes, all three are run as pre-registered, at their pre-registered ceilings, with no change to prompts, samples, or specifications.
- If the budget test fails, all three are dropped together. Dropping a subset would require a results-based argument for which to keep, which this memo forbids. The paper then reports 22 of 25 registered tests (21 done plus Team 06) and discloses the deviation as in §6.
- The PI does not look at any new result (including Team 06's, once run) before this memo is signed.

## 5. Decision

- [ ] **RUN** Teams 05, 10, 12 (budget test passed)
- [ ] **DROP** Teams 05, 10, 12 (budget test failed)
- [x] **FINISH** Team 06 in either case

Budget facts relied on: ______________________________________________________

Signed: ______________________  Date: ______________

## 6. Disclosure text for the paper (fill in the chosen branch)

**If RUN:**
> Three of the 25 pre-registered tests (Teams 05, 10 and 12) and the final third of a fourth (Team 06) were completed after the results of the other 21 tests were known. The decision to complete them was taken on [date] under a written, budget-only stopping rule recorded before the analyses were resumed; no registered specification was altered.

**If DROP:**
> Three of the 25 pre-registered tests (Teams 05, 10 and 12) were not run. The decision was taken on [date] on cost grounds under a written stopping rule, after the results of the other 21 tests were known. The three omitted tests are the LLM content-classifier tests of critical, technocratic and normative framing, which the pre-registration identified as the family where a self-censorship effect would be most plausible. We therefore treat the reported null as a null over 22 of 25 registered tests and discuss what the omitted family could and could not have shown. Their pre-registered analysis plans remain public in the replication repository.

Either text goes in the methods section, with the memo itself included in the transparency appendix (task C3).

## 7. Follow-on actions once signed

1. Finish Team 06 (`run_team06.ps1`).
2. If RUN: launch 05, 10, 12 through `scripts/launch_analyst.ps1` with the pre-registered ceilings; run the cost preflight first.
3. Run `scripts/bonferroni_adjust.R` over the final team set (task A5).
4. Add this memo to the transparency appendix and cite the decision date in the methods section (tasks C3, D2).
5. Record the decision in `notes.md`, `STATUS.md`, and `AI_LOG.md`.
