# Team 29 — Research Question

## Research question

Does country size moderate the self-censorship effect of autocracy on the share of politically sensitive SSH articles, such that the negative association between autocratic rule and `share_sensitive` is weaker in countries with larger populations?

## Rationale

All prior tests in this project estimate average autocracy effects pooled across countries of very different sizes. Large SSH-producing autocracies — China, Russia, Iran — generate the bulk of autocratic-country output, so the pooled estimate is heavily influenced by their behavior. If the self-censorship effect differs systematically by country size, pooling may obscure important heterogeneity and mischaracterize the mechanism. Country size also proxies for academic-sector capacity: larger countries host more universities, more diverse scholarly communities, and more domestic publication channels, all of which may buffer or amplify regime pressure on research output.

## Theoretical mechanism

Two competing mechanisms generate opposite predictions. The **attenuation hypothesis** holds that larger countries have larger, more internally differentiated academic communities. Academic critical mass provides insulation: even under autocracy, large systems contain enough research institutions, scholars, and disciplinary subfields that pockets of politically diverse output persist. Large autocracies also tend to maintain stronger international research connections — driven partly by size-induced prestige pressures and resource endowments — which could provide further protection against uniform topic suppression. Under this hypothesis, the self-censorship coefficient on `v2x_libdem` is smaller in absolute magnitude in large countries: `β(v2x_libdem × log(pop)) > 0`.

The **amplification hypothesis** holds that large autocracies have greater state capacity to surveil, coordinate, and enforce compliance across a large academic sector. More universities mean more bureaucratic entry points for regime control; more researchers mean greater absolute returns to centralized enforcement. China and Russia illustrate how large states deploy extensive academic monitoring apparatus that small autocracies cannot replicate. Under this hypothesis, the self-censorship coefficient is larger in magnitude in large countries: `β(v2x_libdem × log(pop)) < 0`.

**Primary prediction:** The attenuation hypothesis is favored, predicting a positive and significant interaction coefficient on `v2x_libdem × log(e_wb_pop)`. The logic: academic critical mass and diversity operate at the level of the research community, and large communities are harder to homogenize fully even when the state tries. State monitoring capacity also scales with country size but is already high in all the large autocracies in the sample; marginal variation in capacity is insufficient to produce additional suppression above what the democracy score captures. The analysis should report both the primary result and its direction relative to both predictions.

## Theory family

`regime-channels`

## Estimand

The interaction coefficient on `v2x_libdem × log(e_wb_pop)` in a country-year panel regression of `share_sensitive` on `v2x_libdem`, `log(e_wb_pop)`, their interaction, `log(e_gdppc)`, and country and year fixed effects. A positive coefficient supports the attenuation hypothesis; a negative coefficient supports the amplification hypothesis; a null result indicates that the self-censorship effect is homogeneous across country sizes.

## Unit of analysis

Country-year (one observation per `iso3 × year` combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_sensitive`: the country-year proportion of distinct articles (identified by `wos_id`) for which at least one term in the regime-sensitive keyword dictionary matches in either the `title` or `keywords` field (case-insensitive regex). Replicates Team 04's construction:

    share_sensitive = (# distinct wos_id with at least one keyword match) / n_articles_country_year

Keyword dictionary follows Team 04: democracy/democratization, human rights, civil rights/liberties, corruption/bribery, protest/contention, repression/censorship, political prisoners, authoritarianism, political freedom, electoral manipulation, dissent/opposition.

## Key independent variable

`v2x_libdem × log(e_wb_pop)` — the interaction of the Liberal Democracy Index (continuous, 0–1; higher = more democratic) with log-transformed country population from the World Bank (`e_wb_pop`). `log(e_wb_pop)` is mean-centered before interacting to facilitate interpretation of the `v2x_libdem` main effect as the autocracy effect at average population size. Country fixed effects absorb the time-invariant component of country size, so identification comes from within-country variation in `v2x_libdem` over time, moderated by the country's (largely stable) log population.

## Uniqueness check

rq.md files were reviewed for all teams with files available: Teams 01–28.

- **Teams 01, 04, 05, 06, 08, 10, 11, 12:** All estimate the main (unconditional) effect of `v2x_libdem` on various topic or content outcomes. None introduces a moderating variable based on country size.
- **Teams 25, 26, 28:** Test temporal moderation (decade dummies), regime-duration moderation, and regime-type subgroup comparisons, respectively. None uses population or SSH volume as a moderator.
- **Teams 23, 24:** Event-study designs for democratization and autocratization. No size moderation.
- **Team 27 (no rq.md at time of writing):** Per project brief, assigned to GDP moderation — neighboring but distinct. Team 29 uses population size as a proxy for academic-community critical mass, which is theoretically separable from GDP per capita (economic development). A country can be large and poor, or small and rich; the mechanisms differ.
- **No team** in the 01–28 set uses population size or SSH production volume as a moderator of the autocracy–self-censorship relationship. Team 29 is the only team testing whether country size conditions the strength of the core autocracy effect.
