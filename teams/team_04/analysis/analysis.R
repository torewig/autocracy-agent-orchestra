# Team 04 — Regime-sensitive keyword prevalence analysis
# Research question: Do researchers from more autocratic countries publish SSH
# articles with regime-sensitive terms at lower rates?
# Pre-registration: teams/team_04/preregistration.md

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

# ---- Paths ------------------------------------------------------------------

data_path   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
out_dir     <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_04/analysis"
fig_dir     <- file.path(out_dir, "figures")

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Load data --------------------------------------------------------------

corpus <- readRDS(data_path)

# ---- Dictionary (PI-approved, see preregistration.md + pi_notes.md) ---------
# PI note: remove "demonstrat" (too broad); use "demonstration" instead.

dict_pattern <- paste(
  "democra",
  "human rights", "civil rights", "civil liberties",
  "corrupt", "bribery", "kleptocra",
  "\\bprotest", "demonstration", "\\buprising", "\\briot\\b", "\\brebellion", "civil unrest",
  "\\brepression", "repressive", "state violence", "state terror",
  "\\bcensor", "political prisoner", "prisoner of conscience",
  "authoritarian", "\\bautocraci", "\\bdictatorship",
  "political freedom", "freedom of expression", "freedom of press", "free press", "free speech",
  "election fraud", "electoral fraud", "vote rigging", "vote buying", "electoral manipulation",
  "\\bdissent", "\\bdissident", "political opposition", "regime critic",
  sep = "|"
)

# Dictionary for RC1: title + keywords only (no abstract)
dict_pattern_rc1 <- dict_pattern  # same pattern, different fields

# ---- Stage 1: Flag regime-sensitive articles --------------------------------
# Primary: match on title + keywords + abstract (PI extension)
# NA fields treated as empty string

corpus <- corpus |>
  mutate(
    text_full = paste(
      replace_na(title,    ""),
      replace_na(keywords, ""),
      replace_na(abstract, ""),
      sep = " | "
    ),
    text_title_kw = paste(
      replace_na(title,    ""),
      replace_na(keywords, ""),
      sep = " | "
    ),
    regime_sensitive      = as.integer(str_detect(text_full,     regex(dict_pattern,     ignore_case = TRUE))),
    regime_sensitive_rc1  = as.integer(str_detect(text_title_kw, regex(dict_pattern_rc1, ignore_case = TRUE)))
  )

# ---- Stage 2: Aggregate to country-year -------------------------------------

# Primary flag uses article-level (ut) deduplication per country:
# one article can appear in multiple country rows but the flag is constant
# across rows for the same ut (title/keywords/abstract don't vary by country).

