# Team 04: Analysis Plan

## Method

OLS regression with two-way fixed effects (country + year). The outcome is a country-year-level measure of regime-sensitive topic prevalence constructed from keyword matching against a predefined dictionary. No external APIs or LLMs are used — the measurement relies on string matching against `keywords` and `keywords_plus`.

## Model specification

**Data construction:**

1. Define a regime-sensitive keyword dictionary. Terms (matched case-insensitively, as whole words or word stems):
   - **Political accountability:** democracy, democratization, democratic transition, election fraud, electoral integrity, political opposition, dissent, authoritarian, autocracy
   - **Rights and freedoms:** human rights, civil liberties, press freedom, freedom of expression, censorship, civil society
   - **State critique:** corruption, governance failure, repression, political violence, state violence, police brutality
   - **Contention:** protest, social movement, revolution, uprising, regime change, political mobilization
2. For each article-country row, code `sensitive_topic = 1` if any term from the dictionary appears in `keywords` or `keywords_plus`, 0 otherwise. Code `sensitive_topic = NA` if both keyword fields are missing.
3. Collapse to country-year level: compute `share_sensitive_topic` = mean of `sensitive_topic` (excluding NAs) per country-year. Retain `n_articles_country_year`, mean `v2x_libdem`, and modal `subject_primary`.
4. Restrict to country-years with at least 20 SSH articles with non-missing keywords.
5. Restrict to 1990-2019 (pre-1990 WOS coverage is thin and keyword fields are sparser).

**Main specification (Model 1):**

`share_sensitive_topic ~ v2x_libdem + log(n_articles_country_year) + country_FE + year_FE`

- Outcome: `share_sensitive_topic` (proportion, 0-1)
- Key predictor: `v2x_libdem` (continuous, 0-1)
- Fixed effects: country, year
- Standard errors: clustered by country
- Control: `log(n_articles_country_year)` to account for the possibility that keyword composition shifts with total output volume

**Robustness specifications:**

- Model 2: Replace `v2x_libdem` with `regime_binary` (required robustness check)
- Model 3: Replace `v2x_libdem` with `v2x_regime` as a factor (4-category) to inspect non-linearity across regime types
- Model 4: Add `subject_primary` fixed effects (field FE) at the article-country level, estimated as a linear probability model on `sensitive_topic` rather than aggregated shares — tests whether the effect holds within disciplines, not just across them
- Model 5: Restrict to countries that experienced a regime transition (change in `v2x_regime` category) during 1990-2019 (within-transitioner sample)

## Causal identification strategy

**Variation exploited:** Within-country changes in liberal democracy over time. Country fixed effects absorb all time-invariant country characteristics (language, academic traditions, historical disciplinary structure, WOS indexing patterns). Year fixed effects absorb global trends in keyword usage (e.g., the post-2010 rise of "corruption" research worldwide). The identifying variation comes from countries whose regime type changes — democratization or autocratization episodes — and whether those political changes coincide with shifts in the prevalence of regime-sensitive research topics.

**Confounders controlled:**

- Country fixed effects: persistent differences in academic culture, language barriers, WOS coverage, disciplinary traditions
- Year fixed effects: global trends in topic popularity, keyword norms, WOS coverage expansion
- Log total articles: scale effects on keyword composition
- Field fixed effects (Model 4): holds discipline constant, isolating within-field topic selection

**Identification threats:**

- **Keyword measurement error:** The dictionary is English-language and may miss regime-sensitive research published with non-English keywords. This would attenuate the estimated effect (bias toward zero) if autocracies systematically publish more in non-English-keyword journals. Acknowledged as a conservative bias.
- **WOS selection bias:** WOS disproportionately indexes international, English-language journals. Regime-sensitive research in autocracies may appear in domestic outlets not indexed by WOS. This would inflate the estimated effect. Acknowledged as a key limitation.
- **Reverse causality:** A thriving human rights research community could contribute to democratization, rather than democracy enabling such research. Partially addressed by checking results with lagged `v2x_libdem` (t-1 and t-2).
- **Omitted time-varying confounders:** Economic development, internationalization, and university expansion could jointly affect both democracy and topic selection. GDP is not available in the corpus; acknowledged as a limitation.
- **Dictionary sensitivity:** Results could depend on the specific keywords chosen. Addressed by reporting results with (a) a narrower "core" dictionary (democracy, human rights, corruption, protest only) and (b) the full dictionary.

## Expected output files

| File | Description |
|------|-------------|
| `figures/fig1_share_by_regime.png` | Descriptive: mean share of regime-sensitive topics by `v2x_regime` category (bar chart with CIs) |
| `figures/fig2_timeseries.png` | Time series of mean `share_sensitive_topic` for autocracies vs. democracies, 1990-2019 |
| `figures/tab1_main_results.png` | Regression table: Models 1-3 (main + binary + 4-category) |
| `figures/tab2_robustness.png` | Regression table: Models 4-5 (within-field + transitioner sample) |
