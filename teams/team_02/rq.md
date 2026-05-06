# Team 02 — Research Question

## Research question
Does higher autocracy reduce the topical breadth of author-supplied keywords in SSH publications, as measured by the Shannon entropy of the keyword distribution aggregated to the country-year level?

## Rationale
Author-supplied keywords are the researcher's own signal of what a paper is about; in autocratic settings, researchers who self-censor will gravitate toward safer, institutionally approved topics, causing keyword vocabularies to concentrate around a narrower range of terms. If self-censorship operates systematically, this compression should be visible in the aggregate diversity of keywords produced by a country in a given year. Topical entropy is a direct, interpretable summary of how broadly or narrowly distributed scholarly attention is across the keyword space, making it well-suited to detecting this compression.

## Theoretical mechanism
Autocratic regimes impose career costs — through dismissal, grant denial, publication rejection, or informal social sanctioning — on scholars who study politically sensitive subjects such as governance, civil liberties, protest, or regime critique. Faced with these costs, individual researchers rationally avoid risky topic choices, shifting instead toward politically neutral subjects (economic history, linguistics, natural resource management, etc.). When this avoidance is widespread across a country's research community, the aggregate keyword distribution becomes more concentrated: fewer distinct keywords are used, and a smaller set of dominant terms accounts for a larger share of total keyword tokens. The expected direction is negative — higher `v2x_libdem` (more democracy) is associated with higher keyword entropy (wider topical spread).

## Theory family
topic-avoidance

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the Shannon entropy of the country-year author-keyword distribution, conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis
Country-year

## Outcome variable
`keyword_entropy_cy` — constructed variable: for each country-year, parse `author_keywords` into individual keyword tokens (split on `";"` or `"|"`), strip whitespace, lowercase; compute Shannon entropy H = -sum(p_k * log(p_k)) over the empirical keyword frequency distribution for that country-year (p_k = relative frequency of keyword k among all keyword tokens for that country-year). Articles without author keywords are excluded from the keyword pool for that country-year. Denominator check: country-years with fewer than 10 keyword-bearing articles are dropped to ensure stable entropy estimates.

## Hypothesis
H1: Countries with lower Liberal democracy levels will exhibit lower Shannon entropy of author-supplied keyword distributions at the country-year level, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no rq.md files found for teams 01–06 at time of writing).
Distinction: Team 01 counts political-content keywords in abstracts (a sensitivity/prevalence measure); Team 04 counts specific sensitive terms (democracy, human rights) in titles and keywords; Team 06 measures semantic diversity via costly text embeddings. This team measures the topical breadth of the author-supplied keyword vocabulary using Shannon entropy — a structural diversity measure applied specifically to the keyword field, requiring no API and no predefined dictionary.
