# Team 30 — Research Question

## Research question

Does the V-DEM Academic Freedom Index (`v2clacfree`) predict the country-year share of regime-sensitive SSH articles better than — and independently of — the general Liberal Democracy Index (`v2x_libdem`), and does `v2clacfree` retain a positive coefficient when both variables compete in the same horse-race model?

## Rationale

Team 04 and related teams establish a robust negative association between autocracy (`v2x_libdem`) and the prevalence of sensitive-topic SSH research. However, `v2x_libdem` is a composite measure of general democratization that captures much more than the specific freedoms relevant to scientific production — including electoral competitiveness, civil society, and rule of law. If self-censorship by researchers is the operative mechanism, then a measure that directly captures state interference with academic inquiry (`v2clacfree`) should outperform — or at minimum retain independent predictive power alongside — the broader democracy index. Failing to make this distinction leaves open the alternative that the `v2x_libdem` effect reflects general resource availability, the selection of capable researchers into democratic settings, or other confounders that covary with democratization but have nothing to do with academic self-censorship per se.

## Theoretical mechanism

The self-censorship mechanism implies that researchers adapt their behavior specifically in response to threats directed at academic work — surveillance of publications, politically motivated dismissals, restrictions on research topics, and interference with international collaboration. These threats are operationalized most directly by `v2clacfree`, which codes precisely this domain. By contrast, `v2x_libdem` captures a much broader cluster of political freedoms, most of which do not directly regulate what scholars can write or publish. If the mechanism is specifically academic self-censorship, then in a horse-race regression that includes both `v2clacfree` and `v2x_libdem`, `v2clacfree` should carry the bulk of the predictive weight and retain a statistically and substantively significant positive coefficient (higher academic freedom → higher share of regime-sensitive articles), while the coefficient on `v2x_libdem` should be attenuated. Conversely, if the effect is primarily an artifact of general democratization — rather than specifically of academic freedom — then `v2x_libdem` should dominate and `v2clacfree` should lose explanatory power once `v2x_libdem` is held constant. The expected direction of both coefficients in isolation is positive: more academic freedom and more liberal democracy each independently predict a higher share of sensitive-topic articles.

## Theory family

`regime-channels`

## Estimand

The relative predictive contribution of `v2clacfree` versus `v2x_libdem` to the country-year share of regime-sensitive SSH articles, as assessed by: (a) the sign, magnitude, and statistical significance of each coefficient in parallel single-predictor models (Model A, Model B) and in a joint horse-race model (Model C); and (b) model-fit statistics (within-R² and RMSE) across the three specifications. The estimand is not a causal effect — it is a test of mechanism specificity: which dimension of political context is the more proximate predictor of the self-censorship outcome.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus and non-missing values for both `v2x_libdem` and `v2clacfree`).

## Outcome variable

`share_sensitive`: the country-year proportion of distinct SSH articles that contain at least one match from the regime-sensitive keyword dictionary in the article title or author-supplied keywords, as defined and constructed by Team 04. Formally:

    share_sensitive = (# distinct ut with at least one dictionary match) / n_articles_country_year

## Key independent variables

- **Primary interest:** `v2clacfree` — V-DEM Academic Freedom Index (continuous, approximately −3 to 3; higher = more academic freedom from state interference in teaching, research, and publication)
- **Comparator:** `v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1; higher = more democratic)

## Uniqueness check

All 29 prior teams (Teams 01–29) use either `v2x_libdem` or `lied_binary` as their primary regime measure; no team uses `v2clacfree` as a primary independent variable or explicitly pits `v2clacfree` against `v2x_libdem` in a horse-race design. Team 30 is therefore distinct from all prior teams in its research question (mechanism specificity) and design (parallel model comparison plus a joint horse-race). It is not testing a new outcome dimension — it uses the same `share_sensitive` outcome as Team 04 — but it asks a different question: *which* aspect of the political context drives the association. This makes Team 30 a methodological and conceptual complement to the core regime-sensitivity papers, not a duplicate.
