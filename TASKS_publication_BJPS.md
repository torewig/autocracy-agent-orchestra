# P02 — Task list: getting to submission at BJPS (or related venue)

**Paper:** How Autocracy Shapes the Social Sciences: Synthesized Evidence from an Agent Orchestra
**Target:** British Journal of Political Science; fallbacks PSRM (methods-friendly, CUP) or Research & Politics (short format). Chosen because the agent-orchestra method requires a venue not hostile to AI-assisted research. Decided 2026-09-08.
**Basis:** `STATUS.md` (2026-06-23), `CRITICAL_REVIEW_2026-07-03.md`. This list operationalizes that review — read it in full before starting; nothing here supersedes it.

---

## Honest assessment — what this paper is and isn't

**What we have:** 21/25 pre-registered tests complete; **0/21 significant after Bonferroni**; the one nominal hit (Team 22) is wrong-signed. This is a clean null. The publishable paper is an *informative null about the intensive margin of internationally indexed SSH output*, plus a transparent template for agent-orchestrated confirmatory research. It is not, and cannot honestly be presented as, evidence that self-censorship doesn't exist.

**The weaknesses a BJPS reviewer will find (all from the 2026-07-03 review, still unaddressed):**

1. **The null is currently uninformative.** TWFE identification comes from within-country regime change; China and Russia (~half the autocracy-side data) are flat on v2x_libdem. No power analysis, MDE, or equivalence test exists anywhere. Without them, "0/21" cannot distinguish "theory wrong" from "design can't see it." *This is the make-or-break gap.*
2. **Collider/selection problem.** WOS conditions on the outcome of the censorship process — the effectively censored article never appears. All 25 tests are intensive-margin; the theory's sharpest predictions are extensive-margin. The draft doesn't discuss WOS selection at all.
3. **Outcome dilution.** SSH-wide country-year unweighted means; political science is ~2.5% of the corpus; domestic and internationally co-authored papers are pooled.
4. **Pre-registration compliance gap.** The promised human validation of the LLM classifiers (Teams 23–25; 350 abstracts per pi_notes) was never run. This is a deviation toward less rigor and must be fixed, not footnoted. Team 24's prompt injects country names — needs a masked-country robustness check.
5. **Selective-stopping risk.** Deciding the fate of Teams 05/10/12 *after* seeing 21 nulls conditions the confirmatory set on results. Team 06 sits at 65% with ~$0.30 to finish — indefensible to leave.
6. **Verified data bug.** SUN/CSK/YUG mapped to ISO codes absent from `vdem_clean.rds`; 5,049 rows silently dropped; code comment claims otherwise. Harmless for ≥1990 analyses but must be fixed and documented.
7. **Draft state.** `draft_APSG.tex` reports 18 teams (21 done), Discussion is ~120 words, ~10 typos, two unverified forward-dated citations.

**The AI angle, honestly:** the agent orchestra is the paper's methodological novelty and its reviewer risk. The only way it survives review is full auditability — prompts, gate reviews, prereg commit hash, cost logs, and classifier validation in an appendix. CUP journals require AI-use disclosure; here the AI *is* the method, so over-document rather than under-document.

---

## Task list

### Phase A — Close the confirmatory record (do first; order matters for integrity)

- [ ] **A1. Write the stopping-rule memo NOW, before any further results contact:** decide Teams 05/10/12 on budget grounds only, in writing, dated. If dropped: disclose in the paper as a funding-constrained deviation decided 2026-07/09. (~$400–900 each if run.)
- [ ] **A2. Finish Team 06** (~$0.30, paused at 65%, preprocessing cached). No excuse.
- [ ] **A3. Run the pre-registered human validation for Teams 23–25** (350 abstracts each): accuracy/κ vs. own coding, class distributions, inter-run agreement. Report whatever comes out — poor validation conditions interpretation, it doesn't license re-running.
- [ ] **A4. Team 24 masked-country robustness** run on a subsample.
- [ ] **A5. Run pipeline steps D → D′ (`bonferroni_adjust.R`) → E–G → S** so the confirmatory record closes cleanly.
- [ ] **A6. Fix the SUN/CSK/YUG join bug** + wrong code comment; document as a data correction. Update `notes.md`, which still wrongly describes the corpus as "Cold War subset 1945–1983."

### Phase B — Make the null informative (exploratory, labeled as such)

- [ ] **B1. Power/MDE per team + equivalence tests (TOST)** against a smallest-effect-of-interest. Converts "not significant" into "we can rule out effects larger than X." *Highest-value single addition.*
- [ ] **B2. Identifying-variation diagnostics:** within-country SD of v2x_libdem in the estimation sample; influential-country/episode analysis; re-estimate on countries with meaningful regime change (range > 0.1).
- [ ] **B3. Event-study around regime transitions** (ERT episodes) alongside continuous TWFE.
- [ ] **B4. De-dilution re-runs:** sensitive fields only; domestic-only vs. internationally co-authored; article-count-weighted.
- [ ] **B5. Attrition table:** N and regime composition at each filter step; abstract-missingness by decade × regime (`check_abstracts.R` output exists, unreported).

### Phase C — Rewrite the paper

- [ ] **C1. Update results to the full team set** (currently reports 18) and fix typos + verify the two 2026-dated citations.
- [ ] **C2. Discussion (3–5 pages)** built around the three-way interpretation — true null vs. measurement attenuation vs. extensive-margin selection — adjudicated with the Phase B diagnostics. Explicit WOS-selection section.
- [ ] **C3. Transparency appendix:** prereg commit hash, all prompts, gate review docs, cost logs, validation results. This is what makes the AI-assisted method defensible at review.
- [ ] **C4. Frame the contribution as:** (i) first pre-registered many-implication test of self-censorship theory at corpus scale; (ii) informative null on the intensive margin of indexed output; (iii) transparent agent-orchestra template. Do NOT oversell the null as "no self-censorship."
- [ ] **C5. Decide on a separate methods paper** for the agent-orchestra protocol itself (PSRM/R&P) so the substantive paper doesn't carry both loads.

### Phase D — BJPS submission mechanics

- [ ] **D1.** Check current BJPS word limit and format; the 25-test apparatus goes to online appendix.
- [ ] **D2.** AI-use disclosure per CUP policy (method section + acknowledgments).
- [ ] **D3.** Replication package: repo is public-ready? (currently `how-autocracy-shapes-social-sciences`); freeze at submission with a Zenodo DOI. WOS raw data cannot be redistributed — prepare aggregated replication data + scripts.
- [ ] **D4.** ERC funding acknowledgement + prereg statement in the manuscript.
- [ ] **D5.** Journal ladder in writing: BJPS → PSRM → Research & Politics (short version). Decide before first submission so rejection turnaround is fast.

---

## Suggested order

1. A1 (stopping memo) — today, before anything else touches results
2. A2–A6 in parallel (small jobs except A3)
3. B1–B5 (the informative-null apparatus)
4. C1–C4 rewrite
5. D1–D5 and submit

**Realistic risk:** even done well, a null-results paper with a novel AI method is a hard sell at BJPS. The insurance is (a) the equivalence-test apparatus making the null quantitatively informative, and (b) the extensive-margin successor (P05) which this paper should explicitly set up — the two papers argue for each other.
