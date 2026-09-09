# Team 22 — Citation Concentration (Gini) and Autocracy
# Outcome: gini_tot_cites = Gini coefficient of tot_cites per country-year
# Theory family: visibility-suppression

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_22/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

# Custom Gini function
gini_approx <- function(x) {
  x <- x[!is.na(x) & x >= 0]
  if (length(x) < 2) return(NA_real_)
  x <- sort(x)
  n <- length(x)
  2 * sum(seq_len(n) * x) / (n * sum(x)) - (n + 1) / n
}

message("Computing Gini per country-year ...")

# Deduplicate: one row per (article × focal country)
articles <- corpus |>
  filter(!is.na(iso3), !is.na(tot_cites)) |>
  distinct(ut, iso3, year, .keep_all = TRUE)

# Country-year aggregation
cy <- articles |>
  group_by(iso3, year) |>
  summarise(
    gini_tot_cites  = gini_approx(tot_cites),
    top1pct_share   = {
      x <- tot_cites[!is.na(tot_cites)]
      if (length(x) < 2) NA_real_
      else sum(sort(x, decreasing = TRUE)[1:max(1, floor(0.01 * length(x)))]) / sum(x)
    },
    n_articles      = n(),
    log_n_articles  = log(n()),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

panel <- cy |>
  filter(n_articles >= 10, !is.na(gini_tot_cites)) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE (with log_n_articles as extra pre-registered control)
mod_twfe <- feols(
  gini_tot_cites ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  gini_tot_cites ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | year,
  data = panel, cluster = ~iso3
)

# RC1: exclude post-2018 articles
cy_mature <- articles |>
  filter(year <= 2018) |>
  group_by(iso3, year) |>
  summarise(
    gini_mature = gini_approx(tot_cites),
    n_mat = n(), log_n_mat = log(n()),
    v2x_libdem = first(v2x_libdem),
    e_gdppc = first(e_gdppc), e_wb_pop = first(e_wb_pop),
    .groups = "drop"
  )
panel_mature <- cy_mature |>
  filter(n_mat >= 10, !is.na(gini_mature), !is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |> mutate(year = as.integer(year))

mod_rc1 <- feols(
  gini_mature ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_mat | iso3 + year,
  data = panel_mature, cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  gini_tot_cites ~ lied_binary + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC3: top-1% share as alternative outcome
mod_rc3 <- feols(
  top1pct_share ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year,
  data = panel |> filter(!is.na(top1pct_share)), cluster = ~iso3
)

# RC4: higher thresholds
mod_rc4a <- feols(
  gini_tot_cites ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year,
  data = filter(panel, n_articles >= 20), cluster = ~iso3
)
mod_rc4b <- feols(
  gini_tot_cites ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year,
  data = filter(panel, n_articles >= 30), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1: Pre-2019" = mod_rc1, "RC2: lied_binary" = mod_rc2,
       "RC3: Top-1% share" = mod_rc3),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population",
               "log_n_articles" = "Log article count"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = gini_tot_cites)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Gini coefficient of citations",
       title = "Citation concentration (Gini) vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_gini_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "22",
  hypothesis_label = "Countries with lower liberal democracy levels exhibit higher Gini coefficients of citation distributions, indicating greater citation concentration.",
  theory_family    = "visibility-suppression",
  predictor        = "v2x_libdem",
  outcome          = "gini_tot_cites",
  model_description = "feols(gini_tot_cites ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) + log_n_articles | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
