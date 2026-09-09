# =============================================================================
# Team 03 — Disciplinary Composition: Share of SSH Output in Sensitive Fields
# Pre-registered analysis plan
# Outcome: share_sensitive (proportion of country-year output in 7 sensitive fields)
# Key IV: v2x_libdem
# =============================================================================

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)
library(ggplot2)

# ---- Paths ------------------------------------------------------------------

DATA_PATH  <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR    <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_03/analysis"
FIG_DIR    <- file.path(OUT_DIR, "figures")

dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)

# ---- Load data --------------------------------------------------------------

corpus <- readRDS(DATA_PATH)
cat("Loaded corpus:", nrow(corpus), "rows,", ncol(corpus), "columns\n")
cat("Columns:", paste(names(corpus), collapse = ", "), "\n")

# ---- Step 1: Define sensitive fields ----------------------------------------

# Primary specification: 7 fields (PI-approved, PI notes gate B)
sensitive_primary <- c(
  "Political Science",
  "International Relations",
  "Law",
  "Sociology",
  "Social Issues",
  "Ethnic Studies",
  "Women's Studies"
)

# RC1: Expanded list (10 fields — adds 3 borderline fields)
sensitive_rc1 <- c(
  sensitive_primary,
  "Public Administration",
  "Area Studies",
  "Criminology & Penology"
)

# RC2: History-included (8 fields — adds History to primary)
sensitive_rc2 <- c(
  sensitive_primary,
  "History"
)

# Inspect subject_primary distribution
cat("\nTop 30 subject_primary values:\n")
print(
  corpus |>
    count(subject_primary, sort = TRUE) |>
    slice_head(n = 30)
)

# Check missingness of subject_primary
miss_subj <- sum(is.na(corpus$subject_primary))
cat("\nMissing subject_primary:", miss_subj,
    sprintf("(%.1f%%)", 100 * miss_subj / nrow(corpus)), "\n")

# ---- Step 2: Aggregate to country-year (primary) ----------------------------

# Drop rows with missing subject_primary or v2x_libdem
corpus_clean <- corpus |>
  filter(!is.na(subject_primary), !is.na(v2x_libdem))

cat("\nRows after dropping missing subject_primary / v2x_libdem:",
    nrow(corpus_clean), "\n")

country_year <- corpus_clean |>
  mutate(is_sensitive = subject_primary %in% sensitive_primary) |>
  group_by(iso3, year) |>
  summarise(
    share_sensitive  = mean(is_sensitive),
    n_articles       = n_articles_country_year[1],
    v2x_libdem       = v2x_libdem[1],
    lied_binary      = lied_binary[1],
    v2x_regime       = v2x_regime[1],
    log_gdppc        = log(e_gdppc[1]),
    log_pop          = log(e_wb_pop[1]),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10)

cat("\nCountry-year panel rows (n_articles >= 10):", nrow(country_year), "\n")
cat("Countries:", n_distinct(country_year$iso3), "\n")
cat("Years:", min(country_year$year), "–", max(country_year$year), "\n")
cat("share_sensitive summary:\n")
print(summary(country_year$share_sensitive))

# ---- Step 2b: RC1 and RC2 country-year datasets -----------------------------

country_year_rc1 <- corpus_clean |>
  mutate(is_sensitive = subject_primary %in% sensitive_rc1) |>
  group_by(iso3, year) |>
  summarise(
    share_sensitive  = mean(is_sensitive),
    n_articles       = n_articles_country_year[1],
    v2x_libdem       = v2x_libdem[1],
    lied_binary      = lied_binary[1],
    v2x_regime       = v2x_regime[1],
    log_gdppc        = log(e_gdppc[1]),
    log_pop          = log(e_wb_pop[1]),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10)

country_year_rc2 <- corpus_clean |>
  mutate(is_sensitive = subject_primary %in% sensitive_rc2) |>
  group_by(iso3, year) |>
  summarise(
    share_sensitive  = mean(is_sensitive),
    n_articles       = n_articles_country_year[1],
    v2x_libdem       = v2x_libdem[1],
    lied_binary      = lied_binary[1],
    v2x_regime       = v2x_regime[1],
    log_gdppc        = log(e_gdppc[1]),
    log_pop          = log(e_wb_pop[1]),
    .groups = "drop"
  ) |>
  filter(n_articles >= 10)

# ---- Step 3: Regression -----------------------------------------------------

# Primary model: TWFE (country + year FE), clustered SEs by iso3
mod_twfe <- feols(
  share_sensitive ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = country_year,
  cluster = ~iso3
)

# Secondary model: pooled OLS, year FE only
mod_pooled <- feols(
  share_sensitive ~ v2x_libdem + log_gdppc + log_pop | year,
  data    = country_year,
  cluster = ~iso3
)

# RC1: Expanded field list (TWFE)
mod_rc1 <- feols(
  share_sensitive ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = country_year_rc1,
  cluster = ~iso3
)

# RC2: History-included (TWFE)
mod_rc2 <- feols(
  share_sensitive ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = country_year_rc2,
  cluster = ~iso3
)

# RC3: Alternative regime measure — lied_binary (TWFE)
mod_rc3 <- feols(
  share_sensitive ~ lied_binary + log_gdppc + log_pop | iso3 + year,
  data    = country_year,
  cluster = ~iso3
)

cat("\n--- Primary TWFE model ---\n")
print(summary(mod_twfe))

cat("\n--- Pooled OLS (year FE) ---\n")
print(summary(mod_pooled))

# ---- Regression table -------------------------------------------------------

tab_dir <- file.path(OUT_DIR, "tables")
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

