library(tidyverse)

corpus <- readRDS("data/agent_corpus.rds")

cat("=== CORPUS OVERVIEW ===\n")
cat("Rows:", nrow(corpus), "\n")
cat("Columns:", ncol(corpus), "\n\n")

cat("=== COLUMN NAMES ===\n")
print(names(corpus))

cat("\n=== YEAR DISTRIBUTION ===\n")
corpus |> count(year) |> arrange(year) |> print(n = 50)

cat("\n=== REGIME DISTRIBUTION ===\n")
corpus |> count(v2x_regime, regime_label = case_when(
  v2x_regime == 0 ~ "closed autocracy",
  v2x_regime == 1 ~ "electoral autocracy",
  v2x_regime == 2 ~ "electoral democracy",
  v2x_regime == 3 ~ "liberal democracy"
)) |> print()

cat("\n=== TOP 10 COUNTRIES ===\n")
corpus |> count(country_name, sort = TRUE) |> head(10) |> print()

cat("\n=== TOP 10 SUBJECT FIELDS ===\n")
corpus |> count(subject_primary, sort = TRUE) |> head(10) |> print()

cat("\n=== SAMPLE 5 ROWS (key vars) ===\n")
corpus |>
  select(ut, year, iso3, country_name, subject_primary, v2x_libdem, v2x_regime,
         regime_binary, v2clacfree, field_year_mean_cites, tot_cites,
         n_articles_country_year) |>
  slice_sample(n = 5) |>
  print(width = 120)

cat("\n=== MISSING DATA SUMMARY ===\n")
corpus |>
  select(v2x_libdem, v2x_regime, regime_binary, v2clacfree,
         v2x_freexp_altinf, v2csreprss, v2xnp_regcorr,
         field_year_mean_cites, tot_cites, n_articles_country_year) |>
  summarise(across(everything(), ~sum(is.na(.)))) |>
  pivot_longer(everything(), names_to = "var", values_to = "n_missing") |>
  print()

cat("\n=== V-DEM VARIABLE RANGES ===\n")
corpus |>
  select(v2x_libdem, v2clacfree, v2x_freexp_altinf, v2csreprss, v2xnp_regcorr) |>
  summary() |> print()
