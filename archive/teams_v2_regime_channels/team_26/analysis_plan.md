# Team 26 — Analysis Plan

## Method

### Variable construction — `autocracy_duration`

Within each country (`iso3`), sorted by `year`:

1. Flag each year as autocratic if `v2x_regime <= 1`.
2. Identify contiguous autocratic spells (a spell breaks whenever `v2x_regime > 1`).
3. Within each spell, assign `autocracy_duration` = current year minus the first year of the spell (so the first year of a spell gets duration = 0, the second year = 1, etc.).
4. For democratic years (`v2x_regime > 1`), set `autocracy_duration = 0`.

The resulting variable is non-negative, integer-valued, and resets at every democratic interruption.

### Outcome construction — `share_sensitive`

Replicate Team 04's keyword flag at the article level (`sensitive_flag`, binary). Aggregate to country-year: `share_sensitive = mean(sensitive_flag)` within `iso3 x year`. Drop country-years with fewer than 10 articles.

---

## Model specification

**Primary model (additive):**

```r
feols(
  share_sensitive ~ autocracy_duration + v2x_libdem +
                    log_gdppc + log_pop | iso3 + year,
  data = cy_panel,
  cluster = ~iso3
)
```

Primary estimand: coefficient on `autocracy_duration` — the within-country association between one additional year of uninterrupted autocratic rule and `share_sensitive`, conditional on contemporaneous democracy score, economic controls, and country + year FE.

**Secondary model (interaction):**

```r
feols(
  share_sensitive ~ autocracy_duration * v2x_libdem +
                    log_gdppc + log_pop | iso3 + year,
  data = cy_panel,
  cluster = ~iso3
)
```

Secondary estimand: whether the autocracy–sensitivity gradient in `v2x_libdem` is modulated by how long the country has been autocratic.

---

## Identification strategy

Country FE absorb all time-invariant country-level heterogeneity. Year FE absorb global trends. Residual identifying variation comes from within-country changes in duration as autocratic spells accumulate and reset.

**Main threat:** `autocracy_duration` increases mechanically by one unit per year within an ongoing spell, creating correlation with country-specific linear time trends. A country-specific linear trend robustness check provides the most conservative test.

---

## Robustness checks

1. **Alternative IV:** Replace `v2x_libdem` with `lied_binary`.
2. **Log transformation:** Use `log(autocracy_duration + 1)` to reduce leverage of very long spells.
3. **Autocratic observations only:** Restrict to country-years where `v2x_regime <= 1`.
4. **Country-specific linear trend:** Add country × year linear trend to the FE structure.
5. **Minimum article threshold sensitivity:** Re-run at thresholds of 5 and 25 articles per country-year.

---

## Expected output files

| File | Contents |
|---|---|
| `analysis/analysis.R` | Full R script |
| `analysis/primary_results.json` | Coefficient, SE, p-value, N |
| `analysis/figures/fig_duration_effect.pdf` | Marginal effect of `autocracy_duration` at varying `v2x_libdem` quantiles |
| `analysis/figures/fig_spell_distribution.pdf` | Histogram of `autocracy_duration` values in estimation sample |
| `analysis/tables/table_main.tex` | Regression table: additive + interaction models |
| `analysis/tables/table_robustness.tex` | Robustness checks table |
