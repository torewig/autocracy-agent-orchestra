suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(lubridate))

wos <- readRDS("C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/DATA/bibliometric/WOS_scrapes/wos_ssh_articles.rds")

wos2 <- wos |>
  mutate(year = year(date)) |>
  filter(doc_type == "Article", year >= 1970, year <= 2023, !is.na(subject_categories))

cat("Total articles:", format(nrow(wos2), big.mark = ","), "\n\n")

wos2 |>
  mutate(
    has_abstract = !is.na(abstract) & nchar(trimws(abstract)) > 10,
    decade = paste0((year %/% 10) * 10, "s")
  ) |>
  group_by(decade) |>
  summarise(total = n(), with_abstract = sum(has_abstract),
            pct = round(100 * with_abstract / total, 1), .groups = "drop") |>
  print()
