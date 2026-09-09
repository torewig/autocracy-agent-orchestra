# scripts/extract_pooled_coefs.R
#
# For each of the 18 completed teams, re-source the team's analysis.R in a
# fresh environment with the corpus pre-injected (so readRDS short-circuits),
# capture the pre-registered pooled-OLS (year-FE only) model object, and
# extract the coefficient, clustered SE, and p-value for the team's primary
# predictor.  Writes tables/pooled_coefficients.json.
#
# Run from project root:  Rscript scripts/extract_pooled_coefs.R
#
# Why this script exists: each team's analysis.R estimates the pre-registered
# pooled-OLS secondary model alongside its primary TWFE, but only the TWFE
# coefficient is persisted in primary_results.json.  Rather than modify all
# 18 analysis scripts and re-run them, this wrapper sources them as-is.

suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
  library(jsonlite)
})

ROOT <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra"
setwd(ROOT)

teams_done <- sprintf("%02d", c(1:4, 7:9, 11, 13:22))

# Name of the pooled-OLS model object in each team's analysis.R.  Hardcoded
# because object names vary across teams and grepping is fragile.
pooled_obj <- c(
  "01" = "mod_ols",     "02" = "mod_ols",
  "03" = "mod_pooled",  "04" = "mod_year_fe",
  "07" = "mod_year",
  "08" = "mod_pool",    "09" = "mod_pool",   "11" = "mod_pool",
  "13" = "mod_pool",    "14" = "mod_pool",   "15" = "mod_pool",
  "16" = "mod_pool",    "17" = "mod_pool",   "18" = "mod_pool",
  "19" = "mod_pool",    "20" = "mod_pool",   "21" = "mod_pool",
  "22" = "mod_pool"
)

DATA_PATH <- file.path(ROOT, "data/agent_corpus.rds")

cat("Loading corpus (one-time) ...\n")
t0 <- proc.time()[3]
corpus_cached <- readRDS(DATA_PATH)
cat(sprintf("  %d rows, %d cols loaded in %.1fs\n",
            nrow(corpus_cached), ncol(corpus_cached), proc.time()[3] - t0))

# Intercept readRDS in the team-script environment so the cached corpus is
# returned instead of re-loading the 1.1 GB file.  Only intercept reads of
# agent_corpus.rds; other readRDS calls pass through.
make_readRDS_intercept <- function(real_readRDS) {
  function(file, refhook = NULL) {
    if (basename(file) == "agent_corpus.rds") {
      message("[intercept] readRDS('agent_corpus.rds') -> cached")
      return(corpus_cached)
    }
    real_readRDS(file, refhook = refhook)
  }
}

# Suppress slow file-writes (figures, JSON, tables) inside the sourced
# scripts.  We only care about the in-memory model objects.
noop <- function(...) invisible(NULL)

extract_one <- function(team) {
  cat(sprintf("\n=== Team %s ===\n", team))
  script_path <- file.path(ROOT, sprintf("teams/team_%s/analysis/analysis.R", team))
  if (!file.exists(script_path)) {
    cat("  SKIP: analysis.R missing\n"); return(NULL)
  }

  env <- new.env(parent = globalenv())
  # Pre-populate hooks.
  env$readRDS    <- make_readRDS_intercept(base::readRDS)
  env$ggsave     <- noop                  # skip figure writes
  env$write_json <- noop                  # team scripts use jsonlite::write_json
  env$writeLines <- noop                  # skip log writes
  env$dir.create <- noop

  pj_path  <- file.path(ROOT, sprintf("teams/team_%s/analysis/primary_results.json", team))
  primary  <- fromJSON(pj_path)
  predictor <- primary$predictor          # e.g. "v2x_libdem" or "v2x_libdem:sensitive_flag"

  t1 <- proc.time()[3]
  ok <- tryCatch({
    sys.source(script_path, envir = env, chdir = FALSE)
    TRUE
  }, error = function(e) {
    cat(sprintf("  ERROR sourcing analysis.R: %s\n", conditionMessage(e)))
    FALSE
  })
  cat(sprintf("  sourced in %.1fs\n", proc.time()[3] - t1))
  if (!ok) return(NULL)

  obj_name <- pooled_obj[[team]]
  if (!exists(obj_name, envir = env, inherits = FALSE)) {
    cat(sprintf("  ERROR: pooled object '%s' not found in env\n", obj_name))
    return(NULL)
  }
  m <- get(obj_name, envir = env)

  # Pull coef table; fixest stores it as $coeftable with rownames = vars.
  ct <- summary(m)$coeftable
  if (!(predictor %in% rownames(ct))) {
    # fixest renders interactions either as "a:b" or "a x b"; try both.
    alt <- gsub(":", " x ", predictor, fixed = TRUE)
    if (alt %in% rownames(ct)) predictor <- alt
  }
  if (!(predictor %in% rownames(ct))) {
    cat(sprintf("  ERROR: predictor '%s' not in coeftable. Rows: %s\n",
                predictor, paste(rownames(ct), collapse = ", ")))
    return(NULL)
  }
  row <- ct[predictor, , drop = TRUE]
  cat(sprintf("  pooled coef = %.5f  se = %.5f  p = %.4f\n",
              row["Estimate"], row[2], row[4]))

  list(
    team               = team,
    family             = primary$theory_family,
    predictor          = predictor,
    coefficient_pooled = unname(row["Estimate"]),
    se_pooled          = unname(row[2]),
    t_pooled           = unname(row[3]),
    p_pooled           = unname(row[4])
  )
}

results <- lapply(teams_done, extract_one)
names(results) <- teams_done
results <- Filter(Negate(is.null), results)

out_path <- file.path(ROOT, "tables/pooled_coefficients.json")
write_json(results, out_path, pretty = TRUE, auto_unbox = TRUE, digits = 8)
cat(sprintf("\nWrote: %s  (%d teams)\n", out_path, length(results)))

if (length(results) < length(teams_done)) {
  miss <- setdiff(teams_done, names(results))
  cat(sprintf("Missing pooled estimates for: %s\n",
              paste(miss, collapse = ", ")))
}