modelsummary(
  list(
    "TWFE (primary)"       = mod_twfe,
    "Pooled OLS (year FE)" = mod_pooled,
    "RC1: Expanded fields" = mod_rc1,
    "RC2: +History"        = mod_rc2,
    "RC3: LIED binary"     = mod_rc3
  ),
  output  = file.path(tab_dir, "tab1_main_regression.tex"),
  stars   = c("*" = 0.05, "**" = 0.01, "***" = 0.001),
  gof_map = c("nobs", "FE: iso3", "FE: year", "r.squared"),
  coef_rename = c(
    "v2x_libdem" = "Liberal democracy (v2x_libdem)",
    "lied_binary" = "Democracy (LIED binary)",
    "log_gdppc"  = "Log GDP per capita",
    "log_pop"    = "Log population"
  ),
  title = "Effect of Liberal Democracy on Share of SSH Output in Sensitive Fields"
)

cat("\nRegression table saved to", file.path(tab_dir, "tab1_main_regression.tex"), "\n")

# ---- Figure 1: Scatter — mean share_sensitive by v2x_regime -----------------

# Regime labels
country_year_plot <- country_year |>
  filter(!is.na(v2x_regime)) |>
  mutate(regime_label = factor(
    v2x_regime,
    levels = 0:3,
    labels = c("Closed autocracy", "Electoral autocracy",
               "Electoral democracy", "Liberal democracy")
  ))

fig1 <- ggplot(country_year_plot, aes(x = v2x_libdem, y = share_sensitive,
                                       colour = regime_label)) +
  geom_point(alpha = 0.25, size = 0.8) +
  geom_smooth(aes(group = regime_label), method = "loess", se = TRUE,
              linewidth = 0.9, alpha = 0.15) +
  scale_colour_manual(
    values = c("#d62728", "#ff7f0e", "#2ca02c", "#1f77b4"),
    name   = "Regime type"
  ) +
  labs(
    x     = "Liberal democracy index (v2x_libdem)",
    y     = "Share of SSH output in sensitive fields",
    title = "Disciplinary composition by regime type",
    subtitle = "Country-year observations, 1970–2023"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig1_share_by_regime.png"),
       plot = fig1, width = 8, height = 6, dpi = 150)
cat("Saved fig1_share_by_regime.png\n")

# ---- Figure 2: Coefficient plot for primary model ---------------------------

# Extract coefficient and CI from primary TWFE model
coef_df <- tibble(
  term    = "Liberal democracy\n(v2x_libdem)",
  estimate = coef(mod_twfe)["v2x_libdem"],
  se       = se(mod_twfe)["v2x_libdem"]
) |>
  mutate(
    ci_lo = estimate - 1.96 * se,
    ci_hi = estimate + 1.96 * se
  )

fig2 <- ggplot(coef_df, aes(x = estimate, y = term)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.15) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  labs(
    x     = "Coefficient (OLS, two-way FE, clustered SE)",
    y     = NULL,
    title = "Effect of liberal democracy on share of output in sensitive fields",
    subtitle = "Primary TWFE model; 95% confidence interval"
  ) +
  theme_minimal(base_size = 12)

ggsave(file.path(FIG_DIR, "fig2_coef_main.png"),
       plot = fig2, width = 7, height = 4, dpi = 150)
cat("Saved fig2_coef_main.png\n")

# ---- Figure 3: Time-series by democracy/autocracy group ---------------------

trend_data <- country_year |>
  filter(!is.na(lied_binary)) |>
  mutate(regime_group = if_else(lied_binary == 1, "Democracy", "Autocracy")) |>
  group_by(year, regime_group) |>
  summarise(
    mean_share = mean(share_sensitive, na.rm = TRUE),
    .groups    = "drop"
  )

fig3 <- ggplot(trend_data, aes(x = year, y = mean_share,
                                colour = regime_group, linetype = regime_group)) +
  geom_line(linewidth = 1) +
  scale_colour_manual(values = c("Democracy" = "#1f77b4", "Autocracy" = "#d62728"),
                      name = NULL) +
  scale_linetype_manual(values = c("Democracy" = "solid", "Autocracy" = "dashed"),
                        name = NULL) +
  labs(
    x     = "Year",
    y     = "Mean share of output in sensitive fields",
    title = "Trend in disciplinary composition by regime group",
    subtitle = "Mean share_sensitive; democracies vs. autocracies (LIED binary)"
  ) +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig3_trend_over_time.png"),
       plot = fig3, width = 9, height = 5, dpi = 150)
cat("Saved fig3_trend_over_time.png\n")

# ---- Write primary_results.json ---------------------------------------------

hypothesis_label <- paste0(
  "Countries with lower Liberal democracy levels will produce a lower share of ",
  "SSH output in politically sensitive disciplines, after controlling for country ",
  "fixed effects, year fixed effects, log GDP per capita, and log population."
)

primary_results <- list(
  team             = "03",
  hypothesis_label = hypothesis_label,
  theory_family    = "topic-avoidance",
  predictor        = "v2x_libdem",
  outcome          = "share_sensitive",
  model_description = "feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(country_year$iso3[!is.na(country_year$v2x_libdem)]))
)

write_json(
  primary_results,
  path       = file.path(OUT_DIR, "primary_results.json"),
  auto_unbox = TRUE,
  pretty     = TRUE
)

cat("\nprimary_results.json written to", file.path(OUT_DIR, "primary_results.json"), "\n")
cat("\n=== Key result ===\n")
cat(sprintf(
  "v2x_libdem coefficient: %.6f  SE: %.6f  t: %.4f  p: %.6f\n",
  primary_results$coefficient,
  primary_results$se,
  primary_results$t_stat,
  primary_results$p_value
))
cat(sprintf("N obs: %d  N countries: %d\n",
            primary_results$n_obs, primary_results$n_countries))
cat("\nAnalysis complete.\n")
