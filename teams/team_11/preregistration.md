# Pre-registration: team_11

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 11 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use first-person argumentative stance phrases — such as "we argue," "I argue," "we show," or "we demonstrate" — at lower rates in SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Making an explicit attributed claim in academic writing ("we argue that X") exposes the author as the source of an assertion, increasing personal accountability for the content of a paper. In autocratic settings, where the costs of being identified as the author of politically problematic arguments are non-trivial, researchers have an incentive to avoid constructions that anchor claims directly to their own authorial voice. An observable symptom of this risk-management strategy is a reduced rate of first-person argumentative stance phrases in published abstracts, as researchers substitute passive, impersonal, or institutional constructions ("it is found that," "the results suggest," "this paper examines") that diffuse accountability.

## Theoretical mechanism

In autocracies, the personal attribution of intellectual claims generates career risk: a researcher who writes "we argue that the state is responsible for X" has publicly staked a position that can be scrutinized, quoted, and used against them by regime actors, employers, or colleagues acting as informants. Researchers anticipate this risk and learn — through direct experience or social observation — to write in ways that reduce personal exposure, which includes replacing first-person argumentative constructions with impersonal or passive voice equivalents that are harder to attribute to the author's own convictions. This defensive rhetorical strategy would be practiced selectively and rationally: researchers in sensitive fields or under more repressive regimes would depress their argumentative stance rate more than researchers in safe contexts. The expected direction is positive: higher `v2x_libdem` → higher mean argumentative-stance phrase rate per abstract word, because democratic environments reduce the cost of explicit personal attribution.

## Hypothesis

**H1:** Countries with lower Liberal democracy levels will exhibit lower mean rates of first-person argumentative stance phrases in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean argumentative-stance phrase rate (stance phrase count per abstract word), conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis

Country-year

## Outcome variable

`stance_rate_mean`: constructed at the article level as the count of matches to the stance-phrase regex divided by the abstract word count (producing a rate bounded [0, ∞)); then averaged across all articles with non-missing abstracts within each country-year. Construction steps:

1. Lowercase the `abstract` field.
2. Count matches of the following regex pattern (all boundaries are word-level):
   `\b(we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim)\b`
3. Count abstract words as the number of whitespace-delimited tokens (`\w+` matches).
4. Compute `stance_rate = n_matches / n_words` for each article. Articles with fewer than 20 words or missing abstracts are excluded.
5. Aggregate to country-year: `stance_rate_mean = mean(stance_rate, na.rm = TRUE)`, restricted to country-years with at least 5 qualifying articles.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. rq.md files exist for teams 01–06; teams 07–10 have no rq.md files at time of writing. The brief for this project specifies that Team 08 covers **hedging** (epistemic uncertainty softeners such as "may," "might," "possibly") and Team 09 covers **normative language** (evaluative and prescriptive phrasing).

Team 11 is distinct on all three dimensions:

- **Versus Teams 01, 02, 04 (topic-avoidance family):** Those teams measure what researchers write *about* (political keywords, sensitive topics, disciplinary field); Team 11 measures *how* researchers write — the rhetorical stance adopted toward their own claims, not the content of those claims.
- **Versus Team 08 (hedging):** Hedging measures epistemic diffidence — the softening of truth claims through modal verbs and uncertainty markers. Team 11 measures argumentative assertion — the explicit attribution of a conclusion to the authors' own reasoning. These are complementary and can move in the same or opposite directions; they tap different self-censorship mechanisms (reducing exposure to uncertainty vs. reducing personal accountability for claims).
- **Versus Team 09 (normative language):** Normative language covers evaluative judgment ("should," "ought," "it is important that"), which is thematically distinct from the first-person argumentative framing targeted here. A paper can be normative without using first-person assertions, and vice versa.
- **No overlap with Teams 03, 05, 06:** These measure disciplinary composition, LLM-classified governance critique, and semantic diversity of embeddings, respectively — all structurally different from a regex count of first-person stance phrases.


---

## Analysis Plan

# Team 11 — Analysis Plan

## Hypothesis

**H11:** Researchers affiliated with more autocratic countries use first-person argumentative stance phrases at lower rates in SSH article abstracts. Formally: the coefficient on `v2x_libdem` in the main regression is positive and statistically significant.

---

## Outcome variable construction

### Stance-phrase regex

The following patterns are matched case-insensitively on the `abstract` field:

```
we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim
```

All patterns are applied with word-boundary anchors where applicable. No stemming or fuzzy matching is used. The pattern list covers the most common first-person argumentative constructions in English-language SSH abstracts. Variants such as "the authors argue" (third-person) are intentionally excluded: the mechanism is self-exposure via first-person attribution, not any assertion structure.

### Normalization

For each article:
- `n_stance` = number of regex matches in the lowercased abstract
- `n_words` = number of whitespace-delimited tokens matching `\w+`
- `stance_rate` = `n_stance / n_words`

Exclusions before computing the rate:
- Articles with missing or empty abstracts
- Articles with `n_words < 20` (likely non-English fragments or placeholder text)

### Aggregation to country-year

`stance_rate_mean` = arithmetic mean of `stance_rate` across all qualifying articles for a given `iso3` x `year` cell. Country-years with fewer than 5 qualifying articles are dropped from the regression sample to avoid noisy estimates from very small cells.

