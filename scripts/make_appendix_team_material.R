# scripts/make_appendix_team_material.R
#
# Parses all 25 teams/team_NN/preregistration.md files and emits two LaTeX
# fragment files used by the paper's appendix:
#
#   tables/appendix_hypothesis_list.tex  --  body rows of a longtable that
#                                             reproduces every team's full
#                                             pre-registered H1 sentence.
#   tables/appendix_mini_plans.tex       --  25 compact per-team blocks
#                                             (hypothesis, outcome, predictor,
#                                             controls, robustness labels).
#
# Run from project root:  Rscript scripts/make_appendix_team_material.R
#
# Source of truth = teams/team_NN/preregistration.md.  Nothing here is
# hand-curated except the family map (used as a fallback when a team has
# no primary_results.json yet) and a small library of short outcome glosses
# used in the mini-plan table (keeps the gloss to one line; the full
# variable definition is one paragraph in the prereg, too long for a table cell).

suppressPackageStartupMessages({
  library(stringr)
  library(jsonlite)
})

root <- normalizePath(".")
if (!dir.exists(file.path(root, "teams"))) {
  root <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra"
}

teams <- sprintf("%02d", 1:25)

# Hardcoded family map (matches STATUS.md and tab:families in draft.tex).
# Used as the authoritative source so the appendix matches the rest of the
# paper exactly. primary_results.json carries the same value where present,
# but seven teams (05, 06, 10, 12, 23-25) have no JSON yet.
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

# Short outcome glosses for the mini-plan table.  The prereg's `## Outcome
# variable' section is one paragraph long for most teams; we keep the
# canonical variable name (parsed below) and add a one-line gloss here
# so each mini-plan block is scannable.
outcome_gloss <- c(
  "01" = "country-year mean PCI score (share of abstract text matching political-content keyword dictionary)",
  "02" = "Shannon entropy of the country-year author-keyword distribution",
  "03" = "country-year share of output published in politically sensitive WOS disciplines",
  "04" = "country-year share of articles whose abstracts mention regime-sensitive terms (democracy, rights, corruption, protest)",
  "05" = "country-year share of abstracts critically examining own-country governance (LLM-classified)",
  "06" = "country-year mean pairwise cosine distance of abstract embeddings within field-year clusters",
  "07" = "country-year share of articles acknowledging international funding agencies",
  "08" = "country-year mean rate of epistemic hedging phrases per abstract word",
  "09" = "country-year mean rate of normative/prescriptive terms per abstract word",
  "10" = "country-year share of abstracts classified as exclusively technocratic (LLM)",
  "11" = "country-year rate of 1st-person argumentative stance phrases",
  "12" = "country-year share of abstracts ending with an explicit normative/policy conclusion (LLM)",
  "13" = "country-year share of articles published in domestically dominated journals",
  "14" = "country-year mean number of distinct co-author countries per article",
  "15" = "country-year share of articles with at least one co-author from a liberal democracy",
  "16" = "country-year share of articles with exclusively domestic authorship",
  "17" = "country-year mean author count per article",
  "18" = "country-year mean number of distinct author institutions per article",
  "19" = "country-year mean of log normalized citation ratio",
  "20" = "article-level log(1 + citation ratio); tests the v2x_libdem x topic-sensitivity interaction",
  "21" = "country-year share of articles with at least one citation",
  "22" = "country-year Gini coefficient of tot_cites across articles",
  "23" = "country-year share of NEUTRAL + NONE abstracts in the 5-label LLM ideology classifier",
  "24" = "country-year share of abstracts actively legitimating the domestic political system (LLM binary)",
  "25" = "country-year share of abstracts with explicit anti-liberal-democracy framing (LLM binary)"
)

