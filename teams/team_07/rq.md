# Team 07 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish SSH articles that acknowledge international funding agencies at lower rates, compared to researchers from more democratic countries?

## Rationale

Receiving funding from international agencies — such as the US National Science Foundation, the European Research Council, the World Bank, the Ford Foundation, or bilateral aid bodies — involves agreeing to donor norms, submitting to external review, and producing work that is visible to international audiences. Autocratic regimes may view this cross-border funding relationship as threatening, and researchers aware of this may self-select out of such arrangements or be blocked from accessing them. If this mechanism operates at scale, the share of a country-year's SSH output that acknowledges international funding should be systematically lower in more autocratic settings.

## Theoretical mechanism

Autocratic rulers are threatened by research networks that originate outside their control: international funding creates accountability relationships to foreign institutions, imposes liberal norms around academic freedom and open publication, and can facilitate the production of research on politically sensitive topics (governance quality, human rights, protest) that might not otherwise be funded domestically. Researchers in autocracies therefore face two compounding pressures: (1) they anticipate that seeking or accepting international funding will attract state scrutiny and career risk, and (2) autocratic governments may directly restrict foreign-funded research through registration requirements, permit denials, or the stigmatization of foreign-funded NGOs and universities. Both mechanisms produce the same observable pattern: the share of articles acknowledging international funding should be monotonically lower in more autocratic country-years. The expected direction of the main coefficient is positive: higher `v2x_libdem` is associated with a higher share of internationally funded articles.

## Hypothesis

H1: Countries with lower Liberal democracy levels will have a lower share of SSH articles acknowledging international funding agencies, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles that acknowledge at least one international funding agency, conditional on country and year fixed effects, `log(e_gdppc)`, and `log(e_wb_pop)`.

## Unit of analysis

Country-year (one observation per iso3 x year, restricted to country-years with at least five SSH articles).

## Outcome variable

`share_intl_funded`: constructed as follows.

1. For each article, search for matches of an international-funding-agency regex dictionary in the `funding_text` or `grant_agencies` field if available; otherwise fall back to searching the `abstract` field.
2. An article is coded 1 if at least one match is found, 0 otherwise.
3. Aggregate to country-year: `share_intl_funded = (# articles coded 1) / n_articles_country_year`.

The outcome is a proportion bounded in [0, 1]. The international funding agency dictionary is defined in `analysis_plan.md`.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. Teams 01–06 cover the following angles: PCI score on abstract vocabulary (01), Shannon entropy of author keywords (02), disciplinary composition using WOS subject categories (03), regime-sensitive keyword prevalence in titles/keywords (04), LLM classification of critical domestic framing in abstracts (05), semantic diversity via text embeddings (06).

Team 07 is distinct on two dimensions. First, the outcome is based on funding acknowledgment metadata rather than any aspect of article content (title, keywords, abstract, or discipline): it captures researchers' international institutional linkages, not their topic choices or word choices. Second, the theoretical mechanism is different — it concerns cross-border institutional exposure and the threat that foreign oversight poses to autocratic control, rather than direct topic or vocabulary self-censorship. No other team uses funding acknowledgment as an outcome.
