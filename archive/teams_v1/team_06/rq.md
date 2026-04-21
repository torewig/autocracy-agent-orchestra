# Team 06 — Research Question

## Research question

Does autocracy reduce the intellectual diversity of SSH research, as measured by the semantic similarity of article abstracts within country-field-year clusters?

## Rationale

The overarching question asks not only what topics are studied but what *direction* research takes and how knowledge *progresses*. A key dimension of scientific progress is intellectual diversity — the breadth of questions, frameworks, and arguments that scholars explore within a field. If autocracy constrains this diversity, it represents a qualitatively different form of impact than simply suppressing volume or shifting disciplinary composition. Semantic similarity of abstracts within country-field-year clusters provides a direct, content-based measure of whether the ideas being explored are more uniform under autocratic conditions.

## Theoretical mechanism

Autocratic regimes constrain the intellectual diversity of SSH through three reinforcing channels. First, state censorship and editorial control narrow the range of acceptable arguments, questions, and conclusions — scholars cannot publish findings that contradict official narratives or threaten regime legitimacy. Second, anticipatory self-censorship leads scholars to cluster around "safe" framings and avoid intellectually risky or heterodox positions, even when direct repression is absent. Third, centralized research funding and agenda-setting (e.g., state-directed grant priorities, ideological guidelines for universities) channel scholars toward a narrower set of approved research questions within each field. Together, these mechanisms predict that abstracts from autocracies will be more semantically homogeneous — more similar to one another in content, framing, and argumentation — than abstracts from democracies in the same field and year.

## Theory family

`intellectual-conformity`

## Estimand

The average within-country effect of a one-unit increase in liberal democracy (`v2x_libdem`, 0-1) on the mean semantic diversity of SSH abstracts within country-field-year clusters, controlling for country and year fixed effects.

## Unit of analysis

Country-field-year (aggregated from article-level text embeddings). Field = `subject_primary`.

## Outcome variable

Constructed: `semantic_diversity` — the mean pairwise cosine distance (1 minus cosine similarity) among abstract embeddings within each country x `subject_primary` x year cell. Higher values indicate greater intellectual diversity. Embeddings obtained via an API (e.g., OpenAI `text-embedding-3-small`).

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0-1).
