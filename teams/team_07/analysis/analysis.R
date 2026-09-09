# =============================================================================
# Team 07 — Analysis: Share of SSH articles acknowledging international funding
# Pre-registered: 2026-05-06 | Analyst run: 2026-05-06
# =============================================================================
#
# NOTE: Funding text column used:
#   Priority 1 — grant_agencies (dedicated funding metadata field)
#   Fallback    — abstract (searched for funding acknowledgment phrases)
#   The column `grant_agencies` is present in agent_corpus.rds.
#   For the primary analysis, `coalesce(grant_agencies, abstract)` is used
#   so that articles with dedicated metadata use that; others fall back to abstract.
#   RC2 robustness check restricts to rows where grant_agencies is non-missing.
#
# =============================================================================

library(tidyverse)
library(fixest)
library(jsonlite)

# ---- Paths ------------------------------------------------------------------

data_path  <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
out_dir    <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_07/analysis"
fig_dir    <- file.path(out_dir, "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# ---- Load corpus ------------------------------------------------------------

corpus <- readRDS(data_path)

cat("Corpus loaded:", nrow(corpus), "rows x", ncol(corpus), "columns\n")
cat("grant_agencies non-missing:", sum(!is.na(corpus$grant_agencies)), "\n")
cat("Year range:", min(corpus$year, na.rm = TRUE), "-", max(corpus$year, na.rm = TRUE), "\n")

# ---- International funding agency regex dictionary --------------------------
# (defined in preregistration.md Step 2)

intl_fund_regex <- paste(
  "national science foundation", "\\bNSF\\b",
  "european research council", "\\bERC\\b",
  "european commission", "horizon 20[0-9][0-9]", "marie curie", "horizon europe",
  "world bank", "\\bIMF\\b", "international monetary fund",
  "\\bUSAID\\b", "ford foundation",
  "gates foundation", "bill.*melinda gates", "wellcome trust",
  "open society", "soros foundation",
  "\\bUKRI\\b", "\\bESRC\\b", "\\bAHRC\\b",
  "deutsche forschungsgemeinschaft", "\\bDFG\\b",
  "swiss national science foundation", "\\bSNSF\\b",
  "vetenskapsr[ao]det", "swedish research council",
  "norges forskningsr.d", "research council of norway",
  "nordforsk", "\\bNWO\\b",
  "agence nationale de la recherche", "\\bANR\\b",
  "national institutes of health", "\\bNIH\\b",
  "\\bUNDP\\b", "\\bUNESCO\\b", "\\bUNICEF\\b", "united nations",
  "asian development bank", "african development bank",
  "inter.american development bank",
  sep = "|"
)

# ---- Step 3: Construct article-level indicator ------------------------------

corpus <- corpus |>
  mutate(
    # Use grant_agencies field preferentially; fall back to abstract
    target_text  = coalesce(grant_agencies, abstract),
    intl_funded  = as.integer(str_detect(tolower(coalesce(target_text, "")), intl_fund_regex))
  )

cat("intl_funded distribution:\n")
print(table(corpus$intl_funded))

# Deduplicate to unique wos_id (ut) x country before aggregating
# (corpus is article x author-country; we want article-country-level outcome)
corpus_dedup <- corpus |>
  distinct(ut, iso3, year, .keep_all = TRUE)

# Aggregate to country-year
cy <- corpus_dedup |>
  group_by(iso3, year) |>
  summarise(
    share_intl_funded = mean(intl_funded, na.rm = TRUE),
    n_articles        = n_distinct(ut),
    v2x_libdem        = mean(v2x_libdem, na.rm = TRUE),
    lied_binary       = mean(lied_binary, na.rm = TRUE),
    e_gdppc           = mean(e_gdppc, na.rm = TRUE),
    e_wb_pop          = mean(e_wb_pop, na.rm = TRUE),
    .groups           = "drop"
  ) |>
  filter(n_articles >= 5)

cat("Country-year panel after filtering (n_articles >= 5):\n")
cat("  Rows:", nrow(cy), "\n")
cat("  Countries:", n_distinct(cy$iso3), "\n")
cat("  Years:", min(cy$year), "-", max(cy$year), "\n")
cat("  Share intl funded — mean:", round(mean(cy$share_intl_funded, na.rm = TRUE), 4),
    " sd:", round(sd(cy$share_intl_funded, na.rm = TRUE), 4), "\n")

# Drop rows with missing controls
cy_reg <- cy |>
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop),
         e_gdppc > 0, e_wb_pop > 0)

cat("Regression sample after dropping missing controls:\n")
cat("  Rows:", nrow(cy_reg), "\n")
cat("  Countries:", n_distinct(cy_reg$iso3), "\n")

# ============================================================================
# REGRESSION MODELS
# ============================================================================

# ---- Primary: TWFE (country + year FE, clustered by iso3) ------------------

mod_twfe <- feols(
  share_intl_funded ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = cy_reg,
  cluster = ~iso3
)

