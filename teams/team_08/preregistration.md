# Pre-registration: team_08

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 08 — Research Question

## Research question

Do researchers affiliated with more autocratic countries produce SSH abstracts with higher rates of epistemic hedging language — as measured by the frequency of hedging terms (may, might, seem, appear, suggest, perhaps, possibly, likely, probably, could, would) normalised by abstract word count — compared to researchers in more democratic countries?

## Rationale

Researchers working under autocratic constraints face institutional incentives not only to avoid politically sensitive topics outright, but also to hedge and soften any claims they do make, deflecting regime scrutiny by rendering findings provisional rather than declarative. If self-censorship operates through rhetorical defensiveness, the language of published abstracts in autocratic contexts should systematically exhibit more hedged epistemic commitments than comparable output from democratic settings. Epistemic hedging is detectable at scale without any external API using a closed dictionary of modal and evidential markers, making it a tractable and reproducible operationalization.

## Theoretical mechanism

Researchers in autocracies anticipate reputational and career sanctions — grant denial, employment loss, harassment, or legal exposure — for work that is interpreted as making confident, politically contestable claims. The self-protective response is not only to avoid sensitive topics but also to weaken the epistemic force of assertions, deploying modal hedges ("may suggest," "could appear," "might indicate") to signal that findings are tentative and non-threatening rather than authoritative and politically actionable. This defensive framing strategy should be most pronounced under more autocratic conditions, where the penalty for asserting inconvenient truths is highest. The expected direction of the main coefficient is negative: higher `v2x_libdem` (more democracy) is associated with lower hedging rates per abstract word, because democratic researchers face fewer incentives to soften their epistemic commitments rhetorically.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit higher mean epistemic hedging rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean hedging rate per abstract word, conditional on country and year fixed effects and controls for `log(e_gdppc)` (log GDP per capita) and `log(e_wb_pop)` (log population).

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article carrying a non-missing abstract in the corpus).

## Outcome variable

`hedge_rate_mean`: constructed at the article level as the count of hedging-term tokens divided by total word count of the abstract, then aggregated to the country-year mean. Formally:

1. For each article with a non-missing abstract, compute `hedge_count` = `str_count(tolower(abstract), "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would)\\b")`.
2. Compute `word_count` = `str_count(abstract, "\\w+")`.
3. Compute article-level `hedge_rate` = `hedge_count / word_count`. Articles with `word_count < 20` are excluded (too short for a stable rate).
4. Aggregate to country-year: `hedge_rate_mean` = arithmetic mean of `hedge_rate` across all qualifying articles in that country-year.

The denominator normalisation ensures that the outcome reflects the *intensity* of hedging language per word, not the absolute count, and is therefore comparable across abstracts of different lengths.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, 0–1, continuous; higher = more democratic).

## Uniqueness check

Performed. Teams 01–06 have rq.md files; teams 07, 09, and 11 do not yet exist.

- **Teams 01–04** (topic-avoidance family): all measure *what* topics or keywords appear — political content index, keyword entropy, sensitive disciplinary share, or regime-sensitive term prevalence in titles/keywords. None measure *how* claims are linguistically hedged.
- **Team 05** (LLM critical-framing classification): classifies whether an abstract critically evaluates domestic governance. This captures *framing direction*, not *epistemic hedging intensity*.
- **Team 06** (semantic diversity via embeddings): measures convergence in semantic content across abstracts. Conceptually related to framing but uses dense continuous embeddings rather than a targeted hedging dictionary.
- **Teams 09 and 11** (normative language; argumentative stance): not yet specified, but per the orchestra assignment these concern normative vocabulary and stance respectively — distinct in that normative language measures value-laden terminology (Team 09) and argumentative stance measures assertive/critical orientation (Team 11), while Team 08 specifically targets epistemic uncertainty markers that soften factual claims regardless of their political valence.

