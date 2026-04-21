---
title: 'Agent Orchestra v2 -- Gate B Review: All 25 Research Questions'
date: '2026-04-20'
---



ewpage

# Team 01 — Research Question

## Research question
Do SSH researchers in more autocratic countries produce abstracts with a lower share of political-content keywords — as measured by the Political-Content Index (PCI) score — than researchers in more democratic countries, after controlling for country, year, GDP per capita, and population?

## Rationale
Researchers working under autocratic rule face institutional incentives to avoid topics that may attract state scrutiny, including explicitly political subject matter. If self-censorship operates through topic avoidance, we should observe that the textual content of published abstracts from autocratic contexts is systematically depleted of political vocabulary. The abstract is the first and most visible signal of a paper's political content, making it a plausible site of strategic softening or omission.

## Theoretical mechanism
In autocracies, researchers anticipate that using political vocabulary in published work — terms such as "democracy," "repression," "protest," or "human rights" — increases the probability of institutional sanction, loss of funding, or career setback. Facing this risk, researchers either self-select out of politically sensitive topics or reframe their work to minimize explicitly political language at the stage of writing up and publishing. This behavioral response reduces the aggregate share of political-content keywords in abstracts from autocratic country-years. The expected direction is negative: higher `v2x_libdem` → higher PCI score (more political content), because greater political freedom removes the self-censorship incentive.

## Theory family
topic-avoidance

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean PCI score (share of abstract word tokens matching a political-content keyword dictionary), conditional on country and year fixed effects.

## Unit of analysis
Country-year

## Outcome variable
`pci_mean`: constructed by (1) tokenizing each article abstract, (2) computing the share of tokens matching a political-content keyword dictionary (PCI score per article), then (3) averaging PCI scores to the country-year level, weighted by article count. The PCI dictionary covers terms in the clusters: democracy/autocracy, repression/rights, governance/corruption, protest/conflict, elections/parties (approximately 80–120 stems; full list defined in analysis.R).

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no other team rq.md files exist yet for teams 02–06).
Distinction: Teams 02–04 are assigned to topical diversity, disciplinary composition, and a specific four-keyword set respectively; Team 01 is the only team using a broad multi-cluster PCI dictionary applied to raw abstract text aggregated to country-year mean share.



ewpage

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
The average within-country effect of a one-unit increase in `v2x_libdem` on the Shannon entropy of the country-year author-keyword distribution, conditional on country and year fixed effects and standard economic controls.

## Unit of analysis
Country-year

## Outcome variable
`keyword_entropy_cy` — constructed variable: for each country-year, parse `author_keywords` into individual keyword tokens (split on `";"` or `"|"`), strip whitespace, lowercase; compute Shannon entropy H = -sum(p_k * log(p_k)) over the empirical keyword frequency distribution for that country-year (p_k = relative frequency of keyword k among all keyword tokens for that country-year). Articles without author keywords are excluded from the keyword pool for that country-year. Denominator check: country-years with fewer than 10 keyword-bearing articles are dropped to ensure stable entropy estimates.

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. Most similar existing team: none (no rq.md files found for teams 01–06 at time of writing).
Distinction: Team 01 counts political-content keywords in abstracts (a sensitivity/prevalence measure); Team 04 counts specific sensitive terms (democracy, human rights) in titles and keywords; Team 06 measures semantic diversity via costly text embeddings. This team measures the topical breadth of the author-supplied keyword vocabulary using Shannon entropy — a structural diversity measure applied specifically to the keyword field, requiring no API and no predefined dictionary.



ewpage

# Team 03 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish a lower share of their SSH output in politically sensitive disciplines (political science, law, sociology, international relations, public administration, area studies, social issues, ethnic studies, criminology, and women's studies)?

## Rationale

Self-censorship does not operate only within disciplines — it also operates across them. A researcher aware that political science or law carries regime risk may shift their career into a less exposed field (economics, psychology, linguistics) where sensitive topics are peripheral. If this mechanism operates at scale, autocracies should exhibit a structurally different disciplinary profile of SSH output — one systematically tilted away from fields in which engagement with power, rights, and governance is constitutive. This outcome is observable in WOS subject category data without any text analysis, making it a direct, low-noise test of disciplinary-level self-censorship.

## Theoretical mechanism

Autocratic regimes constrain academic freedom through formal mechanisms (restricted research agendas, surveillance of university departments, politically appointed deans) and informal ones (career penalties for scholars whose work embarrasses the regime). Researchers and graduate students respond by self-selecting into disciplines where politically sensitive inquiry is marginal — economics, psychology, linguistics, or the arts — rather than fields where engagement with state power, rights, or governance is disciplinary core. At the country-year level, this produces a lower share of SSH output in politically sensitive disciplines in more autocratic settings. The expected direction of the main coefficient is negative: higher liberal democracy scores predict a higher share of output in sensitive fields, because democratic environments permit and even reward scholarship that scrutinizes power.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in v2x_libdem on the share of country-year SSH output assigned to politically sensitive WOS subject categories.

## Unit of analysis

Country-year

## Outcome variable

**Construction:** For each article-country-year row, classify `subject_primary` as sensitive (1) or neutral (0) using the list below. Aggregate to country-year: `share_sensitive = n_sensitive_articles / n_total_articles` (where n_total = `n_articles_country_year`). The outcome is a proportion bounded in [0, 1].

**Politically sensitive WOS subject categories (classified as 1):**

| Category | Justification |
|---|---|
| Political Science | Core discipline of state, power, governance |
| International Relations | Power, conflict, foreign policy — direct political content |
| Law | Legal rights, state authority, constitutional order |
| Sociology | Social inequality, social movements, institutions |
| Public Administration | State apparatus, bureaucratic performance |
| Area Studies | Regional political and social analysis; often sensitive in context |
| Social Issues | Social problems, inequality, marginalization — politically charged |
| Ethnic Studies | Minority rights, ethnic conflict, identity politics |
| Criminology & Penology | State punishment, policing, justice systems |
| Women's Studies | Gender rights, feminist critique of power |

All other SSH fields (`Economics`, `Psychology` variants, `Education` variants, `Geography`, `History`, `Communication`, `Demography`, `Linguistics`, `Language & Linguistics`, `Management`, `Information Science & Library Science`, `Planning & Development`, `Anthropology`, `Ergonomics`, `Family Studies`, `Health Policy & Services`, `History & Philosophy of Science`, `Industrial Relations & Labor`, `Regional & Urban Planning`, `Social Sciences, Biomedical`, `Social Sciences, Interdisciplinary`, `Social Sciences, Mathematical Methods`, `Social Work`, `Urban Studies`, all Arts & Humanities categories) are classified as neutral (0).

**Note on borderline cases:** `History` is classified as neutral in the primary specification because its sensitivity depends on political context in ways that are not consistent across countries; sensitivity robustness check uses a "History-included" classification.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Most similar existing teams: 01 (keyword-based PCI score), 04 (regime-sensitive keyword prevalence in titles/keywords).

Distinction: Team 03 uses WOS journal-assigned subject categories — a structural, metadata-level indicator of disciplinary composition — rather than any text content of titles, abstracts, or keywords. The outcome reflects field choice, not word choice.



ewpage

# Team 04 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish SSH articles that use regime-sensitive terms — specifically words denoting democracy, human rights, corruption, and political protest — at lower rates in their titles and author-supplied keywords, compared to researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that researchers in autocracies avoid topics that could draw state scrutiny or threaten their careers. Regime-sensitive concepts such as democracy, human rights, and corruption are precisely the topics most likely to alarm authoritarian authorities, making them high-cost subjects for scholars in non-democratic settings. The explicit topic labels that researchers attach to their work — titles and author keywords — are the most visible signals of what a paper is "about," and are therefore the most plausible site of anticipatory avoidance behavior.

## Theoretical mechanism

