# =============================================================================
# bonferroni_adjust.R
#
# Reads primary_results.json from all team analysis folders, groups hypotheses
# by theory_family, and applies Bonferroni correction within each family.
#
# The Bonferroni correction here addresses the multiple-testing problem that
# arises when several teams test hypotheses derived from the same theoretical
# argument. Teams sharing a theory_family label are treated as a family of
# related tests; the adjusted threshold is alpha / k where k = number of tests
# in the family.
#
# Outputs:
#   data/adjusted_pvalues.rds       — loaded by Writer agents (one row per team)
#   data/adjusted_pvalues_report.md — human-readable table for PI review
#
# Usage:
#   Rscript scripts/bonferroni_adjust.R
# =============================================================================

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(jsonlite))

setwd("C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra")

# -----------------------------------------------------------------------------
# 1. Collect all primary_results.json files
# -----------------------------------------------------------------------------
json_files <- list.files(
  path       = "teams",
  pattern    = "primary_results.json",
  recursive  = TRUE,
  full.names = TRUE
)

if (length(json_files) == 0) {
  stop("No primary_results.json found in any team folder.\n",
       "Analysts must produce this file as part of their deliverable.")
}

cat(sprintf("Found %d primary_results.json file(s) (expecting 30)\n", length(json_files)))

results <- lapply(json_files, function(f) {
  cat("  Reading:", f, "\n")
  fromJSON(f)
}) |>
  bind_rows()

cat(sprintf("\nTotal hypothesis tests collected: %d\n\n", nrow(results)))

# -----------------------------------------------------------------------------
# 2. Validate required fields
# -----------------------------------------------------------------------------
required_fields <- c("team", "hypothesis_label", "theory_family", "predictor",
                     "outcome", "model_description", "coefficient", "se",
                     "t_stat", "p_value", "n_obs")
missing_fields <- setdiff(required_fields, names(results))
if (length(missing_fields) > 0) {
  stop("Missing required fields in primary_results.json: ",
       paste(missing_fields, collapse = ", "))
}

# Warn on missing or blank theory_family
blank_family <- results |> filter(is.na(theory_family) | trimws(theory_family) == "")
if (nrow(blank_family) > 0) {
  warning(sprintf("%d row(s) have missing theory_family — assigned 'unclassified'",
                  nrow(blank_family)))
  results <- results |>
    mutate(theory_family = if_else(is.na(theory_family) | trimws(theory_family) == "",
                                   "unclassified", theory_family))
}

# -----------------------------------------------------------------------------
# 3. Bonferroni correction within theory family
# -----------------------------------------------------------------------------
results <- results |>
  group_by(theory_family) |>
  mutate(
    n_tests_in_family = n(),
    p_adjusted        = pmin(p_value * n_tests_in_family, 1),
    sig_raw           = p_value    < 0.05,
    sig_adjusted      = p_adjusted < 0.05
  ) |>
  ungroup() |>
  arrange(theory_family, team)

# -----------------------------------------------------------------------------
# 4. Save RDS for Writer agents
# -----------------------------------------------------------------------------
saveRDS(results, "data/adjusted_pvalues.rds")
cat("Saved: data/adjusted_pvalues.rds\n")

# -----------------------------------------------------------------------------
# 5. Write human-readable markdown report
# -----------------------------------------------------------------------------
families  <- sort(unique(results$theory_family))
n_teams   <- n_distinct(results$team)
timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")

lines <- c(
  "# Bonferroni-Adjusted P-values",
  "",
  sprintf("**Generated:** %s", timestamp),
  sprintf("**Teams included:** %d", n_teams),
  sprintf("**Total hypothesis tests:** %d", nrow(results)),
  "",
  paste0(
    "P-values are adjusted using the Bonferroni method. ",
    "The correction is applied within families of hypotheses that share the same ",
    "theoretical argument (`theory_family` from each team's `rq.md`). ",
    "For a family of *k* tests, the adjusted p-value is `p_raw × k`, capped at 1. ",
    "The adjusted p-value applies to each team's **primary hypothesis test only**; ",
    "robustness checks use raw p-values."
  ),
  "",
  "---",
  ""
)

for (fam in families) {
  fam_data <- filter(results, theory_family == fam)
  k <- unique(fam_data$n_tests_in_family)

  lines <- c(
    lines,
    sprintf("## Theory family: `%s`", fam),
    sprintf("*%d test(s) — Bonferroni multiplier: %d*", k, k),
    "",
    "| Team | Hypothesis | Predictor | Outcome | p (raw) | p (adjusted) | Sig (adj)? |",
    "|------|------------|-----------|---------|---------|--------------|------------|"
  )

  for (i in seq_len(nrow(fam_data))) {
    row <- fam_data[i, ]
    sig_label <- if (isTRUE(row$sig_adjusted)) "Yes" else "No"
    lines <- c(lines, sprintf(
      "| %s | %s | `%s` | `%s` | %.4f | %.4f | %s |",
      row$team,
      row$hypothesis_label,
      row$predictor,
      row$outcome,
      row$p_value,
      row$p_adjusted,
      sig_label
    ))
  }
  lines <- c(lines, "")
}

# Summary table
lines <- c(
  lines,
  "---",
  "",
  "## Summary by theory family",
  "",
  "| Theory family | Tests | Sig (raw) | Sig (adjusted) |",
  "|---------------|-------|-----------|----------------|"
)
summary_df <- results |>
  group_by(theory_family) |>
  summarise(n_tests        = n(),
            n_sig_raw      = sum(sig_raw),
            n_sig_adjusted = sum(sig_adjusted),
            .groups = "drop") |>
  arrange(theory_family)

for (i in seq_len(nrow(summary_df))) {
  r <- summary_df[i, ]
  lines <- c(lines, sprintf("| %s | %d | %d | %d |",
    r$theory_family, r$n_tests, r$n_sig_raw, r$n_sig_adjusted))
}

writeLines(lines, "data/adjusted_pvalues_report.md")
cat("Saved: data/adjusted_pvalues_report.md\n\n")

# -----------------------------------------------------------------------------
# 6. Console summary
# -----------------------------------------------------------------------------
cat("=== Bonferroni adjustment complete ===\n\n")
print(summary_df)
cat("\nReview data/adjusted_pvalues_report.md before starting Writer sessions.\n")
cat("Check that theory_family groupings are sensible and all 30 teams are present.\n")
cat("Expected sub-families: topic-avoidance (7), framing-neutrality (6),\n")
cat("  collaboration-constraint (5), visibility-suppression (4),\n")
cat("  temporal-dynamics (4), heterogeneity-moderation (4)\n")
