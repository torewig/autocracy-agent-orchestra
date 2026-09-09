# Team 11 — First-Person Argumentative Stance and Autocracy
# Outcome: stance_rate_mean (argumentative stance phrases per word, country-year mean)
# Theory family: framing-neutrality

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_11/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

STANCE_PRIMARY  <- "we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim"
STANCE_EXTENDED <- "we argue|i argue|we show|we find|we demonstrate|we contend|this paper argues|we claim|we suggest|we propose|we hypothesize|we posit|this paper contends|the authors argue"

message("Computing article-level stance rates ...")

articles <- corpus |>
  filter(!is.na(abstract), abstract != "") |>
  mutate(
    word_count      = str_count(abstract, "\\w+"),
    stance_count    = str_count(tolower(abstract), STANCE_PRIMARY),
    stance_extended = str_count(tolower(abstract), STANCE_EXTENDED)
  ) |>
  filter(word_count >= 20) |>
  mutate(
    stance_rate          = stance_count    / word_count,
    stance_rate_extended = stance_extended / word_count
  )

articles_dedup <- articles |>
  distinct(ut, iso3, year, .keep_all = TRUE)

# RC1: English-language filter (ASCII heuristic >= 90%)
articles_dedup <- articles_dedup |>
  mutate(
    is_english = (nchar(gsub("[^\x01-\x7F]", "", abstract, perl = TRUE)) /
                  nchar(abstract)) >= 0.90
  )

cy_full <- articles_dedup |>
  group_by(iso3, year) |>
  summarise(
    stance_rate_mean          = mean(stance_rate,          na.rm = TRUE),
    stance_rate_extended_mean = mean(stance_rate_extended, na.rm = TRUE),
    n_abstracts               = n(),
    v2x_libdem   = first(v2x_libdem),
    lied_binary  = first(lied_binary),
    e_gdppc      = first(e_gdppc),
    e_wb_pop     = first(e_wb_pop),
    .groups = "drop"
  )

cy_english <- articles_dedup |>
  filter(is_english) |>
  group_by(iso3, year) |>
  summarise(
    stance_rate_mean_en = mean(stance_rate, na.rm = TRUE),
    n_english           = n(),
    .groups = "drop"
  )

panel <- cy_full |>
  filter(n_abstracts >= 5) |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(year = as.integer(year)) |>
  left_join(cy_english, by = c("iso3", "year"))

message(sprintf("Panel: %d rows | %d countries | %d-%d",
                nrow(panel), n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# Primary TWFE
mod_twfe <- feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Pooled OLS
mod_pool <- feols(
  stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: English only
panel_en <- panel |> filter(!is.na(stance_rate_mean_en), n_english >= 5)
mod_rc1 <- feols(
  stance_rate_mean_en ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel_en, cluster = ~iso3
)

# RC2: lied_binary
mod_rc2 <- feols(
  stance_rate_mean ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC3: extended phrase list
mod_rc3 <- feols(
  stance_rate_extended_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE (primary)" = mod_twfe, "Pooled OLS" = mod_pool,
       "RC1: English only" = mod_rc1, "RC2: lied_binary" = mod_rc2,
       "RC3: Extended phrases" = mod_rc3),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c("v2x_libdem" = "Liberal democracy (V-DEM)",
               "lied_binary" = "Democracy (binary, LIED)",
               "log(e_gdppc)" = "Log GDP per capita",
               "log(e_wb_pop)" = "Log population"),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

p1 <- ggplot(panel, aes(x = v2x_libdem, y = stance_rate_mean)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick", linewidth = 0.8) +
  labs(x = "V-DEM Liberal Democracy Index",
       y = "Mean first-person stance rate",
       title = "Argumentative stance rate vs. liberal democracy") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_stance_rate_by_regime.png"), p1, width = 7, height = 5, dpi = 150)

results <- list(
  team             = "11",
  hypothesis_label = "Countries with lower liberal democracy levels produce SSH abstracts with lower rates of first-person argumentative stance phrases.",
  theory_family    = "framing-neutrality",
  predictor        = "v2x_libdem",
  outcome          = "stance_rate_mean",
  model_description = "feols(stance_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. coef=%.6f  SE=%.6f  p=%.4f", results$coefficient, results$se, results$p_value))
