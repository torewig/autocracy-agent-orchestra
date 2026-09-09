# Team 19 — Normalized Citation Impact and Autocracy
# Outcome: log_cite_ratio_mean = mean(log1p(tot_cites / field_year_mean_cites)) per country-year
# Theory family: visibility-suppression

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_19/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

message("Computing log citation ratio ...")

articles <- corpus |>
  filter(!is.na(tot_cites), !is.na(field_year_mean_cites)) |>
  filter(field_year_mean_cites > 0) |>
  mutate(
    cite_ratio     = tot_cites / field_year_mean_cites,
    log_cite_ratio = log1p(cite_ratio)
  )

# Deduplicate: one row per (article × focal country)
articles_dedup <- articles |>
  filter(!is.na(iso3)) |>
  distinct(ut, iso3, year, .keep_all = TRUE)

# Country-year aggregation
cy <- articles_dedup |>
  group_by(iso3, year) |>
  summarise(
    log_cite_ratio_mean = mean(log_cite_ratio, na.rm = TRUE),
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
  log_cite_ratio_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  log_cite_ratio_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: exclude articles published after 2018 (citation maturity)
cy_mature <- articles_dedup |>
  filter(year <= 2018) |>
  group_by(iso3, year) |>
  summarise(
    log_cite_ratio_mature = mean(log_cite_ratio, na.rm = TRUE),
    n_mature = n(), v2x_libdem = first(v2x_libdem),
    e_gdppc = first(e_gdppc), e_wb_pop = first(e_wb_pop),
    .groups = "drop"
  )
panel_mature <- cy_mature |>
  filter(n_mature >= 10, !is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |> mutate(year = as.integer(year))

mod_rc1 <- feols(
  log_cite_ratio_mature ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel_mature, cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  log_cite_ratio_mean ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC3: floor thresholds (5 and 25)
mod_rc3a <- feols(
  log_cite_ratio_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = filter(panel, n_articles >= 5), cluster = ~iso3
)
mod_rc3b <- feols(
  log_cite_ratio_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = filter(panel, n_articles >= 25), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1: Pre-2019" = mod_rc1, "RC2: lied_binary" = mod_rc2,
       "RC3a: N>=5" = mod_rc3a, "RC3b: N>=25" = mod_rc3b),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = log_cite_ratio_mean)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Mean log citation ratio",
       title = "Normalized citation impact vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_cite_ratio_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "19",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit lower normalized citation impact (log field-year adjusted citation ratio) for their SSH publications.",
  theory_family    = "visibility-suppression",
  predictor        = "v2x_libdem",
  outcome          = "log_cite_ratio_mean",
  model_description = "feols(log_cite_ratio_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
