# Team 08 — Epistemic Hedging and Autocracy
# Research question: Do researchers in autocratic countries produce SSH abstracts
# with higher rates of epistemic hedging language?
# Theory family: framing-neutrality

library(tidyverse)
library(fixest)
library(modelsummary)
library(jsonlite)

# ── Paths ────────────────────────────────────────────────────────────────────

DATA_PATH <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/data/agent_corpus.rds"
OUT_DIR   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra/teams/team_08/analysis"
FIG_DIR   <- file.path(OUT_DIR, "figures")
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)

# ── 1. Load corpus ───────────────────────────────────────────────────────────

message("Loading corpus ...")
corpus <- readRDS(DATA_PATH)
message(sprintf("Corpus loaded: %d rows, %d columns", nrow(corpus), ncol(corpus)))

# ── 2. Construct article-level hedging rate ──────────────────────────────────

# Hedging dictionary (11 terms, primary)
HEDGE_PATTERN_PRIMARY <- "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would)\\b"

# RC2: narrow dictionary — remove "would" and "likely" (9 terms)
HEDGE_PATTERN_NARROW  <- "\\b(may|might|seem|appear|suggest|perhaps|possibly|probably|could)\\b"

# Extended dictionary for robustness (c)
HEDGE_PATTERN_EXTENDED <- "\\b(may|might|seem|appear|suggest|perhaps|possibly|likely|probably|could|would|arguably|conceivably|presumably|seemingly|relatively|somewhat)\\b"

message("Computing article-level hedging rates ...")

articles <- corpus |>
  # Keep rows with non-missing abstract
  filter(!is.na(abstract), abstract != "") |>
  # Compute word count and hedging counts at article level
  mutate(
    word_count     = str_count(abstract, "\\w+"),
    hedge_count    = str_count(tolower(abstract), HEDGE_PATTERN_PRIMARY),
    hedge_count_narrow   = str_count(tolower(abstract), HEDGE_PATTERN_NARROW),
    hedge_count_extended = str_count(tolower(abstract), HEDGE_PATTERN_EXTENDED)
  ) |>
  # Exclude abstracts with fewer than 20 words
  filter(word_count >= 20) |>
  # Article-level hedging rates
  mutate(
    hedge_rate          = hedge_count    / word_count,
    hedge_rate_narrow   = hedge_count_narrow   / word_count,
    hedge_rate_extended = hedge_count_extended / word_count
  )

message(sprintf("Articles with valid abstracts (>= 20 words): %d", nrow(articles)))

# RC1: English-language filter
# Use language field if available; otherwise ASCII-share heuristic (>= 90% ASCII)
if ("language" %in% colnames(articles)) {
  articles <- articles |>
    mutate(
      is_english = str_detect(tolower(language), "english") |
                   (nchar(gsub("[^\x01-\x7F]", "", abstract, perl = TRUE)) /
                    nchar(abstract)) >= 0.90
    )
} else {
  articles <- articles |>
    mutate(
      is_english = (nchar(gsub("[^\x01-\x7F]", "", abstract, perl = TRUE)) /
                    nchar(abstract)) >= 0.90
    )
}

# ── 3. Deduplicate on ut before aggregating ──────────────────────────────
# One row per article (first occurrence) within each iso3 x year cell

message("Deduplicating and aggregating to country-year ...")

articles_dedup <- articles |>
  distinct(ut, iso3, year, .keep_all = TRUE)

# ── 4. Construct binary democracy indicator (lied_binary) ───────────────────

articles_dedup <- articles_dedup |>
  mutate(lied_binary = as.integer(!is.na(e_lexical_index) & e_lexical_index >= 4))

# ── 5. Country-year aggregation ──────────────────────────────────────────────

cy_full <- articles_dedup |>
  group_by(iso3, year) |>
  summarise(
    hedge_rate_mean          = mean(hedge_rate, na.rm = TRUE),
    hedge_rate_mean_narrow   = mean(hedge_rate_narrow, na.rm = TRUE),
    hedge_rate_mean_extended = mean(hedge_rate_extended, na.rm = TRUE),
    n_abstracts              = n(),
    v2x_libdem               = first(v2x_libdem),
    lied_binary              = first(lied_binary),
    e_gdppc                  = first(e_gdppc),
    e_wb_pop                 = first(e_wb_pop),
    e_lexical_index          = first(e_lexical_index),
    .groups = "drop"
  )

# English-only country-year aggregate
cy_english <- articles_dedup |>
  filter(is_english) |>
  group_by(iso3, year) |>
  summarise(
    hedge_rate_mean_english = mean(hedge_rate, na.rm = TRUE),
    n_abstracts_english     = n(),
    .groups = "drop"
  )

