# Team 01 — Political-Content Index (PCI) analysis
# Analyst: Claude (AutoKnow Agent Orchestra)
# Pre-registration: teams/team_01/preregistration.md
# Outcome: pci_mean (country-year mean share of abstract tokens matching PCI dictionary)
# Primary IV: v2x_libdem
# Design: TWFE (country + year FE), cluster-robust SE by iso3

library(tidyverse)
library(fixest)
library(jsonlite)
library(ggrepel)

# ── 0. Paths ──────────────────────────────────────────────────────────────────
data_path   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
out_dir     <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_01/analysis"
fig_dir     <- file.path(out_dir, "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

# ── 1. Load data ──────────────────────────────────────────────────────────────
raw <- readRDS(data_path)

# ── 2. PCI dictionary (five clusters, ~100 stems) ────────────────────────────
pci_stems <- c(
  # democracy/autocracy
  "democrat", "autocrat", "authoritar", "regime", "dictator", "despoti",
  "tyrann", "totalitar", "illiberal", "hybrid regime", "competitive authori",
  # repression/rights
  "repres", "censor", "human right", "civil libert", "freedom", "dissiden",
  "political prisoner", "torture", "surveil", "crackdown", "suppress",
  "arbitrary detent", "political persec",
  # governance/corruption
  "corrupt", "govern", "bureaucra", "institution", "rule of law",
  "accountability", "transparency", "state capac", "public administr",
  "patronage", "clientel", "rent.seek",
  # protest/conflict
  "protest", "revolt", "upris", "dissent", "civil war", "demonstrat",
  "riot", "insurrect", "rebel", "mobiliz", "contentious", "mass movement",
  "political violence",
  # elections/parties
  "election", "ballot", "party", "parliament", "vote", "suffrage",
  "electoral", "campaign", "candidat", "legislat", "multiparty",
  "opposition party", "political competition"
)

# Build single regex (case-insensitive)
pci_regex <- paste(pci_stems, collapse = "|")

# ── 3. Article-level PCI score ────────────────────────────────────────────────
# Work only on rows with non-missing abstract
articles <- raw |>
  filter(!is.na(abstract), nchar(trimws(abstract)) > 0) |>
  # Tokenize by whitespace, remove punctuation tokens
  mutate(
    abstract_clean = str_to_lower(str_replace_all(abstract, "[^a-zA-Z0-9\\s]", " ")),
    n_tokens = str_count(abstract_clean, "\\S+"),
    n_pci    = str_count(abstract_clean, regex(pci_regex, ignore_case = TRUE)),
    pci_article = if_else(n_tokens > 0, n_pci / n_tokens, NA_real_)
  ) |>
  filter(!is.na(pci_article), n_tokens >= 10)  # drop degenerate abstracts

# ── 4. Country-year aggregation ───────────────────────────────────────────────
# Primary: unweighted mean; also compute weighted for robustness
cy <- articles |>
  group_by(iso3, year) |>
  summarise(
    pci_mean          = mean(pci_article, na.rm = TRUE),
    pci_mean_weighted = weighted.mean(pci_article, w = rep(1, n()), na.rm = TRUE),
    n_articles_cy     = n(),
    v2x_libdem        = first(v2x_libdem),
    lied_binary       = first(lied_binary),
    v2x_regime        = first(v2x_regime),
    e_gdppc           = first(e_gdppc),
    e_wb_pop          = first(e_wb_pop),
    .groups = "drop"
  )

# ── 5. Sample restriction (pre-registered) ───────────────────────────────────
panel <- cy |>
  filter(
    year >= 1990, year <= 2023,
    n_articles_cy >= 5,
    !is.na(v2x_libdem),
    !is.na(e_gdppc),
    !is.na(e_wb_pop),
    e_gdppc > 0,
    e_wb_pop > 0
  )

cat("Panel dimensions:", nrow(panel), "country-years,",
    n_distinct(panel$iso3), "countries\n")

# ── 6. Regression models ──────────────────────────────────────────────────────

# Model 1: TWFE (primary, pre-registered)
mod_twfe <- feols(
  pci_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# Model 2: Pooled OLS — year FE only (descriptive/cross-sectional)
mod_ols <- feols(
  pci_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data    = panel,
  cluster = ~iso3
)

# RC1: Robustness — replace v2x_libdem with lied_binary (binary regime)
mod_rc1 <- feols(
  pci_mean ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# RC2: Robustness — replace v2x_libdem with v2x_regime (ordinal 0-3)
mod_rc2 <- feols(
  pci_mean ~ v2x_regime + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# RC3: Robustness — weighted aggregation
mod_rc3 <- feols(
  pci_mean_weighted ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# Print main table
cat("\n--- TWFE (primary) ---\n")
print(summary(mod_twfe))
cat("\n--- Pooled OLS ---\n")
print(summary(mod_ols))
cat("\n--- RC1: lied_binary ---\n")
print(summary(mod_rc1))
cat("\n--- RC2: v2x_regime ---\n")
print(summary(mod_rc2))
cat("\n--- RC3: weighted PCI ---\n")
print(summary(mod_rc3))

# ── 7. Extract primary results ────────────────────────────────────────────────
coef_val  <- coef(mod_twfe)["v2x_libdem"]
se_val    <- se(mod_twfe)["v2x_libdem"]
t_val     <- tstat(mod_twfe)["v2x_libdem"]
p_val     <- pvalue(mod_twfe)["v2x_libdem"]
n_obs     <- nobs(mod_twfe)
n_ctry    <- n_distinct(panel$iso3[!is.na(panel$v2x_libdem) & !is.na(panel$e_gdppc) & !is.na(panel$e_wb_pop)])

results_json <- list(
  team              = "01",
  hypothesis_label  = "Countries with lower Liberal democracy levels will exhibit lower mean PCI scores in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.",
  theory_family     = "topic-avoidance",
  predictor         = "v2x_libdem",
  outcome           = "pci_mean",
  model_description = "feols(pci_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient       = unname(coef_val),
  se                = unname(se_val),
  t_stat            = unname(t_val),
  p_value           = unname(p_val),
  n_obs             = as.integer(n_obs),
  n_countries       = as.integer(n_ctry)
)

write_json(results_json, file.path(out_dir, "primary_results.json"),
           pretty = TRUE, auto_unbox = TRUE, digits = NA)
cat("\nprimary_results.json written.\n")

# ── 8. Figures ────────────────────────────────────────────────────────────────

# ---- 8a. fig_main_coef.png: coefficient plot from TWFE ----------------------
coef_df <- tibble(
  model  = "TWFE\n(country + year FE)",
  coef   = unname(coef_val),
  se     = unname(se_val),
  ci_lo  = coef_val - 1.96 * se_val,
  ci_hi  = coef_val + 1.96 * se_val
)

p_coef <- ggplot(coef_df, aes(x = coef, y = model)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.15, linewidth = 0.7) +
  geom_point(size = 3) +
  labs(
    title    = "Effect of Liberal Democracy on PCI Score",
    subtitle = "TWFE: country + year FE, SE clustered by country",
    x        = "Coefficient on v2x_libdem",
    y        = NULL,
    caption  = paste0("N = ", formatC(n_obs, format = "d", big.mark = ","),
                      " country-years; outcome: pci_mean")
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_main_coef.png"), p_coef,
       width = 6, height = 3, dpi = 150)

# ---- 8b. fig_trend.png: mean PCI by regime quartile over time ----------------
panel <- panel |>
  mutate(
    regime_q = cut(v2x_libdem,
                   breaks    = quantile(v2x_libdem, probs = c(0, .25, .5, .75, 1), na.rm = TRUE),
                   labels    = c("Q1\n(most autocratic)", "Q2", "Q3", "Q4\n(most democratic)"),
                   include.lowest = TRUE)
  )

trend_df <- panel |>
  filter(!is.na(regime_q)) |>
  group_by(year, regime_q) |>
  summarise(pci_yr = mean(pci_mean, na.rm = TRUE), .groups = "drop")

p_trend <- ggplot(trend_df, aes(x = year, y = pci_yr, colour = regime_q, group = regime_q)) +
  geom_line(linewidth = 0.8) +
  geom_smooth(method = "loess", se = FALSE, linetype = "dashed", linewidth = 0.5) +
  scale_colour_manual(
    values = c("#d73027", "#fc8d59", "#91bfdb", "#4575b4"),
    name   = "Democracy quartile\n(v2x_libdem)"
  ) +
  labs(
    title   = "Mean PCI Score by Regime Quartile, 1990–2023",
    x       = "Year",
    y       = "Mean PCI score (abstract keyword share)",
    caption = "Quartiles defined on full panel; loess smoother shown"
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_trend.png"), p_trend,
       width = 8, height = 5, dpi = 150)

# ---- 8c. fig_scatter.png: country-year scatter --------------------------------
# Compute per-country means for labeling
ctry_mean <- panel |>
  group_by(iso3) |>
  summarise(
    v2x_libdem_m = mean(v2x_libdem, na.rm = TRUE),
    pci_mean_m   = mean(pci_mean,   na.rm = TRUE),
    n            = n(),
    .groups = "drop"
  ) |>
  arrange(desc(n)) |>
  mutate(label = if_else(row_number() <= 30, iso3, NA_character_))

p_scatter <- ggplot(ctry_mean, aes(x = v2x_libdem_m, y = pci_mean_m)) +
  geom_point(aes(size = n), alpha = 0.5, colour = "steelblue") +
  geom_smooth(method = "lm", colour = "firebrick", se = TRUE, linewidth = 0.8) +
  geom_text_repel(aes(label = label), size = 2.5, max.overlaps = 20) +
  scale_size_continuous(name = "Country-years", range = c(1, 6)) +
  labs(
    title   = "Country Mean PCI Score vs. Liberal Democracy",
    subtitle = "Each point = country (time-average); OLS line shown",
    x       = "Mean v2x_libdem",
    y       = "Mean PCI score",
    caption = "Top 30 countries by N labelled"
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_scatter.png"), p_scatter,
       width = 8, height = 6, dpi = 150)

# ---- 8d. fig_robustness.png: robustness coefficient plot ---------------------
rc_coef <- bind_rows(
  tibble(
    spec  = "Primary\n(v2x_libdem, TWFE)",
    coef  = unname(coef(mod_twfe)["v2x_libdem"]),
    se    = unname(se(mod_twfe)["v2x_libdem"])
  ),
  tibble(
    spec  = "Pooled OLS\n(v2x_libdem, year FE only)",
    coef  = unname(coef(mod_ols)["v2x_libdem"]),
    se    = unname(se(mod_ols)["v2x_libdem"])
  ),
  tibble(
    spec  = "RC1: binary regime\n(lied_binary, TWFE)",
    coef  = unname(coef(mod_rc1)["lied_binary"]),
    se    = unname(se(mod_rc1)["lied_binary"])
  ),
  tibble(
    spec  = "RC2: ordinal regime\n(v2x_regime 0–3, TWFE)",
    coef  = unname(coef(mod_rc2)["v2x_regime"]),
    se    = unname(se(mod_rc2)["v2x_regime"])
  ),
  tibble(
    spec  = "RC3: weighted PCI\n(v2x_libdem, TWFE)",
    coef  = unname(coef(mod_rc3)["v2x_libdem"]),
    se    = unname(se(mod_rc3)["v2x_libdem"])
  )
) |>
  mutate(
    ci_lo = coef - 1.96 * se,
    ci_hi = coef + 1.96 * se,
    spec  = factor(spec, levels = rev(spec))
  )

p_rob <- ggplot(rc_coef, aes(x = coef, y = spec)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey60") +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi), height = 0.2, linewidth = 0.7) +
  geom_point(size = 3) +
  labs(
    title    = "Robustness Checks — PCI and Democracy",
    subtitle = "95% CI, SE clustered by country (iso3)",
    x        = "Coefficient",
    y        = NULL,
    caption  = "All models: controls = log(GDP/capita) + log(population)"
  ) +
  theme_bw(base_size = 12)

ggsave(file.path(fig_dir, "fig_robustness.png"), p_rob,
       width = 7, height = 5, dpi = 150)

cat("\nAll figures saved to", fig_dir, "\n")
cat("Analysis complete.\n")
