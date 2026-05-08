# Team 21 — Share Ever Cited and Autocracy
# Outcome: prop_ever_cited = proportion of articles with tot_cites >= 1 per country-year
# Theory family: visibility-suppression

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/teams/team_21/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

message("Computing share ever-cited ...")

# Deduplicate: one row per (article × focal country)
articles <- corpus |>
  filter(!is.na(iso3), !is.na(tot_cites)) |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  mutate(ever_cited = as.integer(tot_cites >= 1))

# Country-year aggregation
cy <- articles |>
  group_by(iso3, year) |>
  summarise(
    prop_ever_cited = mean(ever_cited, na.rm = TRUE),
    n_articles      = n(),
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
  prop_ever_cited ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  prop_ever_cited ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: restrict to 1990–2023
mod_rc1 <- feols(
  prop_ever_cited ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = filter(panel, year >= 1990), cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  prop_ever_cited ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1: Post-1990" = mod_rc1, "RC2: lied_binary" = mod_rc2),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = prop_ever_cited)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Share of articles ever cited",
       title = "Share ever-cited vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_ever_cited_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "21",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit lower shares of SSH articles that receive at least one citation.",
  theory_family    = "visibility-suppression",
  predictor        = "v2x_libdem",
  outcome          = "prop_ever_cited",
  model_description = "feols(prop_ever_cited ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