Researchers in autocracies operate under surveillance and face credible risks — loss of funding, dismissal, harassment, or detention — if they are perceived as challenging the regime. This generates incentives to avoid producing and publicly labeling research using terms that are politically dangerous in their national context. The behavioral response is anticipatory self-censorship: scholars steer clear of regime-sensitive topics at the point of topic selection, and avoid explicitly flagging sensitive content in the most visible metadata fields (title and keywords) even when related work is conducted. Because these incentives scale with the degree of autocratic repression, we expect the share of articles bearing regime-sensitive labels to be monotonically decreasing in the level of autocracy (i.e., decreasing in `v2x_libdem`): the less democratic the country, the lower the prevalence of regime-sensitive keywords.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles that contain at least one match from the regime-sensitive keyword dictionary in the article title or author-supplied keywords (`keywords` field).

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_regime_sensitive`: the proportion of distinct articles from a given country-year for which at least one term in the regime-sensitive dictionary matches in either the `title` or `keywords` fields (case-insensitive regex). Constructed as:

    share_regime_sensitive = (# distinct ut with at least one match) / n_articles_country_year

**Regime-sensitive keyword dictionary (see analysis_plan.md for full regex patterns):**

| Term cluster | Representative terms |
|---|---|
| Democracy / democratization | democrat, democratiz, democratis |
| Human rights | human rights, civil rights, civil liberties |
| Corruption / accountability | corruption, corrupt, bribery, kleptocracy |
| Protest / contention | protest, demonstrat, uprising, riot, rebellion, civil unrest |
| Political repression | repression, repressive, censorship, censor, political prisoner |
| Authoritarianism | authoritarian, autocra, dictatorship |
| Political freedom | political freedom, political liberty, free speech, freedom of expression, freedom of press |
| Electoral manipulation | election fraud, electoral fraud, vote rigging, vote buying |
| Dissent / opposition | dissent, dissident, political opposition, regime critic |

## Key independent variable

`v2x_libdem` (Liberal Democracy Index, 0–1, continuous; higher = more democratic)

## Uniqueness check

Performed. Most similar existing team: none (no other rq.md files exist at time of writing; closest by design would be Team 01).
Distinction: Team 01 constructs a Political Content Index (PCI) score from abstracts using a broader keyword list; Team 04 uses a curated dictionary of specifically regime-sensitive terms matched on title + author keywords (not abstracts), and measures prevalence as a country-year share rather than a scored index.



ewpage

# Team 05 — Research Question

## Research question

Does higher levels of authoritarianism reduce the share of social science and humanities articles that critically examine the author's own country's governance and institutions, as classified by a large language model applied to article abstracts?

## Rationale

Self-censorship theories predict that researchers operating under authoritarian constraints avoid producing work that could be perceived as threatening to the regime. Critiquing domestic governance — examining failures of one's own state's institutions, political processes, or ruling actors — is among the most politically exposed scholarly activities a researcher can undertake. If self-censorship operates through avoidance of such critical domestic framing, we should observe a lower share of such articles in more authoritarian country-years. Dictionary-based keyword approaches used by other teams capture the presence of politically sensitive terms but cannot distinguish between an article that critiques domestic governance and one that merely studies democracy or institutions in a neutral or comparative frame; LLM classification addresses this gap.

## Theoretical mechanism

In autocracies, researchers face career sanctions — including denial of employment, funding, publication opportunities, or in extreme cases legal consequences — if their work is interpreted as critical of the ruling regime or its institutions. Anticipating these risks, individual researchers self-censor by reframing or abandoning research questions that involve evaluating or critiquing their own country's governance, even when the scholarly question is legitimate. Over time, this selective avoidance should produce a measurable deflation in the share of a country's SSH output that critically examines domestic institutions. The expected direction is negative: higher authoritarianism (lower v2x_libdem) is associated with a lower share of critical domestic governance framing.

## Theory family

topic-avoidance

## Estimand

The average within-country association between a country-year's level of liberal democracy (v2x_libdem) and the share of that country-year's SSH articles whose abstracts critically examine own-country governance and institutions, conditional on country fixed effects, year fixed effects, and standard economic controls.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Construction:** For each abstract in the stratified sample, an LLM assigns one of three labels: (1) critically examines own-country governance/institutions, (2) discusses own country but not critically, (3) does not focus on own country. The outcome is the share of classified articles receiving label (1), computed per country-year and denoted `share_critical_domestic`. This is a proportion variable bounded [0, 1].

The outcome is constructed from the `abstract` and `iso3` fields. The "own country" reference for each abstract is the author's country identified by `iso3`.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance.

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost model from Anthropic API) or GPT-4o-mini as alternative.

**Prompt design:** Each API call passes (a) the article abstract and (b) the author's country name (derived from `iso3`) and asks for a single-label classification. The prompt is reproduced in full in `analysis_plan.md`.

**Label scheme:**
- Label 1: "CRITICAL-DOMESTIC" — the abstract critically examines, evaluates, or critiques the governance, political institutions, policies, or political processes of [country name]. "Critical" requires that the article not merely describe or study these institutions but evaluates their performance, failures, accountability deficits, or democratic/rule-of-law shortcomings.
- Label 2: "NEUTRAL-DOMESTIC" — the abstract discusses [country name] as a case or context but in a neutral, descriptive, or comparative manner without critical evaluation of institutions or governance.
- Label 3: "NOT-DOMESTIC" — the abstract does not primarily focus on [country name]; it may be comparative, theoretical, or focused on another country.

**Ambiguous cases:** The prompt instructs the model to output a single label only (no explanations), to default to Label 2 if the framing is mixed or unclear, and to use Label 3 if the country is mentioned only incidentally (e.g., as one case among many in a comparative study). The Analyst will validate classification quality by manually reviewing a random sample of 50 abstracts per label.

**Handling non-English abstracts:** The LLM can handle multilingual text. The prompt instructs the model to classify based on content regardless of language.

## Sampling strategy

To manage API cost, classification is performed on a stratified random sample rather than the full corpus:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 articles per stratum (fewer if stratum is smaller)
- **Estimated total N:** ~7,000–10,000 abstracts (depending on stratum coverage)
- **Cost estimate:** ~$0.001–0.002 per abstract for Claude Haiku → ~$7–20 total
- **Scaling to country-year:** Country-year shares are computed from the sampled articles; a weighted estimator adjusts for unequal sampling rates across strata. Country-years with fewer than 5 sampled abstracts are excluded from regression analysis.
- **Restriction:** Only articles with non-missing abstracts of at least 50 characters are eligible for sampling. All SSH fields are included (not restricted to political science), as governance critique appears across disciplines.

## Uniqueness check

Performed. Most similar existing team: Team 04 (regime-sensitive keyword prevalence: democracy, human rights, corruption, protest — regex on title + keywords).

Distinction: Team 04 detects the presence of politically sensitive vocabulary via regex but cannot determine whether the article is critically evaluating the author's own country's institutions, which requires semantic understanding of the abstract's framing relative to a country reference — a judgment that LLM classification is designed to handle.



ewpage

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
The average treatment effect of a unit increase in liberal democracy (v2x_libdem) on the mean pairwise cosine distance of abstract embeddings within country-field-year cells, aggregated to the country-year level, conditional on country and year fixed effects.

## Unit of analysis
Country-year (aggregated from country × subject_primary × year cells; each cell requires ≥ 5 articles with non-missing abstracts).

## Outcome variable
`mean_semantic_diversity`: the mean pairwise cosine distance of text-embedding vectors across all article pairs within a country × subject_primary × year cell, averaged across cells within a country-year (weighted by cell size). Higher values indicate greater semantic spread; lower values indicate convergence.

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



ewpage

# Team 07 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish SSH articles that acknowledge international funding agencies at lower rates, compared to researchers from more democratic countries?

## Rationale

Receiving funding from international agencies — such as the US National Science Foundation, the European Research Council, the World Bank, the Ford Foundation, or bilateral aid bodies — involves agreeing to donor norms, submitting to external review, and producing work that is visible to international audiences. Autocratic regimes may view this cross-border funding relationship as threatening, and researchers aware of this may self-select out of such arrangements or be blocked from accessing them. If this mechanism operates at scale, the share of a country-year's SSH output that acknowledges international funding should be systematically lower in more autocratic settings.

## Theoretical mechanism

Autocratic rulers are threatened by research networks that originate outside their control: international funding creates accountability relationships to foreign institutions, imposes liberal norms around academic freedom and open publication, and can facilitate the production of research on politically sensitive topics (governance quality, human rights, protest) that might not otherwise be funded domestically. Researchers in autocracies therefore face two compounding pressures: (1) they anticipate that seeking or accepting international funding will attract state scrutiny and career risk, and (2) autocratic governments may directly restrict foreign-funded research through registration requirements, permit denials, or the stigmatization of foreign-funded NGOs and universities. Both mechanisms produce the same observable pattern: the share of articles acknowledging international funding should be monotonically lower in more autocratic country-years. The expected direction of the main coefficient is positive: higher `v2x_libdem` is associated with a higher share of internationally funded articles.

## Theory family

topic-avoidance

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles that acknowledge at least one international funding agency, conditional on country and year fixed effects and standard economic controls.

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



ewpage

# Team 08 — Research Question

## Research question

Do researchers affiliated with more autocratic countries produce SSH abstracts with higher rates of epistemic hedging language — as measured by the frequency of hedging terms (may, might, seem, appear, suggest, perhaps, possibly, likely, probably, could, would) normalised by abstract word count — compared to researchers in more democratic countries?

## Rationale

Researchers working under autocratic constraints face institutional incentives not only to avoid politically sensitive topics outright, but also to hedge and soften any claims they do make, deflecting regime scrutiny by rendering findings provisional rather than declarative. If self-censorship operates through rhetorical defensiveness, the language of published abstracts in autocratic contexts should systematically exhibit more hedged epistemic commitments than comparable output from democratic settings. Epistemic hedging is detectable at scale without any external API using a closed dictionary of modal and evidential markers, making it a tractable and reproducible operationalization.

## Theoretical mechanism

Researchers in autocracies anticipate reputational and career sanctions — grant denial, employment loss, harassment, or legal exposure — for work that is interpreted as making confident, politically contestable claims. The self-protective response is not only to avoid sensitive topics but also to weaken the epistemic force of assertions, deploying modal hedges ("may suggest," "could appear," "might indicate") to signal that findings are tentative and non-threatening rather than authoritative and politically actionable. This defensive framing strategy should be most pronounced under more autocratic conditions, where the penalty for asserting inconvenient truths is highest. The expected direction of the main coefficient is negative: higher `v2x_libdem` (more democracy) is associated with lower hedging rates per abstract word, because democratic researchers face fewer incentives to soften their epistemic commitments rhetorically.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean hedging rate per abstract word, conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article carrying a non-missing abstract in the corpus).

## Outcome variable

`hedge_rate_mean`: constructed at the article level as the count of hedging-term tokens divided by total word count of the abstract, then aggregated to the country-year mean. Formally:

1. For each article with a non-missing abstract, compute `hedge_count` = `str_count(tolower(abstract), "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would)\\b")`.
2. Compute `word_count` = `str_count(abstract, "\\w+")`.
3. Compute article-level `hedge_rate` = `hedge_count / word_count`. Articles with `word_count < 20` are excluded (too short for a stable rate).
4. Aggregate to country-year: `hedge_rate_mean` = arithmetic mean of `hedge_rate` across all qualifying articles in that country-year.

The denominator normalisation ensures that the outcome reflects the *intensity* of hedging language per word, not the absolute count, and is therefore comparable across abstracts of different lengths.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, 0–1, continuous; higher = more democratic).

## Uniqueness check

Performed. Teams 01–06 have rq.md files; teams 07, 09, and 11 do not yet exist.

- **Teams 01–04** (topic-avoidance family): all measure *what* topics or keywords appear — political content index, keyword entropy, sensitive disciplinary share, or regime-sensitive term prevalence in titles/keywords. None measure *how* claims are linguistically hedged.
- **Team 05** (LLM critical-framing classification): classifies whether an abstract critically evaluates domestic governance. This captures *framing direction*, not *epistemic hedging intensity*.
- **Team 06** (semantic diversity via embeddings): measures convergence in semantic content across abstracts. Conceptually related to framing but uses dense continuous embeddings rather than a targeted hedging dictionary.
- **Teams 09 and 11** (normative language; argumentative stance): not yet specified, but per the orchestra assignment these concern normative vocabulary and stance respectively — distinct in that normative language measures value-laden terminology (Team 09) and argumentative stance measures assertive/critical orientation (Team 11), while Team 08 specifically targets epistemic uncertainty markers that soften factual claims regardless of their political valence.

**Distinction summary:** Team 08 is the only team measuring the linguistic hedging of epistemic commitment as a defensive framing strategy, operationalised via a closed dictionary of modal and evidential hedging markers normalised by abstract length — requiring no API, no embedding, and no semantic classification.



ewpage

# Team 09 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use normative and prescriptive language — terms such as "rights," "justice," "freedom," and "accountability" — at a lower rate in their SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that scholars in autocracies strategically minimise language that could be read as a political or moral claim against the regime. Normative vocabulary — terms that assert what ought to be or that invoke universal values such as human rights, justice, and freedom — is especially exposed because it signals evaluative intent that autocratic authorities may interpret as implicit criticism. If this mechanism operates, we should observe that the density of normative terms per abstract word is systematically lower in more autocratic country-years, even after controlling for economic development, population, and stable country and year characteristics.

## Theoretical mechanism

Researchers operating under authoritarian rule face credible career risks — dismissal, loss of funding, publication bans, or in extreme cases legal consequences — if their work is perceived as making normative claims against the state. Normative vocabulary (words like "should," "ought," "rights," "justice," "freedom," "accountability," "dignity," "equality," "fairness," "liberty") is particularly hazardous because it frames social and political arrangements as unjust or illegitimate, even when embedded in otherwise descriptive academic prose. Anticipating this risk, rational authors self-censor by omitting or replacing normative terms with descriptive substitutes — writing, for example, "the state controls" rather than "the state should be accountable." This avoidance is distinct from epistemic hedging (avoidance of uncertainty language) and from topic avoidance (choosing not to study democracy or rights at all): an author may study political institutions in entirely empirical terms while systematically stripping normative framings. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher normative term rate per abstract word.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean normative term rate per abstract word, conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least one SSH article with a non-missing abstract).

## Outcome variable

`mean_norm_rate`: constructed as follows.

1. For each article with a non-missing abstract, compute:
   - `norm_count` = count of case-insensitive whole-word matches in the abstract for the normative term dictionary (see analysis_plan.md for the full dictionary).
   - `word_count` = total word count of the abstract (all whitespace-delimited tokens).
   - `norm_rate` = `norm_count / word_count` (set to NA if `word_count == 0`).
2. Aggregate to country-year: `mean_norm_rate = mean(norm_rate, na.rm = TRUE)` across all articles from the same `iso3` × `year` cell.

The outcome is a continuous variable bounded in [0, 1]; typical values are in the range 0.005–0.030 based on exploratory analysis of the specified dictionary.

**Normative term dictionary (core set):**

| Cluster | Terms |
|---|---|
| Obligation / prescription | should, ought |
| Rights | rights |
| Justice | justice, fairness |
| Freedom / liberty | freedom, liberty |
| Equality / dignity | equality, dignity |
| Accountability | accountability |
| Democracy (normative use) | democracy |

Full regex patterns (word-boundary anchored, case-insensitive) are defined in `analysis_plan.md`.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic). Use as the primary regime measure.

## Uniqueness check

Performed. Existing rq.md files inspected: teams 01–07 (team 08 has no rq.md at time of writing).

**Distinction from most similar teams:**

- **Team 01 (PCI score on abstracts):** Team 01 constructs a Political-Content Index measuring the share of abstract tokens matching a broad multi-cluster dictionary of politically sensitive topic terms (democracy, repression, governance, protest, elections). Team 09 measures normative/prescriptive language — terms that assert value judgments or obligations — not political topic terms. A paper about electoral autocracy that uses entirely empirical, descriptive language scores high on Team 01's PCI but zero on Team 09's normative rate; conversely, an economics paper arguing what policy "should" achieve scores zero on PCI but positive on Team 09.
- **Team 04 (regime-sensitive keywords in title/keywords):** Team 04 detects politically sensitive topic vocabulary in title and author-keyword fields; Team 09 measures evaluative-prescriptive vocabulary in the abstract body. Distinct text field, distinct vocabulary, distinct theoretical mechanism (framing avoidance vs. topic avoidance).
- **Team 05 (LLM classification of critical domestic framing):** Team 05 classifies whether abstracts critically evaluate own-country governance — a semantic judgment about the target and stance of critique. Team 09 uses a transparent dictionary count with no LLM and does not require a domestic-country reference.
- **Team 06 (semantic diversity via embeddings):** Team 06 measures holistic semantic convergence via cosine distance of dense embeddings; Team 09 measures the surface-form rate of a specific vocabulary class.
- **Team 08 (epistemic hedging — uncertainty language):** Team 08's domain (assigned but not yet filed) is uncertainty/hedging language (e.g., "may," "might," "perhaps," "appears to") — words that soften epistemic claims. Team 09 targets normative/prescriptive language — words that assert value claims or obligations. These are conceptually orthogonal dimensions: a sentence can hedge normatively ("these policies may undermine rights") or state empirical claims without hedging ("the policy reduced freedom"). The expected direction under self-censorship theory is also different: epistemic hedging could plausibly increase or decrease under autocracy depending on the mechanism invoked, while normative avoidance has a clear downward prediction.



ewpage

# Team 10 — Research Question

## Research question

Does higher authoritarianism increase the share of SSH article abstracts that use exclusively technical, methodological, or administrative vocabulary with no political references, as classified by a large language model?

## Rationale

Self-censorship theory predicts that researchers in autocracies will actively reframe their work to minimize the risk of regime scrutiny — not only by avoiding sensitive topics altogether, but by stripping politically referential language from work they do publish, presenting it instead in purely technical or administrative terms. Technocratic framing is a lower-cost adaptation than topic abandonment: the researcher retains the research but sanitizes its presentation. If this mechanism is widespread, autocratic country-years should exhibit a systematically higher share of abstracts that are purely technocratic in vocabulary and carry no political signal.

## Theoretical mechanism

Researchers in autocracies face institutional incentives — denial of employment, grant funding, or publication access, or in extreme cases legal sanction — when their published work is perceived as politically relevant or threatening to the regime. Even when a researcher's underlying question has political implications, they can reduce their exposure by presenting findings in vocabulary that invokes only technical processes, measurement instruments, statistical methods, or administrative categories, without ever naming political actors, outcomes, institutions, or values. This strategic adoption of technocratic framing makes the abstract appear politically inert to regime surveillance, thereby lowering the personal cost of publication. The expected direction is positive: higher authoritarianism (lower `v2x_libdem`) is associated with a higher share of technocratically framed abstracts, as researchers systematically adopt neutral, apolitical language as a survival strategy.

## Theory family

`framing-neutrality`

## Estimand

The average within-country association between a country-year's level of liberal democracy (`v2x_libdem`) and the share of that country-year's SSH abstracts classified as TECHNOCRATIC (exclusively technical/methodological/administrative vocabulary, no political references), conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM binary classifications to the country-year level.

## Outcome variable

**`share_technocratic`**: For each abstract in the stratified sample, an LLM assigns one of two labels — TECHNOCRATIC or NOT-TECHNOCRATIC (see LLM classification specification below). The outcome is the share of classified articles receiving the TECHNOCRATIC label, computed per country-year. This is a proportion bounded [0, 1], constructed from the `abstract` field and aggregated using the `iso3` and `year` fields.

Country-years with fewer than 5 sampled and classified abstracts are excluded from regression analysis.

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model); GPT-4o-mini as fallback.

**Task:** Binary classification of each abstract into TECHNOCRATIC or NOT-TECHNOCRATIC.

**Full classification prompt (to be used verbatim in analysis.R):**

```
You are a scientific text classifier. Your task is to classify the following article abstract according to whether it uses exclusively technical, methodological, or administrative vocabulary — with no political references of any kind — or whether it contains at least some political vocabulary.

