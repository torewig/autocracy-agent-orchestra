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
