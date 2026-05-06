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
