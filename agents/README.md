# Agent Infrastructure

This folder contains the prompt templates and invocation guide for the
AutoKnow Agent Orchestra.

## What "agents" are

Each agent is a Claude Code session. Sessions have no memory between runs —
all persistent state lives in files inside the team folder. The three roles
are three **separate sessions**, run sequentially with PI review between each.

## Files in this folder

| File | Purpose |
|------|---------|
| `README.md` | This file |
| `prompt_designer.md` | Opening prompt for the Designer session |
| `prompt_analyst.md` | Opening prompt for the Analyst session |
| `prompt_writer.md` | Opening prompt for the Writer session |
| `prompt_reviewer.md` | Opening prompt for the Peer Reviewer session |
| `HOWTO_INVOKE.md` | Step-by-step invocation guide |

## Quick reference

All sessions are opened from the **project root directory**. Replace `[N]`
with the two-digit team number (01–10).

| Role | When | Files read | Files written |
|------|------|------------|---------------|
| Designer | Step A | brief.md | rq.md, analysis_plan.md |
| Analyst | Step C (after PI review) | rq.md, analysis_plan.md | analysis/analysis.R, analysis/figures/* |
| Writer | Step E (after PI review) | rq.md, analysis_plan.md, analysis/* | report/report.md |
| Reviewer | Step F (after all Writers) | report/report.md | report/peer_review.md |
