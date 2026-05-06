# Team 07 — Analysis Plan

## Method

### Step 1: Identify funding text column

Inspect corpus for columns matching `fund`, `grant`, `ack`, `agency` (case-insensitive). Priority order:
1. `funding_text`
2. `grant_agencies`
3. `acknowledgment` / `acknowledgement`
4. Fallback: `abstract` — search for funding acknowledgment phrases

Document which column is used in a note at the top of `analysis.R`.

### Step 2: International funding agency dictionary

Apply regex case-insensitively. An article is coded 1 if at least one pattern matches.

| Agency group | Key patterns |
|---|---|
| US National Science Foundation | `national science foundation`, `\bNSF\b` |
| European Research Council / Horizon | `european research council`, `\bERC\b`, `horizon 20[0-9][0-9]`, `marie curie`, `horizon europe` |
| European Commission | `european commission` |
| World Bank | `world bank` |
| IMF | `\bIMF\b`, `international monetary fund` |
| USAID | `\bUSAID\b` |
| Ford Foundation | `ford foundation` |
| Gates Foundation | `gates foundation`, `bill.*melinda gates` |
| Wellcome Trust | `wellcome trust` |
| Open Society | `open society`, `soros foundation` |
| UKRI / ESRC / AHRC | `\bUKRI\b`, `\bESRC\b`, `\bAHRC\b` |
| German DFG | `deutsche forschungsgemeinschaft`, `\bDFG\b` |
| Swiss SNSF | `swiss national science foundation`, `\bSNSF\b` |
| Swedish Research Council | `vetenskapsr[ao]det`, `swedish research council` |
| Norwegian Research Council | `norges forskningsr.d`, `research council of norway` |
| NordForsk | `nordforsk` |
| NWO (Netherlands) | `\bNWO\b` |
| ANR (France) | `agence nationale de la recherche`, `\bANR\b` |
| NIH | `national institutes of health`, `\bNIH\b` |
| UN agencies | `\bUNDP\b`, `\bUNESCO\b`, `\bUNICEF\b`, `united nations` |
| Regional dev. banks | `asian development bank`, `african development bank`, `inter.american development bank` |

```r
intl_fund_regex <- paste(
  "national science foundation", "\\bNSF\\b",
  "european research council", "\\bERC\\b",
  "european commission", "horizon 20[0-9][0-9]", "marie curie", "horizon europe",
  "world bank", "\\bIMF\\b", "international monetary fund",
  "\\bUSAID\\b", "ford foundation",
  "gates foundation", "bill.*melinda gates", "wellcome trust",
  "open society", "soros foundation",
  "\\bUKRI\\b", "\\bESRC\\b", "\\bAHRC\\b",
  "deutsche forschungsgemeinschaft", "\\bDFG\\b",
  "swiss national science foundation", "\\bSNSF\\b",
  "vetenskapsr[ao]det", "swedish research council",
  "norges forskningsr.d", "research council of norway",
  "nordforsk", "\\bNWO\\b",
  "agence nationale de la recherche", "\\bANR\\b",
  "national institutes of health", "\\bNIH\\b",
  "\\bUNDP\\b", "\\bUNESCO\\b", "\\bUNICEF\\b", "united nations",
  "asian development bank", "african development bank",
  "inter.american development bank",
  sep = "|"
)
```

### Step 3: Construct article-level indicator and aggregate to country-year

```r
corpus <- corpus |>
  mutate(
    target_text = coalesce(funding_text, abstract),  # adjust from Step 1
    intl_funded = as.integer(str_detect(tolower(target_text), intl_fund_regex))
  )

cy <- corpus |>
  group_by(iso3, year) |>
  summarise(
    share_intl_funded = mean(intl_funded, na.rm = TRUE),
    n_articles        = n_distinct(wos_id),
    .groups           = "drop"
  ) |>
  filter(n_articles >= 5)
```

---

## Model specification

### Primary specification (pre-registered)

Two-way fixed effects — country FE + year FE, SE clustered by `iso3`.

```r
feols(
  share_intl_funded ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = cy,
  cluster = ~iso3
)
```

- Fixed effects: country (`iso3`) + year
- Standard errors: clustered by country
- Controls: `log(e_gdppc)`, `log(e_wb_pop)`
- Outcome: `share_intl_funded` (proportion, 0–1)

### Secondary specification (descriptive)

Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate. Both specifications should be reported in the same regression table.

```r
feols(
  share_intl_funded ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data    = cy,
  cluster = ~iso3
)
```

- Fixed effects: year only (no country FE)
- Standard errors: clustered by country
- Controls: `log(e_gdppc)`, `log(e_wb_pop)`
- Outcome: `share_intl_funded` (proportion, 0–1)

---

## Causal identification strategy

Within-country variation in `v2x_libdem` over time. Country FE absorbs time-invariant characteristics; year FE absorbs global trends in international collaboration. Key limitations:
- Reverse causality: international funding may strengthen democracy.
- WOS coverage of funding acknowledgments is inconsistent across journals and years.
- Corpus selection: WOS over-represents internationally integrated countries.

---

## Robustness checks

- **RC1 — Alternative regime measure:** Replace `v2x_libdem` with `lied_binary` as the main independent variable.
- **RC2 — Restrict to grant_agencies field only:** Re-estimate excluding the abstract fallback, using only articles where the `grant_agencies` field is non-missing. This tests whether results are driven by the fallback matching strategy rather than dedicated funding metadata.
- One-year lag of `v2x_libdem`
- Restrict to `n_articles >= 20`
- Fractional logit functional-form check
- Interact `v2x_libdem` with politically sensitive `subject_primary` indicator

---

## Expected output files

| File | Contents |
|---|---|
| `analysis/analysis.R` | Full analysis script |
| `analysis/primary_results.json` | Coefficient, SE, p-value, N |
| `analysis/figures/fig1_scatter.pdf` | Binned scatter: v2x_libdem vs. share_intl_funded (residualized) |
| `analysis/figures/fig2_coef_plot.pdf` | Coefficient plot across specifications |
| `analysis/figures/fig3_descriptives.pdf` | Time trends by regime type |
| `analysis/tables/tab1_main.tex` | Regression table |
