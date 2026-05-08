# Team 09 — Normative Language Avoidance and Autocracy
# Outcome: mean_norm_rate (normative terms per word, country-year mean)
# Theory family: framing-neutrality

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra/teams/team_09/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

NORM_PATTERN_PRIMARY  <- "\\b(should|ought|justice|rights|freedom|liberty|equality|dignity|fairness|democracy|accountability)\\b"
NORM_PATTERN_NARROW   <- "\\b(should|ought|justice|liberty|equality|dignity|fairness|accountability)\\b"

message("Computing article-level normative rates ...")

articles <- corpus |>
  filter(!is.na(abstract), abstract != "") |>
  mutate(
    word_count  = str_count(abstract, "\\w+"),
    norm_count  = str_count(tolower(abstract), NORM_PATTERN_PRIMARY),
    norm_narrow = str_count(tolower(abstract), NORM_PATTERN_NARROW)
  ) |>
  filter(word_count >= 20) |>
  mutate(
    norm_rate        = norm_count  / word_count,
    norm_rate_narrow = norm_narrow / word_count
  )

# Deduplicate per article × country × year
articles_dedup <- articles |>
  distinct(ut, iso3, year, .keep_all = TRUE)

cy <- articles_dedup |>
  group_by(iso3, year) |>
  summarise(
    mean_norm_rate        = mean(norm_rate,        na.rm = TRUE),
    median_norm_rate      = median(norm_rate,      na.rm = TRUE),
    mean_norm_rate_narrow = mean(norm_rate_narrow, na.rm = TRUE),
    n_abstracts           = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

panel <- cy |>
  filter(n_abstracts >= 5) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE
mod_twfe <- feols(
  mean_norm_rate ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  mean_norm_rate ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: narrow dictionary
mod_narrow <- feols(
  mean_norm_rate_narrow ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC2: lied_binary
mod_lied <- feols(
  mean_norm_rate ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC3: median outcome
mod_median <- feols(
  median_norm_rate ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

print(summary(mod_twfe))

# Regression table
modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC: Narrow dict." = mod_narrow, "RC: lied_binary" = mod_lied,
       "RC: Median outcome" = mod_median),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

# Figure 1 — scatter + LOESS
p1 <- ggplot(panel, aes(x = v2x_libdem, y = mean_norm_rate)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Mean normative language rate",
       title = "Normative language rate vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_norm_rate_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

# Write primary_results.json
results <- list(
  team             = "09",
  hypothesis_label = "Countries with lower liberal democracy levels produce SSH abstracts with lower rates of normative evaluative language.",
  theory_family    = "framing-neutrality",
  predictor        = "v2x_libdem",
  outcome          = "mean_norm_rate",
  model_description = "feols(mean_norm_rate ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
