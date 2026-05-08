# Team 02 — Analysis: Shannon entropy of author keywords by country-year
# Pre-registered outcome: keyword_entropy_cy
# Key IV: v2x_libdem
# Model: TWFE (country + year FE) and pooled OLS (year FE only)
# Author: Team 02 Analyst Agent

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

# ---- Paths ----------------------------------------------------------------
proj_root <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra"
data_path <- file.path(proj_root, "data/agent_corpus.rds")
out_dir   <- file.path(proj_root, "teams/team_02/analysis")
fig_dir   <- file.path(out_dir, "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Load data ------------------------------------------------------------
raw <- readRDS(data_path)

# ---- Construct keyword_entropy_cy -----------------------------------------
# Keep only rows with non-missing keywords
kw_rows <- raw |>
  filter(!is.na(keywords), nchar(trimws(keywords)) > 0)

# Parse keywords: split on ";" or "|", trim, lowercase
kw_long <- kw_rows |>
  select(iso3, year, keywords) |>
  mutate(kw_list = str_split(keywords, "[;|]")) |>
  unnest(kw_list) |>
  mutate(kw = str_to_lower(trimws(kw_list))) |>
  filter(nchar(kw) > 0) |>
  select(iso3, year, kw)

# Count keyword-bearing articles per country-year for denominator check
articles_with_kw <- kw_rows |>
  group_by(iso3, year) |>
  summarise(n_kw_articles = n_distinct(row_number()), .groups = "drop")

# Compute Shannon entropy per country-year
shannon_entropy <- function(tokens) {
  freq <- table(tokens)
  p    <- as.numeric(freq) / sum(freq)
  -sum(p * log(p + 1e-10))
}

entropy_cy <- kw_long |>
  group_by(iso3, year) |>
  summarise(
    keyword_entropy_cy = shannon_entropy(kw),
    n_kw_tokens        = n(),
    .groups = "drop"
  )

# Count keyword-bearing articles per country-year
n_kw_art <- kw_rows |>
  group_by(iso3, year) |>
  summarise(n_kw_articles = n(), .groups = "drop")

entropy_cy <- entropy_cy |>
  left_join(n_kw_art, by = c("iso3", "year"))

# Drop country-years with < 10 keyword-bearing articles
entropy_cy <- entropy_cy |>
  filter(n_kw_articles >= 10)

# ---- Join controls ---------------------------------------------------------
# Get one row per country-year for the regime/control variables
controls_cy <- raw |>
  select(iso3, year, v2x_libdem, lied_binary, v2x_regime,
         e_gdppc, e_wb_pop, n_articles_country_year) |>
  distinct()

panel <- entropy_cy |>
  left_join(controls_cy, by = c("iso3", "year")) |>
  filter(!is.na(v2x_libdem),
         !is.na(e_gdppc),
         !is.na(e_wb_pop),
         e_gdppc > 0,
         e_wb_pop > 0) |>
  filter(year >= 1990, year <= 2023) |>
  mutate(
    log_gdppc = log(e_gdppc),
    log_pop   = log(e_wb_pop),
    log_n_art = log(n_kw_articles)
  )

cat("Panel rows:", nrow(panel), "\n")
cat("Countries:", n_distinct(panel$iso3), "\n")
cat("Years:", min(panel$year), "-", max(panel$year), "\n")

# ---- Regression models ----------------------------------------------------

# Primary: TWFE weighted by log(n_kw_articles)
mod_twfe <- feols(
  keyword_entropy_cy ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = panel,
  cluster = ~iso3,
  weights = ~log_n_art
)

# Secondary: pooled OLS with year FE only
mod_ols <- feols(
  keyword_entropy_cy ~ v2x_libdem + log_gdppc + log_pop | year,
  data    = panel,
  cluster = ~iso3,
  weights = ~log_n_art
)

# RC1: TWFE unweighted (robustness)
mod_unweighted <- feols(
  keyword_entropy_cy ~ v2x_libdem + log_gdppc + log_pop | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# RC2: binary regime measure (lied_binary)
mod_lied <- feols(
  keyword_entropy_cy ~ lied_binary + log_gdppc + log_pop | iso3 + year,
  data    = panel |> filter(!is.na(lied_binary)),
  cluster = ~iso3,
  weights = ~log_n_art
)

# Print summaries
cat("\n=== Primary TWFE ===\n"); print(summary(mod_twfe))
cat("\n=== Pooled OLS (year FE) ===\n"); print(summary(mod_ols))
cat("\n=== Unweighted TWFE ===\n"); print(summary(mod_unweighted))
cat("\n=== lied_binary TWFE ===\n"); print(summary(mod_lied))

# ---- Regression table (Tab 1) ---------------------------------------------
tab1 <- modelsummary(
  list(
    "Pooled OLS (year FE)" = mod_ols,
    "TWFE (main)"          = mod_twfe,
    "TWFE unweighted"      = mod_unweighted,
    "TWFE lied_binary"     = mod_lied
  ),
  stars     = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map  = c(
    v2x_libdem  = "Liberal democracy",
    lied_binary = "Democracy (binary)",
    log_gdppc   = "log(GDP pc)",
    log_pop     = "log(Population)"
  ),
  gof_map   = c("nobs", "r.squared", "adj.r.squared"),
  output    = file.path(out_dir, "tab1_main_results.tex")
)

# ---- Figure 1: Entropy by regime category ---------------------------------
# v2x_regime: 0=closed autocracy, 1=electoral autocracy, 2=electoral democracy, 3=liberal democracy
regime_labels <- c("0" = "Closed autocracy",
                    "1" = "Electoral autocracy",
                    "2" = "Electoral democracy",
                    "3" = "Liberal democracy")

fig1_data <- panel |>
  filter(!is.na(v2x_regime)) |>
  mutate(regime_cat = factor(
    round(v2x_regime),
    levels = 0:3,
    labels = regime_labels
  ))

p1 <- ggplot(fig1_data, aes(x = regime_cat, y = keyword_entropy_cy, fill = regime_cat)) +
  geom_boxplot(outlier.size = 0.5, alpha = 0.8) +
  scale_fill_manual(values = c("#d73027", "#fc8d59", "#91bfdb", "#4575b4")) +
  labs(
    title    = "Keyword entropy by regime type",
    subtitle = "Country-year observations, 1990–2023",
    x        = NULL,
    y        = "Shannon entropy (keyword distribution)",
    caption  = "Country-years with >= 10 keyword-bearing articles. Weighted TWFE sample."
  ) +
  theme_bw() +
  theme(legend.position = "none",
        axis.text.x     = element_text(angle = 15, hjust = 1))

ggsave(file.path(fig_dir, "fig1_entropy_by_regime.png"), p1,
       width = 7, height = 5, dpi = 300)
cat("Saved fig1\n")

# ---- Figure 2: Mean entropy over time by democracy/autocracy --------------
fig2_data <- panel |>
  filter(!is.na(lied_binary)) |>
  mutate(regime_broad = ifelse(lied_binary == 1, "Democratic", "Autocratic")) |>
  group_by(year, regime_broad) |>
  summarise(
    mean_entropy = mean(keyword_entropy_cy, na.rm = TRUE),
    .groups = "drop"
  )

p2 <- ggplot(fig2_data, aes(x = year, y = mean_entropy,
                             color = regime_broad, linetype = regime_broad)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.2) +
  scale_color_manual(values = c("Democratic" = "#4575b4", "Autocratic" = "#d73027")) +
  labs(
    title    = "Mean keyword entropy over time by regime type",
    subtitle = "Country-year level, 1990–2023",
    x        = "Year",
    y        = "Mean Shannon entropy",
    color    = NULL,
    linetype = NULL
  ) +
  theme_bw() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig2_entropy_trend.png"), p2,
       width = 7, height = 5, dpi = 300)
cat("Saved fig2\n")

# ---- Figure 3: Coefficient plot -------------------------------------------
coef_df <- bind_rows(
  tibble(
    model  = "TWFE (main)",
    term   = "v2x_libdem",
    est    = coef(mod_twfe)["v2x_libdem"],
    se     = se(mod_twfe)["v2x_libdem"]
  ),
  tibble(
    model  = "TWFE unweighted",
    term   = "v2x_libdem",
    est    = coef(mod_unweighted)["v2x_libdem"],
    se     = se(mod_unweighted)["v2x_libdem"]
  ),
  tibble(
    model  = "TWFE lied_binary",
    term   = "lied_binary",
    est    = coef(mod_lied)["lied_binary"],
    se     = se(mod_lied)["lied_binary"]
  ),
  tibble(
    model  = "Pooled OLS (year FE)",
    term   = "v2x_libdem",
    est    = coef(mod_ols)["v2x_libdem"],
    se     = se(mod_ols)["v2x_libdem"]
  )
) |>
  mutate(
    lo95 = est - 1.96 * se,
    hi95 = est + 1.96 * se,
    lo90 = est - 1.645 * se,
    hi90 = est + 1.645 * se,
    model = factor(model, levels = c(
      "Pooled OLS (year FE)", "TWFE (main)",
      "TWFE unweighted", "TWFE lied_binary"
    ))
  )

p3 <- ggplot(coef_df, aes(x = model, y = est)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_linerange(aes(ymin = lo95, ymax = hi95), linewidth = 0.8) +
  geom_linerange(aes(ymin = lo90, ymax = hi90), linewidth = 1.6) +
  geom_point(size = 3, color = "#2166ac") +
  coord_flip() +
  labs(
    title    = "Effect of democracy on keyword entropy: main result and robustness",
    subtitle = "Inner line = 90% CI; outer line = 95% CI",
    x        = NULL,
    y        = "Coefficient"
  ) +
  theme_bw()

ggsave(file.path(fig_dir, "fig3_main_coef.png"), p3,
       width = 7, height = 4, dpi = 300)
cat("Saved fig3\n")

# ---- Write primary_results.json -------------------------------------------
res <- list(
  team             = "02",
  hypothesis_label = "Countries with lower Liberal democracy levels will exhibit lower Shannon entropy of author-supplied keyword distributions at the country-year level, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.",
  theory_family    = "topic-avoidance",
  predictor        = "v2x_libdem",
  outcome          = "keyword_entropy_cy",
  model_description = "feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient      = unname(coef(mod_twfe)["v2x_libdem"]),
  se               = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat           = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value          = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs            = as.integer(nobs(mod_twfe)),
  n_countries      = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem)]))
)

write_json(res, file.path(out_dir, "primary_results.json"),
           pretty = TRUE, auto_unbox = TRUE, digits = NA)
cat("Wrote primary_results.json\n")

cat("\n=== Done ===\n")
cat("Coefficient on v2x_libdem (TWFE):", res$coefficient, "\n")
cat("SE:", res$se, "\n")
cat("p-value:", res$p_value, "\n")
cat("N obs:", res$n_obs, "\n")
cat("N countries:", res$n_countries, "\n")
