# Team 04 — Analysis Plan

## Method

**Overview:** The analysis proceeds in three stages: (1) dictionary-based regex matching to flag regime-sensitive articles; (2) aggregation to country-year share; (3) fixed-effects regression of the share on `v2x_libdem`.

**Stage 1 — Keyword matching:** Apply case-insensitive regex to the concatenation of `title`, `keywords`, and `abstract` for each article-country row. An article is flagged (`regime_sensitive = 1`) if any pattern in the dictionary matches in any of these three fields. Because one article can appear in multiple country rows (multi-country articles), the flag is determined at the article level (based on title, keywords, and abstract, which do not vary by country), but the article is counted once per country it is attributed to.

**Stage 2 — Aggregation:** Collapse to country-year. The outcome is:

    share_regime_sensitive = sum(regime_sensitive) / n_articles_country_year

where `n_articles_country_year` is the pre-computed count of distinct `ut` per `iso3` x `year`. Restrict to country-years with n_articles_country_year >= 5 to avoid extreme proportions from near-zero denominators. Further restrict to 1990-2023 given sparse pre-1990 WOS coverage.

**Stage 3 — Regression:** Estimate a linear probability model (OLS with country and year fixed effects) of `share_regime_sensitive` on `v2x_libdem` and controls. Fixed effects absorb time-invariant country characteristics and global time trends; identification is from within-country over-time variation in regime status.

---

## Keyword dictionary

All patterns are applied case-insensitively (`ignore.case = TRUE`) via `grepl()` or `str_detect()`. The match is on the concatenated string `paste(title, keywords, abstract, sep = " | ")`, treating NA fields as empty strings.

| Cluster | Regex pattern | Justification |
|---|---|---|
| Democracy | democra | Matches democracy, democratic, democratization — core political concept targeted by authoritarian censorship |
| Human rights | human rights | Direct term; the framing most associated with political accountability |
| Civil rights/liberties | civil rights OR civil liberties | Close conceptual relatives of human rights; commonly avoided in autocratic contexts |
| Corruption | corrupt | Matches corruption, corrupt, corrupted — anti-corruption research poses direct threat to elites |
| Bribery/graft | bribery OR kleptocra | Narrower corruption-adjacent terms |
| Protest/contention | \bprotest OR demonstration OR \buprising OR \briot\b OR \brebellion OR civil unrest | Collective action against the state; high-risk topic in authoritarian settings |
| Repression | \brepression OR repressive OR state violence OR state terror | Directly implicates regime behavior |
| Censorship | \bcensor | Matches censorship, censored, censoring — self-referentially sensitive |
| Political prisoners | political prisoner OR prisoner of conscience | Highly sensitive in non-democratic contexts |
| Authoritarianism | authoritarian OR \bautocraci OR \bdictatorship | Labeling regime type as authoritarian is politically risky |
| Political freedom | political freedom OR freedom of expression OR freedom of press OR free press OR free speech | Classic liberal values contested in autocracies |
| Electoral fraud | election fraud OR electoral fraud OR vote rigging OR vote buying OR electoral manipulation | Directly challenges regime legitimacy |
| Dissent/opposition | \bdissent OR \bdissident OR political opposition OR regime critic | Sympathetic framing of anti-regime actors |

**Combined pattern (single regex for R implementation):**

```r
dict_pattern <- paste(
  "democra", "human rights", "civil rights", "civil liberties",
  "corrupt", "bribery", "kleptocra",
  "\\bprotest", "demonstration", "\\buprising", "\\briot\\b", "\\brebellion", "civil unrest",
  "\\brepression", "repressive", "state violence", "state terror",
  "\\bcensor", "political prisoner", "prisoner of conscience",
  "authoritarian", "\\bautocraci", "\\bdictatorship",
  "political freedom", "freedom of expression", "freedom of press", "free press", "free speech",
  "election fraud", "electoral fraud", "vote rigging", "vote buying", "electoral manipulation",
  "\\bdissent", "\\bdissident", "political opposition", "regime critic",
  sep = "|"
)
```

**Note for Team 20:** The article-level binary flag `regime_sensitive` (1/0) produced in Stage 1 is the variable Team 20 should use to stratify citation gap analyses. Apply the same `dict_pattern` to `paste(title, keywords, abstract, sep = " | ")` with `ignore.case = TRUE`.

---

## Model specification

**Primary model:**

    share_regime_sensitive_{c,t} = beta * v2x_libdem_{c,t} + gamma * log(e_gdppc_{c,t}) + delta * log(e_wb_pop_{c,t}) + alpha_c + tau_t + epsilon_{c,t}

