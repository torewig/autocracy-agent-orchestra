# Team 29 — Analysis Plan

## Overview

Test whether country population size moderates the effect of autocracy on the share of politically sensitive SSH articles. Primary specification: interaction regression at the country-year level. No external API required.

---

## Step 1 — Load and prepare data

```r
library(tidyverse)
library(fixest)

corpus <- readRDS("data/agent_corpus.rds")

# Replicate Team 04 keyword flag
dict_pattern <- paste(
  "democrat|democratiz|human rights|civil rights|civil libert",
  "corrupt|bribery|kleptocracy",
  "protest|demonstrat|uprising|riot|rebellion|civil unrest",
  "repression|repressive|censorship|censor|political prisoner",
  "authoritarian|autocra|dictatorship",
  "political freedom|political liberty|free speech|freedom of expression|freedom of press",
  "election fraud|electoral fraud|vote rigging|vote buying",
  "dissent|dissident|political opposition|regime critic",
  sep = "|"
)

corpus <- corpus |>
  mutate(
    text_field     = paste(title, keywords, sep = " | "),
    sensitive_flag = str_detect(text_field, regex(dict_pattern, ignore_case = TRUE))
  )
```

## Step 2 — Aggregate to country-year

```r
cy <- corpus |>
  group_by(iso3, year) |>
  summarise(
    share_sensitive         = mean(sensitive_flag, na.rm = TRUE),
    n_articles              = n_distinct(wos_id),
    v2x_libdem              = first(v2x_libdem),
    lied_binary             = first(lied_binary),
    e_wb_pop                = first(e_wb_pop),
    n_articles_country_year = first(n_articles_country_year),
    e_gdppc                 = first(e_gdppc),
    .groups = "drop"
  ) |>
  filter(n_articles >= 1) |>
  mutate(
    log_pop      = log(e_wb_pop),
    log_pop_c    = log_pop - mean(log_pop, na.rm = TRUE),  # mean-centred
    log_gdppc    = log(e_gdppc),
    log_articles = log(n_articles_country_year + 1),
    large_producer = as.integer(
      n_articles_country_year >= quantile(n_articles_country_year, 0.75, na.rm = TRUE)
    )
  )
```

## Step 3 — Primary model

Method: two-way fixed-effects OLS with country and year fixed effects; SEs clustered by country.

```r
m1 <- feols(
  share_sensitive ~ v2x_libdem * log_pop_c + log_gdppc | iso3 + year,
  data    = cy,
  cluster = ~iso3
)
summary(m1)
```

Key coefficients:

| Coefficient | Interpretation |
|---|---|
| `v2x_libdem` | Effect of democracy on sensitive-topic share at average country size |
| `log_pop_c` | Effect of population on sensitive-topic share at mean democracy |
| `v2x_libdem:log_pop_c` | Moderation: positive = attenuation; negative = amplification |

Country FE absorbs time-invariant size differences; identification exploits within-country variation in `v2x_libdem` over time.

---

## Step 4 — Robustness checks

### R1: Alternative regime IV (lied_binary)

```r
m_rob1 <- feols(
  share_sensitive ~ lied_binary * log_pop_c + log_gdppc | iso3 + year,
  data = cy, cluster = ~iso3
)
```

### R2: Alternative size measure — log SSH production volume

```r
m_rob2 <- feols(
  share_sensitive ~ v2x_libdem * log_articles + log_gdppc | iso3 + year,
  data = cy, cluster = ~iso3
)
```

### R3: Large-producer binary dummy

```r
m_rob3 <- feols(
  share_sensitive ~ v2x_libdem * large_producer + log_gdppc | iso3 + year,
  data = cy, cluster = ~iso3
)
```

Tests whether the autocracy effect differs in the top quartile of SSH producers vs. the rest.

### R4: Restrict to country-years with at least 10 articles