---

## Regression model

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    iso3 + year,
  data = cy_data,
  cluster = ~iso3
)
```

- **Estimator:** `fixest::feols` (OLS with fixed effects via the Frisch-Waugh-Lovell partialling approach)
- **Outcome:** `stance_rate_mean` (country-year mean stance-phrase rate)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)` — log-transformed to reduce skew; both entered as continuous variables
- **Fixed effects:** country (`iso3`) + year (`year`) — two-way FE absorbing all time-invariant country characteristics and common year shocks
- **Standard errors:** clustered by country (`iso3`) to allow arbitrary within-country serial correlation

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`.

```r
feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
    year,
  data = cy_data,
  cluster = ~iso3
)
```

- **Estimator:** `fixest::feols`
- **Outcome:** `stance_rate_mean`
- **Key predictor:** `v2x_libdem`
- **Controls:** `log(e_gdppc)`, `log(e_wb_pop)`
- **Fixed effects:** year (`year`) only — no country FE
- **Standard errors:** clustered by country (`iso3`)
- **Purpose:** Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Because country FE are omitted, the coefficient reflects both within- and between-country variation and should be interpreted descriptively, not causally.

Both specifications are reported in the same regression table.

### Rationale for fixed-effects design

Country FE remove all between-country confounders (geography, colonial history, language environment, base level of academic culture). Year FE remove global trends in abstract writing style (e.g., increasing norm of explicit argumentative framing in international journals over time). The identifying variation is within-country change in regime level over time, correlated with within-country change in the mean stance rate. The secondary pooled OLS specification retains between-country variation, providing a complementary descriptive picture of the cross-sectional level difference between autocracies and democracies.

---

## Identification strategy

**Variation exploited:** Within-country, over-time variation in `v2x_libdem` — regime transitions, gradual liberalization or autocratization — that predict changes in the mean stance-phrase rate within the same country.

**Confounders controlled:**

| Threat | How addressed |
|---|---|
| Time-invariant country differences (language, academic culture, institutional tradition) | Country FE |
| Global secular trend in abstract style (increasing explicit argumentation in anglophone journals) | Year FE |
| Economic development (richer countries publish more and may have different writing norms) | `log(e_gdppc)` |
| Country size / publication volume | `log(e_wb_pop)` |

**Remaining identification threats:**

1. **Composition effect — journal selectivity:** Journals indexed by WOS skew toward international, English-language outlets that may already select for explicit argumentative style, attenuating the true effect downward. This is a concern for level differences; the within-country FE design mitigates this for trend estimates.
2. **Non-English abstracts:** Stance phrases are defined for English; non-English abstracts will by construction have near-zero stance rates, which creates measurement error correlated with country and possibly with regime type if non-English output is more common in certain autocracies. This is addressed in a robustness check (see below).
3. **Reverse causality / simultaneity:** Stance rate is unlikely to affect regime type; directional concern is minimal.
4. **Pre-trends / slow-moving treatment:** V-Dem scores change slowly; year-over-year within-country variation may be small, leading to imprecise estimates. Event-study analysis around large regime transitions (if data density permits) would strengthen identification — flagged for future extension.

---

## Robustness checks

### RC1 — Restrict to English-language abstracts *(critical)*

The stance-phrase regex is English-only; non-English abstracts will register near-zero stance rates by construction, generating measurement error correlated with country and potentially with regime type (many autocracies publish substantially in non-English languages). Re-estimate on the subsample of abstracts identified as English via the corpus language field (if available) or an ASCII/function-word heuristic: articles where `abstract` contains high-frequency English function words ("the", "and", "of", "in", "to") at a rate >= 1 per 20 words. This is the most important robustness check given the multilingual nature of the corpus.

### RC2 — Alternative regime measure: `lied_binary`

Re-estimate the primary model replacing `v2x_libdem` with `lied_binary` (binary: 1 = electoral democracy, 0 = non-democracy). This tests whether the result is robust to a dichotomous operationalization of regime type and to a different coding source (LIED vs. V-DEM).

### R3 — Disciplinary subsample: political science and sociology

If self-censorship through argumentative-stance suppression is politically motivated, the effect should be strongest in the most politically exposed disciplines. Re-estimate on the subsample where `subject_primary` is "Political Science" or "Sociology." A larger (more negative) coefficient in this subsample relative to the full sample would be consistent with the theoretical mechanism.

### R4 — Expanded phrase list

Re-estimate using an expanded regex that additionally captures: `we suggest|we propose|we hypothesize|we posit|this paper contends|the authors argue`. This tests sensitivity to the phrase-list boundary.

---

## Expected output files

All files written to `teams/team_11/analysis/`:

| File | Content |
|---|---|
| `analysis.R` | Full reproducible R script (tidyverse + fixest) |
| `figures/fig1_stance_rate_by_regime.pdf` | Binscatter of `stance_rate_mean` vs. `v2x_libdem`, within-country demeaned, with regression line |
| `figures/fig2_coef_plot.pdf` | Coefficient plot: primary model + robustness checks (RC1, RC2, R3, R4) on the same axis |
| `figures/tab1_main_regression.tex` | Main regression table (modelsummary or stargazer): primary spec + RC1 + RC2 |
| `primary_results.json` | Machine-readable primary result: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs |

---

Step 1 complete — ready for PI review.
