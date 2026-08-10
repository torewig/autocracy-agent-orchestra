# Critical Review — Agent Orchestra Project

**Date:** 2026-07-03
**Scope:** Full project review — design, data, analysis, paper draft, and paths forward.
**Basis:** PLAN.md, STATUS.md, REPORT_2026-06-23.md, gate_b_review.md, draft_APSG.tex, slides.tex, scripts/00_prepare_data.R, scripts/bonferroni_adjust.R, team materials for teams 01, 06, 13, 17, 20, 22, 23, 24 (rq.md, preregistration.md, analysis.R, primary_results.json), data/n_summary.txt, data/country_match_log.txt, plus direct verification of the V-DEM join in R.

---

## 1. Where the project stands

- 25 pre-registered teams (commit `960525f`, 2026-05-06), one hypothesis each, five Bonferroni sub-families, all testing implications of a single self-censorship theory on a WOS SSH corpus (2.7M articles, 3.19M article-country rows, 1970–2023) merged with V-DEM.
- 21/25 analyses complete. **0/21 significant after within-family Bonferroni; only Team 22 nominally significant (p=0.039) and wrong-signed.** With 21 true nulls one would expect ~1 nominal hit by chance — the pattern is a clean null.
- 4 complex teams pending (05, 06, 10, 12), blocked on an API-budget decision. Team 06 is paused at ~65% with ~$0.30 marginal cost to finish.
- Paper draft (draft_APSG.tex) is a 60–70% skeleton, outdated (reports 18 teams, omits 23–25), with a ~120-word Discussion.
- Steps D (gate review), D′ (Bonferroni script), E–G (writer/reviewer sessions), S (synthesis) not yet run; `synthesis/` is empty.

## 2. Verdict in brief

The infrastructure is genuinely impressive — the pre-registration discipline, file-based agent pipeline, uniform specs, and honest null reporting are better practice than most published work in this literature. But **as it stands, the null result is not interpretable**, for three reasons that compound: (a) the TWFE design has almost no identifying variation where the data are (China/Russia are flat on v2x_libdem; transitions are rare); (b) the outcome measures are diluted (country-year means over a corpus dominated by economics/education/psychology, mixing domestic and international-coauthored papers); and (c) the corpus itself conditions on the collider — self-censorship plausibly operates at the *extensive* margin (what never gets written, or never reaches an English-language WOS journal), while every test here operates on the *intensive* margin (how indexed abstracts are worded). "No detectable trace of self-censorship in internationally indexed SSH abstracts" is a defensible and publishable claim; "no self-censorship" is not, and the current draft does not yet equip the reader to tell the difference.

---

## 3. What is genuinely strong

1. **Pre-registration done properly.** Hypotheses, directions, families, specs, and even API cost ceilings locked in a timestamped commit before analysis. Team 22's wrong-signed nominal hit is correctly reported as a non-result — exactly what pre-registration is for.
2. **Uniform estimation across 25 tests** (same TWFE spec, same controls, same clustering) makes the results genuinely comparable — closer to a coordinated many-analysts design than to 25 ad hoc papers.
3. **Within-family Bonferroni is implemented correctly** (verified in `bonferroni_adjust.R`).
4. **Pipeline engineering is clean.** 99.98% ISO3 match, 99.78% V-DEM join, transparent logs (`n_summary.txt`, `country_match_log.txt`), reproducible team scripts, JSON results for machine synthesis.
5. **Honest reporting culture.** STATUS.md and REPORT_2026-06-23.md state the nulls plainly, including the wrong signs. No spin.
6. **Measurement diversity** — dictionaries, structural/behavioral outcomes (co-authorship, journals, citations), embeddings, LLM classifiers — means the null is not an artifact of one measurement choice.

---

## 4. Critical issues, ranked

### 4.1 The null is currently uninformative about the theory (design + power) — HIGH

