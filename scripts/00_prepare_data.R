# scripts/00_prepare_data.R
# Phase 0 data preparation: produces data/agent_corpus.rds
# Run from the project root directory.
#
# Inputs:
#   DATA/bibliometric/WOS_scrapes/wos_articles.rds  (~3.9 GB in RAM)
#   DATA/vdem/vdem_clean.rds
#   ssh_fields.txt
#
# Outputs:
#   data/agent_corpus.rds
#   data/n_summary.txt
#   data/country_match_log.txt

suppressPackageStartupMessages({
  library(tidyverse)
  library(lubridate)
  library(countrycode)
})

t0 <- Sys.time()
cat("=== Phase 0: Data preparation ===\n")
cat("Started:", format(t0), "\n\n")

# ── Paths ─────────────────────────────────────────────────────────────────────

base <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG"

wos_path   <- file.path(base, "DATA/bibliometric/WOS_scrapes/wos_articles.rds")
vdem_path  <- file.path(base, "DATA/vdem/vdem_clean.rds")
ssh_path   <- "ssh_fields.txt"    # relative to project root
out_dir    <- "data"
out_corpus <- file.path(out_dir, "agent_corpus.rds")
out_nsumm  <- file.path(out_dir, "n_summary.txt")
out_cmatch <- file.path(out_dir, "country_match_log.txt")

dir.create(out_dir, showWarnings = FALSE)

# ── 1. SSH field list ─────────────────────────────────────────────────────────

cat("Step 1: Loading SSH field list...\n")
ssh_fields <- readLines(ssh_path) |>
  str_subset("^[^#]") |>
  str_trim() |>
  (\(x) x[nchar(x) > 0])() |>
  str_to_lower()
cat("  SSH categories:", length(ssh_fields), "\n\n")

# Build regex for efficient matching: field names as exact semicolon-delimited tokens
ssh_escaped <- str_replace_all(ssh_fields, "([.+*?\\[\\]{}()|^$\\\\])", "\\\\\\1")
ssh_regex   <- paste0("(?i)(?:^|;)\\s*(?:", paste(ssh_escaped, collapse = "|"), ")\\s*(?:;|$)")

# ── 2. Load WOS data ──────────────────────────────────────────────────────────

cat("Step 2: Loading WOS data (3.9 GB in RAM, may take several minutes)...\n")
wos <- readRDS(wos_path)
cat("  Loaded:", format(nrow(wos), big.mark = ","), "rows x", ncol(wos), "cols\n")

# Drop columns not needed for the corpus (free ~1.5 GB)
keep_cols <- c("ut", "date", "doc_type", "title", "abstract", "keywords",
               "keywords_plus", "subject_categories", "journal", "tot_cites",
               "n_authors", "institutions", "grant_agencies", "countries")
wos <- wos[, intersect(keep_cols, names(wos))]
invisible(gc())
cat("  After column drop:", format(object.size(wos), units = "GB"), "\n\n")

# ── 3. Derive year and subject_primary; filter ────────────────────────────────

cat("Step 3: Filtering to Article / 1970-2023 / SSH...\n")

wos <- wos |>
  mutate(
    year            = as.integer(year(date)),
    subject_primary = str_trim(str_extract(subject_categories, "^[^;]+"))
  ) |>
  filter(
    doc_type == "Article",
    !is.na(year), year >= 1970, year <= 2023,
    !is.na(subject_categories)
  )
cat("  After Article + year filter:", format(nrow(wos), big.mark = ","), "\n")

wos <- wos |> filter(grepl(ssh_regex, subject_categories, perl = TRUE))
cat("  After SSH filter:           ", format(nrow(wos), big.mark = ","), "\n")
invisible(gc())

# ── 4. Expand to article-country rows ─────────────────────────────────────────

cat("\nStep 4: Expanding to article-country rows...\n")

wos_long <- wos |>
  filter(!is.na(countries), countries != "") |>
  mutate(country_raw = str_split(countries, ";\\s*")) |>
  select(-countries) |>
  unnest(country_raw) |>
  mutate(country_raw = str_trim(country_raw)) |>
  filter(country_raw != "") |>
  distinct(ut, country_raw, .keep_all = TRUE)

