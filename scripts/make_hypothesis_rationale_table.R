# scripts/make_hypothesis_rationale_table.R
#
# Builds the body rows of a main-body table that summarises each team's
# pre-registered hypothesis together with a one-sentence rationale.
# Used by draft_APSG.tex via \input{tables/main_hypothesis_rationale.tex}.
#
# Source of truth = teams/team_NN/preregistration.md.
# Hypothesis text is condensed (strip the trailing "after controlling for ..."
# clause).  Rationale is the first sentence of the `## Rationale' section.

suppressPackageStartupMessages({
  library(stringr)
})

ROOT <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra"
teams <- sprintf("%02d", 1:25)

# Reuse the family map already used elsewhere in the paper -------------------
family_of <- c(
  "01" = "topic-avoidance",          "02" = "topic-avoidance",
  "03" = "topic-avoidance",          "04" = "topic-avoidance",
  "05" = "topic-avoidance",          "06" = "topic-avoidance",
  "07" = "topic-avoidance",
  "08" = "framing-neutrality",       "09" = "framing-neutrality",
  "10" = "framing-neutrality",       "11" = "framing-neutrality",
  "12" = "framing-neutrality",       "13" = "framing-neutrality",
  "14" = "collaboration-constraint", "15" = "collaboration-constraint",
  "16" = "collaboration-constraint", "17" = "collaboration-constraint",
  "18" = "collaboration-constraint",
  "19" = "visibility-suppression",   "20" = "visibility-suppression",
  "21" = "visibility-suppression",   "22" = "visibility-suppression",
  "23" = "ideological-alignment",    "24" = "ideological-alignment",
  "25" = "ideological-alignment"
)

# Per-team rationale overrides.  Used in place of the auto-extracted
# first sentence from `## Rationale' when the auto-extraction is too thin
# (i.e. describes what the outcome measures, or reports a data fact, rather
# than the theoretical pathway from self-censorship to the outcome).  Add a
# team key here to override; leave out to keep the parsed rationale.
rationale_overrides <- c(
  # --- visibility suppression (Teams 19-22): articulate the
  # self-censorship -> reduced citation visibility pathway explicitly,
  # rather than describing what citations measure.
  "19" = paste(
    "Self-censorship produces work that is rhetorically cautious,",
    "topically narrow, and unlikely to engage the politically salient",
    "debates that drive citation traffic in SSH; hedged claims and",
    "depoliticized framings give other scholars little to build on,",
    "criticize, or extend, so on average autocracy-produced SSH work",
    "should attract fewer citations than comparable work from",
    "democratic contexts."
  ),
  "20" = paste(
    "If self-censorship operates through cautious framing and weakened",
    "claims, the citation penalty should not apply uniformly: politically",
    "non-sensitive SSH topics impose few framing constraints in either",
    "regime context, so citations should be comparable, while sensitive",
    "topics force autocratic authors to hedge, depoliticize, or narrow",
    "their contributions in ways their democratic counterparts are not",
    "constrained to do --- producing a citation gap that concentrates",
    "precisely where the theory predicts self-censorship bites hardest."
  ),
  "21" = paste(
    "Articles that fail to advance any distinctive claim are the ones",
    "most likely to attract zero citations; if self-censorship pushes",
    "researchers toward incremental, low-stakes contributions on safe",
    "topics, autocratic SSH output should exhibit a larger share of",
    "articles that never enter scholarly conversation at all.",
    "This is the extensive-margin counterpart to the average-impact",
    "test in Team 19."
  ),
  "22" = paste(
    "Self-censorship may bifurcate autocratic SSH output: a small set",
    "of articles --- those touching on regime-endorsed priorities,",
    "applied development topics, or internationally co-funded",
    "projects --- escape the constraints and accumulate citations",
    "normally, while the conformist majority is undifferentiated and",
    "rarely cited. Citation distribution within autocratic",
    "country-years should therefore be more skewed than in democratic",
    "ones, captured by a higher within-cell citation Gini."
  )
)

# --- parsing helpers --------------------------------------------------------