**Distinction summary:** Team 08 is the only team measuring the linguistic hedging of epistemic commitment as a defensive framing strategy, operationalised via a closed dictionary of modal and evidential hedging markers normalised by abstract length — requiring no API, no embedding, and no semantic classification.


---

## Analysis Plan

# Team 08 — Analysis Plan

## Hypothesis

Higher autocracy (lower `v2x_libdem`) is associated with a higher mean epistemic hedging rate per abstract word at the country-year level, reflecting defensive rhetorical framing under political constraint.

---

## Outcome variable construction

**Step 1 — Hedging dictionary.** The following terms constitute the hedging lexicon. All matches are case-insensitive, whole-word (regex `\b...\b`):

| Category | Terms |
|---|---|
| Modal verbs | may, might, could, would |
| Evidential verbs | suggest, appear, seem |
| Epistemic adverbs | perhaps, possibly, likely, probably |

This 11-term dictionary covers the core epistemic uncertainty vocabulary in academic English. It is intentionally constrained to avoid over-counting functional uses of common words; "can" and "will" are excluded because their hedging function is less reliable across disciplines.

**Step 2 — Article-level rate.** For each article row with a non-missing abstract and `word_count >= 20`:

```
hedge_count  = str_count(tolower(abstract), "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would)\\b")
word_count   = str_count(abstract, "\\w+")
hedge_rate   = hedge_count / word_count
```

**Step 3 — Country-year aggregation.** Deduplicate on `wos_id` before aggregating (the corpus has one row per article x author-country; each abstract should be counted once per country-year). Aggregate to country-year:

```
hedge_rate_mean = mean(hedge_rate) across unique wos_id articles for that iso3 x year
```

Country-years with fewer than 10 qualifying abstracts are dropped to avoid unstable means from sparse cells.

**Step 4 — Controls.** Merge in `log_gdppc = log(e_gdppc)` and `log_pop = log(e_wb_pop)`. Drop country-years where either control is missing.

---

## Model specification

**Primary specification (pre-registered)** — two-way fixed effects OLS via `fixest::feols`:

```
hedge_rate_mean ~ v2x_libdem + log_gdppc + log_pop | iso3 + year
```

- Fixed effects: country (`iso3`) and year (`year`)
- Standard errors: clustered by `iso3` (country-level clustering accounts for serial correlation within countries)
- Sample: all country-years with >= 10 qualifying abstracts and non-missing values on all variables

**Interpretation of coefficient on `v2x_libdem`:** The within-country change in mean hedging rate associated with a one-unit increase in liberal democracy, net of year fixed effects and time-varying economic controls. A negative coefficient is consistent with the hypothesis (more democracy -> less hedging).

**Secondary specification (descriptive)** — pooled OLS with year FE only via `fixest::feols`:

```
hedge_rate_mean ~ v2x_libdem + log_gdppc + log_pop | year
```

- Fixed effects: year (`year`) only — no country FE
- Standard errors: clustered by `iso3`
- Sample: same as primary specification

**Interpretation:** The cross-sectional association between regime type and mean hedging rate, net of global year trends and time-varying economic controls. Because country FE are absent, this estimate reflects both within- and between-country variation — it captures how autocratic and democratic countries differ in their average hedging levels, not only how countries change as their regime type changes. This complements the TWFE estimate by showing the level difference across regime types.

Both specifications are reported in the same regression table.

---

## Identification strategy

**Source of variation exploited:** Within-country changes in `v2x_libdem` over time (1970-2023). Country fixed effects absorb all stable cross-national differences in academic culture, language norms, and institutional structure. Year fixed effects absorb global trends in academic writing style (hedging norms have shifted toward more hedged language in published science over recent decades).

**Confounders addressed:**
- Country-level economic development (`log_gdppc`): richer countries may have different writing conventions and also tend toward democracy.
- Country-level population (`log_pop`): larger countries produce more articles, potentially affecting mean estimates through composition.
- Country-level time-invariant writing culture: absorbed by country FE.
- Global trends in hedging norms: absorbed by year FE.