TECHNOCRATIC means ALL of the following are true:
1. The abstract uses only technical, statistical, methodological, scientific, or administrative terminology.
2. The abstract contains NO references to political actors (e.g., governments, parties, leaders, regimes, states as political entities), political processes (e.g., elections, democratization, governance quality, repression, protest, civil society), political values (e.g., democracy, freedom, human rights, civil liberties, accountability), or politically charged social categories (e.g., ethnic conflict, political prisoners, political opposition).
3. The framing is purely about data, methods, measurement, technical processes, or administrative/managerial outcomes.

NOT-TECHNOCRATIC means AT LEAST ONE of the following is true:
1. The abstract mentions any political actor, institution, process, or outcome.
2. The abstract uses vocabulary that signals a political frame, even if the core methodology is technical (e.g., a study of "protest event detection using machine learning" is NOT-TECHNOCRATIC because it explicitly references protest).
3. The abstract evaluates or discusses governance, state capacity, policy effectiveness, or similar politically loaded concepts.

Instructions:
- Output only the label: TECHNOCRATIC or NOT-TECHNOCRATIC. No explanation.
- If the abstract is borderline, default to NOT-TECHNOCRATIC.
- If the abstract is very short (fewer than 20 words), classify based on what is present, not what is absent.
- Language: classify based on content regardless of the abstract's language.

