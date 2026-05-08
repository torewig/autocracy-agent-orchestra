# Team 18 — Institutional Diversity and Autocracy
# Outcome: mean_n_inst = mean distinct institutions per article, country-year
# Theory family: collaboration-constraint

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/teams/team_18/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

# Check institutions coverage
n_with_inst <- sum(!is.na(corpus$institutions) & corpus$institutions != "")
message(sprintf("Rows with non-missing institutions: %d (%.1f%%)",
                n_with_inst, 100 * n_with_inst / nrow(corpus)))

# Count distinct institutions per article (deduplicate by ut first)
message("Computing institution count per article ...")

art_inst <- corpus |>
  filter(!is.na(institutions), institutions != "") |>
  distinct(ut, .keep_all = TRUE) |>  # one row per article
  mutate(
    n_inst = map_int(str_split(institutions, ";"),
                     ~ length(unique(trimws(.x[nchar(trimws(.x)) > 0]))))
  ) |>
  select(ut, n_inst)

message(sprintf("Articles with institution data: %d", nrow(art_inst)))

# Join back to article-country rows
corpus_inst <- corpus |>
  filter(!is.na(iso3)) |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  left_join(art_inst, by = "ut")

# Country-year aggregation (only articles with institution data)
cy <- corpus_inst |>
  filter(!is.na(n_inst)) |>
  group_by(iso3, year) |>
  summarise(
    mean_n_inst    = mean(n_inst, na.rm = TRUE),
    log_mean_n_inst = mean(log(n_inst + 1), na.rm = TRUE),
    n_with_inst    = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

# Also compute co-author breadth (from Team 14's approach) as additional control
art_n_countries <- corpus |>
  filter(!is.na(iso3)) |>
  group_by(ut) |>
  summarise(n_coauthor_countries = n_distinct(iso3), .groups = "drop")

cy_coauth <- corpus |>
  filter(!is.na(iso3)) |>
  distinct(ut, iso3, year) |>
  left_join(art_n_countries, by = "ut") |>
  group_by(iso3, year) |>
  summarise(mean_n_coauthor_countries = mean(n_coauthor_countries, na.rm = TRUE),
            .groups = "drop")

panel <- cy |>
  filter(n_with_inst >= 5) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year)) |>
  left_join(cy_coauth, by = c("iso3", "year"))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE (with mean_n_coauthor_countries as additional pre-registered control)
mod_twfe <- feols(
  mean_n_inst ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + mean_n_coauthor_countries | iso3 + year,
  data = panel, cluster = ~iso3
)

# Secondary: without co-author breadth control (baseline TWFE)
mod_twfe_base <- feols(
  mean_n_inst ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  mean_n_inst ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + mean_n_coauthor_countries | year,
  data = panel, cluster = ~iso3
)

# RC1: multi-author articles only
corpus_multi_inst <- corpus_inst |>
  filter(!is.na(n_inst), !is.na(n_authors), n_authors > 1)
cy_multi <- corpus_multi_inst |>
  group_by(iso3, year) |>
  summarise(
    mean_n_inst_multi = mean(n_inst, na.rm = TRUE),
    n_multi = n(), v2x_libdem = first(v2x_libdem),
    e_gdppc = first(e_gdppc), e_wb_pop = first(e_wb_pop),
    .groups = "drop"
  )
panel_multi <- cy_multi |>
  filter(n_multi >= 5, !is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |> mutate(year = as.integer(year))

mod_rc1 <- feols(
  mean_n_inst_multi ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel_multi, cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  mean_n_inst ~ lied_binary + log(e_gdppc) + log(e_wb_pop) + mean_n_coauthor_countries | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC3: log outcome
mod_rc3 <- feols(
  log_mean_n_inst ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + mean_n_coauthor_countries | iso3 + year,
  data = panel, cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "TWFE (no coauth ctrl)" = mod_twfe_base,
       "Pooled OLS" = mod_pool, "RC1: Multi-author" = mod_rc1,
       "RC2: lied_binary" = mod_rc2, "RC3: Log outcome" = mod_rc3),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "mean_n_coauthor_countries" = "Mean co-author country count",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = mean_n_inst)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Mean institutions per article",
       title = "Institutional diversity vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_n_inst_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "18",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit lower mean counts of distinct author institutions per SSH article.",
  theory_family    = "collaboration-constraint",
  predictor        = "v2x_libdem",
  outcome          = "mean_n_inst",
  model_description = "feols(mean_n_inst ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + mean_n_coauthor_countries | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
