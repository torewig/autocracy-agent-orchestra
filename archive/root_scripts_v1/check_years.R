suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))

base   <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG"
corpus <- file.path(base, "Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds")
wos_p  <- file.path(base, "DATA/bibliometric/WOS_scrapes/wos_articles.rds")

cat("=== 1. Year dist in agent_corpus.rds ===\n")
ac <- readRDS(corpus)
cat("Year range:", min(ac$year, na.rm=TRUE), "-", max(ac$year, na.rm=TRUE), "\n")
print(table(ac$year %/% 10 * 10))
cat("\nSample 10 rows:\n")
set.seed(42)
print(ac |> sample_n(10) |> select(ut, year, country, subject_primary))
rm(ac); invisible(gc())

cat("\n=== 2. Full WOS: year range + decade dist for Articles ===\n")
wos <- readRDS(wos_p)
wos_art <- wos |>
  filter(doc_type == "Article") |>
  mutate(yr = as.integer(year(date)))
cat("Year range:", min(wos_art$yr, na.rm=TRUE), "-", max(wos_art$yr, na.rm=TRUE), "\n")
dec <- wos_art |> filter(!is.na(yr), yr >= 1960, yr <= 2030) |>
  mutate(decade = yr %/% 10 * 10) |>
  count(decade)
print(dec, n = 30)

cat("\n=== 3. Country NA rate by decade ===\n")
wos_art |>
  filter(!is.na(yr), yr >= 1960, yr <= 2030) |>
  mutate(decade      = yr %/% 10 * 10,
         has_country = !is.na(countries) & nchar(countries) > 0) |>
  count(decade, has_country) |>
  pivot_wider(names_from = has_country, values_from = n, values_fill = 0L) |>
  rename(no_country = `FALSE`, has_country = `TRUE`) |>
  mutate(pct_with = round(100 * has_country / (has_country + no_country), 1)) |>
  print(n = 20)

cat("\n=== 4. Sample 5 post-1990 Articles: date + countries ===\n")
post90 <- wos_art |> filter(yr >= 1990) |> slice_sample(n = 5)
print(post90 |> select(ut, yr, date, countries, subject_categories))
