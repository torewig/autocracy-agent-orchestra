# scripts/make_consistency_figure.R
#
# Builds the "Consistency across specifications" figure used in the Results
# section of draft_APSG.tex.  For each of the 18 completed teams, plot two
# standardized estimates side-by-side:
#   * TWFE   (primary, country + year FE)  --  from primary_results.json
#   * Pooled OLS (year FE only, secondary) --  from pooled_coefficients.json
# Each is drawn as a point with 95% CI on the standardized z = beta / SE
# scale, faceted by theory sub-family.
#
# Run from project root, AFTER scripts/extract_pooled_coefs.R has written
# tables/pooled_coefficients.json.

suppressPackageStartupMessages({
  library(tidyverse)
  library(jsonlite)
})

ROOT <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/Autocracy and science_Agent Orchestra"

teams_done <- sprintf("%02d", c(1:4, 7:9, 11, 13:22))

# Short outcome label, mirrors make_main_coef_figure.R.
short_label <- c(
  "01" = "PCI score",
  "02" = "Keyword entropy",
  "03" = "Share sensitive fields",
  "04" = "Share regime-sensitive keywords",
  "07" = "Share intl-funded",
  "08" = "Epistemic hedging rate",
  "09" = "Normative language rate",
  "11" = "Argumentative stance rate",
  "13" = "Share domestic journals",
  "14" = "Mean co-author countries",
  "15" = "Share democratic co-authors",
  "16" = "Share domestic-only authorship",
  "17" = "Mean author count",
  "18" = "Mean distinct institutions",
  "19" = "Log citation ratio",
  "20" = "Citation gap x sensitivity",
  "21" = "Share ever cited",
  "22" = "Citation Gini"
)

# --- TWFE coefficients (from each team's primary_results.json) -------------
twfe <- map_dfr(teams_done, function(t) {
  j <- fromJSON(file.path(ROOT, sprintf("teams/team_%s/analysis/primary_results.json", t)))
  tibble(
    team   = t,
    family = j$theory_family,
    spec   = "TWFE (country + year FE)",
    beta   = as.numeric(j$coefficient),
    se     = as.numeric(j$se)
  )
})

# --- Pooled-OLS coefficients (from pooled_coefficients.json) ---------------
pool_raw <- fromJSON(file.path(ROOT, "tables/pooled_coefficients.json"),
                    simplifyVector = FALSE)
pool <- map_dfr(pool_raw, function(x) {
  tibble(
    team   = x$team,
    family = x$family,
    spec   = "Pooled OLS (year FE only)",
    beta   = as.numeric(x$coefficient_pooled),
    se     = as.numeric(x$se_pooled)
  )
})

# --- Combine, standardize, label -------------------------------------------
d <- bind_rows(twfe, pool) |>
  mutate(
    z    = beta / se,
    z_lo = z - 1.96,
    z_hi = z + 1.96,
    label = paste0("T", team, ": ", short_label[team]),
    family = factor(
      family,
      levels = c("topic-avoidance", "framing-neutrality",
                 "collaboration-constraint", "visibility-suppression"),
      labels = c("Topic avoidance", "Framing neutrality",
                 "Collaboration constraint", "Visibility suppression")
    ),
    spec = factor(spec, levels = c("TWFE (country + year FE)",
                                   "Pooled OLS (year FE only)"))
  ) |>
  arrange(family, team) |>
  mutate(label = factor(label, levels = rev(unique(label))))

# --- Plot ------------------------------------------------------------------
fam_colors <- c(
  "TWFE (country + year FE)"   = "#1f77b4",
  "Pooled OLS (year FE only)"  = "#d62728"
)

p <- ggplot(d, aes(x = z, y = label, color = spec, shape = spec)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey30") +
  geom_vline(xintercept = c(-1.96, 1.96), linetype = "dashed",
             color = "grey55") +
  geom_errorbarh(aes(xmin = z_lo, xmax = z_hi),
                 height = 0, linewidth = 0.45,
                 position = position_dodge(width = 0.55)) +
  geom_point(size = 2.1, position = position_dodge(width = 0.55)) +
  facet_grid(family ~ ., scales = "free_y", space = "free_y", switch = "y") +
  scale_color_manual(values = fam_colors, name = NULL) +
  scale_shape_manual(values = c(16, 21), name = NULL) +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  labs(
    x = expression(
      "Standardized estimate "*hat(beta)/hat(SE)*" (95% CI), coefficient on "*v2x_libdem
    ),
    y = NULL,
    caption = paste(
      "Each row = one team.  Blue closed circle: pre-registered TWFE primary specification (country + year FE).",
      "Red open circle: pre-registered pooled-OLS secondary specification (year FE only).  Both use the same controls",
      "(log GDP per capita, log population) and cluster standard errors by country.  Dashed: nominal +/- 1.96.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 10) +
  theme(
    strip.text.y.left   = element_text(angle = 0, face = "bold", hjust = 0),
    strip.placement     = "outside",
    panel.grid.minor    = element_blank(),
    panel.spacing.y     = unit(0.3, "lines"),
    legend.position     = "top",
    legend.box.spacing  = unit(0, "pt"),
    plot.caption        = element_text(hjust = 0, size = 8, color = "grey25"),
    plot.caption.position = "plot"
  )

out_png <- file.path(ROOT, "figures/fig_consistency.png")
out_pdf <- file.path(ROOT, "figures/fig_consistency.pdf")
ggsave(out_png, p, width = 9, height = 7, dpi = 200)
ggsave(out_pdf, p, width = 9, height = 7, device = cairo_pdf)

cat("Wrote:\n", out_png, "\n", out_pdf, "\n", sep = "")

# --- Headline-stat summary for the prose paragraph -------------------------
agree_sign <- d |>
  select(team, spec, beta) |>
  pivot_wider(names_from = spec, values_from = beta) |>
  mutate(same_sign = sign(`TWFE (country + year FE)`) ==
                     sign(`Pooled OLS (year FE only)`))
cat(sprintf("Sign agreement TWFE vs Pooled: %d of %d teams\n",
            sum(agree_sign$same_sign), nrow(agree_sign)))
