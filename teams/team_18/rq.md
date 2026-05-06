# Team 18 — Research Question

## Research question

Do researchers in more autocratic countries collaborate across fewer distinct author institutions per SSH article, compared to researchers in more democratic countries?

## Rationale

Inter-institutional collaboration requires spreading a research project across organizational boundaries — across universities, research centers, government agencies, and other bodies. In autocratic settings, each additional institutional partner creates a new surveillance surface: administrators, colleagues, and security actors at partner institutions may scrutinize and report on the collaboration. Researchers who anticipate this exposure have an incentive to keep projects within a single institution or a narrow institutional network, limiting the organizational breadth of their scientific collaborations. If this mechanism operates systematically, autocratic country-years should exhibit lower mean institutional diversity per published article.

## Theoretical mechanism

In autocracies, institutional actors — department heads, university administrators, and party liaisons embedded in research organizations — monitor research activity and can impose career costs on researchers whose projects attract political scrutiny. A collaboration that involves institutions outside the researcher's home organization brings in unfamiliar gatekeepers who may apply unpredictable political standards or report sensitive topics to authorities. Anticipating these risks, researchers in repressive environments self-censor by confining collaborations to a single trusted institution or to a very small number of familiar partners, reducing the organizational surface area of the project. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher mean count of distinct institutions per article at the country-year level, because democratic environments lower the political cost of multi-institutional collaboration.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a lower mean number of distinct author institutions per SSH article, after controlling for country fixed effects, year fixed effects, log GDP per capita, log population, and mean co-author country count.

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean number of distinct author institutions per article, conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Controls

- `log(e_gdppc)` — log GDP per capita (V-Dem/World Bank)
- `log(e_wb_pop)` — log population (World Bank)
- `mean_n_coauthor_countries` — country-year mean of distinct co-author countries per article, constructed following Team 14's approach (added to control for international collaboration breadth as a confound)

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least 5 articles with non-missing `institutions` data).

## Outcome variable

`mean_n_inst`: the country-year mean of the per-article distinct institution count, constructed as follows.

**Institution field used:** `institutions` — a semicolon-delimited string retained from the WOS source in `agent_corpus.rds` (see `scripts/00_prepare_data.R`, line 52). This field lists all author institutions for a given article, regardless of author country. It is duplicated across all article-country rows for the same `ut` value; deduplication by `ut` is required before parsing.

**Scope:** Because `institutions` lists all author affiliations in the article (not only the focal country's affiliations), the resulting measure captures total institutional diversity across the full author team — domestic and international. This is interpretable as the organizational breadth of the collaboration network, not purely domestic institutional diversity. Where only domestic institution data were available, the measure would reflect within-country institutional diversity; the present data does not restrict to focal-country institutions, which is noted as a scope condition in the analysis.

**Construction steps:**

1. Deduplicate the corpus to one row per `ut` (use `distinct(ut, .keep_all = TRUE)`).
2. Filter to rows where `institutions` is non-missing and non-empty.
3. For each article, split `institutions` on `";"`, trim whitespace, and count distinct non-empty tokens: `n_inst = n_distinct(str_trim(strsplit(institutions, ";")[[1]]))`.
4. Join back to the full corpus (article-country rows) via `ut` to recover `iso3` and `year`.
5. Aggregate to country-year: `mean_n_inst = mean(n_inst, na.rm = TRUE)`, grouped by `iso3` and `year`.
6. Exclude country-years with fewer than 5 articles contributing to the mean.

The outcome is a continuous, right-skewed count-based mean, bounded below at 1.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1; higher = more democratic). Used as the primary IV. At least one robustness check uses `lied_binary`.

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 10, 11, 12, and 15 at the time of writing. No rq.md files were found for teams 09, 13, 14, 16, and 17.

Team 18's domain is confirmed distinct from all collaboration-constraint teams (14–17) per the brief assignments and available rq.md files:

- **Versus Team 14 (distinct co-author countries per article):** Team 14 counts distinct `iso3` values per `ut` — the number of *countries* represented in the author team. Team 18 counts distinct *institutions* per article using the `institutions` string field. Two articles can have identical country-level collaboration breadth (e.g., both involve only two countries) but differ substantially in institutional diversity (one may span six universities, the other only two). The mechanisms are also distinct: Team 14 captures cross-border collaboration suppression; Team 18 captures within-and-across-country organizational fragmentation of the research team.

- **Versus Team 15 (democratic co-authorship share):** Team 15 measures whether co-author countries have `v2x_libdem > 0.5` — a question about the ideological valence of the co-authorship network, not its organizational breadth. Team 18 makes no distinction by regime type of co-author country.

- **Versus Team 16 (domestic-only authorship share):** Team 16 flags articles where all author countries are the same, testing whether autocracy drives researchers toward purely domestic collaborations. Team 18 does not distinguish domestic from international institutions — it measures total institutional diversity across the full author team, including both domestic and foreign institutions.

- **Versus Team 17 (mean author count):** Team 17 uses `n_authors` (a pre-computed count already in the corpus). Team 18 uses the `institutions` string field, which must be parsed. Person count and institutional count are empirically correlated but conceptually distinct: a single institution can contribute many authors, and a two-person team can span two institutions. The theoretical mechanism also differs — Team 17 tests whether autocracy produces smaller teams; Team 18 tests whether autocracy produces organizationally narrower teams regardless of team size.

- **Versus Teams 01–13 (topic-avoidance and framing-neutrality families):** None of these teams measure collaborative or organizational structure; they all measure textual content, field composition, or framing of abstracts. Team 18 is structurally unrelated to all of them.
