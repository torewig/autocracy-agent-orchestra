# Pre-registration: team_06

**Timestamp:** 2026-05-06 13:09:56
**Project:** AutoKnow ERC -- Autocracy and science
**PI:** Tore Wig, University of Oslo

> This document was committed to version control before any analysis was run.
> The Git commit hash and timestamp serve as the pre-registration record.
> The contents of this file must not be modified after the initial commit.

---

## Research Question

# Team 06 — Research Question

## Research question
Does autocracy reduce the semantic diversity of social science and humanities abstracts within country-field-year clusters, as measured by mean pairwise cosine distance of text embeddings?

## Rationale
If researchers in autocracies self-censor by converging on politically safe topics and framings, the full semantic space of their published output — not just the presence or absence of specific keywords — should narrow. Dense text embeddings capture meaning holistically, including subtle shifts in framing, emphasis, and topic selection that keyword counts miss. A systematic reduction in pairwise semantic distance within a country's publications in a given field and year is therefore a more sensitive and comprehensive indicator of intellectual convergence than any dictionary-based measure.

## Theoretical mechanism
Under autocracy, researchers face career costs — dismissal, loss of funding, reputational damage, or physical risk — for publishing work that touches on politically sensitive topics such as regime legitimacy, state repression, civil liberties, or opposition politics. To minimize these risks, researchers rationally self-censor: they shift toward topics that are empirically safe, methodologically conventional, and ideologically neutral. At the aggregate level, this behavioral convergence means that papers from a given field and country in a given year become more semantically similar to one another — they cluster in a narrower region of the semantic space. The expected direction is negative: higher liberal democracy scores (v2x_libdem) are associated with greater semantic diversity (higher mean pairwise cosine distance) within country-field-year clusters.

## Theory family
topic-avoidance

## Estimand
The average treatment effect of a unit increase in liberal democracy (v2x_libdem) on the mean pairwise cosine distance of abstract embeddings within country-field-year cells, aggregated to the country-year level, conditional on country fixed effects, year fixed effects, log GDP per capita (`log(e_gdppc)`), and log population (`log(e_wb_pop)`).

## Unit of analysis
Country-year (aggregated from country × subject_primary × year cells; each cell requires ≥ 5 articles with non-missing abstracts).

## Outcome variable
`mean_semantic_diversity`: the mean pairwise cosine distance of text-embedding vectors across all article pairs within a country × subject_primary × year cell, averaged across cells within a country-year (weighted by cell size). Higher values indicate greater semantic spread; lower values indicate convergence.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit lower mean pairwise semantic diversity of SSH abstracts within country-field-year clusters, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Key independent variable
`v2x_libdem`

## Embedding specification
- Model: OpenAI `text-embedding-3-small` (1536-dimensional output)
- Input: `abstract` field, truncated at 512 tokens if needed (most SSH abstracts are 100–250 tokens)
- Estimated cost: ~$0.00002 per 1,000 tokens; at ~150 tokens/abstract and ~100,000 unique abstracts ≈ $0.30 for full corpus
- Pairwise distances: cosine distance = 1 − cosine_similarity, computed within each country × subject_primary × year cell
- Minimum cell size: 5 articles with non-missing embeddings

## Sampling strategy
Embed the full corpus of unique abstracts (deduplicated on wos_id before embedding to avoid redundant API calls). Given the estimated cost of ~$0.30 for the full unique-abstract set, there is no cost justification for sampling. Embeddings will be stored as a named matrix (rows = wos_id) in an RDS file and reused for all downstream distance computations.

## Uniqueness check
Performed. Most similar existing team: Team 02.
Distinction: Team 02 measures topical diversity via the breadth of discrete author-supplied keyword types, while Team 06 measures semantic diversity via the geometric spread of dense continuous embeddings of full abstract text — capturing convergence in meaning, framing, and emphasis across the entire abstract rather than the presence or absence of specific keywords.


---

## Analysis Plan

# Team 06 — Analysis Plan

## Method
Full pipeline in four stages:

1. **Embedding**: Deduplicate corpus on `wos_id`, filter to rows with non-missing `abstract`, call OpenAI `text-embedding-3-small` API in batches, store result as a named matrix (wos_id × 1536 dimensions) saved as an RDS file.
2. **Distance computation**: For each country × `subject_primary` × year cell with ≥ 5 articles, compute all pairwise cosine distances among the embedding vectors in that cell. The cell-level semantic diversity score is the mean of these pairwise distances.
3. **Aggregation**: For each country-year, compute a weighted mean of cell-level semantic diversity scores, weighting by cell size (number of articles in the cell). This produces one observation per country-year: `mean_semantic_diversity`.
4. **Regression**: Regress `mean_semantic_diversity` on `v2x_libdem` plus controls and fixed effects (see model specification below). The primary estimand is the within-country effect of democratic variation on semantic diversity over time.

## Embedding pipeline
- Model: `text-embedding-3-small` (OpenAI)
- Input: `abstract` text field; truncate at 512 tokens using `tiktoken` (or equivalent) if needed
- Deduplication: embed each unique `wos_id` once; join embeddings back to corpus rows via `wos_id`
- Storage: save embeddings as `teams/team_06/analysis/embeddings_matrix.rds` — a named numeric matrix (rows = wos_id, columns = embedding dimensions)
- Batching: submit 100–500 abstracts per API request to stay within rate limits
- Estimated cost: ~$0.30 for ~100,000 unique abstracts at ~150 tokens/abstract and $0.00002/1K tokens

