---
title: "Team 06 — Research Design"
subtitle: "AutoKnow Agent Orchestra"
date: "2026-03-19"
geometry: margin=2.5cm
fontsize: 11pt
mainfont: "Calibri"
---
# Team 06 — Research Question

---

## Research question

Does autocracy reduce the intellectual diversity of SSH research, as measured by
the semantic similarity of article abstracts within country-field-year clusters?

## Rationale

The overarching question asks not only what topics are studied but what
*direction* research takes and how knowledge *progresses*. A key dimension of
scientific progress is intellectual diversity — the breadth of questions,
frameworks, and arguments that scholars explore within a field. If autocracy
constrains this diversity, it represents a qualitatively different form of impact
than simply suppressing volume or shifting disciplinary composition. Semantic
similarity of abstracts within country-field-year clusters provides a direct,
content-based measure of whether the ideas being explored are more uniform under
autocratic conditions.

## Theoretical mechanism

Autocratic regimes constrain the intellectual diversity of SSH through three
reinforcing channels. First, state censorship and editorial control narrow the
range of acceptable arguments, questions, and conclusions — scholars cannot
publish findings that contradict official narratives or threaten regime
legitimacy. Second, anticipatory self-censorship leads scholars to cluster
around "safe" framings and avoid intellectually risky or heterodox positions,
even when direct repression is absent. Third, centralized research funding and
agenda-setting (e.g., state-directed grant priorities, ideological guidelines
for universities) channel scholars toward a narrower set of approved research
questions within each field. Together, these mechanisms predict that abstracts
from autocracies will be more semantically homogeneous — more similar to one
another in content, framing, and argumentation — than abstracts from
democracies in the same field and year.

## Theory family

`intellectual-conformity`

## Estimand

The within-country, over-time effect of a one-unit increase in liberal
democracy (`v2x_libdem`) on the mean semantic diversity of SSH abstracts within
country-field-year clusters. This is a partial identification estimate: country
and year fixed effects remove stable country-level characteristics and global
trends, but cannot rule out all time-varying confounders.

## Unit of analysis

Country-field-year (aggregated from article-level text embeddings).
Field = `subject_primary`.

## Outcome variable

`semantic_diversity`: the mean cosine distance (1 minus cosine similarity)
from each article's embedding to the cell centroid, computed within each
country × `subject_primary` × year cell. Higher values indicate greater
intellectual diversity. Embeddings obtained via the OpenAI
`text-embedding-3-small` API (1536 dimensions).

## Key independent variable

`v2x_libdem` — V-Dem liberal democracy index (continuous, 0–1).

`regime_binary` and `v2x_regime` used in robustness checks.

---

# Team 06 — Analysis Plan

---

## Method

Text embedding + two-way FE OLS via `fixest::feols()`. The outcome is a
country-field-year-level measure of semantic diversity constructed by embedding
article abstracts using the OpenAI `text-embedding-3-small` API and computing
within-cluster dispersion. The main analysis regresses this diversity measure
on `v2x_libdem`.

---

## Step 1 — Embed abstracts

### 1a. API embedding

Use the OpenAI Embeddings API (`text-embedding-3-small`, 1536 dimensions)
to embed all abstracts with non-NA text (~2.5M abstracts).

- Estimated cost: ~500M tokens at $0.02/1M tokens ≈ $10.
- Process in batches of 1,000 via the OpenAI batch API.
- Fallback: embed a stratified random sample (200,000 abstracts stratified
  by country-regime-field-decade) if full-corpus embedding is not desired.

### 1b. Save embeddings

```r
# Save embeddings matrix alongside article identifiers
embeddings <- tibble(ut, country, iso3, year, subject_primary, embedding)
saveRDS(embeddings, "teams/team_06/analysis/embeddings.rds")
```

---

## Step 2 — Compute semantic diversity

### 2a. Group and compute centroids

```r
cells <- embeddings |>
  filter(!is.na(v2x_libdem)) |>
  group_by(country, iso3, subject_primary, year) |>
  filter(n() >= 10) |>
  mutate(
    centroid = list(colMeans(matrix(unlist(embedding), ncol = 1536, byrow = TRUE)))
  )
```

### 2b. Mean distance to centroid

For each cell with ≥ 10 articles: compute the centroid embedding, then
calculate the mean cosine distance from each article's embedding to the
centroid. This is `semantic_diversity_{c,f,t}`.

- Avoids O(n²) pairwise computation.
- Secondary measure: standard deviation of pairwise cosine similarities
  (on a random subsample of pairs if n > 50).

### 2c. Country-field-year aggregation