```r
m_rob4 <- feols(
  share_sensitive ~ v2x_libdem * log_pop_c + log_gdppc | iso3 + year,
  data = cy |> filter(n_articles >= 10), cluster = ~iso3
)
```

---

## Step 5 — Marginal effects plot

```r
library(marginaleffects)

pop_grid <- quantile(cy$log_pop_c, probs = c(0.1, 0.25, 0.5, 0.75, 0.9), na.rm = TRUE)

me <- slopes(
  m1,
  variables = "v2x_libdem",
  newdata   = datagrid(log_pop_c = pop_grid)
)

ggplot(me, aes(x = log_pop_c, y = estimate, ymin = conf.low, ymax = conf.high)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_ribbon(alpha = 0.2) +
  geom_line() +
  geom_point(size = 2) +
  labs(
    x     = "Log population (mean-centred)",
    y     = "Marginal effect of v2x_libdem on share_sensitive",
    title = "Autocracy effect on sensitive-topic share by country size"
  ) +
  theme_minimal()

ggsave("teams/team_29/output/marginal_effects_pop.png", width = 7, height = 4.5)
```

Annotate with country labels for the five largest autocratic producers.

---

## Step 6 — Regression table

```r
library(modelsummary)

modelsummary(
  list(
    "Main (pop)"          = m1,
    "Rob: lied_binary"    = m_rob1,
    "Rob: log articles"   = m_rob2,
    "Rob: large producer" = m_rob3,
    "Rob: n >= 10"        = m_rob4
  ),
  stars   = TRUE,
  gof_map = c("nobs", "r.squared", "FE: iso3", "FE: year"),
  coef_map = c(
    "v2x_libdem"                = "Liberal democracy (v2x_libdem)",
    "log_pop_c"                 = "Log population (centred)",
    "v2x_libdem:log_pop_c"      = "v2x_libdem x log population",
    "lied_binary"               = "LIED binary",
    "lied_binary:log_pop_c"     = "LIED x log population",
    "log_articles"              = "Log SSH articles",
    "v2x_libdem:log_articles"   = "v2x_libdem x log SSH articles",
    "large_producer"            = "Large producer (binary)",
    "v2x_libdem:large_producer" = "v2x_libdem x large producer",
    "log_gdppc"                 = "Log GDP per capita"
  ),
  output = "teams/team_29/output/regression_table.tex"
)
```

---

## Expected output files

| File | Contents |
|---|---|
| `teams/team_29/output/marginal_effects_pop.png` | Marginal effects plot: autocracy coefficient at population percentiles (10th–90th), 95% CI |
| `teams/team_29/output/regression_table.tex` | Five-column modelsummary table (main + four robustness models) |
| `teams/team_29/output/descriptives.txt` | Summary stats for `share_sensitive`, `v2x_libdem`, `log_pop_c`, `n_articles` by regime quartile |

---

## Identification note

Country FE absorb time-invariant differences including mean population size. Identification of `v2x_libdem x log_pop_c` comes from within-country variation in `v2x_libdem` over time and whether larger vs. smaller countries show different democracy-to-sensitivity slopes. Because population is largely stable within countries, most moderating variation is cross-sectional; the interaction coefficient should be interpreted as a cross-country comparison of slopes, not a pure within-country causal effect. This limitation should be noted in the write-up. Year FE handle global time trends (e.g., post-2000 expansion of SSH output from China).

---

## Data variables required

| Variable | Source | Notes |
|---|---|---|
| `wos_id` | WOS corpus | Article identifier |
| `title`, `keywords` | WOS corpus | For keyword flag |
| `iso3` | WOS corpus | Country identifier |
| `year` | WOS corpus | Publication year |
| `v2x_libdem` | V-DEM | Primary regime IV |
| `lied_binary` | LIED | Robustness IV |
| `e_wb_pop` | World Bank via V-DEM | Population (country size) |
| `n_articles_country_year` | Derived | SSH production volume |
| `e_gdppc` | V-DEM | GDP per capita control |

---

Step 1 complete — ready for PI review.