# Hardcoded outcome variable name (the backticked identifier).  Parsed where
# available; falls back to this table.  These match tab:hypotheses in
# draft.tex (lines ~404-514) and primary_results.json `outcome` field.
outcome_var <- c(
  "01" = "pci_mean",
  "02" = "keyword_entropy_cy",
  "03" = "share_sensitive_fields",
  "04" = "share_sensitive",
  "05" = "share_critical_framing",
  "06" = "mean_semantic_diversity",
  "07" = "share_intl_funded",
  "08" = "hedging_rate",
  "09" = "normative_rate",
  "10" = "share_technocratic",
  "11" = "stance_rate",
  "12" = "share_normative_conclusion",
  "13" = "share_domestic_journal",
  "14" = "mean_n_coauthor_countries",
  "15" = "share_libdem_coauth",
  "16" = "share_domestic_only",
  "17" = "mean_n_authors",
  "18" = "mean_n_institutions",
  "19" = "log_cite_ratio_mean",
  "20" = "log1p(cite_ratio)",
  "21" = "prop_ever_cited",
  "22" = "gini_tot_cites",
  "23" = "share_apolitical",
  "24" = "share_legitimating",
  "25" = "share_anti_liberal"
)

# -- Parsing helpers ----------------------------------------------------------

# Read a prereg file as a single character string.
read_prereg <- function(team) {
  f <- file.path(root, sprintf("teams/team_%s/preregistration.md", team))
  if (!file.exists(f)) stop("Missing preregistration.md for team ", team)
  paste(readLines(f, warn = FALSE), collapse = "\n")
}

# Return the body of a level-2 section `## <heading>` from a markdown text.
# Returns NA_character_ if the heading is absent.
md_section <- function(text, heading) {
  pat <- paste0("(?ms)^##[ \\t]+",
                str_replace_all(heading, "([\\.\\^\\$\\|\\(\\)\\[\\]\\{\\}\\*\\+\\?\\\\])", "\\\\\\1"),
                "[ \\t]*$\\s*(.+?)(?=^##[ \\t]|\\z)")
  m <- str_match(text, pat)
  if (is.na(m[1, 2])) return(NA_character_)
  str_trim(m[1, 2])
}

# Fuzzy variant: find any `## ` heading whose text contains `keyword`
# (case-insensitive).  Used because some teams prefix their robustness
# section with "Step 6:" or similar.
md_section_fuzzy <- function(text, keyword) {
  pat <- paste0("(?msi)^##[ \\t]+[^\\n]*",
                str_replace_all(keyword, "([\\.\\^\\$\\|\\(\\)\\[\\]\\{\\}\\*\\+\\?\\\\])", "\\\\\\1"),
                "[^\\n]*$\\s*(.+?)(?=^##[ \\t]|\\z)")
  m <- str_match(text, pat)
  if (is.na(m[1, 2])) return(NA_character_)
  str_trim(m[1, 2])
}

# Extract the first sentence of a paragraph (rough: up to first '. ' or end).
first_sentence <- function(s) {
  if (is.na(s) || !nzchar(s)) return(NA_character_)
  m <- str_match(s, "^(.+?\\.)(?:\\s|$)")
  if (!is.na(m[1, 2])) m[1, 2] else str_trim(s)
}

# Strip residual markdown emphasis (**bold**, *italic*, `code`) from a
# string.  Used on hypothesis and robustness labels that we don't want to
# carry markdown markup into LaTeX.
clean_md <- function(s) {
  if (is.na(s)) return(s)
  s <- str_replace_all(s, "\\*\\*([^*]+?)\\*\\*", "\\1")  # **bold**
  s <- str_replace_all(s, "\\*([^*]+?)\\*", "\\1")        # *italic*
  s <- str_replace_all(s, "`([^`]+)`", "\\1")             # `code`
  s
}

# Strip an "H1:" or "H1." prefix from a hypothesis sentence (handles a
# residual "**H1:**" markdown wrapper).
strip_h1 <- function(s) {
  if (is.na(s)) return(s)
  s <- clean_md(s)
  str_trim(str_replace(s, "^H1[:\\.\\)]?\\s*", ""))
}

