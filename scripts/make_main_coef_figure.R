library(tidyverse)
library(jsonlite)

root <- here::here()
if (!dir.exists(file.path(root, "teams"))) {
  root <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG/Papers/P02_autocracy-science-agent-orchestra"
}

teams_done <- sprintf("%02d", c(1:4, 7:9, 11, 13:22))

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

read_team <- function(tid) {
  f <- file.path(root, sprintf("teams/team_%s/analysis/primary_results.json", tid))
  j <- fromJSON(f)
  tibble(
    team   = tid,
    family = j$theory_family,
    beta   = as.numeric(j$coefficient),
    se     = as.numeric(j$se),
    p      = as.numeric(j$p_value),
    n_obs  = as.integer(j$n_obs)
  )
}

d <- map_dfr(teams_done, read_team) |>
  mutate(
    z        = beta / se,
    z_lo     = z - 1.96,
    z_hi     = z + 1.96,
    label    = paste0("T", team, ": ", short_label[team]),
    family   = factor(
      family,
      levels = c("topic-avoidance", "framing-neutrality",
                 "collaboration-constraint", "visibility-suppression"),
      labels = c("Topic avoidance", "Framing neutrality",
                 "Collaboration constraint", "Visibility suppression")
    )
  ) |>
  arrange(family, team) |>
  mutate(label = factor(label, levels = rev(label)))

bonf_thresh <- tibble(
  family = factor(
    c("Topic avoidance", "Framing neutrality",
      "Collaboration constraint", "Visibility suppression"),
    levels = levels(d$family)
  ),
  k = c(7, 6, 5, 4)
) |>
  mutate(z_crit = qnorm(1 - (0.05 / k) / 2))

fam_colors <- c(
  "Topic avoidance"         = "#1f77b4",
  "Framing neutrality"      = "#ff7f0e",
  "Collaboration constraint"= "#2ca02c",
  "Visibility suppression"  = "#d62728"
)

p <- ggplot(d, aes(x = z, y = label, color = family)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey30") +
  geom_vline(xintercept = c(-1.96, 1.96), linetype = "dashed",
             color = "grey55") +
  geom_vline(data = bonf_thresh,
             aes(xintercept =  z_crit), linetype = "dotted", color = "grey20") +
  geom_vline(data = bonf_thresh,
             aes(xintercept = -z_crit), linetype = "dotted", color = "grey20") +
  geom_errorbarh(aes(xmin = z_lo, xmax = z_hi), height = 0, linewidth = 0.5) +
  geom_point(size = 2.2) +
  facet_grid(family ~ ., scales = "free_y", space = "free_y", switch = "y") +
  scale_color_manual(values = fam_colors, guide = "none") +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  labs(
    x = expression("Standardized estimate "*hat(beta)/hat(SE)*" (95% CI) — coefficient on "*v2x_libdem),
    y = NULL,
    title = NULL,
    caption = paste(
      "Each row = one pre-registered team test (TWFE: country and year FE, GDP/pop controls, clustered by country).",
      "Solid line: zero. Dashed: nominal ±1.96. Dotted: family-specific Bonferroni 5% threshold.",
      "Sign convention: positive z = outcome rises with liberal democracy (typically the theory-predicted direction).",
      "18 of 25 pre-registered teams reported here; 7 LLM/embedding-based teams (05, 06, 10, 12, 23–25) pending.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 10) +
  theme(
    strip.text.y.left   = element_text(angle = 0, face = "bold", hjust = 0),
    strip.placement     = "outside",
    panel.grid.minor    = element_blank(),
    panel.spacing.y     = unit(0.3, "lines"),
    plot.caption        = element_text(hjust = 0, size = 8, color = "grey25"),
    plot.caption.position = "plot"
  )

out_png <- file.path(root, "figures/fig_main_coefficients.png")
out_pdf <- file.path(root, "figures/fig_main_coefficients.pdf")

ggsave(out_png, p, width = 9, height = 6, dpi = 200)
ggsave(out_pdf, p, width = 9, height = 6, device = cairo_pdf)

cat("Wrote:\n", out_png, "\n", out_pdf, "\n", sep = "")