```r
cfy <- cells |>
  group_by(country, iso3, subject_primary, year) |>
  summarise(
    semantic_diversity = mean(cosine_dist_to_centroid),
    n_articles         = n(),
    mean_n_authors     = mean(n_authors, na.rm = TRUE),
    v2x_libdem         = first(v2x_libdem),
    v2x_regime         = first(v2x_regime),
    regime_binary      = first(regime_binary),
    e_gdppc            = first(e_gdppc),
    e_wb_pop           = first(e_wb_pop),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10, year >= 1990)
```

---

## Model specification

**Model 1 (main):**

```
semantic_diversity ~ v2x_libdem + log(n_articles) + mean_n_authors
  | country + subject_primary + year
```

- SE clustered at country level via `feols()`

**Model 2 (robustness — binary regime measure):**

```
semantic_diversity ~ regime_binary + log(n_articles) + mean_n_authors
  | country + subject_primary + year
```

**Model 3 (robustness — 4-category regime type):**

```
semantic_diversity ~ i(v2x_regime) + log(n_articles) + mean_n_authors
  | country + subject_primary + year
```

**Model 4 (country-field FE):**

```
semantic_diversity ~ v2x_libdem + log(n_articles) + mean_n_authors
  | country^subject_primary + year
```

- Absorbs field-specific traditions per country; stricter identification

**Model 5 (transitioner sample):**

```
semantic_diversity ~ v2x_libdem + log(n_articles) + mean_n_authors
  | country + subject_primary + year
```

- Restricted to countries that experienced a change in `v2x_regime` category
  during 1990–2023

**Model 6 (with economic controls):**

```
semantic_diversity ~ v2x_libdem + log(n_articles) + mean_n_authors
  + log(e_gdppc) + log(e_wb_pop)
  | country + subject_primary + year
```

All models: `cluster = ~country` via `feols()`

---

## Causal identification strategy

**Variation exploited:** Within-country over-time changes in liberal democracy,
1990–2023. Country fixed effects absorb all time-invariant country
characteristics (language, academic traditions, historical university structure,
WOS indexing patterns). Year fixed effects absorb global trends in research
diversity. Field fixed effects (or country-field FE) absorb baseline
differences in intellectual diversity across disciplines. The identifying
variation comes from countries whose regime type changes — democratization or
autocratization episodes — and whether those political changes coincide with
shifts in the semantic diversity of their SSH output.

**Confounders controlled:**

- Country FE: national academic culture, language, institutional structure,
  historical field composition
- Field FE (or country-field FE): discipline-specific norms for intellectual
  diversity, field size
- Year FE: global trends in SSH publishing, WOS coverage changes,
  methodological convergence/divergence
- Log total articles: mechanical effect of cell size on diversity estimation
- Mean author count: collaboration patterns that may affect diversity
- GDP per capita and population (Model 6): economic development controls

**Threats:**

1. *Economic development:* GDP growth drives both democratization and
   university expansion. Larger, better-funded systems may produce more
   diverse research regardless of regime type. Partially addressed by
   controlling for `log(e_gdppc)` in Model 6, and by the cell-size control.
2. *Internationalization:* Democracies may have more internationally connected
   scholars whose diverse training feeds into heterogeneous research. This is
   a potential mediator (international openness as a channel through which
   democracy increases diversity) rather than a pure confounder, but
   complicates interpretation.
3. *WOS selection bias:* If WOS indexes a narrower slice of autocracies'
   research (e.g., only English-language output), observed abstracts may come
   from a more homogeneous, internationally oriented subset. This would bias
   toward finding less diversity in autocracies for the wrong reason. The
   transitioner robustness check (Model 5) helps — within-country regime
   changes with stable indexing patterns provide cleaner variation.
4. *Embedding artifacts:* Semantic similarity may capture stylistic or
   linguistic features (e.g., formal vs. informal English) rather than
   substantive intellectual content. Using a high-dimensional embedding model
   and focusing on cosine distance mitigates this, but the concern remains.
5. *Field heterogeneity:* Different fields have different baseline levels of
   intellectual diversity (e.g., philosophy vs. economics). Field FE or
   country-field FE address this.

---

## Expected output files

All saved to `teams/team_06/analysis/figures/`:

| File | Description |
|---|---|
| `fig1_diversity_by_regime.png` | Boxplot/violin: distribution of semantic diversity by `v2x_regime` category |
| `fig2_diversity_trends.png` | Time series: mean semantic diversity for autocracies vs. democracies, 1990–2023 |
| `tab1_main_results.png` | Regression table: Models 1–3 (main + binary + 4-category) via `modelsummary` |
| `fig3_field_heterogeneity.png` | Coefficient plot: effect of `v2x_libdem` estimated separately for top 5 SSH fields |
