# Team 15 — Democratic Co-authorship and Autocracy
# Outcome: share_dem_coauthor = proportion of articles with at least one co-author from a democracy (libdem > 0.5)
# Theory family: collaboration-constraint

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/teams/team_15/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

message("Computing democratic co-authorship flag ...")

# For each article (ut), compute:
#   - n_countries: number of distinct iso3 rows
#   - n_dem_countries: number of iso3 rows with v2x_libdem > 0.5
#   - sum_dem_indicator: sum of (v2x_libdem > 0.5) across all rows
# Then for each focal row (ut, iso3_focal):
#   has_dem_coauthor = any OTHER country in same article has libdem > 0.5
#   = (sum_dem_indicator - self_is_dem) > 0, among multi-country articles

art_stats <- corpus |>
  filter(!is.na(iso3)) |>
  group_by(ut) |>
  summarise(
    n_art_countries   = n_distinct(iso3),
    sum_dem_gt05      = sum(!is.na(v2x_libdem) & v2x_libdem > 0.5),
    sum_dem_regime2   = sum(!is.na(v2x_regime)  & v2x_regime >= 2),
    sum_dem_regime3   = sum(!is.na(v2x_regime)  & v2x_regime == 3),
    .groups = "drop"
  )

# Join back to focal rows
corpus_dem <- corpus |>
  filter(!is.na(iso3)) |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  left_join(art_stats, by = "ut") |>
  mutate(
    self_dem_gt05    = as.integer(!is.na(v2x_libdem) & v2x_libdem > 0.5),
    self_dem_regime2 = as.integer(!is.na(v2x_regime)  & v2x_regime >= 2),
    self_dem_regime3 = as.integer(!is.na(v2x_regime)  & v2x_regime == 3),
    # has_dem_coauthor: any co-author (not self) from libdem > 0.5 country
    has_dem_coauthor    = as.integer(n_art_countries > 1 &
                                       (sum_dem_gt05 - self_dem_gt05) > 0),
    has_dem_coa_regime2 = as.integer(n_art_countries > 1 &
                                       (sum_dem_regime2 - self_dem_regime2) > 0),
    has_dem_coa_regime3 = as.integer(n_art_countries > 1 &
                                       (sum_dem_regime3 - self_dem_regime3) > 0)
  )

# Country-year aggregation
cy <- corpus_dem |>
  group_by(iso3, year) |>
  summarise(
    share_dem_coauthor    = mean(has_dem_coauthor,    na.rm = TRUE),
    share_dem_coa_regime2 = mean(has_dem_coa_regime2, na.rm = TRUE),
    share_dem_coa_regime3 = mean(has_dem_coa_regime3, na.rm = TRUE),
    n_articles            = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

panel <- cy |>
  filter(n_articles >= 5) |>
  filter(year >= 1990, year <= 2023) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE
mod_twfe <- feols(
  share_dem_coauthor ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  share_dem_coauthor ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1a: alternative threshold (v2x_regime >= 2)
mod_rc1a <- feols(
  share_dem_coa_regime2 ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC1b: strict threshold (v2x_regime == 3)
mod_rc1b <- feols(
  share_dem_coa_regime3 ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC2: lied_binary as focal IV
mod_rc2 <- feols(
  share_dem_coauthor ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1a: regime>=2" = mod_rc1a, "RC1b: regime==3" = mod_rc1b,
       "RC2: lied_binary" = mod_rc2),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = share_dem_coauthor)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Share of articles with democratic co-author",
       title = "Democratic co-authorship vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_dem_coauthor_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "15",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit lower shares of SSH articles with at least one co-author from a liberal democracy (v2x_libdem > 0.5).",
  theory_family    = "collaboration-constraint",
  predictor        = "v2x_libdem",
  outcome          = "share_dem_coauthor",
  model_description = "feols(share_dem_coauthor ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