Abstract:
[ABSTRACT TEXT]
```

**Label scheme:**
- `TECHNOCRATIC` — exclusively technical/methodological/administrative vocabulary, zero political references
- `NOT-TECHNOCRATIC` — contains at least one political reference, actor, institution, process, or politically framed concept

**Handling ambiguous cases:** The prompt instructs the model to default to NOT-TECHNOCRATIC in borderline cases, creating a conservative classifier that minimizes false positives for technocratic framing. The Analyst will validate classification quality by manually reviewing a random sample of 50 abstracts per label after classification.

## Sampling strategy

API cost is managed through stratified random sampling:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 abstracts per stratum (fewer if the stratum is smaller)
- **Eligibility:** articles with non-missing abstracts of at least 50 characters; all SSH fields included
- **Estimated total N:** ~7,000–8,000 abstracts (depending on stratum coverage)
- **Estimated cost:** ~$0.001–0.002 per abstract for Claude Haiku → ~$8–10 total
- **Aggregation:** country-year `share_technocratic` is computed from sampled articles; a weighted estimator adjusts for unequal sampling rates. Country-years with fewer than 5 classified abstracts are excluded from regression.

## Key independent variable

`v2x_libdem` — V-Dem Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance.

## Uniqueness check

Performed. Existing teams with completed rq.md files: Teams 01–07.

Most similar team: **Team 05** (critical domestic governance framing — LLM classifying whether abstracts critically examine the author's own country's institutions).

Distinction from Team 05: Team 05 asks whether an abstract *critiques own-country institutions* — a question about the target and evaluative stance of an article toward a specific national context. Team 10 asks a categorically different question: whether an abstract uses *any political vocabulary at all*, regardless of country focus, evaluative direction, or whether the author's own country is mentioned. A comparative study of democratization in twenty countries would be NOT-TECHNOCRATIC for Team 10 (political vocabulary present) but NOT-DOMESTIC for Team 05 (does not focus on own country). A purely methods paper on survey design contains no political reference and is therefore TECHNOCRATIC for Team 10, while it would be NOT-DOMESTIC for Team 05. The two constructs are orthogonal.

Distinction from Team 01: Team 01 constructs a continuous Political Content Index (PCI) score based on the share of abstract word tokens matching a political-content dictionary; Team 10 uses LLM binary classification to identify abstracts with *zero* political reference of any kind. The PCI captures degree of political content; Team 10 captures the presence or absence of a political register in the full semantic sense, including framings and usages that would not be captured by a fixed-vocabulary dictionary.

Distinction from Team 04: Team 04 detects regime-sensitive terms (democracy, human rights, corruption, protest) via regex on titles and author keywords. Team 10 uses LLM classification of full abstract text to detect the complete absence of political vocabulary — a holistic semantic judgment about framing that a regex approach cannot make.

No other existing team measures the technocratic/apolitical framing dimension using LLM classification of full abstract text.



ewpage

# Team 11 — Research Question

## Research question

Do researchers affiliated with more autocratic countries use first-person argumentative stance phrases — such as "we argue," "I argue," "we show," or "we demonstrate" — at lower rates in SSH article abstracts, compared to researchers from more democratic countries?

## Rationale

Making an explicit attributed claim in academic writing ("we argue that X") exposes the author as the source of an assertion, increasing personal accountability for the content of a paper. In autocratic settings, where the costs of being identified as the author of politically problematic arguments are non-trivial, researchers have an incentive to avoid constructions that anchor claims directly to their own authorial voice. An observable symptom of this risk-management strategy is a reduced rate of first-person argumentative stance phrases in published abstracts, as researchers substitute passive, impersonal, or institutional constructions ("it is found that," "the results suggest," "this paper examines") that diffuse accountability.

## Theoretical mechanism

In autocracies, the personal attribution of intellectual claims generates career risk: a researcher who writes "we argue that the state is responsible for X" has publicly staked a position that can be scrutinized, quoted, and used against them by regime actors, employers, or colleagues acting as informants. Researchers anticipate this risk and learn — through direct experience or social observation — to write in ways that reduce personal exposure, which includes replacing first-person argumentative constructions with impersonal or passive voice equivalents that are harder to attribute to the author's own convictions. This defensive rhetorical strategy would be practiced selectively and rationally: researchers in sensitive fields or under more repressive regimes would depress their argumentative stance rate more than researchers in safe contexts. The expected direction is positive: higher `v2x_libdem` → higher mean argumentative-stance phrase rate per abstract word, because democratic environments reduce the cost of explicit personal attribution.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean argumentative-stance phrase rate (stance phrase count per abstract word), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year

## Outcome variable

`stance_rate_mean`: constructed at the article level as the count of matches to the stance-phrase regex divided by the abstract word count (producing a rate bounded [0, ∞)); then averaged across all articles with non-missing abstracts within each country-year. Construction steps:

1. Lowercase the `abstract` field.
2. Count matches of the following regex pattern (all boundaries are word-level):
   `\b(we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim)\b`
3. Count abstract words as the number of whitespace-delimited tokens (`\w+` matches).
4. Compute `stance_rate = n_matches / n_words` for each article. Articles with fewer than 20 words or missing abstracts are excluded.
5. Aggregate to country-year: `stance_rate_mean = mean(stance_rate, na.rm = TRUE)`, restricted to country-years with at least 5 qualifying articles.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. rq.md files exist for teams 01–06; teams 07–10 have no rq.md files at time of writing. The brief for this project specifies that Team 08 covers **hedging** (epistemic uncertainty softeners such as "may," "might," "possibly") and Team 09 covers **normative language** (evaluative and prescriptive phrasing).

Team 11 is distinct on all three dimensions:

- **Versus Teams 01, 02, 04 (topic-avoidance family):** Those teams measure what researchers write *about* (political keywords, sensitive topics, disciplinary field); Team 11 measures *how* researchers write — the rhetorical stance adopted toward their own claims, not the content of those claims.
- **Versus Team 08 (hedging):** Hedging measures epistemic diffidence — the softening of truth claims through modal verbs and uncertainty markers. Team 11 measures argumentative assertion — the explicit attribution of a conclusion to the authors' own reasoning. These are complementary and can move in the same or opposite directions; they tap different self-censorship mechanisms (reducing exposure to uncertainty vs. reducing personal accountability for claims).
- **Versus Team 09 (normative language):** Normative language covers evaluative judgment ("should," "ought," "it is important that"), which is thematically distinct from the first-person argumentative framing targeted here. A paper can be normative without using first-person assertions, and vice versa.
- **No overlap with Teams 03, 05, 06:** These measure disciplinary composition, LLM-classified governance critique, and semantic diversity of embeddings, respectively — all structurally different from a regex count of first-person stance phrases.



ewpage

# Team 12 — Research Question

## Research question

Do researchers affiliated with more autocratic countries produce SSH abstracts that end with an explicit normative or policy conclusion — a recommendation, "should" claim, or call to action — at a lower rate than researchers from more democratic countries?

## Rationale

Self-censorship theory predicts that researchers under autocratic constraints avoid signaling political engagement. Making an explicit normative or policy conclusion is one of the most legible signals of political engagement available in academic writing: it tells readers, censors, and employers not only what the researcher found, but what the researcher thinks should be done about it. Researchers who anticipate political scrutiny should therefore systematically strip normative conclusions from their published work, presenting findings descriptively even when the implications would warrant a recommendation. Because normative conclusions are concentrated in the final sentence(s) of an abstract — where authors conventionally summarize implications — this signal is detectable with high precision from abstract text using LLM classification.

## Theoretical mechanism

In autocracies, the act of recommending a policy or asserting that an outcome "should" change is potentially more dangerous than the underlying empirical finding, because it constitutes a public political position attributable to the researcher. Regime actors, institutional gatekeepers, and self-appointed informants scan academic output for precisely this kind of normative exposure; a researcher who concludes "the government should reform X" has staked a position that can be quoted, reported, and used to deny grants, block promotions, or trigger legal consequences. Anticipating these risks, researchers in autocratic settings learn to end their abstracts with factual summaries or statements of contribution rather than normative conclusions, substituting constructions such as "our findings suggest that X affects Y" for "policymakers should consider Z." This behavioral adaptation is selective and tractable: researchers do not need to suppress the entire research agenda — they need only to trim the final normative step from their public presentation. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher country-year share of abstracts that end with an explicit normative or policy conclusion.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH abstracts classified as ending with an explicit normative or policy conclusion, conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per `iso3` × `year` combination, restricted to country-years with at least 5 sampled abstracts with non-missing text).

## Outcome variable

`share_normative_conclusion`: the proportion of classified abstracts in a country-year stratum that receive the label NORMATIVE (see LLM classification specification below), computed as:

```
share_normative_conclusion = (# abstracts labelled NORMATIVE) / (# abstracts successfully classified)
```

Construction steps:

1. Draw a stratified random sample from the corpus (see Sampling strategy).
2. For each sampled abstract, extract the last two sentences using a sentence-boundary regex or `str_extract(abstract, "[^.!?]+[.!?]\\s*[^.!?]+[.!?]?\\s*$")`.
3. Submit the extracted text to the LLM classifier (see prompt below); record the returned label.
4. Aggregate to country-year: `share_normative_conclusion = mean(label == "NORMATIVE", na.rm = TRUE)`.
5. Exclude country-years with fewer than 5 successfully classified abstracts.

The outcome is a proportion bounded [0, 1].

## LLM classification specification

**Model:** `claude-haiku-4-5` (Anthropic API, low-cost tier) or `claude-haiku-3-5` as fallback; alternatively `gpt-4o-mini` if Anthropic API is unavailable.

**Input:** The last two sentences of the abstract (extracted as described above). If sentence extraction fails (e.g., abstract has only one sentence), use the full abstract.

**Full prompt (verbatim — use exactly this in the API call):**

```
You are a scientific text classifier. Read the following excerpt from the end of an academic abstract in the social sciences or humanities.

Classify this excerpt using EXACTLY ONE of the following labels:

NORMATIVE — The excerpt contains an explicit normative or policy conclusion: a recommendation, a "should" or "ought" claim, a call to action, a statement that a policy should be adopted or reformed, or a judgment that a particular outcome is desirable or undesirable. Examples: "Governments should invest in X", "We recommend that policymakers adopt Y", "These findings suggest that Z ought to be reformed", "Our results have implications for improving W".

DESCRIPTIVE — The excerpt does not make any normative or policy recommendation. It summarizes empirical findings, states the contribution of the paper, identifies limitations, suggests future research directions, or presents implications in factual terms without prescribing what should be done. Examples: "Our results show that X predicts Y", "This paper contributes to the literature on Z", "Future research should examine W" (a research-process suggestion, not a policy claim).

Output ONLY the label (NORMATIVE or DESCRIPTIVE). Do not add any explanation, punctuation, or other text.

Abstract excerpt:
{ABSTRACT_EXCERPT}
```

**Ambiguous cases:** If the excerpt is entirely missing, garbled, or in a non-standard script that yields no classifiable content, the API call should be skipped and the abstract flagged as `NA` (excluded from the denominator). The prompt instructs the model to output a single label with no explanation; any response that does not match "NORMATIVE" or "DESCRIPTIVE" exactly is treated as `NA`.

**Label scheme:**
- `NORMATIVE`: abstract concludes with an explicit normative or policy claim
- `DESCRIPTIVE`: abstract concludes descriptively, without normative prescription

**Note:** Research-process recommendations ("future research should examine X") are coded DESCRIPTIVE, not NORMATIVE, because they make no claim about what policymakers, governments, or society should do — they are methodological calls to action addressed to the scientific community. The prompt specifies this explicitly.

**Language:** LLMs handle multilingual input adequately for this binary distinction; no language restriction is applied.

## Sampling strategy

To manage API cost, classification is performed on a stratified random sample:

- **Stratification:** `iso3` × `v2x_regime` (4-category V-Dem typology) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020–2023)
- **Target per stratum:** up to 10 abstracts (fewer if stratum is smaller)
- **Minimum abstract length:** 50 characters; abstracts shorter than this are excluded before sampling
- **Estimated total N:** ~7,000–8,000 abstracts (depending on stratum coverage)
- **Cost estimate:** ~$0.001–0.002 per abstract at Claude Haiku pricing → estimated total cost **$8–16**
- **Deduplication:** sample on unique abstracts (by `wos_id`) before API submission

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 10 (based on Glob search), 11 (confirmed). Team 09 has no rq.md at the time of writing; per Team 11's uniqueness note, Team 09's domain is **normative language frequency** — a rate/count measure of evaluative and prescriptive vocabulary (e.g., "should", "ought") appearing anywhere in the abstract.

**Team 12 is distinct from Team 09 on three dimensions:**

1. **Operationalization:** Team 09 measures how *much* normative vocabulary appears throughout the abstract (a continuous rate, likely computed via regex count/word count). Team 12 classifies whether the abstract *concludes with* an explicit normative or policy recommendation — a binary classification of the abstract's rhetorical endpoint, not an aggregate vocabulary count. A paper can use high normative vocabulary in the body of the abstract while ending descriptively; Team 12 captures the strategic suppression of the normative endpoint specifically.

2. **Measurement method:** Team 09 uses a dictionary/regex approach (no API required). Team 12 uses LLM binary classification, which can distinguish a genuine policy recommendation from incidental normative vocabulary (e.g., "this is an important issue") or research-process recommendations ("future studies should examine X") that Team 09's regex would count but Team 12 does not.

3. **Theoretical mechanism:** Team 09's mechanism concerns general normative vocabulary avoidance throughout the text. Team 12's mechanism targets the *conclusory normative step* — the act of publicly prescribing what should be done — as a distinct act of political signaling that is concentrated in the final sentence(s) of an abstract and subject to its own strategic suppression logic.

**Distinction from Team 05 (LLM critical framing):** Team 05 classifies whether an abstract *critically examines domestic governance*; this is a topic/framing judgment about what the article is about. Team 12 classifies whether the abstract *ends with a normative prescription*; this is a rhetorical-endpoint judgment independent of topic. An article can critically examine governance without prescribing anything, and can prescribe policy in a purely technical domain.

**Distinction from Teams 08 and 11:** Team 08 measures epistemic hedging (softening of truth claims via modal verbs). Team 11 measures first-person argumentative stance phrases ("we argue", "we show"). Neither captures the presence or absence of a normative conclusion in the abstract's final sentences.



ewpage

# Team 13 — Research Question

## Research question

Do researchers affiliated with more autocratic countries publish a higher share of their SSH output in domestically dominated journals — journals where the majority of authors are from the same country — compared to researchers from more democratic countries?

## Rationale

Publishing in an international journal subjects a paper to editorial standards, reviewer networks, and professional norms anchored in liberal academic culture; publishing in a domestically dominated journal places the work in a locally controlled institutional environment where regime-aligned editorial gatekeepers have greater influence. If researchers in autocracies self-censor by selecting publication venues that reduce exposure to external scrutiny and liberal editorial norms, we should observe that autocratic country-years exhibit a systematically higher share of SSH output in journals dominated by authors from the same country. This prediction is observable from the corpus alone — no external journal registry is required.

## Theoretical mechanism

In autocratic settings, researchers and their institutions anticipate that publishing in internationally edited journals increases exposure to external evaluation: foreign reviewers and editors may flag politically sensitive findings, require comparative or regime-critical framings, or simply impose norms of academic freedom that are incompatible with state preferences. To minimize this exposure, researchers rationally prefer publication venues where editorial control is domestic — where local institutions aligned with the regime influence acceptance decisions and where the readership remains largely insulated from international academic debate. At the country-year level, this risk-minimization strategy should produce a measurably higher share of publications in domestically dominated journals under autocracy. The expected direction is negative: higher `v2x_libdem` is associated with a lower share of publications in domestic journals, because democratic environments remove the political cost of engaging with international editorial scrutiny.

## Theory family

`framing-neutrality`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year share of SSH articles published in journals classified as domestically dominated (where the focal country contributes >60% of all articles in that journal across the full corpus), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per `iso3` × `year`, restricted to country-years with at least 5 SSH articles).

## Outcome variable

`share_domestic_journal`: the proportion of a country-year's SSH articles that appear in a journal classified as domestically dominated by that country. Construction:

1. Using the full corpus, for each journal (`journal` column), count the total number of article-country rows per country (iso3). Compute each country's share of total article-country rows for that journal across all years.
2. A journal is classified as **domestic to country X** if country X contributes strictly more than 60% of the journal's total article-country rows in the corpus. A journal may be domestic to at most one country under this rule (since 60% > 0.5, mutual domination is impossible).
3. A journal that does not exceed the 60% threshold for any single country is classified as **international**.
4. For each article in the corpus, assign the binary indicator `is_domestic = 1` if the journal is domestic to the author's `iso3`, else 0.
5. Aggregate to country-year: `share_domestic_journal = sum(is_domestic) / n_articles_country_year`.

The outcome is a proportion bounded in [0, 1].

**Note on large-country bias:** Large SSH producers (USA, UK, China) will mechanically have higher counts in many journals. Controlling for log population (`log_pop`) in the regression partially absorbs this. An additional robustness specification restricts the sample to country-years with `n_articles_country_year` below the 75th percentile (i.e., small and medium producers), where the mechanically-domestic effect is weaker.

## Key independent variable

`v2x_libdem` (V-DEM Liberal Democracy Index, continuous 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 10, 11, and 15 at time of writing.

Team 13 is distinct from all existing teams on two dimensions:

- **Outcome dimension:** No other team uses journal venue choice as the outcome. The closest structural analogues are Team 15 (co-authorship with liberal democracies) and Team 16 (domestic-only authorship). Team 15 measures the regime composition of co-author countries; Team 16 measures whether all authors are from a single country. Team 13 measures a publication venue choice — whether the journal itself is controlled by a domestic author community — which is conceptually and operationally separate: a paper can have exclusively domestic authors (Team 16 = 1) but appear in an international journal (Team 13 = 0), or vice versa.

- **Theoretical mechanism:** Teams 08, 09, 10, 11 in the `framing-neutrality` family all concern the rhetorical or semantic content of what researchers write. Team 13 concerns where they choose to publish — a strategic selection of institutional venue that reflects anticipated editorial scrutiny, not a linguistic framing decision. The channel is editorial gatekeeping under domestic control, not abstract or title wording.

- **No external API required:** The journal-country classification is constructed entirely from the corpus using a count-based threshold, consistent with the Medium complexity rating.



ewpage

# Team 14 — Research Question

## Research question

Do researchers affiliated with more autocratic countries co-author SSH publications with a smaller number of distinct co-author countries, compared to researchers from more democratic countries?

## Rationale

International collaboration in research is not politically neutral: maintaining professional contacts abroad, exchanging manuscripts across borders, and attending international conferences all expose researchers to cross-border oversight and potential regime scrutiny. In autocratic settings, these activities carry formal and informal risks — including surveillance of foreign contacts, career penalties for politically inconvenient international associations, and restricted travel. If these constraints suppress researchers' capacity or willingness to engage in broad international collaboration, the most direct observable implication is a reduction in the raw breadth of co-author country coverage: autocratic country-years should produce articles that draw co-authors from fewer distinct countries than comparable output from democratic settings.

## Theoretical mechanism

Autocratic regimes exercise control over researchers' international networks through multiple overlapping channels: exit visa requirements that limit conference attendance and research visits, formal registration or permit requirements for foreign-funded or foreign-linked research, and informal norms that stigmatize "entanglement" with foreign institutions, particularly those from liberal democracies. Researchers respond by self-censoring the range of their international collaborative contacts — concentrating links on a small number of politically safe partners (often neighbours or politically aligned states) and foregoing the wide-ranging international collaboration that characterises researchers in democratic contexts. At the country-year level, this produces a measurable contraction in the mean number of distinct co-author countries per article. The expected direction of the main coefficient is positive: higher `v2x_libdem` → higher mean number of distinct co-author countries per article.

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean count of distinct co-author countries per article (for articles with at least one author affiliated with the focal country), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per focal iso3 × year combination, restricted to country-years with at least 5 SSH articles in the corpus).

## Outcome variable

`mean_n_coauthor_countries`: constructed in two steps.

1. **Article level:** For each article (wos_id) in which the focal country (iso3_focal) appears, count the number of *distinct* iso3 values present among all author-country rows sharing that wos_id. This count equals 1 for single-country articles (the focal country alone) and > 1 for internationally co-authored articles.
2. **Country-year level:** Average the article-level distinct-country count across all articles where iso3_focal appears in focal year Y: `mean_n_coauthor_countries = mean(n_distinct_iso3)`, computed over all wos_ids associated with iso3_focal in year Y.

The outcome is a continuous count variable with a lower bound of 1 (articles can have no fewer than the focal country itself). Articles with missing iso3 values are excluded.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08, 11, and 15 at time of writing; no files found for teams 09–10, 12–13, or 16.

Team 14 occupies the `collaboration-constraint` sub-family alongside Team 15 and (per brief) Team 16. It is distinct from both:

- **Versus Team 15 (democratic co-authorship share):** Team 15 asks whether autocracies specifically avoid co-authors from liberal democracies (v2x_libdem > 0.5), measuring the ideological valence of co-author countries. Team 14 asks a prior, simpler question: does autocracy suppress the sheer number of distinct countries from which co-authors are drawn, regardless of those countries' regime type? The outcomes are conceptually orthogonal — a country could collaborate with many autocratic countries (high breadth, low democratic share) or concentrate links on a few liberal democracies (low breadth, high democratic share).
- **Versus Team 16 (domestic-only authorship):** Per the brief, Team 16 measures the share of articles with no international co-authors at all (binary domestic-only indicator). Team 14 measures the continuous spread of international co-authorship — not whether it occurs at all, but across how many distinct countries it extends.
- **Versus Teams 01–08, 11 (topic-avoidance and framing-neutrality families):** All of those teams measure textual content of articles (vocabulary, topics, hedging, stance, discipline). Team 14 measures co-authorship network structure — a relational, metadata-level outcome requiring no text analysis and no external API.



ewpage

# Team 15 — Research Question

## Research question

Do researchers in more autocratic countries co-author a lower share of their SSH publications with researchers from liberal democracies (countries with v2x_libdem > 0.5 in the co-author's country-year), compared to researchers in more democratic countries?

## Rationale

Collaboration with scholars in liberal democracies is not politically neutral for researchers in autocracies: democratic co-authors operate under editorial and professional norms that may encourage politically sensitive research agendas, and democratic-country affiliations may trigger regime suspicion toward the collaboration and its outputs. If the self-censorship mechanism extends to strategic avoidance of potentially risky collaborative relationships, we should observe that researchers in more autocratic settings systematically under-represent liberal democracies in their co-authorship networks. This prediction is more theoretically specific than a general reduction in international collaboration: it targets the ideological valence of co-author countries, not collaboration volume per se.

## Theoretical mechanism

Researchers in autocracies face institutional surveillance of their professional networks, and collaboration with scholars from liberal democracies may carry reputational or political costs — such as association with foreign "hostile" research agendas, exposure to cross-border academic freedom norms, or heightened scrutiny from university administrators and state security actors. Anticipating these risks, scholars in autocratic settings self-censor by selectively avoiding or limiting co-authorship links with researchers in liberal democracies, while more readily collaborating with authors from non-democratic or politically aligned countries. The expected direction is positive: higher `v2x_libdem` of the focal country is associated with a higher share of articles co-authored with at least one researcher from a country with `v2x_libdem > 0.5`, because democratic environments reduce the political costs of connecting to liberal-democratic scholarly networks.

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` (focal country) on the country-year share of SSH articles that include at least one co-author from a country with `v2x_libdem > 0.5` in the relevant year, conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per focal iso3 × year combination, restricted to country-years with at least 5 SSH articles in the corpus).

