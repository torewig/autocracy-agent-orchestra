# Team 03 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish a lower share of their SSH output in politically sensitive disciplines (political science, international relations, law, sociology, social issues, ethnic studies, and women's studies)?

## Rationale

Self-censorship does not operate only within disciplines — it also operates across them. A researcher aware that political science or law carries regime risk may shift their career into a less exposed field (economics, psychology, linguistics) where sensitive topics are peripheral. If this mechanism operates at scale, autocracies should exhibit a structurally different disciplinary profile of SSH output — one systematically tilted away from fields in which engagement with power, rights, and governance is constitutive. This outcome is observable in WOS subject category data without any text analysis, making it a direct, low-noise test of disciplinary-level self-censorship.

## Theoretical mechanism

Autocratic regimes constrain academic freedom through formal mechanisms (restricted research agendas, surveillance of university departments, politically appointed deans) and informal ones (career penalties for scholars whose work embarrasses the regime). Researchers and graduate students respond by self-selecting into disciplines where politically sensitive inquiry is marginal — economics, psychology, linguistics, or the arts — rather than fields where engagement with state power, rights, or governance is disciplinary core. At the country-year level, this produces a lower share of SSH output in politically sensitive disciplines in more autocratic settings. The expected direction of the main coefficient is negative: higher liberal democracy scores predict a higher share of output in sensitive fields, because democratic environments permit and even reward scholarship that scrutinizes power.

## Theory family

topic-avoidance

## Hypothesis

H1: Countries with lower Liberal democracy levels will produce a lower share of SSH output in politically sensitive disciplines, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

## Estimand

The average within-country effect of a one-unit increase in v2x_libdem on the share of country-year SSH output assigned to politically sensitive WOS subject categories.

## Unit of analysis

Country-year

## Outcome variable

**Construction:** For each article-country-year row, classify `subject_primary` as sensitive (1) or neutral (0) using the list below. Aggregate to country-year: `share_sensitive = n_sensitive_articles / n_total_articles` (where n_total = `n_articles_country_year`). The outcome is a proportion bounded in [0, 1].

**Politically sensitive WOS subject categories (classified as 1) — primary specification (7 fields):**

| Category | Justification |
|---|---|
| Political Science | Core discipline of state, power, governance |
| International Relations | Power, conflict, foreign policy — direct political content |
| Law | Legal rights, state authority, constitutional order |
| Sociology | Social inequality, social movements, institutions |
| Social Issues | Social problems, inequality, marginalization — politically charged |
| Ethnic Studies | Minority rights, ethnic conflict, identity politics |
| Women's Studies | Gender rights, feminist critique of power |

**Note on excluded borderline fields:** Public Administration, Area Studies, and Criminology & Penology are excluded from the primary classification as conceptually borderline. They are included in the RC1 robustness check (expanded field list).

All other SSH fields (`Economics`, `Psychology` variants, `Education` variants, `Geography`, `History`, `Communication`, `Demography`, `Linguistics`, `Language & Linguistics`, `Management`, `Information Science & Library Science`, `Planning & Development`, `Anthropology`, `Ergonomics`, `Family Studies`, `Health Policy & Services`, `History & Philosophy of Science`, `Industrial Relations & Labor`, `Regional & Urban Planning`, `Social Sciences, Biomedical`, `Social Sciences, Interdisciplinary`, `Social Sciences, Mathematical Methods`, `Social Work`, `Urban Studies`, all Arts & Humanities categories) are classified as neutral (0).

**Note on borderline cases:** `History` is classified as neutral in the primary specification because its sensitivity depends on political context in ways that are not consistent across countries; sensitivity robustness check uses a "History-included" classification.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Most similar existing teams: 01 (keyword-based PCI score), 04 (regime-sensitive keyword prevalence in titles/keywords).

Distinction: Team 03 uses WOS journal-assigned subject categories — a structural, metadata-level indicator of disciplinary composition — rather than any text content of titles, abstracts, or keywords. The outcome reflects field choice, not word choice.
