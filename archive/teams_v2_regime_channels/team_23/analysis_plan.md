# Team 23 — Analysis Plan

## Method

### Stage 1 — Construct the outcome variable

Replicate Team 04's keyword matching at the article level. Apply the combined `dict_pattern` (case-insensitive regex) to `paste(title, keywords, sep = " | ")` for each distinct article. Flag each article as `sensitive = 1` if any pattern matches, `sensitive = 0` otherwise. Aggregate to country-year:

```
share_sensitive_{c,t} = sum(sensitive) / n_articles_country_year
```

Restrict to country-years with `n_articles_country_year >= 5` and years 1990–2023.

### Stage 2 — Identify democratization events

Using `v2x_regime` (0 = closed autocracy, 1 = electoral autocracy, 2 = electoral democracy, 3 = liberal democracy):

1. For each country, sort by year and compute `lag_regime = lag(v2x_regime)`.
2. Flag a democratization event in year `t` if: `lag_regime %in% c(0, 1)` AND `v2x_regime %in% c(2, 3)` AND the country was autocratic for at least 2 consecutive years ending in t-1.
3. For countries with multiple events, retain only the first event.
4. Assign event-time `k = year - event_year` for `k in {-3, ..., +3}`.

### Stage 3 — Event-study regression

Primary specification (two-way FE with event-time dummies):

```r
feols(
  share_sensitive ~ i(rel_year, ref = -1) + log_gdppc + log_pop | iso3 + year,
  data = event_data,
  cluster = ~iso3
)
```

Reference period: k = -1 (omitted). Never-treated countries retained as comparison group.

**Core hypothesis:** Post-transition coefficients β_{+1}, β_{+2}, β_{+3} are jointly positive. Pre-transition coefficients β_{-3}, β_{-2} are jointly indistinguishable from zero (parallel trends test).

---

## Model specification

- **Outcome:** `share_sensitive` (proportion, 0–1; OLS)
- **Event-time dummies:** `D_k` for k in {-3, -2, 0, +1, +2, +3}; k = -1 is reference
- **Controls:** `log(e_gdppc)` + `log(e_wb_pop)`
- **Fixed effects:** Country FE + Year FE (`| iso3 + year`)
- **SE:** Clustered by country (`cluster = ~iso3`)
- **Sample:** Country-years with `n_articles >= 5`, years 1990–2023

---

## Identification strategy

**Variation exploited:** Timing of democratic transitions across countries. Country and year FEs absorb time-invariant heterogeneity and global trends.

**Parallel trends assumption:** Absent democratization, transitioning countries would have followed the same trajectory as non-transitioning countries, conditional on FEs.

**Staggered adoption:** Because events occur in different years, the TWFE estimator can produce biased estimates under heterogeneous treatment effects. The Callaway-Sant'Anna and Sun-Abraham estimators are required robustness checks.

**Identification threats:**
1. Anticipatory effects: researchers may shift before formal regime change.
2. WOS coverage expansion: democratic transitions may coincide with more indexing of domestic journals.
3. Post-Cold War clustering: large share of events cluster in 1989–1993.

---

## Robustness checks

1. **Alternative transition measure:** Replace `v2x_regime`-based flag with `lied_binary` transitions.
2. **Minimum data requirement:** Restrict to country-event pairs with ≥ 5 pre-transition and ≥ 3 post-transition years.
3. **Heterogeneity-robust estimators:** Callaway-Sant'Anna and Sun-Abraham estimators.
4. **Excluding the 1989–1993 wave:** Drop country-events with transition year in 1989–1993.

---

## Expected output files

| File | Description |
|---|---|
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | β_{+1}, SE, p-value, N |
| `analysis/figures/fig_event_study.png` | Event-study plot with 95% CIs; pre-trends visible |
| `analysis/figures/fig_event_study_robust.png` | TWFE vs. Sun-Abraham overlay |
| `analysis/figures/fig_raw_trends.png` | Raw means by event time |
| `analysis/tables/tab_main.txt` | Regression table: primary TWFE + lied_binary robustness |