rm(wos); invisible(gc())
cat("  Article-country rows:", format(nrow(wos_long), big.mark = ","), "\n\n")

# ── 5. Standardize to ISO3 ────────────────────────────────────────────────────

cat("Step 5: Standardizing to ISO3...\n")

# Historical WOS uses non-standard country strings for pre-1984 records.
# Map these to ISO3 (or V-DEM country_text_id equivalents for defunct states).
# DDR = East Germany, CSK = Czechoslovakia — both coded in V-DEM.
historical_map <- c(
  "ENGLAND"         = "GBR",
  "SCOTLAND"        = "GBR",
  "WALES"           = "GBR",
  "NORTH IRELAND"   = "GBR",
  "FED REP GER"     = "DEU",
  "BUNDES REPUBLIK" = "DEU",
  "W GERMANY"       = "DEU",
  "WEST GERMANY"    = "DEU",
  "GER DEM REP"     = "DDR",
  "DEUTSCH DEM REP" = "DDR",
  "E GERMANY"       = "DDR",
  "EAST GERMANY"    = "DDR",
  "CZECHOSLOVAKIA"  = "CSK",
  "CESKOSLOVANSKO"  = "CSK",
  "USSR"            = "SUN",
  "SOVIET UNION"    = "SUN",
  "YUGOSLAVIA"      = "YUG"
)
historical_names <- c(
  "DDR" = "East Germany",
  "CSK" = "Czechoslovakia",
  "SUN" = "Soviet Union",
  "YUG" = "Yugoslavia"
)

wos_long <- wos_long |>
  mutate(
    iso3 = countrycode(country_raw, "country.name", "iso3c",
                       warn = FALSE, custom_match = historical_map),
    country = case_when(
      iso3 %in% names(historical_names) ~ historical_names[iso3],
      !is.na(iso3) ~ countrycode(iso3, "iso3c", "country.name", warn = FALSE),
      TRUE ~ NA_character_
    )
  )

unmatched <- wos_long |>
  filter(is.na(iso3)) |>
  count(country_raw, sort = TRUE)

n_unmatched <- sum(unmatched$n)
match_rate  <- 1 - n_unmatched / nrow(wos_long)

cat(sprintf("  ISO3 match rate: %.2f%% (%s unmatched of %s rows)\n",
            match_rate * 100,
            format(n_unmatched, big.mark = ","),
            format(nrow(wos_long), big.mark = ",")))

writeLines(
  c(sprintf("Country match log — generated %s", format(Sys.time())),
    sprintf("Match rate: %.2f%%", match_rate * 100),
    sprintf("Unmatched rows: %s of %s", format(n_unmatched, big.mark = ","),
            format(nrow(wos_long), big.mark = ",")),
    "",
    "Top 30 unmatched country strings:",
    capture.output(print(head(unmatched, 30), row.names = FALSE))),
  out_cmatch
)
cat("  Match log saved:", out_cmatch, "\n")

if (match_rate < 0.95) {
  cat(sprintf(
    "  NOTE: Match rate %.2f%% < 95%%. Inspect %s.\n",
    match_rate * 100, out_cmatch))
} else {
  cat(sprintf("  Match rate %.2f%% >= 95%%: OK.\n", match_rate * 100))
}

# ── 6. Merge V-DEM ────────────────────────────────────────────────────────────

cat("\nStep 6: Merging V-DEM...\n")
vdem <- readRDS(vdem_path)
cat("  V-DEM columns:", paste(names(vdem), collapse = ", "), "\n")

wos_long <- wos_long |>
  left_join(vdem, by = c("iso3" = "country_text_id", "year"))

vdem_match_rate <- mean(!is.na(wos_long$v2x_libdem))
cat(sprintf("  V-DEM join rate: %.2f%%\n", vdem_match_rate * 100))
rm(vdem); invisible(gc())

# ── 7. Derived variables ──────────────────────────────────────────────────────

cat("\nStep 7: Computing derived variables...\n")

wos_long <- wos_long |>
  group_by(subject_primary, year) |>
  mutate(field_year_mean_cites = mean(tot_cites, na.rm = TRUE)) |>
  ungroup() |>
  group_by(country, year) |>
  mutate(n_articles_country_year = n_distinct(ut)) |>
  ungroup() |>
  group_by(country, year, subject_primary) |>
  mutate(n_articles_country_year_field = n_distinct(ut)) |>
  ungroup()

