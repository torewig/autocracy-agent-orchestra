# Agent Infrastructure

This folder contains the prompt templates and invocation guide for the
AutoKnow Agent Orchestra (v2 — 30 teams, unified self-censorship theory).

## What "agents" are

Each agent is a Claude Code session. Sessions have no memory between runs —
all persistent state lives in files inside the team folder. The roles are
**separate sessions**, run sequentially with PI review between each.

## Files in this folder

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `prompt_designer.md` | Opening prompt for the Designer session (Step A) |
| `prompt_analyst.md` | Opening prompt for the Analyst session (Step C) |
| `prompt_writer.md` | Opening prompt for the Writer session (Step E) |
| `prompt_reviewer.md` | Opening prompt for the Peer Reviewer session (Step F) |
| `prompt_overseer.md` | Daily project overseer — scan status, output task list |
| `prompt_synthesizer.md` | Theory synthesis meta-analyst (Step S, run once) |
| `HOWTO_INVOKE.md` | Step-by-step invocation guide with batching schedule |

## Quick reference

All sessions are opened from the **project root directory**. Replace `[N]`
with the two-digit team number (01–30). Overseer and Synthesizer need no `[N]`.

| Role | Step | When | Files read | Files written |
|------|------|------|------------|---------------|
| Designer | A | Days 2–5 | brief.md | rq.md, analysis_plan.md |
| Analyst | C | Days 10–16 | rq.md, analysis_plan.md | analysis/analysis.R, analysis/figures/*, primary_results.json |
| Writer | E | Days 20–22 | rq.md, analysis_plan.md, analysis/* | report/report.md |
| Reviewer | F | Days 23–24 | report/report.md, rq.md | report/peer_review.md |
| Overseer | Daily | Any day | TIMELINE.md, STATUS.md, all team folders | Chat output only |
| Synthesizer | S | Day 28 | All rq.md, report.md, peer_review.md, adjusted_pvalues | synthesis/theory_evaluation.md |

See `TIMELINE.md` for the full 30-day schedule.
