# Team 05: Research Question

## Research question

Does the level of democracy in a country predict the number of distinct co-author countries on social science and humanities articles affiliated with that country?

## Rationale

International research collaboration is a key driver of knowledge diffusion and scientific progress. Autocratic regimes may constrain cross-border collaboration through restrictions on academic travel, foreign funding, and international partnerships — or indirectly through the chilling effects of surveillance and political control over universities. If autocracy limits the internationalization of research, we should observe that articles affiliated with less democratic countries involve fewer distinct co-author countries.

## Theoretical mechanism

Autocratic regimes reduce international co-authorship through three reinforcing channels. First, **mobility restrictions**: visa regulations, travel bans, and foreign-exchange controls raise the cost of establishing and maintaining international research networks. Second, **institutional isolation**: state control over universities and funding bodies limits participation in international consortia, joint grants, and researcher exchange programs, particularly with Western democracies. Third, **trust and self-censorship**: researchers in autocracies face surveillance risks when collaborating with foreign scholars, especially on politically sensitive topics, which deters the formation of cross-border partnerships. The expected direction is negative: lower levels of liberal democracy lead to fewer co-author countries per article.

## Theory family

`international-isolation`

## Estimand

The average effect of a one-unit increase in the liberal democracy index (`v2x_libdem`, 0-1) on the number of distinct co-author countries per article, holding constant time-invariant country characteristics, common year shocks, and field composition.

## Unit of analysis

Article-country (one row per article × author-affiliation country, as structured in the corpus). The outcome — number of distinct co-author countries — is an article-level property that is constant across rows of the same article. Standard errors are clustered at the country level to account for this.

## Outcome variable

Constructed from the data: `n_co_countries` — the number of distinct values of `country` per `ut` (article identifier). This is computed during analysis and merged back onto each article-country row.

## Key independent variable

`v2x_libdem`
