# scripts/plot_pipeline.R
# Generates figures/pipeline.png for PLAN.md
# Run from project root: Rscript scripts/plot_pipeline.R

library(ggplot2)
library(dplyr)
library(tibble)

# ── 1. Step definitions ───────────────────────────────────────────────────────

steps <- tribble(
  ~id, ~main,                                   ~sub,                                                    ~type,
   1,  "Raw Data",                               "WOS corpus (7.5M articles)  +  V-DEM dataset",          "data",
   2,  "Phase 0: Data Preparation",              "Filter SSH  *  Merge V-DEM  *  Derived variables",      "process",
   3,  "PI: Validate Corpus",                    "Check N counts  *  Join rate  *  Spot-check rows",      "gate",
   4,  "Team Setup",                             "Scaffold 10 folders  *  Write brief.md files",          "process",
   5,  "Step A  -  Designer Sessions (x10)",     "Each team: rq.md  +  analysis_plan.md",                 "parallel",
   6,  "PI Review Gate B",                       "Check RQ convergence  *  Approve or redirect",          "gate",
   7,  "Step C  -  Analyst Sessions (x10)",      "Regression analysis  +  2-4 figures/tables",            "parallel",
   8,  "PI Review Gate D",                       "Check methodology  *  Causal ID  *  Approve",           "gate",
   9,  "Step E  -  Writer Sessions (x10)",       "Each team: report.md  (4-5 pages)",                     "parallel",
  10,  "Step F  -  Peer Review Sessions (x10)",  "Each report reviewed by independent Reviewer agent",    "review",
  11,  "PI: Read Reports + Reviews",             "Review all 10 reports + peer reviews  *  Sign off",     "gate",
  12,  "Synthesis Agent",                        "Summaries  *  Themes  *  Pipeline description  *  Viz", "process",
  13,  "Synthesis Paper",                        "PI writes  *  Agent assists structure, drafts, figures", "output"
)

# ── 2. Layout geometry ────────────────────────────────────────────────────────

n   <- nrow(steps)
bh  <- 0.62   # box half-height
gap <- 0.48   # gap between consecutive boxes

# step 1 at top (highest y), step 13 at bottom (lowest y)
steps <- steps |>
  mutate(cy = rev(seq(bh, bh + (n - 1) * (2 * bh + gap), by = 2 * bh + gap)))

# arrows: bottom of step i -> top of step i+1
arrows_df <- tibble(
  y    = steps$cy[-n] - bh,
  yend = steps$cy[-1] + bh
)

# ── 3. Colour palette ─────────────────────────────────────────────────────────

fill_pal   <- c(data     = "#D6EAF8",
                process  = "#F2F3F4",
                gate     = "#FEF9E7",
                parallel = "#E9F7EF",
                review   = "#F5EEF8",
                output   = "#D5F5E3")

border_pal <- c(data     = "#2874A6",
                process  = "#808B96",
                gate     = "#D4AC0D",
                parallel = "#1E8449",
                review   = "#8E44AD",
                output   = "#196F3D")

text_pal   <- c(data     = "#1A5276",
                process  = "#2C3E50",
                gate     = "#7D6608",
                parallel = "#145A32",
                review   = "#6C3483",
                output   = "#0B5345")

steps <- steps |>
  mutate(fc = fill_pal[type],
         bc = border_pal[type],
         tc = text_pal[type])

# ── 4. Computed reference points ─────────────────────────────────────────────

phase1_top <- steps$cy[steps$id ==  4] + bh + 0.22
phase1_bot <- steps$cy[steps$id == 11] - bh - 0.22
phase1_mid <- (phase1_top + phase1_bot) / 2

phase2_mid <- (steps$cy[steps$id == 12] + steps$cy[steps$id == 13]) / 2
phase0_mid <- (steps$cy[steps$id ==  2] + steps$cy[steps$id ==  3]) / 2

box_left   <- -3.9
label_x    <- -4.1   # left-margin phase label x

# ── 5. Legend ─────────────────────────────────────────────────────────────────

leg_y  <- steps$cy[n] - bh - 0.70
leg_bw <- 0.80
leg_bh <- 0.22
leg <- tibble(
  x     = c(-3.44, -1.72, 0, 1.72, 3.44),
  label = c("Input data", "Process / setup", "PI review gate", "Team sessions", "Peer review"),
  fill  = unname(fill_pal[c("data", "process", "gate", "parallel", "review")]),
  bdr   = unname(border_pal[c("data", "process", "gate", "parallel", "review")])
)

# ── 6. Build plot ─────────────────────────────────────────────────────────────

p <- ggplot() +

  # Phase 1 background band (team workflow, steps 4-11)
  annotate("rect",
    xmin = box_left - 0.18, xmax = 3.9 + 0.18,
    ymin = phase1_bot, ymax = phase1_top,
    fill = "#F0FFF4", color = "#AAAAAA", linetype = "dashed", linewidth = 0.4
  ) +

  # Phase labels (left margin, rotated)
  annotate("text", x = label_x, y = phase0_mid,
    label = "Phase 0", angle = 90, size = 2.3,
    color = "#777777", fontface = "italic", family = "sans") +
  annotate("text", x = label_x, y = phase1_mid,
    label = "Phase 1", angle = 90, size = 2.3,
    color = "#777777", fontface = "italic", family = "sans") +
  annotate("text", x = label_x, y = phase2_mid,
    label = "Phase 2", angle = 90, size = 2.3,
    color = "#777777", fontface = "italic", family = "sans") +

  # Arrows
  geom_segment(
    data = arrows_df,
    aes(x = 0, xend = 0, y = y, yend = yend),
    arrow = arrow(length = unit(5, "pt"), type = "closed"),
    color = "#888888", linewidth = 0.55
  ) +

  # Box fills and borders
  geom_rect(
    data = steps,
    aes(xmin = box_left, xmax = 3.9, ymin = cy - bh, ymax = cy + bh),
    fill  = steps$fc,
    color = steps$bc,
    linewidth = 0.75
  ) +

  # Main (bold) label — upper half of box
  geom_text(
    data = steps,
    aes(x = 0, y = cy + 0.19, label = main),
    size = 2.85, fontface = "bold",
    color = steps$tc, family = "sans"
  ) +

  # Sub label — lower half of box
  geom_text(
    data = steps,
    aes(x = 0, y = cy - 0.24, label = sub),
    size = 2.2,
    color = steps$tc, family = "sans"
  ) +

  # Legend boxes
  geom_rect(
    data = leg,
    aes(xmin = x - leg_bw, xmax = x + leg_bw,
        ymin = leg_y - leg_bh, ymax = leg_y + leg_bh),
    fill = leg$fill, color = leg$bdr, linewidth = 0.55
  ) +
  geom_text(
    data = leg,
    aes(x = x, y = leg_y, label = label),
    size = 1.9, color = "#333333", family = "sans"
  ) +

  coord_cartesian(
    xlim = c(-4.5, 4.2),
    ylim = c(leg_y - leg_bh - 0.30, steps$cy[1] + bh + 0.35)
  ) +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin     = margin(6, 6, 6, 6)
  )

# ── 7. Save ───────────────────────────────────────────────────────────────────

dir.create("figures", showWarnings = FALSE)
ggsave("figures/pipeline.png", p,
       width = 5.8, height = 14.5, dpi = 220, bg = "white")
cat("Saved: figures/pipeline.png\n")
