# add_lied.R
# Adds e_lexical_index and lied_binary to agent_corpus.rds and vdem_clean.rds.
# lied_binary = 1 if e_lexical_index >= 4 (minimally competitive multiparty elections
# with full male and female suffrage for legislature and executive), 0 otherwise.
# Source: V-DEM Lexical Index of Electoral Democracy (Skaaning et al. 2015).
# Run from project root: Rscript scripts/add_lied.R

suppressPackageStartupMessages(library(dplyr))
vdem_full <- readRDS("C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Social_science_in_autocracies/Data and scripts/AutoKnow_socsci2/Data/V-Dem-CY-Full+Others-v15.rds")
lied_lu <- vdem_full |>
  select(iso3 = country_text_id, year, e_lexical_index) |>
  mutate(lied_binary = as.integer(!is.na(e_lexical_index) & e_lexical_index >= 4)) |>
  distinct(iso3, year, .keep_all = TRUE)
corpus <- readRDS("data/agent_corpus.rds")
if ("lied_binary" %in% names(corpus)) corpus <- select(corpus, -e_lexical_index, -lied_binary)
corpus2 <- left_join(corpus, lied_lu, by = c("iso3","year"))
saveRDS(corpus2, "data/agent_corpus.rds")
cat("Done. lied_binary coverage:",
    sprintf("%.1f%%
", 100 * mean(!is.na(corpus2$lied_binary))))
vdem_clean <- readRDS("C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/DATA/vdem/vdem_clean.rds")
if ("lied_binary" %in% names(vdem_clean)) vdem_clean <- select(vdem_clean, -e_lexical_index, -lied_binary)
lied_ctid <- vdem_full |>
  select(country_text_id, year, e_lexical_index) |>
  mutate(lied_binary = as.integer(!is.na(e_lexical_index) & e_lexical_index >= 4)) |>
  distinct(country_text_id, year, .keep_all = TRUE)
vdem_clean2 <- left_join(vdem_clean, lied_ctid, by = c("country_text_id","year"))
saveRDS(vdem_clean2, "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/DATA/vdem/vdem_clean.rds")
cat("Done. vdem_clean saved.
")