cat("  Derived variables added.\n")

# ── 8. N summary ──────────────────────────────────────────────────────────────

cat("\nStep 8: Writing N summary...\n")

n_articles <- n_distinct(wos_long$ut)
n_rows     <- nrow(wos_long)

# Regime breakdown: distinct articles per regime (note: multi-country articles counted once per regime)
by_regime <- wos_long |>
  filter(!is.na(v2x_regime)) |>
  distinct(ut, v2x_regime) |>
  count(v2x_regime) |>
  mutate(label = case_when(
    v2x_regime == 0 ~ "0 = closed autocracy",
    v2x_regime == 1 ~ "1 = electoral autocracy",
    v2x_regime == 2 ~ "2 = electoral democracy",
    v2x_regime == 3 ~ "3 = liberal democracy"
  ))

by_decade <- wos_long |>
  distinct(ut, year) |>
  mutate(decade = (year %/% 10) * 10) |>
  count(decade, sort = FALSE)

top_fields <- wos_long |>
  distinct(ut, subject_primary) |>
  count(subject_primary, sort = TRUE) |>
  head(10)

top_countries <- wos_long |>
  filter(!is.na(iso3)) |>
  distinct(ut, country) |>
  count(country, sort = TRUE) |>
  head(15)

# Academic freedom summary across the corpus
acfree_summ <- wos_long |>
  filter(!is.na(v2clacfree)) |>
  summarise(mean = mean(v2clacfree), sd = sd(v2clacfree),
            min = min(v2clacfree), max = max(v2clacfree))

elapsed <- round(difftime(Sys.time(), t0, units = "mins"), 1)

summary_lines <- c(
  "=============================================================",
  "  N SUMMARY — Phase 0 output",
  sprintf("  Generated: %s  (%.1f min)", format(Sys.time()), as.numeric(elapsed)),
  "=============================================================",
  "",
  sprintf("  Total SSH articles (distinct ut):   %s", format(n_articles, big.mark = ",")),
  sprintf("  Total article-country rows:         %s", format(n_rows, big.mark = ",")),
  sprintf("  ISO3 country match rate:            %.2f%%", match_rate * 100),
  sprintf("  V-DEM join rate:                    %.2f%%", vdem_match_rate * 100),
  "",
  "  Regime breakdown (distinct article-country-regime rows):",
  paste0("    ", by_regime$label, ":  ", format(by_regime$n, big.mark = ",")),
  "",
  "  Articles by decade:",
  paste0("    ", by_decade$decade, "s:  ", format(by_decade$n, big.mark = ",")),
  "",
  "  Top 10 SSH subject categories (by article count):",
  paste0("    ", seq_len(nrow(top_fields)), ". ",
         top_fields$subject_primary, " (", format(top_fields$n, big.mark = ","), ")"),
  "",
  "  Top 15 countries (by article count):",
  paste0("    ", seq_len(nrow(top_countries)), ". ",
         top_countries$country, " (", format(top_countries$n, big.mark = ","), ")"),
  "",
  "  v2clacfree (academic freedom) across matched article-country rows:",
  sprintf("    mean=%.2f  sd=%.2f  min=%.1f  max=%.1f",
          acfree_summ$mean, acfree_summ$sd,
          acfree_summ$min, acfree_summ$max),
  ""
)

writeLines(summary_lines, out_nsumm)
cat(paste(summary_lines, collapse = "\n"), "\n")

# ── 9. Save corpus ────────────────────────────────────────────────────────────

cat("Step 9: Saving agent_corpus.rds...\n")
saveRDS(wos_long, out_corpus)
sz_gb <- round(file.size(out_corpus) / 1e9, 2)
cat(sprintf("  Saved: %s  (%.2f GB on disk)\n", out_corpus, sz_gb))
cat(sprintf("  Final dimensions: %s rows x %d cols\n",
            format(nrow(wos_long), big.mark = ","), ncol(wos_long)))
cat(sprintf("\nPhase 0 complete. Total time: %.1f minutes.\n",
            as.numeric(difftime(Sys.time(), t0, units = "mins"))))