# Pull the labels out of a `## Robustness checks` block.  Handles:
#   1. **RC1 - Exclude recent articles:** ...
#   1. **Alternative regime measure (binary):** ...
#   - **Lagged IV:** ...
#   ### RC1: Restrict to multi-author articles
#   ### R1 - Binary regime IV
# Strips trailing colon and any markdown emphasis.  Returns a character vector.
extract_rc_labels <- function(rc_text) {
  if (is.na(rc_text)) return(character(0))
  lines <- str_split(rc_text, "\n")[[1]]
  out <- character(0)
  for (line in lines) {
    line <- str_trim(line)
    if (!nzchar(line)) next

    # Pattern A: numbered/bulleted list followed by **label:** or **label**
    #   "1. **RC1 - Exclude recent articles:** ..."
    #   "- **Lagged IV:** ..."
    m <- str_match(line, "^(?:\\d+\\.|[-*])\\s*\\*\\*([^*]+?)\\*\\*")
    if (!is.na(m[1, 2])) {
      label <- str_replace(m[1, 2], "[:\\s]+$", "")
      out <- c(out, label); next
    }

    # Pattern B: ### Heading line
    #   "### RC1: Restrict to multi-author articles"
    #   "### RC1 - Restrict to multi-author articles"
    m <- str_match(line, "^###\\s+(.+?)$")
    if (!is.na(m[1, 2])) {
      label <- str_replace(m[1, 2], "\\s*[:\\.]\\s*$", "")
      out <- c(out, label); next
    }

    # Pattern C: paragraph-start bold parenthesized label, with the
    # whole label/title fully inside one **...** group:
    #   "**(a) Binary democracy indicator.** Replace ..."
    #   "**(RC1) Restrict to English-language abstracts.** Re-estimate ..."
    m <- str_match(line, "^\\*\\*\\(([^)]+)\\)\\s*([^*]+?)\\*\\*")
    if (!is.na(m[1, 2])) {
      tag  <- str_trim(m[1, 2])
      rest <- str_trim(str_replace(m[1, 3], "[\\.\\s]+$", ""))
      label <- if (str_detect(tag, "^(?:RC|R)\\d+$"))
        paste0(tag, " - ", rest) else rest
      out <- c(out, label); next
    }

    # Pattern D: paragraph-start bold label without leading list marker:
    #   "**RC1 - Sensitive fields only:** Re-estimate ..."
    #   "**RC1: Restrict to ...** ..."
    m <- str_match(line, "^\\*\\*([^*]+?)\\*\\*")
    if (!is.na(m[1, 2])) {
      label <- str_trim(m[1, 2])
      # Drop trailing colon/period
      label <- str_replace(label, "[:\\.]\\s*$", "")
      # Skip if this looks like a section divider rather than an RC item
      if (str_length(label) > 0 && str_length(label) < 80) {
        out <- c(out, label); next
      }
    }

    # Pattern E: markdown table row "| <first-col> | <second-col> |".
    # If the first column is a bare RC/R tag, append the first phrase of
    # the description (up to colon, comma, or period) so the appendix
    # label is informative.  If the first column already contains the
    # title (e.g. "RC1: Field fixed effects"), keep just that.
    if (str_detect(line, "^\\|") &&
        !str_detect(line, "^\\|\\s*[-:]+\\s*\\|") &&
        !str_detect(line, "(?i)^\\|\\s*(ID|Check|Label)\\s*\\|")) {
      m <- str_match(line, "^\\|\\s*([^|]+?)\\s*\\|\\s*([^|]+?)\\s*\\|")
      if (!is.na(m[1, 2])) {
        col1 <- str_trim(m[1, 2])
        col2 <- str_trim(m[1, 3])
        col1 <- str_replace(col1, "[:\\.]\\s*$", "")
        is_bare_tag <- str_detect(col1, "^R(?:C)?\\d+$")
        if (is_bare_tag && nzchar(col2)) {
          # Trim the description to its leading phrase (up to colon or end
          # of first sentence).  Strip markdown backticks so the gloss
          # renders as plain text rather than ASCII grave accents in TeX.
          gloss <- str_replace(col2, "^([^:\\.,;]+).*$", "\\1")
          gloss <- str_replace_all(gloss, "`", "")
          gloss <- str_trim(gloss)
          # Truncate at word boundary if too long.
          if (str_length(gloss) > 55) {
            gloss <- str_replace(substr(gloss, 1, 55), "\\s+\\S*$", "")
            gloss <- paste0(gloss, "...")
          }
          out <- c(out, paste0(col1, " - ", gloss)); next
        }
        if (str_length(col1) > 0 && str_length(col1) < 80 &&
            str_detect(col1, "(?i)R(?:C)?\\d|^[A-Za-z]")) {
          out <- c(out, col1); next
        }
      }
    }

    # Pattern F: numbered list with NO bold, label up to first colon:
    #   "1. Alternative regime measure: replace v2x_libdem with ..."
    m <- str_match(line, "^\\d+\\.\\s+([^:]+):")
    if (!is.na(m[1, 2])) {
      label <- str_trim(m[1, 2])
      if (str_length(label) > 0 && str_length(label) < 80) {
        out <- c(out, label); next
      }
    }

    # Pattern G: paragraph-start "RC1 - Title: description" without bold:
    #   "RC1 - Country-field-year level: Re-estimate ..."
    m <- str_match(line, "^(R(?:C)?\\d+)\\s*[\\u2014\\u2013\\-]\\s*([^:]+):")
    if (!is.na(m[1, 2])) {
      tag <- str_trim(m[1, 2]); title <- str_trim(m[1, 3])
      out <- c(out, paste0(tag, " - ", title)); next
    }
  }
  # Strip residual markdown emphasis from labels (RC items often contain
  # `var_name` or *italic* in the title) before LaTeX escaping.
  out <- sapply(out, clean_md, USE.NAMES = FALSE)
  # Drop duplicates while preserving order
  out[!duplicated(out)]
}