- **Outcome:** `share_regime_sensitive` (proportion, 0-1; OLS)
- **Predictors:** `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- **Fixed effects:** Country FE + Year FE — implemented via `fixest::feols()` with `| iso3 + year`
- **SE clustering:** By country (`cluster = ~iso3`) to account for within-country serial correlation
- **Sample:** Country-years with n_articles_country_year >= 5, years 1990-2023, non-missing `v2x_libdem`

**Expected sign:** beta > 0 (higher democracy -> higher share of regime-sensitive articles). A negative beta would contradict the self-censorship theory.

**Secondary model (descriptive):**

    share_regime_sensitive_{c,t} = beta * v2x_libdem_{c,t} + gamma * log(e_gdppc_{c,t}) + delta * log(e_wb_pop_{c,t}) + tau_t + epsilon_{c,t}

- **Outcome:** `share_regime_sensitive` (proportion, 0-1; OLS)
- **Predictors:** `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- **Fixed effects:** Year FE only — implemented via `fixest::feols()` with `| year` (no country FE)
- **SE clustering:** By country (`cluster = ~iso3`)
- **Sample:** Same as primary model
- **Purpose:** Estimates the cross-sectional level association between regime type and the outcome. Complements the within-country TWFE estimate by showing the between-country pattern. Not causal; country-level confounders are not absorbed. Both specifications are reported in the same regression table.

**Reporting:** The primary (TWFE) and secondary (pooled OLS) specifications are reported side-by-side in `tab_main.txt`.

---

## Causal identification strategy

**Variation exploited:** Within-country over-time variation in `v2x_libdem`. Countries that democratize or autocratize over the 1990-2023 period provide the primary identifying variation. Country fixed effects absorb all time-invariant confounders (culture, language, geographic location, historical academic traditions). Year fixed effects absorb global trends in SSH topic prevalence (e.g., post-Cold War rise of democracy discourse globally).

**Threats to identification:**

1. **Time-varying confounders:** Economic development (`log(e_gdppc)`) is controlled, but other country-level changes correlated with both regime change and topic choice (e.g., WOS journal coverage expansion in specific countries) could confound estimates.
2. **WOS coverage bias:** WOS may expand coverage of a country's journals for reasons unrelated to regime type, changing which topics appear in the corpus. This could generate spurious correlations if newly indexed journals have systematically different topic profiles.
3. **Reverse causality:** Unlikely at the country-year level — aggregate publication patterns do not plausibly shift regime type.
4. **Anticipatory effects:** Researchers may change behavior before regime change formally registers, slightly misattributing causal timing.
5. **Field composition shifts:** If the share of political science vs. economics output changes with regime type, this could mechanically change keyword share. Addressed by robustness check 3.

---

## Robustness checks

**Pre-specified robustness checks (RC1–RC2) required by Gate B:**

1. **RC1 — Title + keywords only:** Re-estimate Stage 1 restricting the match to `paste(title, keywords, sep = " | ")` only, excluding the abstract field. This is the original pre-abstract specification; tests whether the abstract extension materially changes the result.
2. **RC2 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` (1 = democracy, 0 = autocracy) as the main independent variable. Tests whether the pattern holds for a dichotomous regime classification.

**Additional robustness checks:**

3. **Regime type categories:** Replace `v2x_libdem` with factor indicators for `v2x_regime` (0 = closed autocracy, 1 = electoral autocracy, 2 = electoral democracy, 3 = liberal democracy) to assess monotonicity across regime categories.
4. **Political science / sociology subsample:** Restrict to country-years in fields: Political Science, Sociology, Law, International Relations, Area Studies. Tests whether the effect is concentrated in fields where the dictionary terms are substantively relevant.
5. **Minimum denominator sensitivity:** Rerun with minimum n_articles_country_year thresholds of 10 and 20 (vs. baseline 5).

---

## Expected output files

All saved to `teams/team_04/analysis/figures/`.

| File | Description |
|---|---|
| `fig_main.png` | Binned scatter plot: mean share_regime_sensitive by v2x_libdem decile, with fitted OLS line, color-coded by v2x_regime category |
| `fig_coef.png` | Coefficient plot from primary model and all robustness specifications, with 95% confidence intervals |
| `fig_trends.png` | Time-series of mean share_regime_sensitive by regime category, 1990-2023 |
| `fig_robustness_regime_type.png` | Coefficient plot for v2x_regime category dummies (robustness check 2) |
| `tab_main.txt` | Regression table (primary model + robustness checks 1-2), produced by `modelsummary` |

`primary_results.json` saved to `teams/team_04/analysis/`.
