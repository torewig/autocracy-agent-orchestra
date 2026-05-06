# Team 22 — Research Question

## Research question

Does autocracy predict higher Gini concentration of citations across articles within a country-year, such that publication output in autocracies exhibits a more unequal citation distribution than equivalent output in democracies?

## Rationale

Self-censorship in autocracies may generate a bifurcated scientific output: a small number of ideologically acceptable or strategically prominent articles accrue disproportionate citations, while the bulk of the output — conformist, safe, and undistinctive — receives very few. This produces higher within-country-year inequality in citations, captured by the Gini coefficient, even if mean citation levels differ little. The Gini test is therefore conceptually and statistically distinct from a mean-citation test (Team 19): it asks about the shape of the citation distribution, not its level.

## Theoretical mechanism

In autocracies, career survival incentives lead most researchers to publish on uncontroversial, incremental topics that minimize political exposure — output that is competent but does not advance high-stakes intellectual debates and therefore attracts little international attention. A small subset of articles — those touching on regime-endorsed priorities, applied development topics, or internationally funded projects — escape this dynamic and accumulate citations normally. The structural result is a polarized citation distribution: a few well-cited articles and a long tail of near-zero-citation work. In democracies, where researchers face fewer constraints on topic choice, intellectual boldness, and critical framing, citation uptake is more evenly distributed across the portfolio. The expected direction is that higher `v2x_libdem` (more democratic) is associated with a lower Gini coefficient of `tot_cites` within country-year — i.e., autocracy produces higher citation concentration.

## Hypothesis

H1: Countries with lower Liberal democracy levels will exhibit a higher Gini coefficient of citations across SSH articles, after controlling for country fixed effects, year fixed effects, log GDP per capita, log population, and log article volume.

## Controls

- `log(e_gdppc)` — log GDP per capita
- `log(e_wb_pop)` — log population
- `log(n_articles)` — log of the number of deduplicated articles in the country-year cell, to account for mechanical compression of the Gini in large output cells

## Theory family

`visibility-suppression`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the Gini coefficient of `tot_cites` computed across all articles from that country in that year, conditional on country and year fixed effects and standard economic controls. An additional control for log article volume is required because large country-year output mechanically compresses the Gini.

## Unit of analysis

Country-year (one observation per iso3 × year combination). Restricted to country-years with at least 10 articles to ensure stable Gini estimates.

## Outcome variable

`gini_tot_cites`: the Gini coefficient of `tot_cites` computed across all articles assigned to a given country-year. Articles are deduplicated by `wos_id` before computing the Gini (to prevent multi-author articles from inflating cell size). The Gini is bounded [0, 1]; higher values indicate greater inequality in how citations are distributed across the article portfolio.

The Gini is computed using a custom function:

```
gini_approx <- function(x) {
  x <- sort(x[!is.na(x) & x >= 0])
  n <- length(x)
  if (n < 2 || sum(x) == 0) return(NA)
  sum((2 * seq_along(x) - n - 1) * x) / (n * sum(x))
}
```

Country-years with fewer than 10 distinct articles (after deduplication) are dropped.

## Key IV

`v2x_libdem` (continuous, 0–1; higher = more democratic). Robustness check uses `lied_binary` (0 = autocracy, 1 = democracy).

## Uniqueness check

rq.md files were read for all teams with files available at time of writing: teams 01–12, 14–17, 19–20.

- **Team 19** estimates the effect of autocracy on the mean of normalized citation impact (`log1p(cite_ratio)`) at the country-year level — a test of the average level, not the distribution shape.
- **Team 20** estimates an interaction between autocracy and topic sensitivity at the article level — a test of whether citation penalties are concentrated on politically sensitive work.
- **No other team** uses a distributional outcome or a concentration/inequality measure. Team 22 is the only team asking whether autocracy shifts the within-country-year shape of the citation distribution, as captured by the Gini coefficient.
- Teams 01–08, 10–12, 14–17 all use outcomes based on topic composition, semantic content, hedging, or collaboration structure — none use citation distribution as the estimand.
