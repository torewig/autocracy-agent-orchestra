# Pre-registration: team_07

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 07 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish SSH articles that acknowledge international funding agencies at lower rates, compared to researchers from more democratic countries?

## Rationale

Receiving funding from international agencies — such as the US National Science Foundation, the European Research Council, the World Bank, the Ford Foundation, or bilateral aid bodies — involves agreeing to donor norms, submitting to external review, and producing work that is visible to international audiences. Autocratic regimes may view this cross-border funding relationship as threatening, and researchers aware of this may self-select out of such arrangements or be blocked from accessing them. If this mechanism operates at scale, the share of a country-year's SSH output that acknowledges international funding should be systematically lower in more autocratic settings.

## Theoretical mechanism

Autocratic rulers are threatened by research networks that originate outside their control: international funding creates accountability relationships to foreign institutions, imposes liberal norms around academic freedom and open publication, and can facilitate the production of research on politically sensitive topics (governance quality, human rights, protest) that might not otherwise be funded domestically. Researchers in autocracies therefore face two compounding pressures: (1) they anticipate that seeking or accepting international funding will attract state scrutiny and career risk, and (2) autocratic governments may directly restrict foreign-funded research through registration requirements, permit denials, or the stigmatization of foreign-funded NGOs and universities. Both mechanisms produce the same observable pattern: the share of articles acknowledging international funding should be monotonically lower in more autocratic country-years. The expected direction of the main coefficient is positive: higher `v2x_libdem` is associated with a higher share of internationally funded articles.

## Hypothesis

H1: Countries with lower Liberal democracy levels will have a lower share of SSH articles acknowledging international funding agencies, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles that acknowledge at least one international funding agency, conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis

Country-year (one observation per iso3 x year, restricted to country-years with at least five SSH articles).

## Outcome variable

`share_intl_funded`: constructed as follows.

1. For each article, search for matches of an international-funding-agency regex dictionary in the `funding_text` or `grant_agencies` field if available; otherwise fall back to searching the `abstract` field.
2. An article is coded 1 if at least one match is found, 0 otherwise.
3. Aggregate to country-year: `share_intl_funded = (# articles coded 1) / n_articles_country_year`.

The outcome is a proportion bounded in [0, 1]. The international funding agency dictionary is defined in `analysis_plan.md`.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. Teams 01–06 cover the following angles: PCI score on abstract vocabulary (01), Shannon entropy of author keywords (02), disciplinary composition using WOS subject categories (03), regime-sensitive keyword prevalence in titles/keywords (04), LLM classification of critical domestic framing in abstracts (05), semantic diversity via text embeddings (06).

Team 07 is distinct on two dimensions. First, the outcome is based on funding acknowledgment metadata rather than any aspect of article content (title, keywords, abstract, or discipline): it captures researchers' international institutional linkages, not their topic choices or word choices. Second, the theoretical mechanism is different — it concerns cross-border institutional exposure and the threat that foreign oversight poses to autocratic control, rather than direct topic or vocabulary self-censorship. No other team uses funding acknowledgment as an outcome.


---

## Analysis Plan

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