cat("\n--- Primary model (TWFE) ---\n")
print(summary(mod_twfe))

# ---- Secondary: Year FE only (pooled OLS + year FE) -----------------------

mod_year <- feols(
  share_intl_funded ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data    = cy_reg,
  cluster = ~iso3
)

cat("\n--- Secondary model (year FE only) ---\n")
print(summary(mod_year))

# ---- RC1: Alternative regime measure (lied_binary) -------------------------

mod_rc1 <- feols(
  share_intl_funded ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = cy_reg,
  cluster = ~iso3
)

cat("\n--- RC1: lied_binary (TWFE) ---\n")
print(summary(mod_rc1))

# ---- RC2: Restrict to grant_agencies only (no abstract fallback) -----------

# Re-construct the intl_funded indicator using only grant_agencies
corpus_rc2 <- corpus |>
  distinct(ut, iso3, year, .keep_all = TRUE) |>
  filter(!is.na(grant_agencies)) |>
  mutate(
    intl_funded_ga = as.integer(str_detect(tolower(grant_agencies), intl_fund_regex))
  )

cy_rc2 <- corpus_rc2 |>
  group_by(iso3, year) |>
  summarise(
    share_intl_funded = mean(intl_funded_ga, na.rm = TRUE),
    n_articles        = n_distinct(ut),
    v2x_libdem        = mean(v2x_libdem, na.rm = TRUE),
    e_gdppc           = mean(e_gdppc, na.rm = TRUE),
    e_wb_pop          = mean(e_wb_pop, na.rm = TRUE),
    .groups           = "drop"
  ) |>
  filter(n_articles >= 5,
         !is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop),
         e_gdppc > 0, e_wb_pop > 0)

cat("\nRC2 sample (grant_agencies only, n_articles >= 5):\n")
cat("  Rows:", nrow(cy_rc2), "\n")
cat("  Countries:", n_distinct(cy_rc2$iso3), "\n")

mod_rc2 <- feols(
  share_intl_funded ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = cy_rc2,
  cluster = ~iso3
)

cat("\n--- RC2: grant_agencies only (TWFE) ---\n")
print(summary(mod_rc2))

# ============================================================================
# FIGURES
# ============================================================================

# ---- Figure 1: Binned scatter — v2x_libdem vs. share_intl_funded (residualized) ----

# Residualize: partial out iso3 and year FE from both outcome and predictor
res_y <- feols(share_intl_funded ~ 1 | iso3 + year, data = cy_reg)
res_x <- feols(v2x_libdem ~ 1 | iso3 + year, data = cy_reg)

cy_resid <- cy_reg |>
  mutate(
    resid_y = resid(res_y),
    resid_x = resid(res_x)
  )

# Bin the predictor into 20 quantile bins
cy_resid <- cy_resid |>
  mutate(bin = ntile(resid_x, 20)) |>
  group_by(bin) |>
  summarise(
    mean_x = mean(resid_x, na.rm = TRUE),
    mean_y = mean(resid_y, na.rm = TRUE),
    n      = n(),
    .groups = "drop"
  )

fig1 <- ggplot(cy_resid, aes(x = mean_x, y = mean_y)) +
  geom_point(aes(size = n), alpha = 0.7, colour = "#2c7bb6") +
  geom_smooth(method = "lm", se = TRUE, colour = "#d7191c", linewidth = 0.8) +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  labs(
    title    = "Liberal democracy and international funding acknowledgment",
    subtitle = "Binned scatter (residualized on country + year FEs), n = 20 bins",
    x        = "v2x_libdem (residualized)",
    y        = "Share internationally funded (residualized)",
    caption  = "Each point is a bin of ~5% of country-year observations. Size proportional to N."
  ) +
  theme_bw(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "fig1_scatter.png"), fig1,
       width = 8, height = 5.5, dpi = 150)

cat("Figure 1 saved.\n")

# ---- Figure 2: Coefficient plot across specifications ----------------------

coef_df <- tibble(
  model  = c("TWFE\n(primary)", "Year FE only\n(secondary)", "RC1: lied_binary\n(TWFE)", "RC2: grant_agencies\nonly (TWFE)"),
  predictor = c("v2x_libdem", "v2x_libdem", "lied_binary", "v2x_libdem"),
  est    = c(coef(mod_twfe)["v2x_libdem"],
             coef(mod_year)["v2x_libdem"],
             coef(mod_rc1)["lied_binary"],
             coef(mod_rc2)["v2x_libdem"]),
  se     = c(se(mod_twfe)["v2x_libdem"],
             se(mod_year)["v2x_libdem"],
             se(mod_rc1)["lied_binary"],
             se(mod_rc2)["v2x_libdem"])
) |>
  mutate(
    lo95 = est - 1.96 * se,
    hi95 = est + 1.96 * se,
    lo90 = est - 1.645 * se,
    hi90 = est + 1.645 * se,
    model = factor(model, levels = rev(model))
  )

