# PI Notes — Team 21

## Gate B decision: Approved (redesign)

**Date:** 2026-05-06

## Original design rejected

The original interaction design (v2x_libdem × has_intl_coauthor on citation impact) was rejected as too complex. See first pi_notes entry (now superseded).

## New design approved

**Outcome:** `prop_ever_cited` — country-year proportion of deduplicated SSH articles with `tot_cites >= 1`

**H1:** Countries with lower v2x_libdem scores will exhibit a lower share of SSH articles that receive at least one citation, after controlling for country fixed effects, year fixed effects, log GDP per capita, and log population.

**Controls:** `log(e_gdppc)`, `log(e_wb_pop)`

**Robustness checks:**
- RC1: Restrict to 1990–2023 (WOS coverage quality)
- RC2: Replace `v2x_libdem` with `lied_binary`

## Proceed to Analyst session
