# Team 16 — Domestic-Only Authorship and Autocracy
# Outcome: share_domestic_only (proportion of articles with all authors from same country)
# Theory family: collaboration-constraint

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/teams/team_16/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

message("Classifying articles as domestic-only ...")

# For each article: is it written by authors from a single country?
art_dom <- corpus |>
  filter(!is.na(iso3)) |>
  group_by(ut) |>
  summarise(
    domestic_only   = as.integer(n_distinct(iso3) == 1),
    n_countries_art = n_distinct(iso3),
    .groups = "drop"
  )

# Join flag back to corpus (one row per article × focal country)
corpus_dom <- corpus |>
  filter(!is.na(iso3)) |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  left_join(art_dom, by = "ut")

# Country-year aggregation
cy <- corpus_dom |>
  group_by(iso3, year) |>
  summarise(
    share_domestic_only = mean(domestic_only, na.rm = TRUE),
    n_articles          = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

panel <- cy |>
  filter(n_articles >= 10) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE
mod_twfe <- feols(
  share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: multi-author articles only
corpus_multi <- corpus_dom |>
  filter(!is.na(n_authors), n_authors > 1)

cy_multi <- corpus_multi |>
  group_by(iso3, year) |>
  summarise(
    share_dom_multi = mean(domestic_only, na.rm = TRUE),
    n_multi = n(), v2x_libdem = first(v2x_libdem),
    e_gdppc = first(e_gdppc), e_wb_pop = first(e_wb_pop),
    .groups = "drop"
  )
panel_multi <- cy_multi |>
  filter(n_multi >= 10, !is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |> mutate(year = as.integer(year))

mod_rc1 <- feols(
  share_dom_multi ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel_multi, cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  share_domestic_only ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1: Multi-author" = mod_rc1, "RC2: lied_binary" = mod_rc2),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = share_domestic_only)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Share of articles with domestic-only authorship",
       title = "Domestic-only authorship vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_domestic_only_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "16",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit higher shares of SSH articles with exclusively domestic authorship.",
  theory_family    = "collaboration-constraint",
  predictor        = "v2x_libdem",
  outcome          = "share_domestic_only",
  model_description = "feols(share_domestic_only ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