## Outcome variable

`share_dem_coauthor`: the proportion of distinct articles by authors affiliated with a focal country-year that have at least one co-author row (different iso3, same wos_id) where that co-author country's `v2x_libdem` in the same year exceeds 0.5. Formally:

1. For each article (wos_id) in the corpus, collect all author-country rows sharing that wos_id.
2. For a given focal country (iso3_focal), an article is a "democratic co-author article" if (a) iso3_focal appears among that article's rows and (b) at least one other iso3 in the same article has v2x_libdem > 0.5 in that article's year.
3. Articles where iso3_focal is the only author country (no co-authors at all) are retained as zeros in the numerator (they do not have a democratic co-author), ensuring the denominator equals the full output of the focal country-year.
4. Aggregate to country-year: `share_dem_coauthor = n_articles_with_dem_coauthor / n_articles_country_year`.

The outcome is a proportion bounded [0, 1].

## Key independent variable

`v2x_libdem` of the focal author country (continuous, 0–1; higher = more democratic).

## Uniqueness check

Performed. rq.md files exist for teams 01–08 and 11 at time of writing; no rq.md files found for teams 09–10 and 12–14.

The team most similar in domain is Team 14, which (per the brief) measures the raw count or share of co-author countries generally. Team 15 is distinct in the following respects:

- **Versus Team 14 (raw co-author country count / general international collaboration):** Team 14 tests whether autocracy suppresses the breadth of the co-authorship network regardless of co-author regime type. Team 15 tests a more theoretically specific prediction: that autocratic researchers selectively avoid collaboration with authors from *liberal democracies* specifically, because these connections carry distinct political costs. The outcome is not the overall collaboration rate but the ideological composition of the co-author network.
- **Versus Teams 01–04 (topic-avoidance family):** Those teams measure what topics, keywords, or disciplines researchers choose; Team 15 measures who they collaborate with — a structural network outcome, not a textual content outcome.
- **Versus Teams 05–06 (LLM classification, semantic diversity):** Both use text analysis of abstract content; Team 15 requires no text analysis and no external API — only a cross-join on the article × country row structure using existing `v2x_libdem` values.
- **Versus Teams 08 and 11 (hedging, argumentative stance):** Both measure rhetorical features of writing; Team 15 measures collaborative network structure.



ewpage

# Team 16 — Research Question

## Research question

Do researchers in more autocratic countries produce a higher share of SSH articles with exclusively domestic authorship — defined as articles where every contributing author is affiliated with the same country — compared to researchers in more democratic countries?

## Rationale

Self-censorship theory predicts that researchers in autocracies constrain their collaboration choices to minimize exposure to foreign oversight, documentation of foreign contacts, and the transmission of liberal academic norms. International co-authorship is a publicly traceable institutional tie that autocratic regimes can scrutinize; researchers who anticipate this scrutiny will avoid it by confining their collaborations to domestic partners. If this mechanism operates at scale, autocratic country-years should exhibit a systematically higher share of articles in which all authors are affiliated with the same country.

## Theoretical mechanism

In autocratic settings, researchers face career costs — dismissal, loss of funding, denial of travel permits, or harassment — for maintaining documented institutional relationships with foreign scholars, particularly those in liberal democracies. International co-authorship creates a paper trail of foreign contacts and exposes researchers to the norms, expectations, and potential political influence of foreign academic communities, all of which autocratic regimes may perceive as threatening. Anticipating these risks, researchers self-censor their collaboration strategies: they preferentially seek domestic co-authors, allow international collaborations to lapse, or avoid initiating them in the first place. The expected direction is negative: higher `v2x_libdem` is associated with a lower share of domestically-only authored articles, because greater political freedom removes the incentive to confine collaboration to domestic partners.

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the share of country-year SSH articles in which all author-country affiliations belong to the same country (domestic-only articles), conditional on country and year fixed effects and standard economic controls.

## Unit of analysis

Country-year (one observation per iso3 × year combination, restricted to country-years with at least one SSH article in the corpus).