# Discipline restriction: political science and sociology
polsci_socsci_labels <- c("Political Science", "Sociology",
                           "POLITICAL SCIENCE", "SOCIOLOGY")

cy_discsub <- articles_dedup |>
  filter(subject_primary %in% polsci_socsci_labels |
         str_detect(toupper(coalesce(subject_primary, "")),
                    "POLITICAL|SOCIOLOG")) |>
  group_by(iso3, year) |>
  summarise(
    hedge_rate_mean_polsoc = mean(hedge_rate, na.rm = TRUE),
    n_abstracts_polsoc     = n(),
    .groups = "drop"
  )

# ── 6. Build estimation panel ────────────────────────────────────────────────

panel <- cy_full |>
  # Apply minimum-cell threshold (>= 10 qualifying abstracts)
  filter(n_abstracts >= 10) |>
  # Drop missing controls
  filter(!is.na(v2x_libdem), !is.na(e_gdppc), !is.na(e_wb_pop)) |>
  filter(e_gdppc > 0, e_wb_pop > 0) |>
  mutate(
    log_gdppc = log(e_gdppc),
    log_pop   = log(e_wb_pop),
    year      = as.integer(year)
  ) |>
  # Join English and discipline subsets
  left_join(cy_english, by = c("iso3", "year")) |>
  left_join(cy_discsub, by = c("iso3", "year"))

message(sprintf("Panel rows: %d | Countries: %d | Years: %d-%d",
                nrow(panel),
                n_distinct(panel$iso3),
                min(panel$year), max(panel$year)))

# ── 7. Regression models ─────────────────────────────────────────────────────

message("Running regression models ...")

