suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))

wos <- readRDS("C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/DATA/bibliometric/WOS_scrapes/wos_ssh_articles.rds")

wos2 <- wos |>
  mutate(year = year(date)) |>
  filter(doc_type == "Article", year >= 1970, year <= 2023, !is.na(subject_categories))

cat("=== Missing country vs address breakdown ===\n")
wos2 |>
  mutate(
    has_countries    = !is.na(countries)    & countries    != "",
    has_institutions = !is.na(institutions) & institutions != ""
  ) |>
  count(has_countries, has_institutions) |>
  print()

cat("\n=== Missing country by decade ===\n")
wos2 |>
  mutate(
    decade      = paste0((year %/% 10) * 10, "s"),
    has_country = !is.na(countries) & countries != ""
  ) |>
  count(decade, has_country) |>
  pivot_wider(names_from = has_country, values_from = n,
              names_prefix = "country_", values_fill = 0) |>
  rename(missing = country_FALSE, present = country_TRUE) |>
  mutate(pct_missing = round(100 * missing / (missing + present), 1)) |>
  arrange(decade) |>
  print()

cat("\n=== Examples: has institution but missing country ===\n")
wos2 |>
  filter((is.na(countries) | countries == "") &
         !is.na(institutions) & institutions != "") |>
  select(ut, year, title, institutions, countries) |>
  slice_sample(n = 5) |>
  print(width = 140)

cat("\n=== Examples: missing both institution and country ===\n")
wos2 |>
  filter((is.na(countries)    | countries    == "") &
         (is.na(institutions) | institutions == "")) |>
  select(ut, year, title, institutions, countries) |>
  slice_sample(n = 5) |>
  print(width = 140)
