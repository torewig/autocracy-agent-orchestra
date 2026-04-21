$r = "C:\Program Files\R\R-4.5.1\bin\Rscript.exe"
& $r - << 'EOF'
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))

base    <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG"
corpus  <- file.path(base, "Papers/Autocracy and science_Agent Orchestra/data/agent_corpus.rds")
wos_p   <- file.path(base, "DATA/bibliometric/WOS_scrapes/wos_articles.rds")

cat("=== 1. Year distribution in AGENT CORPUS ===\n")
ac <- readRDS(corpus)
cat("Year range:", min(ac$year, na.rm=T), "-", max(ac$year, na.rm=T), "\n")
print(table(ac$year %/% 10 * 10))

cat("\n=== 2. Sample of 10 articles from corpus ===\n")
set.seed(42)
print(ac |> sample_n(10) |> select(ut, year, country, subject_primary))

cat("\n=== 3. Check full WOS: year range and decade dist for ARTICLES ===\n")
wos <- readRDS(wos_p)
wos_art <- wos |>
  filter(doc_type == "Article") |>
  mutate(year = as.integer(year(date)))
cat("Year range:", min(wos_art$year, na.rm=T), "-", max(wos_art$year, na.rm=T), "\n")
dec <- wos_art |> filter(!is.na(year)) |>
  mutate(decade = year %/% 10 * 10) |>
  count(decade)
print(dec)

cat("\n=== 4. Country NA rate by decade ===\n")
wos_art |>
  filter(!is.na(year), year >= 1970, year <= 2023) |>
  mutate(decade = year %/% 10 * 10,
         has_country = !is.na(countries) & countries != "") |>
  count(decade, has_country) |>
  pivot_wider(names_from = has_country, values_from = n, values_fill = 0) |>
  rename(no_country = `FALSE`, has_country = `TRUE`) |>
  mutate(pct_with_country = round(100 * has_country / (has_country + no_country), 1)) |>
  print()

rm(wos, wos_art); invisible(gc())
EOF