# Fallback: scan the entire document for `### RC\d` or `### R\d` headings
# when the team has no top-level `## Robustness checks` section
# (team_16 puts its RC subsections directly under `## Method`).
extract_rc_labels_global <- function(full_text) {
  lines <- str_split(full_text, "\n")[[1]]
  out <- character(0)
  for (line in lines) {
    line <- str_trim(line)
    m <- str_match(line, "^###\\s+(R(?:C)?\\d+[^\\n]*)$")
    if (!is.na(m[1, 2])) {
      label <- str_replace(m[1, 2], "\\s*[:\\.]\\s*$", "")
      out <- c(out, label)
    }
  }
  out[!duplicated(out)]
}

# Escape LaTeX special characters for body text (not for math, not for verbatim).
# Vectorized.
tex_escape <- function(s) {
  if (length(s) == 0) return(s)
  vapply(s, function(x) {
    if (is.na(x)) return(NA_character_)
    # Replace backslash first to avoid interfering with the others.
    x <- str_replace_all(x, "\\\\", "\\\\textbackslash{}")
    x <- str_replace_all(x, "([&%$#_{}])", "\\\\\\1")
    x <- str_replace_all(x, "~", "\\\\textasciitilde{}")
    x <- str_replace_all(x, "\\^", "\\\\textasciicircum{}")
    x
  }, character(1), USE.NAMES = FALSE)
}

# Render a variable identifier inside \texttt{...} with underscores escaped.
tt_var <- function(name) {
  paste0("\\texttt{", str_replace_all(name, "_", "\\\\_"), "}")
}

# -- Per-team extractor -------------------------------------------------------

parse_team <- function(team) {
  txt <- read_prereg(team)

  hyp <- md_section(txt, "Hypothesis")
  # Collapse internal newlines into spaces (hypothesis is one sentence).
  if (!is.na(hyp)) hyp <- str_replace_all(hyp, "\\s*\n\\s*", " ")
  hyp <- strip_h1(hyp)

  predictor <- md_section(txt, "Key independent variable")
  if (is.na(predictor)) predictor <- md_section(txt, "Key IV")
  predictor_name <- "v2x_libdem"
  if (!is.na(predictor)) {
    m <- str_match(predictor, "`([^`]+)`")
    if (!is.na(m[1, 2])) predictor_name <- m[1, 2]
  }

  controls_text <- md_section(txt, "Controls")
  controls <- "baseline (log GDP per capita, log population, country FE, year FE)"
  if (!is.na(controls_text)) {
    # Extract every backticked identifier from the section.  De-duplicate
    # while preserving order.  Render as a compact texttt list.
    names_all <- str_match_all(controls_text, "`([^`]+)`")[[1]][, 2]
    names_all <- names_all[!duplicated(names_all)]
    if (length(names_all) > 0) {
      controls <- paste0(
        paste(sapply(names_all, tt_var), collapse = ", "),
        "; plus country FE + year FE"
      )
    }
  }

  rc_text <- md_section(txt, "Robustness checks")
  if (is.na(rc_text)) rc_text <- md_section_fuzzy(txt, "Robustness")
  rc_labels <- extract_rc_labels(rc_text)
  if (length(rc_labels) == 0) {
    # No labels parsed inside a labelled section -- scan whole document for
    # `### RC1`-style headings (team 16 layout).
    rc_labels <- extract_rc_labels_global(txt)
  }
  # Cap to first 6 labels, just in case
  if (length(rc_labels) > 6) rc_labels <- rc_labels[1:6]

  list(
    team        = team,
    family      = family_of[[team]],
    hypothesis  = hyp,
    outcome_var = outcome_var[[team]],
    outcome_glo = outcome_gloss[[team]],
    predictor   = predictor_name,
    controls    = controls,        # already LaTeX-ready when it had backticks
    rc_labels   = rc_labels,
    controls_was_escaped = !is.na(controls_text) && length(str_extract_all(controls_text, "`[^`]+`[^\\n]*")[[1]]) > 0
  )
}