## Outcome variable

`share_domestic_only`: constructed by (1) counting the number of distinct values of `iso3` per `wos_id` (i.e., distinct author-country affiliations per article); (2) flagging each article as `domestic_only = TRUE` if `n_distinct(iso3) == 1` for that `wos_id`; (3) aggregating to country-year: `share_domestic_only = (# domestic_only articles) / n_articles_country_year`. The outcome is a proportion bounded in [0, 1].

**Note on corpus structure:** The corpus contains one row per article × author-country combination. Each `wos_id` may therefore appear in multiple rows. Deduplication to the article level is performed before computing `n_articles_country_year` as the denominator to avoid double-counting.

## Key independent variable

`v2x_libdem` (V-Dem Liberal Democracy Index, continuous 0–1; higher = more democratic)

## Uniqueness check

Performed. rq.md files exist for Teams 01–08, 10, and 11 (Teams 09, 12–15 have no rq.md at time of writing). The most relevant comparisons within the `collaboration-constraint` sub-family are Teams 14 and 15, as described in the project design.

- **Team 14** (mean number of distinct co-author countries per article, continuous): Team 14 measures the *degree* of international collaboration on a continuous scale — a country-year with many articles involving 2–3 foreign countries will score differently from one dominated by bilateral collaborations. Team 16 uses a binary indicator (any international co-author present vs. not) that captures the *extensive margin* — the decision to engage in any cross-border co-authorship at all — rather than the depth of collaboration. A country that systematically avoids international co-authorship will produce a high `share_domestic_only` even if its few internationally co-authored articles involve many partner countries.
- **Team 15** (share of articles with at least one co-author from a liberal democracy, v2x_libdem > 0.5): Team 15 identifies co-authorship links to specifically democratic partners and asks whether autocracies avoid those particular collaborations. Team 16 asks a more fundamental prior question: do autocracies avoid *any* international collaboration, regardless of the political character of the partner country? The two outcomes can diverge — a country could co-author with other autocracies without ever co-authoring with democracies, registering a low domestic-only share (Team 16) but a low democracy-collaboration rate (Team 15).
- **Teams 01–11** (topic-avoidance and framing-neutrality families): all are conceptually distinct — they measure what researchers write about or how they write, not with whom they collaborate.



ewpage

# Team 17 — Research Question

## Research question

Do SSH researchers affiliated with more autocratic countries publish articles with fewer authors on average, at the country-year level, compared to researchers from more democratic countries?

## Rationale

Collaborative research requires multiple people to share ideas, access data, and jointly produce work that may attract political scrutiny. In autocratic settings, adding collaborators multiplies the risk of exposure: each additional team member is a potential informant, a source of ideological conflict, or a witness to politically sensitive discussions. Researchers anticipating these risks have an incentive to work alone or in smaller groups, reducing the mean number of authors per article. Team size is therefore a plausible behavioral footprint of self-censorship operating through collaboration avoidance.

## Theoretical mechanism

In autocracies, regime agents, institutional supervisors, and colleagues may monitor research for politically problematic content and report infractions. Each collaborator added to a project increases the number of people with knowledge of the work-in-progress, widening the circle of potential informants and the surface area for surveillance. Researchers rationally minimize this risk by working in smaller teams, avoiding the coordination costs and exposure that come with larger groups. Institutional resource constraints and disciplinary norms also shape team size, so any autocracy effect is expected to be modest and is a weaker test of the self-censorship mechanism than direct measures of collaboration structure (e.g., avoidance of international or democratic partners). The expected direction is positive: higher `v2x_libdem` → higher mean author count per article, because democratic environments reduce the personal risk of collaborative exposure.

**Important limitation:** Team size is heavily determined by disciplinary norms (e.g., natural sciences vs. humanities) and resource availability (lab infrastructure, grant funding). Because the corpus is restricted to SSH articles, disciplinary confounding is partially attenuated, but variation in field mix across country-years must still be controlled. This outcome is therefore a noisy proxy for the self-censorship mechanism and should be interpreted cautiously alongside direct collaboration-structure tests (Teams 14–16).

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean number of authors per article, conditional on country and year fixed effects, discipline (subject field) composition, and standard economic controls.

## Unit of analysis

Country-year

## Outcome variable

`mean_n_authors`: the mean number of authors per article, aggregated to the country-year level. Constructed by (1) computing `n_authors` at the article level — either directly from a pre-existing column or, if absent, by counting the number of distinct author entries per `wos_id` — and (2) taking the unweighted mean across all articles attributed to each country-year. Country-years with fewer than 10 article-author rows are excluded.

Note: The corpus is structured with one row per article-author-country affiliation. If `n_authors` does not exist as a column, it must be derived as `n_distinct(author_id)` or equivalent per `wos_id` before aggregation.

## Key independent variable

`v2x_libdem`

## Uniqueness check

Performed. Existing rq.md files cover Teams 01, 02, 03, 04, 05, 06, and 11. Brief files reviewed for Teams 14, 15, and 16 (the other `collaboration-constraint` teams).

Team 17 is distinct from all prior teams on the following grounds:

- **Versus Teams 14–16 (collaboration-constraint sub-family):** Team 14 measures the number of distinct co-author *countries* per article (geographic breadth of collaboration). Team 15 measures whether any co-author country is a liberal democracy (v2x_libdem > 0.5). Team 16 measures the share of articles that are purely domestic (all author countries identical). All three operationalize the *structure and origin* of collaborators. Team 17 measures the *total number of authors* regardless of their national origin — a distinct quantity that can vary independently: a purely domestic article may have two authors or twenty.
- **Versus Teams 01–06 and 11 (topic-avoidance and framing-neutrality sub-families):** These teams measure what is written (abstract content, political keywords, disciplinary field, argumentative stance) rather than who writes it or how many do.
- No other team tests whether autocracy predicts a lower mean author count per article at the country-year level.



ewpage

# Team 18 — Research Question

## Research question

Do researchers in more autocratic countries collaborate across fewer distinct author institutions per SSH article, compared to researchers in more democratic countries?

## Rationale

Inter-institutional collaboration requires spreading a research project across organizational boundaries — across universities, research centers, government agencies, and other bodies. In autocratic settings, each additional institutional partner creates a new surveillance surface: administrators, colleagues, and security actors at partner institutions may scrutinize and report on the collaboration. Researchers who anticipate this exposure have an incentive to keep projects within a single institution or a narrow institutional network, limiting the organizational breadth of their scientific collaborations. If this mechanism operates systematically, autocratic country-years should exhibit lower mean institutional diversity per published article.

## Theoretical mechanism

In autocracies, institutional actors — department heads, university administrators, and party liaisons embedded in research organizations — monitor research activity and can impose career costs on researchers whose projects attract political scrutiny. A collaboration that involves institutions outside the researcher's home organization brings in unfamiliar gatekeepers who may apply unpredictable political standards or report sensitive topics to authorities. Anticipating these risks, researchers in repressive environments self-censor by confining collaborations to a single trusted institution or to a very small number of familiar partners, reducing the organizational surface area of the project. The expected direction is positive: higher `v2x_libdem` (more democracy) is associated with a higher mean count of distinct institutions per article at the country-year level, because democratic environments lower the political cost of multi-institutional collaboration.

## Theory family

`collaboration-constraint`

## Estimand

The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean number of distinct author institutions per article, conditional on country fixed effects, year fixed effects, log GDP per capita, and log population.

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



ewpage

# Team 19 — Research Question

## Research question
Do SSH articles produced in more autocratic countries receive lower normalized citation impact — measured as the field-year adjusted citation ratio — than articles from more democratic countries, after conditioning on country and year fixed effects and standard economic controls?

## Rationale
Citations are a primary indicator of scholarly influence: a paper that attracts engagement from the wider research community accumulates citations, while work that fails to resonate does not. If self-censorship systematically steers researchers in autocracies toward safer, less intellectually provocative topics and framings, the resulting work is less likely to stimulate debate and scholarly follow-up. Reduced citation impact is therefore a downstream visibility consequence of self-censorship, distinct from questions of publication volume or co-authorship patterns.

## Theoretical mechanism
Researchers in autocracies face institutional incentives to avoid politically sensitive topics, controversial methods, and critical framings that could attract state scrutiny or sanction. This risk calculus produces a portfolio of published work that is systematically biased toward safe, incremental, and domestically oriented scholarship. Such work is less likely to engage the questions and controversies driving international scholarly debate, and therefore less likely to be cited by researchers elsewhere. A second pathway runs through collaboration: self-censored scholars are less likely to form international co-authorship ties, which reduces the global dissemination and uptake of their work. The expected direction is positive — higher `v2x_libdem` (more democratic) is associated with a higher normalized citation ratio, because political freedom removes incentives for the kind of intellectual caution that suppresses citation uptake.

## Theory family
visibility-suppression

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean of log1p(cite_ratio), where cite_ratio = tot_cites / field_year_mean_cites, conditional on country and year fixed effects and controls for log GDP per capita and log population.

## Unit of analysis
Country-year

## Outcome variable
`log_cite_ratio_mean`: constructed by (1) computing `cite_ratio = tot_cites / field_year_mean_cites` for each article, (2) applying the log1p transformation to handle zero-citation articles and right-skew, then (3) averaging log1p(cite_ratio) across all articles for each country-year. Country-years with fewer than 10 articles are dropped to ensure stable means.

## Key independent variable
v2x_libdem

## Uniqueness check
Performed. I scanned rq.md files for teams 01–18 (files found for teams 01–12, 15). No existing team uses `visibility-suppression` as its theory family or employs normalized citation impact as its outcome. All scanned teams fall in either `topic-avoidance` or related families and use outcomes based on abstract text, keyword distributions, disciplinary composition, or publication volume. Teams 20–22 (per project brief) also use citation data but with different designs: Team 20 tests citation gap by topic sensitivity, Team 21 tests a citation × co-authorship interaction, Team 22 tests Gini concentration of citations. Team 19 is the baseline test — does autocracy reduce normalized citation impact overall, unconditional on topic or collaborator type?



ewpage

# Team 20 — Research Question

## Research question

Do autocratic researchers receive a citation penalty specifically for politically sensitive articles, beyond any general autocracy citation disadvantage?

## Rationale

Prior work documents that researchers in autocracies publish less on sensitive topics (self-censorship in topic choice). Team 20 asks whether the work that does get published on sensitive topics from autocracies is further penalized in the citation market. This is analytically distinct from a general citation gap (Team 19): it tests whether the suppression of scientific visibility is most acute precisely where political sensitivity is highest. A significant interaction would indicate that autocracy shapes not only what is written but how much traction sensitive work gains.

## Theoretical mechanism

Autocratic researchers who publish on sensitive topics face two compounding pressures. First, to survive domestic review they likely hedge findings, soften conclusions, or frame arguments in ways that reduce political risk — producing work that is less intellectually bold and therefore less citable internationally. Second, international audiences may discount sensitive-topic articles from autocracies on credibility grounds, suspecting state-induced framing or data access constraints. Both channels predict the same direction: the autocracy penalty on citations is larger for politically sensitive articles than for non-sensitive articles. Formally, the interaction coefficient on `v2x_libdem * sensitive_flag` is expected to be positive (higher democracy score strengthens the citation advantage of sensitive-topic work), or equivalently the interaction `autocracy * sensitive_flag` is negative.

## Theory family

`visibility-suppression`

## Estimand

