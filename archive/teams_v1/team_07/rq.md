# Team 07: Research Question

## Research question

Does autocracy reduce the share of SSH research that critically engages with domestic governance and political institutions?

## Rationale

The overarching question asks how autocracy shapes the *contents and direction* of SSH research. Simple keyword counts show that articles from autocracies and democracies mention politically sensitive terms at nearly identical rates (~7%). But qualitative inspection of abstracts reveals a subtler pattern: researchers in autocracies tend to study *other countries'* politics or adopt descriptive/technocratic framings, rather than critically examining domestic political institutions. Capturing this distinction requires classifying the *stance and focus* of research -- a content dimension that keyword matching cannot reliably detect. We use LLM-based classification of abstracts to measure whether articles critically engage with the governance and political institutions of the author's own country.

## Theoretical mechanism

Autocratic regimes create strong incentives for SSH researchers to avoid critical scrutiny of domestic political institutions. State authorities control university appointments, research funding, and publication permissions, and can sanction scholars whose work challenges regime legitimacy or exposes governance failures. Researchers respond through anticipatory self-censorship: they shift toward studying foreign countries, adopt descriptive or technocratic framings of domestic topics, or avoid governance-related research entirely. The result is not that politically relevant *words* disappear from the literature, but that the *critical analytical stance toward domestic power* is suppressed. Democratization relaxes these constraints by protecting academic freedom and reducing the personal cost of politically inconvenient findings. We therefore expect higher levels of liberal democracy to be associated with a higher share of research that critically examines domestic governance.

## Theory family

`political-self-censorship`

## Estimand

The average effect of a one-unit increase in `v2x_libdem` on the probability that an SSH article critically engages with the governance and political institutions of the author's country, controlling for country and year fixed effects.

## Unit of analysis

Article-country (from a stratified random sample of ~6,000 abstracts, classified via LLM).

## Outcome variable

`critical_domestic` -- a binary indicator (0/1) constructed via LLM classification of abstracts. An article is coded 1 if it critically examines domestic governance, political institutions, state power, or accountability in the author's country; 0 otherwise. This variable is constructed during the analysis phase using the Claude API (Haiku) for cost-efficient classification.

## Key independent variable

`v2x_libdem`