**Key identification threats:**
1. *Composition effects:* The disciplinary mix of articles within a country-year may change as democracy changes (e.g., fewer political science articles under autocracy, and disciplines differ in baseline hedging rates). Addressed in robustness check (b) by restricting to political science and sociology.
2. *Language effects:* Non-English abstracts may have systematically different rates of English hedging terms. WOS abstracts are predominantly in English even for non-Anglophone countries; this is noted but not formally adjusted for in the primary specification.
3. *Reverse causality:* Unlikely to be severe — a country's mean hedging rate in abstracts does not plausibly cause democratic backsliding. The panel design with year FE mitigates common-cause confounding from year-specific shocks.
4. *Pre-1990 sparsity:* WOS coverage before 1990 is thin for many non-Western countries. Report estimates for full sample and post-1990 subsample separately.

---

## Robustness checks

**(a) Binary democracy indicator.** Replace `v2x_libdem` with `lied_binary` (= 1 if `e_lexical_index >= 4`). Same FE structure and clustering. Tests whether the result holds under a procedurally grounded binary regime classification.

**(b) Discipline restriction.** Restrict sample to articles in political science and sociology (`subject_primary %in% c("Political Science", "Sociology")`). If self-censorship drives hedging, the effect should be at least as strong in these fields, where the political stakes of confident claims are highest.

**(c) Extended hedging dictionary.** Re-run primary model replacing the 11-term dictionary with an extended set that adds: `arguably`, `conceivably`, `presumably`, `seemingly`, `relatively`, `somewhat`. Tests sensitivity to dictionary boundaries.

**(d) Post-1990 subsample.** Restrict to 1990-2023 to avoid pre-1990 sparsity artifacts. Expected: results stable or stronger given improved coverage.

**(RC1) Restrict to English-language abstracts.** Re-estimate the primary model on the subset of abstracts identified as English-language. Language identification uses the `language` field if available in the corpus; otherwise apply an ASCII-share heuristic (abstracts where >= 90% of characters are ASCII are treated as English). Hedging markers are English-specific; non-English abstracts may introduce noise or systematic bias if autocracies disproportionately publish in domestic non-English journals.

**(RC2) Narrow hedging dictionary.** Re-estimate the primary model after removing `"would"` and `"likely"` from the hedging dictionary (reducing the lexicon from 11 to 9 terms). These two terms appear frequently in non-defensive academic contexts (e.g., "this would suggest", "future work would benefit", "as one would expect") and their inclusion may inflate hedging counts in ways unrelated to epistemic self-censorship. Tests sensitivity of results to the broadest-coverage items in the dictionary.

---

## Expected output files

All written to `teams/team_08/analysis/`:

| File | Content |
|---|---|
| `analysis.R` | Full reproducible R script (tidyverse + fixest) |
| `figures/fig1_hedge_rate_by_regime.png` | Binned scatter: country-year mean hedging rate vs. v2x_libdem, with lowess smoother |
| `figures/fig2_coef_plot.png` | Coefficient plot: main estimate + robustness checks (a)-(d) |
| `figures/tab1_main_results.tex` | Regression table: primary model + robustness checks (modelsummary or stargazer) |
| `primary_results.json` | Structured results: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |

---

## Computational notes

- The hedging dictionary count uses `stringr::str_count` at the article level — no API, no embedding, no external service required.
- With ~2.7 million articles, the string operation will take several minutes. Compute once on the full corpus, save an intermediate tibble with `wos_id`, `hedge_rate`, and `word_count`, then aggregate. Do not loop row-by-row.
- Country-year aggregation: `group_by(iso3, year) |> summarise(hedge_rate_mean = mean(hedge_rate, na.rm = TRUE), n_abstracts = n())`.
- `fixest::feols` handles two-way FE efficiently for ~180 countries x 50+ years.