fig2 <- ggplot(coef_df, aes(x = est, y = model)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_linerange(aes(xmin = lo95, xmax = hi95), linewidth = 0.8, colour = "#2c7bb6") +
  geom_linerange(aes(xmin = lo90, xmax = hi90), linewidth = 1.6, colour = "#2c7bb6") +
  geom_point(size = 3, colour = "#2c7bb6") +
  labs(
    title    = "Effect of democracy on international funding share",
    subtitle = "Thick bars = 90% CI; thin bars = 95% CI",
    x        = "Coefficient (democracy predictor on share_intl_funded)",
    y        = NULL,
    caption  = "SE clustered by country. All models include log GDP per capita and log population as controls."
  ) +
  theme_bw(base_size = 12) +
  theme(plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "fig2_coef_plot.png"), fig2,
       width = 8, height = 4.5, dpi = 150)

cat("Figure 2 saved.\n")

# ---- Figure 3: Time trends by regime type ----------------------------------

# Classify country-year by regime quartile (of v2x_libdem)
cy_trend <- cy |>
  mutate(
    regime_group = case_when(
      v2x_libdem < 0.2 ~ "Low democracy\n(v2x_libdem < 0.2)",
      v2x_libdem < 0.5 ~ "Mid-low\n(0.2-0.5)",
      v2x_libdem < 0.7 ~ "Mid-high\n(0.5-0.7)",
      TRUE              ~ "High democracy\n(v2x_libdem >= 0.7)"
    ),
    regime_group = factor(regime_group,
                          levels = c("Low democracy\n(v2x_libdem < 0.2)",
                                     "Mid-low\n(0.2-0.5)",
                                     "Mid-high\n(0.5-0.7)",
                                     "High democracy\n(v2x_libdem >= 0.7)"))
  ) |>
  filter(!is.na(regime_group), year >= 1990) |>
  group_by(year, regime_group) |>
  summarise(
    mean_share = mean(share_intl_funded, na.rm = TRUE),
    n          = n(),
    .groups    = "drop"
  ) |>
  filter(n >= 3)

fig3 <- ggplot(cy_trend, aes(x = year, y = mean_share, colour = regime_group)) +
  geom_line(linewidth = 0.9) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 0.4, linetype = "dotted") +
  scale_colour_brewer(type = "div", palette = "RdYlGn",
                      name = "Democracy level") +
  labs(
    title    = "Share of SSH articles acknowledging international funding, by democracy level",
    subtitle = "Mean share per country-year group, 1990-2023 (loess trend = dotted)",
    x        = "Year",
    y        = "Mean share internationally funded"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title   = element_text(face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 9)
  )

ggsave(file.path(fig_dir, "fig3_descriptives.png"), fig3,
       width = 9, height = 5.5, dpi = 150)

cat("Figure 3 saved.\n")

# ============================================================================
# PRIMARY RESULTS JSON
# ============================================================================

primary_results <- list(
  team              = "07",
  hypothesis_label  = "Countries with lower Liberal democracy levels will have a lower share of SSH articles acknowledging international funding agencies, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.",
  theory_family     = "topic-avoidance",
  predictor         = "v2x_libdem",
  outcome           = "share_intl_funded",
  model_description = "feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient       = unname(coef(mod_twfe)["v2x_libdem"]),
  se                = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat            = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value           = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs             = as.integer(nobs(mod_twfe)),
  n_countries       = as.integer(n_distinct(cy_reg$iso3[cy_reg$iso3 %in% unique(model.matrix(mod_twfe, type = "fixef")$iso3)]))
)

# Count countries actually in the model
n_countries_in_model <- as.integer(
  length(unique(cy_reg$iso3[
    paste(cy_reg$iso3, cy_reg$year) %in%
      paste(cy_reg$iso3[!is.na(cy_reg$v2x_libdem) & !is.na(cy_reg$e_gdppc) & !is.na(cy_reg$e_wb_pop)],
            cy_reg$year[!is.na(cy_reg$v2x_libdem) & !is.na(cy_reg$e_gdppc) & !is.na(cy_reg$e_wb_pop)])
  ]))
)
primary_results$n_countries <- n_countries_in_model

write_json(primary_results,
           file.path(out_dir, "primary_results.json"),
           auto_unbox = TRUE,
           digits     = NA)  # NA = full precision

cat("\n=== PRIMARY RESULTS (TWFE) ===\n")
cat("Coefficient (v2x_libdem):", primary_results$coefficient, "\n")
cat("SE:                      ", primary_results$se, "\n")
cat("t-statistic:             ", primary_results$t_stat, "\n")
cat("p-value:                 ", primary_results$p_value, "\n")
cat("N observations:          ", primary_results$n_obs, "\n")
cat("N countries:             ", primary_results$n_countries, "\n")
cat("\nprimary_results.json written.\n")
cat("\nTeam 07 analysis complete.\n")
