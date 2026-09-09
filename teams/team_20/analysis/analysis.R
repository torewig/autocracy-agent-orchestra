# Team 20 — Citation Gap by Topic (Sensitive vs. Non-sensitive) and Autocracy
# Outcome: log1p(cite_ratio) at article level
# Key test: interaction v2x_libdem * sensitive_flag
# Theory family: visibility-suppression

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_20/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

# Regime-sensitive keyword dictionary (Team 04 standard)
SENSITIVE_PATTERN <- paste0(
  "\\b(democrac|human rights|civil rights|corruption|protest|repression|",
  "censorship|political prisoner|authoritarian|political freedom|",
  "electoral fraud|dissent|opposition movement)\\b"
)

message("Constructing article-level dataset ...")

# Primary sample: articles with citations and field-year mean available
articles <- corpus |>
  filter(!is.na(tot_cites), !is.na(field_year_mean_cites)) |>
  filter(field_year_mean_cites > 0) |>
  filter(!is.na(iso3), !is.na(v2x_libdem)) |>
  filter(year >= 1990, year <= 2020) |>
  mutate(
    # Outcome
    cite_ratio     = tot_cites / field_year_mean_cites,
    log_cite_ratio = log1p(cite_ratio),
    # Sensitive flag: match on paste(title, keywords)
    text_for_flag  = tolower(paste(coalesce(title, ""), coalesce(keywords, ""), sep = " | ")),
    sensitive_flag = as.integer(str_detect(text_for_flag, SENSITIVE_PATTERN))
  )

message(sprintf("Article-level sample: %d rows", nrow(articles)))
message(sprintf("Sensitive articles: %d (%.1f%%)",
                sum(articles$sensitive_flag), 100 * mean(articles$sensitive_flag)))

# Remove rows with missing subject_primary (needed for field FE)
articles_fe <- articles |> filter(!is.na(subject_primary))

message(sprintf("Sample with subject_primary: %d rows", nrow(articles_fe)))

# Primary model: TWFE with interaction (country + year + field FE)
mod_twfe <- feols(
  log_cite_ratio ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary,
  data = articles_fe, cluster = ~iso3
)

# Secondary: year + field FE only (no country FE)
mod_pool <- feols(
  log_cite_ratio ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) | year + subject_primary,
  data = articles_fe, cluster = ~iso3
)

# RC1: lied_binary interaction
mod_rc1 <- feols(
  log_cite_ratio ~ lied_binary * sensitive_flag + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary,
  data = articles_fe |> filter(!is.na(lied_binary)), cluster = ~iso3
)

# RC2: narrow keyword dictionary (5 core terms)
NARROW_PATTERN <- "\\b(democrac|human rights|corruption|protest|authoritarianism)\\b"
articles_fe <- articles_fe |>
  mutate(sensitive_narrow = as.integer(str_detect(text_for_flag, NARROW_PATTERN)))

mod_rc2 <- feols(
  log_cite_ratio ~ v2x_libdem * sensitive_narrow + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary,
  data = articles_fe, cluster = ~iso3
)

# RC3: title-only matching
articles_fe <- articles_fe |>
  mutate(sensitive_title = as.integer(str_detect(tolower(coalesce(title, "")), SENSITIVE_PATTERN)))

mod_rc3 <- feols(
  log_cite_ratio ~ v2x_libdem * sensitive_title + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary,
  data = articles_fe, cluster = ~iso3
)

# RC4: restrict to 1990–2015 (citation maturity)
mod_rc4 <- feols(
  log_cite_ratio ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary,
  data = filter(articles_fe, year <= 2015), cluster = ~iso3
)

print(summary(mod_twfe))

modelsummary(
  list("TWFE+interaction (primary)" = mod_twfe, "Year+Field FE" = mod_pool,
       "RC1: lied_binary" = mod_rc1, "RC2: Narrow dict." = mod_rc2,
       "RC3: Title only" = mod_rc3, "RC4: Pre-2016" = mod_rc4),
  stars = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "v2x_libdem" = "Liberal democracy (V-DEM)",
    "sensitive_flag" = "Sensitive topic flag",
    "v2x_libdem:sensitive_flag" = "Libdem × Sensitive",
    "lied_binary" = "Democracy (binary)",
    "lied_binary:sensitive_flag" = "Binary demo × Sensitive",
    "v2x_libdem:sensitive_narrow" = "Libdem × Sensitive (narrow)",
    "v2x_libdem:sensitive_title" = "Libdem × Sensitive (title)",
    "log(e_gdppc)" = "Log GDP per capita",
    "log(e_wb_pop)" = "Log population"
  ),
  gof_map = c("nobs", "r.squared"),
  output = file.path(FIG_DIR, "tab1_main_results.tex")
)

# Figure: mean log cite ratio by regime × sensitivity
fig_data <- articles_fe |>
  filter(!is.na(v2x_libdem)) |>
  mutate(
    regime_broad = ifelse(v2x_libdem >= 0.5, "More democratic\n(libdem>=0.5)",
                          "Less democratic\n(libdem<0.5)"),
    sensitive    = factor(sensitive_flag, levels = c(0, 1),
                          labels = c("Non-sensitive", "Sensitive"))
  ) |>
  group_by(regime_broad, sensitive) |>
  summarise(mean_log_cite = mean(log_cite_ratio, na.rm = TRUE),
            se_log_cite   = sd(log_cite_ratio, na.rm = TRUE) / sqrt(n()),
            .groups = "drop")

p1 <- ggplot(fig_data, aes(x = regime_broad, y = mean_log_cite,
                            fill = sensitive, group = sensitive)) +
  geom_col(position = position_dodge(0.7), width = 0.6) +
  geom_errorbar(aes(ymin = mean_log_cite - 1.96 * se_log_cite,
                    ymax = mean_log_cite + 1.96 * se_log_cite),
                position = position_dodge(0.7), width = 0.2) +
  scale_fill_manual(values = c("Non-sensitive" = "steelblue", "Sensitive" = "firebrick")) +
  labs(x = NULL, y = "Mean log citation ratio",
       fill = NULL,
       title = "Citation impact by regime type and topic sensitivity") +
  theme_bw(base_size = 11)
ggsave(file.path(FIG_DIR, "fig1_cite_gap_by_regime_topic.png"), p1, width = 7, height = 5, dpi = 150)

# Primary coefficient: the INTERACTION term v2x_libdem:sensitive_flag
results <- list(
  team             = "20",
  hypothesis_label = "In autocracies, sensitive-topic SSH articles are cited less than non-sensitive articles relative to democratic contexts (positive interaction: v2x_libdem x sensitive_flag).",
  theory_family    = "visibility-suppression",
  predictor        = "v2x_libdem:sensitive_flag",
  outcome          = "log_cite_ratio (article-level)",
  model_description = "feols(log1p(cite_ratio) ~ v2x_libdem * sensitive_flag + log(e_gdppc) + log(e_wb_pop) | iso3 + year + subject_primary, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem:sensitive_flag"]),
  se               = unname(se(mod_twfe)["v2x_libdem:sensitive_flag"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem:sensitive_flag"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem:sensitive_flag"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(articles_fe$iso3[!is.na(articles_fe$v2x_libdem)]))
)
write_json(results, file.path(OUT_DIR, "primary_results.json"), pretty = TRUE, auto_unbox = TRUE)

message(sprintf("Done. interaction coef=%.6f  SE=%.6f  p=%.4f",
                results$coefficient, results$se, results$p_value))
