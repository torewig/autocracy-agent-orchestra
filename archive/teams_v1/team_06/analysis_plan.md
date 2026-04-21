# Team 06 — Analysis Plan

## Method

Text embedding + OLS regression with two-way fixed effects. The outcome is constructed by embedding article abstracts using an API (OpenAI `text-embedding-3-small`) and computing within-cluster semantic diversity at the country-field-year level. The main analysis is a regression of this diversity measure on `v2x_libdem`.

## Data construction

### Step 1: Embedding abstracts

- Use the OpenAI Embeddings API (`text-embedding-3-small`, 1536 dimensions) to embed all abstracts with non-NA text.
- Estimated cost: ~2.5M abstracts x ~200 tokens each = ~500M tokens. At $0.02/1M tokens ≈ $10. This is cheap but involves ~2.5M API calls. **Will batch using the OpenAI batch API or process in chunks of ~1,000.** Will confirm with PI before running at full scale.
- Alternatively, if the PI prefers to limit API usage: embed a stratified random sample (e.g., 200,000 abstracts stratified by country-regime-field-decade) and restrict analysis to the sample.

### Step 2: Computing semantic diversity

- Group articles by country x `subject_primary` x year.
- For each cell with >= 10 articles: compute the centroid embedding, then calculate the mean cosine distance from each article's embedding to the centroid. This is `semantic_diversity_{c,f,t}`.
- This avoids O(n^2) pairwise computation. Mean distance-to-centroid captures dispersion of the embedding cloud.
- Also compute a secondary measure: standard deviation of pairwise cosine similarities within each cell (on a random subsample of pairs if n > 50 to keep computation tractable).

### Step 3: Restrict sample

- Restrict to 1990-2023 (WOS coverage concern pre-1990).
- Restrict to country-field-year cells with >= 10 articles (avoid noise).
- Drop cells where all abstracts are NA.

## Model specification

### Main specification

```
semantic_diversity_{c,f,t} = beta * v2x_libdem_{c,t} + alpha_c + delta_f + gamma_t + X_{c,f,t} * phi + epsilon_{c,f,t}
```

- **Outcome:** `semantic_diversity` (mean cosine distance to centroid, continuous, ~0-1)
- **Key predictor:** `v2x_libdem` (continuous, 0-1)
- **Fixed effects:** Country (`alpha_c`) + field (`delta_f`) + year (`gamma_t`). Alternatively, country-field FE (`alpha_{c,f}`) + year FE if sufficient within-cell variation.
- **Controls (`X`):**
  - `log(n_articles)` — cell size (more articles mechanically affect diversity estimates)
  - `mean_n_authors` — average team size in the cell (collaboration patterns may affect diversity)
- **Standard errors:** Clustered at the country level
- **Expected sign of beta:** Positive (more democracy → greater semantic diversity)

### Robustness specifications

1. Replace `v2x_libdem` with `regime_binary` (binary autocracy/democracy)
2. Use country-field fixed effects instead of separate country + field FE (absorbs field-specific traditions per country)
3. Restrict to the five largest SSH fields (Economics, Education, Psychology-Clinical, Business, Political Science) to check if the effect holds within specific disciplines
4. Use an alternative diversity measure: standard deviation of pairwise cosine similarities
5. Restrict sample to transition countries only (countries that change regime type during the period) to exploit within-country regime-change variation more tightly

## Causal identification strategy

### Variation exploited

Within-country (or within-country-field) over-time variation in `v2x_libdem`. Country FE absorb time-invariant confounders (language, academic traditions, historical university structure). Year FE absorb global trends (WOS expansion, worldwide shifts in research methods, field-level norms). The cell-size control addresses the mechanical relationship between number of articles and measured diversity.

### Confounders controlled

- **Country FE:** national academic culture, language, institutional structure, historical field composition
- **Field FE (or country-field FE):** discipline-specific norms for intellectual diversity, field size
- **Year FE:** global trends in SSH publishing, WOS coverage changes, methodological convergence/divergence
- **Cell size:** mechanical effect of n on diversity estimation

### Identification threats

1. **Economic development:** GDP growth drives both democratization and university expansion. Larger, better-funded university systems may produce more diverse research regardless of regime type. GDP is not in the dataset, but the cell-size control partially addresses this (more articles from richer countries).
2. **Internationalization:** Democracies may have more internationally connected scholars whose diverse training feeds into heterogeneous research. This is a potential mediator (international openness as a channel through which democracy increases diversity) rather than a pure confounder, but it complicates the interpretation.
3. **Language and journal indexing:** If WOS indexes a narrower slice of autocracies' research (e.g., only English-language output), the observed abstracts may be from a more homogeneous, internationally oriented subset. This would bias toward finding *less* diversity in autocracies for the wrong reason. The transition-country robustness check helps — within-country changes in regime with stable indexing patterns provide cleaner variation.
4. **Embedding artifacts:** Semantic similarity may capture stylistic/linguistic features (e.g., formal vs. informal English) rather than substantive intellectual content. Using a high-dimensional embedding model and focusing on cosine distance (which is relatively robust to style) mitigates this, but the concern remains.
5. **Field heterogeneity:** Different fields may have different baseline levels of intellectual diversity (e.g., philosophy vs. economics). Field FE or country-field FE address this.

## Expected output files

| File | Description |
|------|-------------|
| `figures/fig1_diversity_by_regime.png` | Descriptive: distribution of semantic diversity by `v2x_regime` category (boxplot or violin plot) |
| `figures/fig2_diversity_trends.png` | Time trends: mean semantic diversity over time, separately for autocracies and democracies (using `regime_binary`) |
| `figures/tab1_main_regression.png` | Regression table: main specification + key robustness checks (rendered via `modelsummary`) |
| `figures/fig3_field_heterogeneity.png` | Coefficient plot: effect of `v2x_libdem` estimated separately for each of the top 5 SSH fields |
