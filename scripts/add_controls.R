# add_controls.R
# Adds GDP per capita and population from V-DEM to agent_corpus.rds
# Join key: iso3 x year
# New columns: e_gdppc (GDP pc, thousands 2011 USD), e_wb_pop (World Bank population)

lib <- "C:/Users/torewig/R/win-library/4.4"
.libPaths(c(lib, .libPaths()))

library(vdemdata)
library(dplyr)

base <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra"

cat("Loading agent_corpus.rds...\n")
corpus <- readRDS(file.path(base, "data/agent_corpus.rds"))
cat("Rows:", nrow(corpus), "\n")

# Extract GDP and population from full V-DEM dataset
cat("Extracting GDP and population from vdemdata...\n")
vdem_controls <- vdem |>
  filter(year >= 1970, year <= 2023) |>
  select(
    iso3 = country_text_id,
    year,
    e_gdppc,   # GDP per capita (thousands, 2011 USD) — Maddison/expanded
    e_wb_pop   # Population (World Bank)
  )

cat("V-DEM rows:", nrow(vdem_controls), "\n")
cat("Coverage: e_gdppc", round(mean(!is.na(vdem_controls$e_gdppc))*100,1), "% | e_wb_pop", round(mean(!is.na(vdem_controls$e_wb_pop))*100,1), "%\n")

# Left join — keeps all corpus rows; unmatched get NA for controls
corpus_updated <- corpus |>
  left_join(vdem_controls, by = c("iso3", "year"))

cat("\nCorpus after join:\n")
cat("Rows:", nrow(corpus_updated), "(should equal", nrow(corpus), ")\n")
cat("e_gdppc non-NA:", round(mean(!is.na(corpus_updated$e_gdppc))*100,1), "%\n")
cat("e_wb_pop non-NA:", round(mean(!is.na(corpus_updated$e_wb_pop))*100,1), "%\n")

# Save
out <- file.path(base, "data/agent_corpus.rds")
saveRDS(corpus_updated, out)
cat("\nSaved:", out, "\n")
cat("Final dims:", dim(corpus_updated), "\n")