# Primary TWFE
mod_twfe <- feols(
  hedge_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# Secondary: pooled OLS, year FE only
mod_pool <- feols(
  hedge_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | year,
  data    = panel,
  cluster = ~iso3
)

# RC-a: Binary democracy indicator (TWFE)
mod_rca <- feols(
  hedge_rate_mean ~ lied_binary + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# RC-b: Discipline restriction (polsci + sociology)
panel_polsoc <- panel |> filter(!is.na(hedge_rate_mean_polsoc),
                                 n_abstracts_polsoc >= 10)
mod_rcb <- feols(
  hedge_rate_mean_polsoc ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel_polsoc,
  cluster = ~iso3
)

# RC-c: Extended hedging dictionary
mod_rcc <- feols(
  hedge_rate_mean_extended ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# RC-d: Post-1990 subsample
mod_rcd <- feols(
  hedge_rate_mean ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = filter(panel, year >= 1990),
  cluster = ~iso3
)

# RC1: English-language abstracts only
panel_en <- panel |> filter(!is.na(hedge_rate_mean_english),
                              n_abstracts_english >= 10)
mod_rc1 <- feols(
  hedge_rate_mean_english ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel_en,
  cluster = ~iso3
)

# RC2: Narrow hedging dictionary (remove "would" and "likely")
mod_rc2 <- feols(
  hedge_rate_mean_narrow ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year,
  data    = panel,
  cluster = ~iso3
)

# ── 8. Regression table ──────────────────────────────────────────────────────

message("Producing regression table ...")

models_main <- list(
  "TWFE (primary)"     = mod_twfe,
  "Pooled OLS"         = mod_pool,
  "RC-a: Binary demo." = mod_rca,
  "RC-b: PolSci/Soc"   = mod_rcb,
  "RC-c: Extended dict" = mod_rcc,
  "RC-d: Post-1990"    = mod_rcd,
  "RC1: English only"  = mod_rc1,
  "RC2: Narrow dict."  = mod_rc2
)

tab_tex <- modelsummary(
  models_main,
  stars   = c("*" = 0.1, "**" = 0.05, "***" = 0.01),
  coef_map = c(
    "v2x_libdem"    = "Liberal democracy (V-DEM)",
    "lied_binary"   = "Democracy (binary, LIED)",
    "log(e_gdppc)"  = "Log GDP per capita",
    "log(e_wb_pop)" = "Log population"
  ),
  gof_map  = c("nobs", "r.squared", "FE: iso3", "FE: year"),
  output   = file.path(FIG_DIR, "tab1_main_results.tex")
)

# ── 9. Figure 1 — Binned scatter ─────────────────────────────────────────────

message("Producing Figure 1 ...")

# Bin v2x_libdem into 20 equal-width bins
fig1_data <- panel |>
  mutate(libdem_bin = cut(v2x_libdem, breaks = 20, labels = FALSE)) |>
  group_by(libdem_bin) |>
  summarise(
    libdem_mid  = mean(v2x_libdem, na.rm = TRUE),
    hedge_mean  = mean(hedge_rate_mean, na.rm = TRUE),
    n           = n(),
    .groups = "drop"
  )

p1 <- ggplot(panel, aes(x = v2x_libdem, y = hedge_rate_mean)) +
  geom_point(alpha = 0.05, size = 0.4, colour = "steelblue") +
  geom_point(data = fig1_data, aes(x = libdem_mid, y = hedge_mean),
             colour = "firebrick", size = 2.5) +
  geom_smooth(method = "loess", se = TRUE, colour = "firebrick",
              linewidth = 0.8, alpha = 0.15) +
  labs(
    x     = "V-DEM Liberal Democracy Index",
    y     = "Mean hedging rate (per word)",
    title = "Epistemic hedging rate vs. liberal democracy",
    subtitle = "Country-year observations; red dots = binned means; red line = LOESS smoother"
  ) +
  theme_bw(base_size = 11)

ggsave(file.path(FIG_DIR, "fig1_hedge_rate_by_regime.png"), p1,
       width = 7, height = 5, dpi = 150)

# ── 10. Figure 2 — Coefficient plot ─────────────────────────────────────────

message("Producing Figure 2 ...")

coef_data <- tibble(
  model = c("TWFE (primary)", "Pooled OLS",
            "RC-a: Binary regime (LIED)", "RC-b: PolSci/Sociology",
            "RC-c: Extended dict.", "RC-d: Post-1990",
            "RC1: English abstracts", "RC2: Narrow dict."),
  coef  = c(
    coef(mod_twfe)["v2x_libdem"],
    coef(mod_pool)["v2x_libdem"],
    coef(mod_rca)["lied_binary"],
    coef(mod_rcb)["v2x_libdem"],
    coef(mod_rcc)["v2x_libdem"],
    coef(mod_rcd)["v2x_libdem"],
    coef(mod_rc1)["v2x_libdem"],
    coef(mod_rc2)["v2x_libdem"]
  ),
  se    = c(
    se(mod_twfe)["v2x_libdem"],
    se(mod_pool)["v2x_libdem"],
    se(mod_rca)["lied_binary"],
    se(mod_rcb)["v2x_libdem"],
    se(mod_rcc)["v2x_libdem"],
    se(mod_rcd)["v2x_libdem"],
    se(mod_rc1)["v2x_libdem"],
    se(mod_rc2)["v2x_libdem"]
  )
) |>
  mutate(
    lo95 = coef - 1.96 * se,
    hi95 = coef + 1.96 * se,
    lo90 = coef - 1.645 * se,
    hi90 = coef + 1.645 * se,
    model = fct_rev(factor(model, levels = model))
  )

p2 <- ggplot(coef_data, aes(x = coef, y = model)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey50") +
  geom_linerange(aes(xmin = lo95, xmax = hi95), linewidth = 0.6) +
  geom_linerange(aes(xmin = lo90, xmax = hi90), linewidth = 1.4) +
  geom_point(size = 3, colour = "firebrick") +
  labs(
    x     = "Coefficient on liberal democracy (v2x_libdem)",
    y     = NULL,
    title = "Effect of liberal democracy on epistemic hedging rate",
    subtitle = "Primary model + robustness checks; thick line = 90% CI, thin = 95% CI"
  ) +
  theme_bw(base_size = 11)

ggsave(file.path(FIG_DIR, "fig2_coef_plot.png"), p2,
       width = 8, height = 5, dpi = 150)

# ── 11. primary_results.json ─────────────────────────────────────────────────

message("Writing primary_results.json ...")

results <- list(
  team              = "08",
  hypothesis_label  = "Countries with lower Liberal democracy levels will exhibit higher mean epistemic hedging rates in SSH abstracts, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.",
  theory_family     = "framing-neutrality",
  predictor         = "v2x_libdem",
  outcome           = "hedge_rate_mean",
  model_description = "feols(outcome ~ v2x_libdem + log(e_gdppc) + log(e_wb_pop) | iso3 + year, cluster = ~iso3)",
  coefficient       = unname(coef(mod_twfe)["v2x_libdem"]),
  se                = unname(se(mod_twfe)["v2x_libdem"]),
  t_stat            = unname(tstat(mod_twfe)["v2x_libdem"]),
  p_value           = unname(pvalue(mod_twfe)["v2x_libdem"]),
  n_obs             = as.integer(nobs(mod_twfe)),
  n_countries       = as.integer(n_distinct(panel$iso3[!is.na(panel$v2x_libdem) &
                                                          !is.na(panel$e_gdppc) &
                                                          !is.na(panel$e_wb_pop)]))
)

write_json(results, file.path(OUT_DIR, "primary_results.json"),
           pretty = TRUE, auto_unbox = TRUE)

message("Done. All outputs written to teams/team_08/analysis/")
message(sprintf("  Primary coefficient (v2x_libdem): %.6f  SE: %.6f  p: %.4f",
                results$coefficient, results$se, results$p_value))