panel_raw <- corpus |>
  group_by(iso3, year) |>
  summarise(
    # count distinct flagged articles (primary and RC1)
    n_sensitive      = n_distinct(ut[regime_sensitive     == 1]),
    n_sensitive_rc1  = n_distinct(ut[regime_sensitive_rc1 == 1]),
    n_articles       = n_distinct(ut),
    # use pre-computed denominator where available; fall back to n_distinct(ut)
    n_articles_cy    = first(n_articles_country_year),
    v2x_libdem       = mean(v2x_libdem,  na.rm = TRUE),
    lied_binary      = mean(lied_binary, na.rm = TRUE),
    v2x_regime       = mean(v2x_regime,  na.rm = TRUE),
    e_gdppc          = mean(e_gdppc,     na.rm = TRUE),
    e_wb_pop         = mean(e_wb_pop,    na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    # use pre-computed n_articles_country_year if available, else our count
    denom = if_else(!is.na(n_articles_cy) & n_articles_cy > 0, n_articles_cy, n_articles),
    share_regime_sensitive      = n_sensitive     / denom,
    share_regime_sensitive_rc1  = n_sensitive_rc1 / denom,
    # round lied_binary to 0/1 (should already be, but safe)
    lied_binary = round(lied_binary)
  )

# Apply sample restrictions (pre-registered):
# 1. years 1990-2023
# 2. n_articles >= 5
# 3. non-missing v2x_libdem, e_gdppc, e_wb_pop

panel <- panel_raw |>
  filter(
    year >= 1990, year <= 2023,
    denom >= 5,
    !is.nan(v2x_libdem),  !is.na(v2x_libdem),
    !is.nan(e_gdppc),     !is.na(e_gdppc),
    !is.nan(e_wb_pop),    !is.na(e_wb_pop),
    !is.na(lied_binary)
  ) |>
  mutate(
    year   = as.factor(year),
    iso3   = as.factor(iso3)
  )

cat("Panel dimensions:", nrow(panel), "country-years,", n_distinct(panel$iso3), "countries\n")

# ---- Stage 3: Regression ----------------------------------------------------

# Primary model: TWFE (country + year FE), clustered SE by country
mod_twfe <- feols(
  share_regime_sensitive ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Secondary model: year FE only (pooled OLS)
mod_year_fe <- feols(
  share_regime_sensitive ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data = panel, cluster = ~iso3
)

# RC1: title + keywords only, TWFE
mod_rc1 <- feols(
  share_regime_sensitive_rc1 ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# RC2: replace v2x_libdem with lied_binary, TWFE
mod_rc2 <- feols(
  share_regime_sensitive ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel, cluster = ~iso3
)

# Print summaries
cat("\n--- Primary model (TWFE) ---\n")
print(summary(mod_twfe))

cat("\n--- Secondary model (year FE only) ---\n")
print(summary(mod_year_fe))

cat("\n--- RC1: title + keywords only ---\n")
print(summary(mod_rc1))

cat("\n--- RC2: lied_binary ---\n")
print(summary(mod_rc2))

# ---- Regression table -------------------------------------------------------

tab <- modelsummary(
  list(
    "TWFE (primary)"         = mod_twfe,
    "Year FE (cross-section)" = mod_year_fe,
    "RC1: title+kw only"     = mod_rc1,
    "RC2: lied_binary"       = mod_rc2
  ),
  stars = c("*" = 0.05, "**" = 0.01, "***" = 0.001),
  coef_rename = c(
    "v2x_libdem" = "Liberal democracy (v2x_libdem)",
    "lied_binary" = "Democracy (lied_binary, 0/1)",
    "log(e_gdppc)" = "log GDP per capita",
    "log(e_wb_pop)" = "log Population"
  ),
  gof_omit = "AIC|BIC|RMSE|R2 Within|R2 Pseudo",
  output = file.path(out_dir, "tab_main.txt")
)

# ---- Figure 1: Binned scatter plot ------------------------------------------

# Decile bins of v2x_libdem, colored by mean regime category
panel_numeric <- panel |>
  mutate(
    year = as.numeric(as.character(year)),
    v2x_libdem_num = v2x_libdem,
    decile = ntile(v2x_libdem_num, 10),
    regime_cat = case_when(
      v2x_regime < 0.5  ~ "Closed autocracy",
      v2x_regime < 1.5  ~ "Electoral autocracy",
      v2x_regime < 2.5  ~ "Electoral democracy",
      TRUE              ~ "Liberal democracy"
    ) |> factor(levels = c("Closed autocracy", "Electoral autocracy",
                            "Electoral democracy", "Liberal democracy"))
  )

fig_scatter_data <- panel_numeric |>
  group_by(decile) |>
  summarise(
    mean_libdem   = mean(v2x_libdem_num, na.rm = TRUE),
    mean_share    = mean(share_regime_sensitive, na.rm = TRUE),
    mean_regime   = mean(v2x_regime, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    regime_cat = case_when(
      mean_regime < 0.5  ~ "Closed autocracy",
      mean_regime < 1.5  ~ "Electoral autocracy",
      mean_regime < 2.5  ~ "Electoral democracy",
      TRUE               ~ "Liberal democracy"
    ) |> factor(levels = c("Closed autocracy", "Electoral autocracy",
                            "Electoral democracy", "Liberal democracy"))
  )

fig_main <- ggplot(fig_scatter_data, aes(x = mean_libdem, y = mean_share, color = regime_cat)) +
  geom_point(size = 3) +
  geom_smooth(
    data = panel_numeric,
    aes(x = v2x_libdem_num, y = share_regime_sensitive),
    method = "lm", se = TRUE, color = "black", linewidth = 0.8, inherit.aes = FALSE
  ) +
  scale_color_manual(
    values = c(
      "Closed autocracy"    = "#d73027",
      "Electoral autocracy" = "#fc8d59",
      "Electoral democracy" = "#91bfdb",
      "Liberal democracy"   = "#4575b4"
    ),
    name = "Regime category (bin mean)"
  ) +
  labs(
    title    = "Regime type and regime-sensitive keyword prevalence",
    subtitle = "Binned scatter (deciles of v2x_libdem), 1990-2023",
    x        = "Liberal Democracy Index (v2x_libdem, decile mean)",
    y        = "Share of articles with regime-sensitive terms"
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_main.png"), fig_main, width = 7, height = 5, dpi = 200)

# ---- Figure 2: Coefficient plot ---------------------------------------------

# Collect estimates from all specifications
coef_df <- bind_rows(
  tibble(
    model   = "TWFE (primary)",
    term    = "v2x_libdem",
    est     = coef(mod_twfe)["v2x_libdem"],
    se_val  = se(mod_twfe)["v2x_libdem"],
    p_val   = pvalue(mod_twfe)["v2x_libdem"]
  ),
  tibble(
    model   = "Year FE only",
    term    = "v2x_libdem",
    est     = coef(mod_year_fe)["v2x_libdem"],
    se_val  = se(mod_year_fe)["v2x_libdem"],
    p_val   = pvalue(mod_year_fe)["v2x_libdem"]
  ),
  tibble(
    model   = "RC1: title+kw only",
    term    = "v2x_libdem",
    est     = coef(mod_rc1)["v2x_libdem"],
    se_val  = se(mod_rc1)["v2x_libdem"],
    p_val   = pvalue(mod_rc1)["v2x_libdem"]
  ),
  tibble(
    model   = "RC2: lied_binary",
    term    = "lied_binary",
    est     = coef(mod_rc2)["lied_binary"],
    se_val  = se(mod_rc2)["lied_binary"],
    p_val   = pvalue(mod_rc2)["lied_binary"]
  )
) |>
  mutate(
    lo95 = est - 1.96 * se_val,
    hi95 = est + 1.96 * se_val,
    model = factor(model, levels = rev(c(
      "TWFE (primary)", "Year FE only", "RC1: title+kw only", "RC2: lied_binary"
    )))
  )

fig_coef <- ggplot(coef_df, aes(x = est, xmin = lo95, xmax = hi95, y = model)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(height = 0.2) +
  geom_point(size = 3, aes(color = p_val < 0.05)) +
  scale_color_manual(
    values = c("TRUE" = "#2166ac", "FALSE" = "#d73027"),
    labels = c("TRUE" = "p < 0.05", "FALSE" = "p >= 0.05"),
    name   = ""
  ) +
  labs(
    title    = "Coefficient plot: democracy and regime-sensitive keyword share",
    subtitle = "Primary model and robustness checks (95% CI, SE clustered by country)",
    x        = "Estimated coefficient on regime measure",
    y        = NULL
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_coef.png"), fig_coef, width = 7, height = 4, dpi = 200)

# ---- Figure 3: Time trends by regime category -------------------------------

trend_data <- panel_numeric |>
  mutate(
    regime_cat4 = case_when(
      v2x_regime < 0.5  ~ "Closed autocracy",
      v2x_regime < 1.5  ~ "Electoral autocracy",
      v2x_regime < 2.5  ~ "Electoral democracy",
      TRUE              ~ "Liberal democracy"
    ) |> factor(levels = c("Closed autocracy", "Electoral autocracy",
                            "Electoral democracy", "Liberal democracy"))
  ) |>
  group_by(year, regime_cat4) |>
  summarise(
    mean_share = mean(share_regime_sensitive, na.rm = TRUE),
    n          = n(),
    .groups    = "drop"
  ) |>
  filter(!is.na(regime_cat4))

fig_trends <- ggplot(trend_data, aes(x = year, y = mean_share, color = regime_cat4)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.2, alpha = 0.6) +
  scale_color_manual(
    values = c(
      "Closed autocracy"    = "#d73027",
      "Electoral autocracy" = "#fc8d59",
      "Electoral democracy" = "#91bfdb",
      "Liberal democracy"   = "#4575b4"
    ),
    name = "Regime category"
  ) +
  labs(
    title    = "Regime-sensitive keyword share over time by regime type",
    subtitle = "Mean country-year share, 1990-2023",
    x        = "Year",
    y        = "Mean share of articles with regime-sensitive terms"
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_trends.png"), fig_trends, width = 8, height = 5, dpi = 200)

# ---- Figure 4: v2x_regime category dummy robustness -------------------------

panel_regime_factor <- panel |>
  mutate(
    v2x_regime_cat = factor(
      round(v2x_regime),
      levels = 0:3,
      labels = c("Closed autocracy", "Electoral autocracy", "Electoral democracy", "Liberal democracy")
    )
  ) |>
  filter(!is.na(v2x_regime_cat))

mod_regime_cat <- feols(
  share_regime_sensitive ~
    i(v2x_regime_cat, ref = "Closed autocracy") + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data = panel_regime_factor, cluster = ~iso3
)

cat("\n--- Robustness: v2x_regime category dummies ---\n")
print(summary(mod_regime_cat))

# Extract category dummy coefficients
regime_coef_df <- broom::tidy(mod_regime_cat, conf.int = TRUE) |>
  filter(str_detect(term, "v2x_regime_cat")) |>
  mutate(
    term_label = str_replace(term, "v2x_regime_cat::", ""),
    term_label = factor(term_label, levels = c(
      "Electoral autocracy", "Electoral democracy", "Liberal democracy"
    ))
  )

fig_robustness_regime <- ggplot(regime_coef_df,
                                 aes(x = estimate, xmin = conf.low, xmax = conf.high, y = term_label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(height = 0.2) +
  geom_point(size = 3, aes(color = p.value < 0.05)) +
  scale_color_manual(
    values = c("TRUE" = "#2166ac", "FALSE" = "#d73027"),
    labels = c("TRUE" = "p < 0.05", "FALSE" = "p >= 0.05"),
    name   = ""
  ) +
  labs(
    title    = "Regime category dummies vs. closed autocracy (reference)",
    subtitle = "TWFE, SE clustered by country; 95% CI",
    x        = "Estimated coefficient (vs. closed autocracy)",
    y        = NULL
  ) +
  theme_bw(base_size = 12)

ggsave(
  file.path(fig_dir, "fig_robustness_regime_type.png"),
  fig_robustness_regime, width = 7, height = 4, dpi = 200
)

# ---- primary_results.json ---------------------------------------------------

primary_coef <- coef(mod_twfe)["v2x_libdem"]
primary_se   <- se(mod_twfe)["v2x_libdem"]
primary_t    <- tstat(mod_twfe)["v2x_libdem"]
primary_p    <- pvalue(mod_twfe)["v2x_libdem"]
primary_nobs <- nobs(mod_twfe)
primary_ncty <- n_distinct(panel$iso3[!is.na(panel$share_regime_sensitive) &
                                       !is.na(panel$v2x_libdem) &
                                       !is.na(panel$e_gdppc) &
                                       !is.na(panel$e_wb_pop)])

results_list <- list(
  team              = "04",
  hypothesis_label  = "Countries with lower Liberal democracy levels will have a lower share of SSH articles containing regime-sensitive terms in titles, author keywords, and abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.",
  theory_family     = "topic-avoidance",
  predictor         = "v2x_libdem",
  outcome           = "share_regime_sensitive",
  model_description = "feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient       = unname(primary_coef),
  se                = unname(primary_se),
  t_stat            = unname(primary_t),
  p_value           = unname(primary_p),
  n_obs             = as.integer(primary_nobs),
  n_countries       = as.integer(primary_ncty)
)

write_json(
  results_list,
  path       = file.path(out_dir, "primary_results.json"),
  auto_unbox = TRUE,
  digits     = NA   # full precision
)

cat("\n==== Analysis complete ====\n")
cat("primary_results.json written to:", file.path(out_dir, "primary_results.json"), "\n")
cat("Figures written to:", fig_dir, "\n")
cat("Regression table written to:", file.path(out_dir, "tab_main.txt"), "\n")

# Print key result
cat(sprintf(
  "\nPrimary result: beta(v2x_libdem) = %.4f (SE = %.4f, t = %.3f, p = %.4f), N = %d obs, %d countries\n",
  primary_coef, primary_se, primary_t, primary_p, primary_nobs, primary_ncty
))