The differential effect of autocracy on normalized citations for politically sensitive articles relative to non-sensitive articles — i.e., the interaction effect of `v2x_libdem` and `sensitive_flag` on `log1p(cite_ratio)` at the article level.

## Unit of analysis

Article (one observation per article; country-year and field controls included as covariates and fixed effects).

## Outcome variable

`log1p(cite_ratio)` where `cite_ratio = tot_cites / field_year_mean_cites`. Log-transforming the ratio normalizes across fields and cohorts with different citation norms. Articles with `field_year_mean_cites == 0` or missing are excluded.

## Key IV

`v2x_libdem` (continuous, 0–1; higher = more democratic) interacted with `sensitive_flag` (binary, 1 = article title or keywords match the Team 04 regime-sensitive keyword dictionary). The main effect of `v2x_libdem` controls for the general citation gap; the interaction isolates the additional sensitivity-specific penalty.

## Uniqueness check

Team 19 estimates the overall citation gap between autocracies and democracies (main effect only, country-year level). Team 20 is distinguished by: (1) article-level analysis rather than country-year; (2) the interaction term as the primary estimand; (3) the sensitive-topic subgroup as the mechanism through which autocracy suppresses visibility. No other team in the 01–19 range combines citation outcomes with a topic-sensitivity interaction at the article level.



ewpage

# Team 21 — Research Question

## Research question

Does international co-authorship moderate the autocracy–citation penalty, such that the negative association between autocratic rule and normalized citation impact is weaker for articles that involve at least one author from a foreign country?

## Rationale

Team 19 establishes a baseline autocracy–citation gap at the country-year level. Team 21 asks whether this gap operates heterogeneously: if the mechanism runs partly through constrained collaboration — autocratic researchers being cut off from international networks — then articles that *do* achieve international co-authorship should be less affected by the citation suppression that autocracy induces. The interaction effect (v2x_libdem × has_intl_coauthor) is therefore both a moderation test and an indirect mechanism probe.

## Theoretical mechanism

Autocratic regimes suppress citation impact through two overlapping channels: topic self-censorship (work on politically safe topics garners less international interest) and collaboration constraint (domestically isolated scholars receive fewer citations because their work is less visible and less embedded in global citation networks). International co-authorship partially offsets the second channel: internationally co-authored articles gain access to broader citation networks through the foreign co-authors' institutional affiliations, editorial contacts, and disciplinary communities. The moderation hypothesis is therefore directional: the autocracy citation penalty should be *attenuated* (coefficient on v2x_libdem × has_intl_coauthor is positive) for internationally co-authored articles, because co-authorship partly substitutes for the network integration that democratic openness would otherwise provide. Importantly, this is not a clean mediation test — co-authorship is itself endogenous to regime type — but the interaction pattern is informative about where the citation penalty concentrates.

## Theory family

`visibility-suppression`

## Estimand

The interaction coefficient on `v2x_libdem × has_intl_coauthor` in an article-level fixed-effects regression of log1p(cite_ratio) on v2x_libdem, has_intl_coauthor, their interaction, and controls. A positive interaction coefficient indicates that the autocracy citation penalty is smaller (less negative) for internationally co-authored articles.

## Unit of analysis

Article (wos_id), one row per article. Each article is linked to a focal country (iso3) via the author affiliation data; articles with authors from multiple countries enter the analysis once per focal country represented.

## Outcome variable

`log1p(cite_ratio)`, where `cite_ratio = tot_cites / field_year_mean_cites`. The log1p transformation handles zero-citation articles and right-skew. This is identical to Team 19's outcome, enabling direct comparability of main effect magnitudes.

## Key IV

Interaction: `v2x_libdem × has_intl_coauthor`, where `has_intl_coauthor` is a binary indicator equal to 1 if the article (wos_id) has authors from more than one distinct country (n_distinct(iso3) > 1). The main effect of `v2x_libdem` captures the autocracy penalty for purely domestic articles; the interaction captures how much of that penalty is offset when the article has international co-authors.

## Uniqueness check

Performed against rq.md files for teams 01–20. Team 14 uses international co-authorship breadth as an *outcome* (co-authorship as a symptom of collaboration constraint). Team 19 tests the main citation gap at the country-year level without conditioning on collaborator type. No other team uses an interaction between regime type and co-authorship to test heterogeneity in citation impact at the article level. Team 21 is the only team testing whether co-authorship *moderates* the autocracy citation penalty — asking where in the article distribution the penalty concentrates, rather than whether it exists on average.



ewpage

# Team 22 — Research Question

## Research question

Does autocracy predict higher Gini concentration of citations across articles within a country-year, such that publication output in autocracies exhibits a more unequal citation distribution than equivalent output in democracies?

## Rationale

Self-censorship in autocracies may generate a bifurcated scientific output: a small number of ideologically acceptable or strategically prominent articles accrue disproportionate citations, while the bulk of the output — conformist, safe, and undistinctive — receives very few. This produces higher within-country-year inequality in citations, captured by the Gini coefficient, even if mean citation levels differ little. The Gini test is therefore conceptually and statistically distinct from a mean-citation test (Team 19): it asks about the shape of the citation distribution, not its level.

## Theoretical mechanism

In autocracies, career survival incentives lead most researchers to publish on uncontroversial, incremental topics that minimize political exposure — output that is competent but does not advance high-stakes intellectual debates and therefore attracts little international attention. A small subset of articles — those touching on regime-endorsed priorities, applied development topics, or internationally funded projects — escape this dynamic and accumulate citations normally. The structural result is a polarized citation distribution: a few well-cited articles and a long tail of near-zero-citation work. In democracies, where researchers face fewer constraints on topic choice, intellectual boldness, and critical framing, citation uptake is more evenly distributed across the portfolio. The expected direction is that higher `v2x_libdem` (more democratic) is associated with a lower Gini coefficient of `tot_cites` within country-year — i.e., autocracy produces higher citation concentration.

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



ewpage

# Team 23 — Research Question

## Research question

Does the ideological type of a regime — communist/left-authoritarian versus nationalist/right-authoritarian versus liberal-democratic — predict the political-economy ideological lean of national SSH output, and does all autocracy (regardless of type) suppress liberal or centrist political-economy framing relative to democratic baselines?

## Rationale

Self-censorship under autocracy is not ideologically neutral: researchers in communist regimes face pressure to produce scholarship consonant with statist, collectivist, and anti-market frames, while researchers in nationalist or right-authoritarian regimes face complementary pressures toward market-nationalist or traditionalist frames. Both regime types may suppress liberal-centrist political-economy framing — the framing most compatible with pluralist, rule-of-law, and open-society scholarship — but through different mechanisms. Existing teams capture topic avoidance and framing-neutrality but none test whether the ideological content of political-economy language in SSH abstracts shifts predictably with regime ideology type, which is a distinct and theoretically important form of self-censorship.

## Theoretical mechanism

Autocratic regimes exert direct and indirect pressure on academic institutions to produce scholarship consonant with their official ideology: communist regimes promote statist, redistributive, and collectivist framings and penalize market-liberal or pluralist alternatives; nationalist and right-authoritarian regimes promote market-nationalist, traditionalist, or anti-cosmopolitan framings and penalize universalist or redistributive alternatives. Researchers anticipating these pressures self-censor by framing their work within the ideologically approved vocabulary, even when their empirical subject matter does not require taking a position. Liberal-centrist or ideologically neutral framing — which does not endorse either statism or nationalism — is the framing most compatible with liberal-democratic academic norms; we therefore expect it to be suppressed under both left- and right-authoritarian regimes, but through different substitution patterns. The expected direction for the primary test is positive: higher `v2x_libdem` (more democratic) is associated with a higher share of liberal/neutral political-economy framing (`share_liberal`) and a lower share of left-authoritarian or right-nationalist framing.

## Theory family

ideological-alignment

## Estimand

The average within-country association between `v2x_libdem` and the country-year share of SSH abstracts classified as carrying liberal/neutral political-economy framing (`share_liberal`), conditional on country fixed effects, year fixed effects, and standard economic controls. Secondary estimands test heterogeneity by regime ideology type via interaction with a categorical regime-ideology variable.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Construction:** For each abstract in the stratified sample, an LLM assigns one of four labels reflecting the political-economy ideological framing of the text: (1) LEFT — statist, redistributive, collectivist, or anti-capitalist framing; (2) RIGHT — market-liberal, nationalist, or traditionalist framing; (3) NEUTRAL — technocratic, empiricist, or explicitly non-ideological framing; (4) NONE — the abstract does not carry discernible political-economy framing. Four country-year share variables are constructed: `share_left`, `share_right`, `share_neutral`, `share_none`. The primary outcome is `share_liberal` = `share_neutral` + `share_none` (i.e., the share of abstracts that avoid ideological political-economy framing in either direction), treated as the "suppressed" category under autocracy. Secondary outcomes are `share_left` and `share_right` examined in regime-ideology interaction models.

Framing is distinguished from topic coverage: an abstract that studies redistribution as a topic is classified by the framing through which it discusses it — an empiricist study of redistribution effects with no normative stance is NEUTRAL; one that frames redistribution as a social right or as correcting capitalist exploitation is LEFT; one that frames redistribution as market distortion is RIGHT.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Secondary IV: a categorical regime ideology type variable constructed from V-DEM and external sources (see analysis plan).

## LLM classifier specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost model) primary; GPT-4o-mini as alternative.

**Labels:**
- `LEFT`: The abstract frames its subject using statist, redistributive, collectivist, anti-capitalist, or class-struggle language as an evaluative or normative lens — not merely as a topic under study.
- `RIGHT`: The abstract frames its subject using market-efficiency, market-freedom, nationalist, traditionalist, anti-redistributive, or anti-cosmopolitan language as an evaluative or normative lens — not merely as a topic under study.
- `NEUTRAL`: The abstract discusses political-economy topics (markets, redistribution, governance, inequality, capitalism, etc.) in an explicitly empiricist, technocratic, or non-partisan framing — describing mechanisms or measuring effects without endorsing a normative direction.
- `NONE`: The abstract does not engage with political-economy topics or ideological framing in any discernible way; this includes purely historical, cultural, linguistic, or non-political subject matter.

**Prompt structure:** The prompt passes the abstract text and instructs the model to identify the dominant political-economy framing, emphasizing that it should classify framing (evaluative stance, normative language, rhetorical appeal) rather than topic coverage. The model returns a single label. Ties between LEFT and RIGHT default to NEUTRAL. Ties between NEUTRAL and NONE default to NONE. Full prompt text defined in `analysis_plan.md`.

**Label assignment rules:** Single-label output only. If the abstract discusses political-economy topics descriptively without normative framing, assign NEUTRAL. If the abstract does not engage with political-economy content at all, assign NONE. Default to NONE if genuinely ambiguous. Assign LEFT or RIGHT only when normative framing language is present and unmistakable.

## Uniqueness check

Performed. Teams with most potential overlap:
- Team 05: classifies whether abstracts critically examine domestic governance (binary CRITICAL-DOMESTIC vs. NEUTRAL-DOMESTIC). Does not classify political-economy ideological lean or LEFT/RIGHT/NEUTRAL framing.
- Team 10: classifies technocratic framing (presence of depoliticizing, technocratic language). Tests suppression of political framing generally; does not distinguish LEFT from RIGHT from NEUTRAL.
- Team 12: classifies normative conclusion claims (strong vs. hedged normative claims). Does not classify ideological direction (left vs. right vs. neutral).
- Team 08: classifies hedging/epistemic uncertainty. Does not test ideological lean.

