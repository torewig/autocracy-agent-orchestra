# Team 13 — Journal Domesticity and Autocracy
# Outcome: share_domestic_journal = proportion of articles in journals >60% domestic to the focal country
# Theory family: framing-neutrality

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_13/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

message("Classifying journals as domestic ...")

# Step 1: compute each country's share of each journal's article-country rows
journal_shares <- corpus |>
  filter(!is.na(journal), journal != "", !is.na(iso3)) |>
  count(journal, iso3, name = "n_rows") |>
  group_by(journal) |>
  mutate(
    journal_total = sum(n_rows),
    share         = n_rows / journal_total
  ) |>
  ungroup()

# Step 2: classify journals as domestic to each country (share > 0.60)
domestic_journals_60 <- journal_shares |>
  filter(share > 0.60) |>
  select(journal, iso3_domestic = iso3)

domestic_journals_50 <- journal_shares |>
  filter(share > 0.50) |>
  select(journal, iso3_domestic = iso3)

domestic_journals_70 <- journal_shares |>
  filter(share > 0.70) |>
  select(journal, iso3_domestic = iso3)

message(sprintf("Journals classified as domestic (60%% threshold): %d country-journal pairs",
                nrow(domestic_journals_60)))

# Step 3: flag each article-country row
corpus_flagged <- corpus |>
  filter(!is.na(iso3), !is.na(journal), journal != "") |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  left_join(
    domestic_journals_60 |> rename(iso3 = iso3_domestic) |> mutate(is_dom_60 = 1L),
    by = c("journal", "iso3")
  ) |>
  left_join(
    domestic_journals_50 |> rename(iso3 = iso3_domestic) |> mutate(is_dom_50 = 1L),
    by = c("journal", "iso3")
  ) |>
  left_join(
    domestic_journals_70 |> rename(iso3 = iso3_domestic) |> mutate(is_dom_70 = 1L),
    by = c("journal", "iso3")
  ) |>
  mutate(
    is_dom_60 = coalesce(is_dom_60, 0L),
    is_dom_50 = coalesce(is_dom_50, 0L),
    is_dom_70 = coalesce(is_dom_70, 0L)
  )

# Step 4: aggregate to country-year
cy <- corpus_flagged |>
  group_by(iso3, year) |>
  summarise(
    share_domestic_journal    = mean(is_dom_60, na.rm = TRUE),
    share_domestic_journal_50 = mean(is_dom_50, na.rm = TRUE),
    share_domestic_journal_70 = mean(is_dom_70, na.rm = TRUE),
    n_articles                = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

panel <- cy |>
  filter(n_articles >= 5) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year),
         log_n_articles = log(n_articles))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE
mod_twfe <- feols(
  share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1a: 50% threshold
mod_rc1a <- feols(
  share_domestic_journal_50 ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC1b: 70% threshold
mod_rc1b <- feols(
  share_domestic_journal_70 ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC2: restrict to below-75th-percentile article count (exclude large producers)
p75 <- quantile(panel$n_articles, 0.75, na.rm = TRUE)
mod_rc2 <- feols(
  share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = filter(panel, n_articles <= p75), cluster = ~iso3
)

# RC3: lied_binary
mod_rc3 <- feols(
  share_domestic_journal ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC4: 1990–2005
mod_rc4 <- feols(
  share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = filter(panel, year >= 1990, year <= 2005), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1a: 50% thresh." = mod_rc1a, "RC1b: 70% thresh." = mod_rc1b,
       "RC2: Small producers" = mod_rc2, "RC3: lied_binary" = mod_rc3,
       "RC4: 1990-2005" = mod_rc4),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = share_domestic_journal)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Share of articles in domestic journals",
       title = "Journal domesticity vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_journal_domesticity_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "13",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit higher shares of SSH articles published in journals dominated by that same country.",
  theory_family    = "framing-neutrality",
  predictor        = "v2x_libdem",
  outcome          = "share_domestic_journal",
  model_description = "feols(share_domestic_journal ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
