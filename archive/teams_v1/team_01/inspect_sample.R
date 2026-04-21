base_dir <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra"
outfile  <- file.path(base_dir, "teams/team_01/inspect_out.txt")

cat("Loading agent_corpus.rds...\n")
d <- readRDS(file.path(base_dir, "data/agent_corpus.rds"))
cat("Loaded.\n")

# Derive year from date if year is all NA
if (all(is.na(d$year))) {
  d$year <- as.integer(format(d$date, "%Y"))
}

out <- c(
  paste("Dimensions:", nrow(d), "x", ncol(d)),
  "",
  paste("Column names:", paste(names(d), collapse=", ")),
  "",
  paste("Column classes:", paste(paste(names(d), sapply(d, function(x) class(x)[1]), sep="="), collapse=", ")),
  "",
  paste("Abstract coverage:", sum(!is.na(d$abstract)), "/", nrow(d)),
  paste("Title coverage:", sum(!is.na(d$title)), "/", nrow(d)),
  paste("Keywords coverage:", sum(!is.na(d$keywords)), "/", nrow(d)),
  paste("Keywords_plus coverage:", sum(!is.na(d$keywords_plus)), "/", nrow(d)),
  paste("Year range:", paste(range(d$year, na.rm=TRUE), collapse=" - ")),
  ""
)

# Sample abstract
abs_nonNA <- d$abstract[!is.na(d$abstract)]
if (length(abs_nonNA) > 0) {
  out <- c(out, "Sample abstract (first non-NA):")
  out <- c(out, substr(abs_nonNA[1], 1, 500))
  out <- c(out, "")
  out <- c(out, paste("Median abstract length:", median(nchar(abs_nonNA))))
}

# Year distribution
out <- c(out, "Articles by decade:")
for (dec in c(1940, 1950, 1960, 1970, 1980)) {
  n <- sum(d$year >= dec & d$year < dec + 10, na.rm = TRUE)
  out <- c(out, paste0("  ", dec, "s: ", n))
}
out <- c(out, "")

# Subject categories
out <- c(out, "Top 25 subject_primary values:")
tb <- sort(table(d$subject_primary), decreasing = TRUE)
for (i in seq_len(min(25, length(tb)))) {
  out <- c(out, paste0("  ", names(tb)[i], ": ", tb[i]))
}
out <- c(out, "")

# Regime distribution
out <- c(out, "Regime distribution (v2x_regime):")
rt <- table(d$v2x_regime)
for (i in seq_along(rt)) {
  out <- c(out, paste0("  regime=", names(rt)[i], ": ", rt[i]))
}
out <- c(out, "")

# v2x_libdem summary
out <- c(out, paste("v2x_libdem: mean=", round(mean(d$v2x_libdem, na.rm=TRUE), 3),
                    "sd=", round(sd(d$v2x_libdem, na.rm=TRUE), 3),
                    "min=", round(min(d$v2x_libdem, na.rm=TRUE), 3),
                    "max=", round(max(d$v2x_libdem, na.rm=TRUE), 3)))
out <- c(out, paste("v2clacfree: mean=", round(mean(d$v2clacfree, na.rm=TRUE), 3),
                    "sd=", round(sd(d$v2clacfree, na.rm=TRUE), 3)))

writeLines(out, outfile)
cat("Written to", outfile, "\n")