Team 23 is the only team that (a) classifies the political-economy ideological direction (LEFT / RIGHT / NATIONALIST / NEUTRAL) of SSH abstracts, (b) tests whether autocracy predicts this lean, and (c) tests heterogeneity by regime ideology type to assess whether communist vs. nationalist autocracies produce predictably different lean signatures.



ewpage

# Team 24 — Research Question

## Research question

Does higher authoritarianism predict a higher share of SSH scholarship that actively legitimizes or endorses the current political system, state authority, ruling party, or leadership in the author's country?

## Rationale

Self-censorship theories have largely focused on what researchers avoid; yet autocratic regimes do not merely suppress dissent — they actively incentivize, fund, and reward scholarship that validates state power and ideology. If career rewards flow disproportionately toward work that positively frames the regime, we should observe not just an absence of critical framing but a measurable elevation in the share of SSH output that endorses or legitimizes the political status quo. This is the active, productive dimension of scholarly self-censorship — distinct from silence — and it has received little systematic empirical attention.

## Theoretical mechanism

In autocracies, researchers face strong incentives to produce scholarship that is not merely inoffensive but affirmatively supportive of the regime: state-funded research programs, publication outlets controlled by party or state bodies, and promotion criteria that reward ideological alignment all channel scholarly output toward legitimating framings. At the individual level, anticipating these incentive structures, scholars may adopt legitimating frames proactively even without explicit instruction, as a rational career strategy. At the aggregate level, this produces a higher country-year share of SSH abstracts that characterize the political system, state authority, or leadership as effective, stable, or beneficial. The expected direction is negative: higher authoritarianism (lower v2x_libdem) is associated with a higher share of actively legitimating scholarship (share_legitimating).

## Theory family

ideological-alignment

## Estimand

The average within-country association between a country-year's level of liberal democracy (v2x_libdem) and the share of that country-year's SSH articles whose abstracts actively legitimize or endorse the current political system, state authority, ruling party, or leadership, conditional on country fixed effects, year fixed effects, and standard economic controls.

## Unit of analysis

Country-year, constructed by aggregating article-level LLM classifications to the country-year level.

## Outcome variable

**Name:** `share_legitimating`

**Construction:** For each abstract in the stratified sample, an LLM assigns one of two labels: LEGITIMATING or NON-LEGITIMATING. The outcome is the share of classified articles receiving the LEGITIMATING label, computed per country-year. This is a proportion bounded [0, 1].

The outcome is constructed from the `abstract` and `iso3` fields. The "own country" reference is the author's country identified by `iso3`.

## Key independent variable

`v2x_libdem` — V-DEM Liberal Democracy Index (continuous, 0–1); higher values indicate more democratic governance. Expected sign on v2x_libdem: negative (more autocracy → higher share_legitimating).

## LLM classification specification

**Model:** Claude Haiku (claude-haiku-3-5 or equivalent low-cost Anthropic model) or GPT-4o-mini as alternative.

**Binary label scheme:**

- **LEGITIMATING:** The abstract explicitly endorses, positively frames, or validates the current political system, state authority, ruling party, government institutions, or national leadership of [COUNTRY] as effective, beneficial, legitimate, stable, or necessary. This includes: praise of the political system's achievements or governance capacity; framing state intervention or authority as solving social problems; positive characterization of political stability under the current system; endorsement of ideological frameworks that justify the political order. The endorsement must be explicit and attributable to the article's own argument — not merely reported as a position held by others.

- **NON-LEGITIMATING:** All other abstracts. This includes: neutral or descriptive analysis of the political system; comparative work that includes [COUNTRY] without evaluating its political order positively; critical analysis; historical description; policy analysis without political endorsement; and any abstract that does not discuss domestic governance or politics at all. If there is any doubt, classify as NON-LEGITIMATING.

**Rationale for binary (not three-class) scheme:** The outcome of interest is the presence of active legitimation, which is a distinct and detectable act. A three-class scheme (legitimating / neutral / critical) would replicate Team 05's design rather than test the positive mirror. Binary classification also reduces ambiguity and improves inter-rater reliability in validation.

**Handling non-English abstracts:** The model classifies based on content regardless of language.

**Handling abstracts without regime reference:** If the abstract does not reference domestic politics, governance, or state authority, classify as NON-LEGITIMATING (the default).

## Sampling strategy

Stratified random sample to manage API cost:

- **Stratification variables:** `iso3` × `v2x_regime` (4-category) × decade (1970s, 1980s, 1990s, 2000s, 2010s, 2020s)
- **Target N per stratum:** up to 10 articles (fewer if stratum is smaller)
- **Eligibility:** non-missing abstract with `nchar(abstract) >= 50`
- **Seed:** `set.seed(42)`
- **Estimated total N:** ~7,000–8,000 abstracts
- **Cost estimate:** ~$2–4 at Claude Haiku rates; halt if projected cost exceeds $20

## Uniqueness check

**Most similar team:** Team 05 (critical domestic governance framing, LLM-based, topic-avoidance family).

**Why Team 24 is distinct:** Team 05 tests whether autocracy *suppresses* critical framing of own-country governance — the absence of negative evaluation. Team 24 tests whether autocracy *produces* positive/legitimating framing — the presence of active endorsement. These are not logical complements: a country could show low critical framing simply due to silence (researchers avoiding domestic governance entirely), without any elevation in legitimating content; conversely, a regime could reward legitimating scholarship while also tolerating some neutral descriptive work, producing both low critical framing AND high legitimating shares. Distinguishing suppression-through-silence from active production of legitimating content is theoretically important for understanding the mechanisms of autocratic influence over scholarship. Team 24 is the only team testing the active/positive dimension.

No other team in the orchestra tests the share of actively legitimating SSH scholarship as the primary outcome.



ewpage

# Team 25 — Research Question

## Research question
Do SSH researchers in more autocratic countries produce a higher share of abstracts that actively frame liberal democracy, Western political institutions, or international human rights frameworks as fundamentally flawed, illegitimate, or harmful — as measured by LLM-classified `share_anti_liberal` — than researchers in more democratic countries, after controlling for country, year, GDP per capita, and population?

## Rationale
Self-censorship theory predicts that researchers in autocracies avoid politically sensitive topics to minimize career risk, but the same logic of regime alignment generates an additional prediction: where states actively promote counter-liberal ideologies, researchers face positive incentives to produce scholarship consonant with those ideologies. Autocratic regimes — particularly those advancing civilizational, sovereigntist, or anti-Western narratives — reward ideologically aligned scholarship and create structural pressure toward active ideological production, not merely passive avoidance. This team tests the positive production side of the self-censorship mechanism: not whether autocracy silences liberal discourse, but whether it actively generates anti-liberal counter-discourse.

## Theoretical mechanism
Autocratic regimes that derive legitimacy from anti-liberal ideological frameworks (sovereignty norms, civilizational conservatism, anti-Western hegemony arguments) have material incentives to fund, publish, and reward scholarship that delegitimizes liberal democratic norms and international human rights institutions. Researchers operating under such regimes face career incentives that are the mirror image of the avoidance incentive: producing ideologically aligned anti-liberal content can confer safety and advancement, while conspicuously pro-liberal framings attract sanction. This dynamic is distinct from ordinary topic avoidance — it implies active ideological production under state direction or anticipatory compliance. The expected direction is negative: lower `v2x_libdem` → higher `share_anti_liberal`. The effect is likely non-linear: strongest in closed autocracies (where state ideological pressure is greatest and independent scholarship most constrained), weaker in electoral autocracies, and near-zero in democracies where academic norms of analytical pluralism prevail.

## Theory family
`ideological-alignment`

## Estimand
The average within-country effect of a one-unit increase in `v2x_libdem` on the country-year mean share of abstracts classified as anti-liberal, conditional on country and year fixed effects.

## Unit of analysis
Country-year

## Outcome variable
`share_anti_liberal`: constructed by (1) drawing a stratified sample of ~7,000–8,000 abstracts from the full corpus, (2) classifying each abstract as ANTI-LIBERAL (1) or NOT (0) using an LLM binary classifier (see specification below), then (3) aggregating to the country-year level as the share of classified abstracts labeled ANTI-LIBERAL. Country-years not represented in the sample are excluded from the regression; country-years with fewer than 3 sampled abstracts are also excluded as unstable.

## Key independent variable
`v2x_libdem`

## LLM classifier specification

**Task:** Binary classification of each abstract as ANTI-LIBERAL (1) or NOT ANTI-LIBERAL (0).

**Label definition — ANTI-LIBERAL (code 1):**
An abstract receives code 1 if and only if it frames liberal democracy, Western political institutions, or international human rights norms as fundamentally flawed, illegitimate, or harmful. The framing must invoke regime-aligned anti-liberal arguments — such as appeals to national sovereignty against Western interference, civilizational or cultural-relativist arguments against universal human rights, characterizations of liberal democracy as a tool of Western hegemony or imperialism, delegitimization of international democratic institutions (e.g., the EU, ICC, or UN human rights mechanisms) as biased instruments of Western power, or explicit advocacy for alternative political orders (Confucian governance, Islamic governance, sovereign democracy) as superior to liberal democracy.

**Label definition — NOT ANTI-LIBERAL (code 0):**
An abstract receives code 0 in all other cases, including:
- Abstracts that identify specific failings or limitations of liberal institutions from within a broadly liberal framework (e.g., critiques of neoliberal economic policy, procedural deficits, democratic backsliding, minority exclusion, or imperial applications of liberal norms) — these represent internal critique, not rejection of liberal democracy as such.
- Abstracts drawing on post-liberal or agonistic democratic theory (Mouffe, Schmitt, Laclau) that engage critically with liberalism as a scholarly tradition without endorsing authoritarian alternatives.
- Abstracts that are neutral, descriptive, or analytical in framing without making normative claims about liberal democracy.
- Abstracts on unrelated topics.

**Critical distinction:** The key diagnostic is whether the abstract frames liberal democracy and Western institutions as externally harmful and illegitimate (anti-liberal) versus identifying internal problems within a normative framework that remains broadly liberal (critical liberal). Scholarly critique of liberalism on its own terms does not count; only abstracts that advocate for the rejection or replacement of liberal democratic norms, or that instrumentalize anti-Western frames in line with authoritarian regime discourse, are coded ANTI-LIBERAL.

**Model:** Claude Haiku (claude-haiku-3-5) or GPT-4o-mini. Classification in batches of 50 abstracts per API call. Temperature = 0. Return only "0" or "1" per abstract, no explanation.

**Prompt template:**

```
You are classifying academic abstracts. For each abstract, output exactly "1" if the abstract frames liberal democracy, Western political institutions, or international human rights norms as fundamentally flawed, illegitimate, or harmful using regime-aligned anti-liberal arguments (e.g., sovereignty arguments against Western interference, civilizational alternatives to universal human rights, characterizations of liberal democracy as Western hegemony). Output "0" for all other abstracts, including those that critique liberalism from within a liberal framework, engage with post-liberal theory as a scholarly tradition, or are descriptive/neutral. Output only 0 or 1. No explanation.

Abstract: {abstract_text}
```

## Uniqueness check note
Team 09 (framing-neutrality sub-family) counts the frequency of normative language in abstracts but does not assess the direction of that normativity toward or against liberal democratic norms. No other team tests active production of ideologically anti-liberal content. Team 25 is the only team in the orchestra testing whether autocracy predicts the positive generation of counter-liberal discourse, as opposed to avoidance or omission of politically sensitive material.

