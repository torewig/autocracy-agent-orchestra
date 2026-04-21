# peek_wos.R — check WOS column names and V-DEM variable availability
# Run once to inform script design; not part of the main pipeline

cat("=== WOS structure ===\n")
wos_path <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/DATA/bibliometric/WOS_scrapes/wos_articles.rds"
cat("Loading...\n")
wos <- readRDS(wos_path)
cat("Dimensions:", nrow(wos), "x", ncol(wos), "\n\n")
cat("Column names:\n")
print(names(wos))
cat("\nColumn classes:\n")
print(sapply(wos, class))
cat("\ndoc_type values (top 10):\n")
print(sort(table(wos$doc_type), decreasing = TRUE)[1:10])
cat("\nFirst 2 rows of key columns:\n")
key_cols <- intersect(c("ut", "year", "doc_type", "countries", "subject_categories",
                        "subject_primary", "tot_cites", "title"), names(wos))
print(head(wos[, key_cols, drop = FALSE], 2))
cat("\n=== Memory used ===\n")
cat(format(object.size(wos), units = "GB"), "\n")
rm(wos); gc()

cat("\n=== V-DEM available type-of-autocracy variables ===\n")
library(vdemdata)
vdem_cols <- names(vdem)
check_vars <- c("v2clacfree", "v2x_freexp_altinf", "v2csreprss",
                "v2xnp_regcorr", "v2x_neopat", "v2cseeorgs", "v2mecenefm")
for (v in check_vars) {
  cat(sprintf("  %-25s %s\n", v, if (v %in% vdem_cols) "EXISTS" else "NOT FOUND"))
}
