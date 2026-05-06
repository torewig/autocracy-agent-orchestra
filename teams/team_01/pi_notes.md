# PI Notes — Team 01

## Gate B decision: Approved with revisions

**Date:** 2026-04-27

## Required revisions before Analyst session

1. **Hypothesis:** Add a clear, single-sentence directional hypothesis to rq.md (e.g. "H1: Countries with lower v2x_libdem scores will exhibit lower mean PCI scores in SSH abstracts, after controlling for country fixed effects, year fixed effects, GDP per capita, and population.").

2. **Dual estimation strategy:** The analysis plan should include both:
   - **TWFE (two-way fixed effects):** country + year FE — identifies the effect of *within-country changes* in regime type on PCI. This is the primary causal identification.
   - **Pooled OLS (cross-sectional):** no country FE, year FE only (or no FE) — identifies the *level* association between regime type and PCI across countries. Report alongside TWFE; interpret as descriptive/correlational.
   Both estimates should appear in the main regression table with a note on what variation each exploits.

## No redesign required — proceed to Analyst session after revisions