## Distance computation
- Unit: country × `subject_primary` × year cell
- Minimum cell size: 5 articles with non-missing embeddings (cells below this threshold are dropped before aggregation)
- Large cell handling: if a cell contains more than 500 articles, draw a random subsample of 500 with `set.seed(42)` before computing pairwise distances. Record the threshold (N > 500) and the number of affected cells as comments in `analysis/analysis.R`.
- Pairwise cosine distance: `dist_ij = 1 − (e_i · e_j) / (||e_i|| ||e_j||)` for all pairs (i, j) in a cell
- Cell-level score: mean of all pairwise distances within the cell
- Country-year aggregation: weighted mean of cell scores, weighted by cell size (n articles in cell)
- Output column: `mean_semantic_diversity` (country-year level)

## Model specification
- Outcome: `mean_semantic_diversity` (mean pairwise cosine distance, country-year)
- Predictors: `v2x_libdem` + `log(e_gdppc)` + `log(e_wb_pop)`
- SE clustering: by country (two-way country × year clustering as robustness)
- Estimator: `feols` from the `fixest` package
- Both specifications below are reported in the same regression table.

**Primary specification (pre-registered):** Two-way fixed effects — country FE + year FE, SE clustered by `iso3`. Identifies the within-country effect of democratic variation on semantic diversity over time.

```r
feols(mean_semantic_diversity ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
        iso3 + year,
      data = cy_panel,
      cluster = ~iso3)
```

**Secondary specification (descriptive):** Pooled OLS — year FE only (no country FE), SE clustered by `iso3`. Estimates the cross-sectional level association between regime type and the outcome, complementing the within-country TWFE estimate.

```r
feols(mean_semantic_diversity ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
        year,
      data = cy_panel,
      cluster = ~iso3)
```

## Causal identification strategy
Variation exploited: within-country over-time variation in liberal democracy scores, net of country fixed effects (absorbing all time-invariant country characteristics) and year fixed effects (absorbing global trends in embedding-model-induced semantic patterns or WOS coverage changes).

Key threats and mitigations:
- **Coverage expansion bias**: WOS indexes more journals over time, and more articles per country-year mechanically increases cell size and potentially measured diversity. Mitigated by (a) the minimum cell-size filter (≥ 5), (b) weighting by cell size in aggregation, and (c) including `log(n_articles_country_year)` as a control in robustness specifications.
- **Embedding model artifacts**: The embedding model may encode linguistic or stylistic features unrelated to topic selection (e.g., English proficiency, discipline-specific jargon). Mitigated by within-field comparisons (cell-level distances always compare papers in the same `subject_primary` field in the same year).
- **Reverse causality**: Unlikely at the country-year level — the semantic diversity of publications does not plausibly cause changes in national democracy scores.
- **Field composition shifts**: If autocratic countries shift toward fields that are inherently more homogeneous, the weighted mean will reflect compositional change rather than within-field convergence. Examined in robustness by restricting to a balanced sample of country-field pairs observed across the full panel.

## Robustness checks
RC1 — Country-field-year level: Re-estimate the primary model at the country × `subject_primary` × year level (without aggregating to country-year), including `subject_primary × year` fixed effects in addition to country FE. This tests whether the result holds within field-year cells and is not driven by field composition shifts across countries or over time.

```r
feols(cell_semantic_diversity ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) |
        iso3 + subject_primary^year,
      data = cfy_panel,
      cluster = ~iso3)
```

2. Replace `v2x_libdem` with `lied_binary` (binary democracy indicator, primary pre-registered robustness)
3. Restrict to cells with ≥ 10 articles (stricter minimum cell size)
4. Add `log(n_articles_country_year)` as a covariate to control for output volume effects on measured diversity
5. Two-way clustered SE (country × year) instead of country-only clustering
6. Restrict sample to 1990–2023 (pre-1990 WOS coverage is sparse)
7. Restrict to political science, sociology, law, and IR fields only (fields where self-censorship pressure is theoretically highest)

## Expected output files
- `teams/team_06/analysis/embeddings_matrix.rds` — named matrix of abstract embeddings (intermediate; wos_id × 1536)
- `teams/team_06/analysis/cell_diversity.rds` — cell-level (country × field × year) semantic diversity scores
- `teams/team_06/analysis/cy_panel.rds` — country-year panel dataset with `mean_semantic_diversity` and all covariates
- `teams/team_06/analysis/figures/fig1_libdem_vs_diversity.pdf` — binned scatter plot of `v2x_libdem` against `mean_semantic_diversity` (residualized on country and year FE)
- `teams/team_06/analysis/figures/fig2_regime_type_distribution.pdf` — distribution of `mean_semantic_diversity` by `v2x_regime` category (boxplot or violin)
- `teams/team_06/analysis/figures/fig3_coefplot.pdf` — coefficient plot for main model and robustness specifications
- `teams/team_06/analysis/primary_results.json` — machine-readable results with fields: team, hypothesis_label, theory_family, predictor, outcome, coefficient, SE, p_value, n_obs

## API cost disclosure
- API: OpenAI `text-embedding-3-small`
- Rate: $0.00002 per 1,000 tokens
- Estimated cost: ~$0.30 for ~100,000 unique abstracts at ~150 tokens/abstract
- Sample strategy: full corpus (no sampling); cost is low enough that sampling is not necessary
- Actual cost incurred will be logged as a comment in `analysis/analysis.R` after execution