read_prereg <- function(team) {
  f <- file.path(ROOT, sprintf("teams/team_%s/preregistration.md", team))
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

md_section_fuzzy <- function(text, keyword) {
  # Find the FIRST `## ` heading containing `keyword' (case-insensitive),
  # grab everything until the next `## ' heading.
  pat <- paste0("(?msi)^##[ \\t]+[^\\n]*",
                str_replace_all(keyword,
                                "([\\.\\^\\$\\|\\(\\)\\[\\]\\{\\}\\*\\+\\?\\\\])",
                                "\\\\\\1"),
                "[^\\n]*$\\s*(.+?)(?=^##[ \\t]|\\z)")
  m <- str_match(text, pat)
  if (is.na(m[1, 2])) return(NA_character_)
  str_trim(m[1, 2])
}

clean_md <- function(s) {
  if (is.na(s)) return(s)
  s <- str_replace_all(s, "\\*\\*([^*]+?)\\*\\*", "\\1")
  s <- str_replace_all(s, "\\*([^*]+?)\\*",       "\\1")
  s <- str_replace_all(s, "`([^`]+)`",            "\\1")
  s
}

strip_h1 <- function(s) {
  if (is.na(s)) return(s)
  s <- clean_md(s)
  str_trim(str_replace(s, "^H1[:\\.\\)]?\\s*", ""))
}

# Drop the trailing ", after controlling for ..." clause to make the row
# scan more easily in a printed table.
condense_hyp <- function(h) {
  if (is.na(h)) return(h)
  h <- str_replace_all(h, "\\s*\n\\s*", " ")
  h <- str_replace(h, ",?\\s*after controlling[^\\.]*\\.?\\s*$", ".")
  str_trim(h)
}

first_sentence <- function(s) {
  if (is.na(s) || !nzchar(s)) return(NA_character_)
  s <- str_replace_all(s, "\\s*\n\\s*", " ")
  s <- clean_md(s)
  m <- str_match(s, "^(.+?[\\.!?])(?:\\s|$)")
  out <- if (!is.na(m[1, 2])) m[1, 2] else s
  str_trim(out)
}

tex_escape <- function(s) {
  if (length(s) == 0) return(s)
  vapply(s, function(x) {
    if (is.na(x)) return(NA_character_)
    x <- str_replace_all(x, "\\\\", "\\\\textbackslash{}")
    x <- str_replace_all(x, "([&%$#_{}])", "\\\\\\1")
    x <- str_replace_all(x, "~", "\\\\textasciitilde{}")
    x <- str_replace_all(x, "\\^", "\\\\textasciicircum{}")
    x
  }, character(1), USE.NAMES = FALSE)
}

# --- per-team extraction ----------------------------------------------------

parse_team <- function(team) {
  txt <- read_prereg(team)
  hyp <- md_section_fuzzy(txt, "Hypothesis")
  rat <- md_section_fuzzy(txt, "Rationale")
  # Override the parsed rationale where one is supplied.  Auto-extracted
  # first sentence is used otherwise.
  rationale <- if (team %in% names(rationale_overrides))
                 rationale_overrides[[team]]
               else
                 first_sentence(rat)
  list(
    team       = team,
    family     = family_of[[team]],
    hypothesis = condense_hyp(strip_h1(hyp)),
    rationale  = rationale
  )
}

rows <- lapply(teams, parse_team)
names(rows) <- teams

# Sanity check ---------------------------------------------------------------
miss <- sapply(rows, function(r) is.na(r$hypothesis) || is.na(r$rationale))
if (any(miss)) stop("Missing hypothesis or rationale for teams: ",
                    paste(teams[miss], collapse = ", "))

# --- emit body rows ---------------------------------------------------------

emit_row <- function(r) {
  sprintf(
    "%s & %s & %s & %s \\\\[3pt]",
    r$team,
    tex_escape(r$family),
    tex_escape(r$hypothesis),
    tex_escape(r$rationale)
  )
}

lines <- c(
  "% Auto-generated by scripts/make_hypothesis_rationale_table.R --- do not edit by hand.",
  "% Body rows for the main-body longtable defined in draft_APSG.tex",
  "% (label = tab:hypotheses-rationale).",
  sapply(rows, emit_row)
)

out <- file.path(ROOT, "tables/main_hypothesis_rationale.tex")
writeLines(lines, out)
cat(sprintf("Wrote %s (%d rows)\n", out, length(rows)))