teams_data <- lapply(teams, parse_team)
names(teams_data) <- teams

# Quick sanity report --------------------------------------------------------
missing_hyp <- sapply(teams_data, function(d) is.na(d$hypothesis) || !nzchar(d$hypothesis))
if (any(missing_hyp)) stop("Missing hypothesis in teams: ",
                           paste(teams[missing_hyp], collapse = ", "))
missing_rc <- sapply(teams_data, function(d) length(d$rc_labels) == 0)
if (any(missing_rc)) warning("No robustness labels parsed for teams: ",
                             paste(teams[missing_rc], collapse = ", "))

# -- Write LaTeX fragment 1: hypothesis list ----------------------------------

emit_hyp_row <- function(d) {
  sprintf(
    "%s & %s & %s & %s \\\\[3pt]",
    d$team,
    tex_escape(d$family),
    tt_var(d$outcome_var),
    tex_escape(d$hypothesis)
  )
}

hyp_lines <- c(
  "% Auto-generated by scripts/make_appendix_team_material.R - do not edit by hand.",
  "% Body rows for the longtable defined in draft.tex (label = tab:hypotheses-full).",
  sapply(teams_data, emit_hyp_row)
)

writeLines(hyp_lines, file.path(root, "tables/appendix_hypothesis_list.tex"))

# -- Write LaTeX fragment 2: mini research plans ------------------------------

emit_mini_block <- function(d) {
  rc_field <- if (length(d$rc_labels) == 0) {
    "(none parsed)"
  } else {
    paste(tex_escape(d$rc_labels), collapse = "; ")
  }
  c(
    # Display-style heading (not \paragraph, which is run-in and pushes
    # the following tabular off the right margin).
    "\\medskip",
    sprintf("\\noindent\\textbf{Team~%s~---~\\textit{%s}}\\par\\nopagebreak\\smallskip",
            d$team, tex_escape(d$family)),
    "\\noindent\\begin{tabular}{@{}>{\\bfseries}p{2.6cm}p{12.6cm}@{}}",
    sprintf("Hypothesis        & %s \\\\[2pt]", tex_escape(d$hypothesis)),
    sprintf("Outcome variable  & %s --- %s \\\\[2pt]",
            tt_var(d$outcome_var), tex_escape(d$outcome_glo)),
    sprintf("Predictor         & %s \\\\[2pt]", tt_var(d$predictor)),
    sprintf("Controls          & %s \\\\[2pt]", d$controls),
    sprintf("Robustness checks & %s \\\\", rc_field),
    "\\end{tabular}",
    ""
  )
}

mini_lines <- c(
  "% Auto-generated by scripts/make_appendix_team_material.R - do not edit by hand.",
  "% Inserted via \\input{} inside the appendix section in draft.tex.",
  "",
  unlist(lapply(teams_data, emit_mini_block))
)

writeLines(mini_lines, file.path(root, "tables/appendix_mini_plans.tex"))

# -- Console summary ---------------------------------------------------------

cat("Wrote:\n",
    " tables/appendix_hypothesis_list.tex  (", length(teams_data), " team rows)\n",
    " tables/appendix_mini_plans.tex       (", length(teams_data), " team blocks)\n",
    sep = "")
n_rc <- sapply(teams_data, function(d) length(d$rc_labels))
cat("Robustness labels per team (range): ", min(n_rc), "-", max(n_rc), "\n", sep = "")