- `v2x_libdem` is a slow-moving regressor. With country and year FE, identification comes only from within-country regime *change*, and the effective sample is the small set of transition episodes — not 2,500–3,500 country-years. China (~85K articles, ~30% of all autocracy observations) and Russia (~47K, ~17%) are essentially **flat** on v2x_libdem across the period when they publish; together they contribute ~half the autocracy-side data and ~zero identifying variation.
- ~160 clusters, country-year aggregation, unweighted means: minimum detectable effects for several teams are plausibly larger than any realistic true effect (e.g., Team 01's MDE is roughly 10× its observed coefficient).
- **No power analysis, MDE, or equivalence test appears anywhere.** Without these, "0/21 significant" cannot distinguish "theory is wrong" from "design cannot see it." This is the single most important gap between the current material and a publishable informative-null paper.

### 4.2 The corpus conditions on the outcome of the censorship process (conceptual) — HIGH

- WOS indexes English-language, internationally oriented journals. A researcher who self-censors most effectively simply never appears there with sensitive work — the censored counterfactual article is missing from the data, not reworded within it. Testing wording/topic shares *conditional on being indexed* selects on the collider.
- Compounding this: WOS coverage of Chinese and Russian SSH expanded massively in exactly the period studied (61% of the corpus is from the 2010s), so within-country trends confound regime dynamics with indexing dynamics. Year FE do not absorb country-specific coverage growth.
- The draft does not address selection into WOS at all. It must — and the deeper fix is a design that observes the extensive margin (Section 6).

### 4.3 Outcome dilution (aggregation) — HIGH

- The corpus is dominated by **non-sensitive fields**: Economics, Education, Clinical Psychology, Business are the top categories; Political Science is #10 (~2.5% of articles). A self-censorship effect concentrated in politically sensitive fields is averaged away in SSH-wide country-year means.
- Country-year aggregates mix domestic-only papers with international collaborations. If regime pressure binds mainly on domestically authored work, mixing in internationally coauthored papers (whose agendas democratic co-authors shape) attenuates the estimate — and the mixing proportion itself correlates with regime.
- Most teams use unweighted country-year means, so a 5-article country-year counts the same as a 50,000-article one; noisy small autocracy country-years inflate SEs.

### 4.4 LLM classifier validation was planned but never run (compliance gap) — HIGH

- pi_notes for Team 23 specifies a human validation sample (350 abstracts, 70 per class); nothing in analysis.R or the results reports it. Team 24 similarly lacks any human benchmark, class-distribution reporting, or inter-run reliability check. **This is a deviation from the approved plan, in the direction of less rigor** — running the validation now is compliance, not a post hoc addition.
- Team 24 injects the country name into the classification prompt — sensible for context, but it risks the classifier keying on country identity rather than text (e.g., "China" priming "legitimating"). Needs a masked-country robustness run on a subsample.

### 4.5 Data pipeline issues — MEDIUM (one verified bug)

- **Verified bug:** `00_prepare_data.R` maps USSR→`SUN`, Czechoslovakia→`CSK`, Yugoslavia→`YUG`, and the comment at line 99 claims these are "coded in V-DEM." They are not — `vdem_clean.rds` contains only `DDR` and `RUS` among these. Result: **5,049 article-country rows (SUN 2,314; CSK 2,594; YUG 141) silently get NA regime scores and drop out.** Harmless for the current ≥1990 analyses, but it contradicts the code comment, and `notes.md` still describes the project as a "Cold War-era subset (1945–1983)" — any Cold War extension would be built on a broken join. Fix: map to V-DEM's continuous units (USSR→RUS, Czechoslovakia→CZE, Yugoslavia→SRB) or drop with explicit documentation.
- **No attrition accounting.** The filters (year ≥1990, n_articles ≥5, non-missing v2x_libdem/GDP/pop, non-missing abstract) each disproportionately remove autocracy observations, and no table reports N by regime type at each step. Reviewers will ask; you should know the answer before they do.
- Abstract availability by decade/regime (`check_abstracts.R` exists but output unreported) is an unquantified selection channel.
- Minor: Team 01's "weighted" robustness uses uniform weights (`w = rep(1, n())`) — it is not weighted; Team 13's journal-domesticity classification is constructed from the same corpus as the outcome (mild circularity).

### 4.6 The 4 unfinished teams are now a selective-stopping risk — MEDIUM, time-sensitive

- Teams 05, 10, 12 are the LLM content classifiers where, as STATUS.md itself notes, "any self-censorship effect is most plausible." Deciding *after seeing 21 nulls* whether to spend the money completes or truncates the pre-registered set conditional on results — the mirror image of p-hacking. Either finish them, or document a results-independent (budget-only) stopping rule now and disclose it in the paper as a deviation. Team 06 costs ~$0.30 to finish; there is no defensible reason to leave it at 65%.

### 4.7 Paper draft state — MEDIUM (effort, not design)

- Draft reports 18 teams; 21 are done — Teams 23–25 results are missing entirely.
- Discussion is one paragraph (~120 words). No power discussion, no measurement-validity discussion, no WOS-selection discussion, no theory re-evaluation — the four things a null-results paper lives or dies by.
- ~10 typos in the current text ("shoul dobserve", "orhcestra", "Democray", "free speec", etc.); two forward-dated citations (zhu2026hler, gupta2026accelerating) need checking.
- The agent-orchestra method is framed modestly (efficiency + PI oversight), which is right — but the transparency assets that would make it credible (prompts, gate reviews, cost logs, validation) are not yet surfaced in the paper.

---

## 5. Improving the current material — within pre-registration norms

Guiding principle: the pre-registration locks the 25 confirmatory tests. It does not forbid (a) completing planned steps, (b) disclosed corrections of data errors, (c) clearly labeled exploratory/diagnostic analyses, or (d) robustness checks. It does forbid results-contingent stopping, re-specification of primary tests, and re-running classifiers until something moves.

**A. Complete the confirmatory record (highest priority)**
1. Finish Team 06 immediately (~$0.30).
2. Decide teams 05/10/12 on budget grounds only, in writing, now — before further results contact. If run, run as pre-registered; if dropped, disclose as a funding-constrained deviation decided 2026-07, and report it in the paper.
3. Run the pre-registered human validation for Teams 23–25 (350-abstract samples per pi_notes): report accuracy/κ against your own coding, class distributions, and an inter-run agreement check. If validation is poor, that is itself a finding that conditions interpretation — it does not retroactively change the registered test.
4. Run Steps D′–S as planned so the confirmatory pipeline closes cleanly.

**B. Make the null informative (exploratory, labeled as such)**
5. **Power/MDE analysis per team** — simulate or compute minimum detectable effects under the registered spec; add **equivalence tests (TOST)** against a smallest-effect-of-interest. This converts "not significant" into "we can rule out effects larger than X." This is the single highest-value addition to the paper.
6. **Diagnose the identifying variation:** report within-country SD of v2x_libdem for the estimation sample; show which countries/episodes drive the estimates; re-estimate on the subsample with meaningful regime change (e.g., within-country range > 0.1).
7. **Event-study around regime transitions** (democratization and autocratization episodes, e.g., ERT dataset) instead of/alongside continuous TWFE — this is the design the question actually wants.
8. **De-dilute:** re-run key outcomes (i) restricted to sensitive fields (political science, law, sociology, history, area studies), (ii) split by domestic-only vs internationally coauthored papers, (iii) weighted by article counts. If self-censorship exists anywhere in this corpus, it is in domestic-only political-science papers — say so and look there.
9. **Attrition table:** N and regime composition at every filter step; abstract-missingness by decade × regime.
10. Fix the SUN/CSK/YUG join and the wrong code comment; document as a data correction (no registered hypothesis touches pre-1990 data, so this is uncontroversial).

**C. Rewrite the paper around the honest story**
11. Update to 21 (or 25) teams; fix typos; verify the two 2026 citations.
12. Build the Discussion (3–5 pages) around the three-way interpretation — true null vs. measurement attenuation vs. extensive-margin selection — and use the Section-B diagnostics to adjudicate between them as far as possible.
13. Frame the contribution as: (i) the first pre-registered, many-implication test of self-censorship theory at corpus scale; (ii) a precise, well-powered-conditional-on-design null on the *intensive margin of internationally indexed output*; (iii) a transparent template for agent-orchestrated confirmatory research. Surface the transparency assets (prompts, gates, prereg commit, cost logs) in an appendix — for the method to be a credible contribution, its audit trail must be inspectable.
14. Venue: with an expanded discussion and the informative-null apparatus, this is plausible at a strong general or methods-friendly outlet (JOP, BJPolS, Research & Politics for a shorter version; *Nature Human Behaviour*-adjacent venues if the agent-methodology angle is foregrounded). APSR is a stretch for a null unless the method framing carries more weight.

---

## 6. Ways forward — probing the question deeper

The current design asks: *do indexed English-language abstracts from autocracies read differently?* The deeper question is about what never appears. Ranked by expected payoff:

1. **Extensive-margin comparison across corpora.** Compare national-language corpora (CNKI for China, eLibrary/RSCI for Russia, local indices elsewhere) against WOS for the same countries/fields/years. Self-censorship predicts sensitive topics survive in domestic venues but vanish from international ones — or vanish everywhere after crackdowns. This directly tests the selection mechanism the current design conditions away.
2. **Researcher-level panels around sharp shocks.** Follow individual authors (disambiguated via OpenAlex/Scopus IDs) through regime events: Hungary post-2010, Turkey post-2016, Hong Kong post-NSL-2020, Russia post-2022, China post-Document-No.-9 (2013). Author-level event studies — topic switching, venue switching, exit from publishing, emigration — give the within-unit variation that country-level TWFE lacks. This is the strongest feasible causal design and a natural flagship paper.
3. **Émigré/diaspora contrasts.** Same-origin researchers inside vs. outside the country (or the same researcher pre/post emigration) writing on the same fields — a difference-in-differences on regime exposure holding culture/language/training constant.
4. **"Missing topics" counterfactual measurement.** Train topic models on democracies' output within field × year, predict expected topic distributions for autocracies given their field mix, and measure the *deficit* — absence relative to a counterfactual, rather than presence of keywords. Keyword dictionaries cannot see avoidance by construction; this can.
5. **Sharpen to sensitive-field, domestic-only subcorpora** as the primary lens for any future confirmatory round — SSH-wide averages are now known to be too dilute.
6. **Link to the project's other data.** The attacks-on-science dataset gives event-level treatment (arrests, dismissals, university purges) for event studies on colleagues' subsequent behavior — chilling-effect spillovers are the theory's most distinctive prediction. The planned surveys can field list experiments/conjoints on topic avoidance with researchers in or from autocracies, measuring self-censorship directly rather than via its textual shadow.
7. **A second, separated methods paper** on the agent-orchestra design itself (protocol, gates, failure modes, costs, validation), aimed at a methods venue — do not make the substantive paper carry both loads.

---

## 7. Bottom line

Complete the confirmatory pipeline exactly as registered (including the classifier validation you already promised yourself), add the power/equivalence and de-dilution diagnostics as labeled exploratory work, and rewrite the paper as an *informative* null about the intensive margin of internationally indexed science — while building the next study around researcher-level panels and cross-corpus extensive-margin comparisons, where the theory actually makes its sharpest predictions.
