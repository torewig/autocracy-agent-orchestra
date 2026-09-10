# P02: How Autocracy Shapes the Social Sciences (Agent Orchestra) — AI use log

Purpose: contemporaneous record of what AI tools did on this paper, so the journal AI-use declaration can be written accurately at submission. Governing policy: APSR / Cambridge University Press (see project `CLAUDE.md`, section "AI use policy"). If the target journal has a stricter policy (e.g. AJPS), that applies. Entry format and category codes: `PAPERS/_AI_LOG_TEMPLATE.md`.

| Field | Value |
|---|---|
| Tool | Claude Code (Anthropic), desktop app |
| Model(s) | claude-fable-5-1 (from 2026-09-09); earlier sessions: model not recorded |
| Access | https://claude.com/claude-code (subscription on the PI account) |
| Log started | 2026-09-09 |
| Maintained by | The agent writes entries in the same session as the work; the PI fills in "Human review" |

## Disclosure statement (draft — rewrite from the log before submission)

_Not yet written._ Must give tool name and model ID, dates of use, access, a full description of use, and citations for third-party material the tool drew on. Placement per APSR: text generation in acknowledgements or a footnote; data collection/analysis in the methods section; figures in the captions.

In this paper AI agents are the method, so the methods section must describe the full pipeline (models, versions, prompts, dates, human oversight points). This log captures what is not already documented in `PLAN.md`, `STATUS.md`, and `agents/`, plus any AI contribution to the manuscript prose itself, which is separate from the method.

## Pre-log period (before 2026-09-09) — reconstructed, verify before use

AI assistance was used on this paper before this log existed. Items below are compiled from Claude Code session titles and dates and from dated entries in `notes.md` and `_TRACKER.md`. They are pointers for the PI to verify against session transcripts and git history, not a contemporaneous record of what the AI produced.

- 2026-06-05 — session "Draft compilation" (cwd: this folder): LaTeX compilation of the draft (EDIT/ADMIN; check whether text was changed).
- 2026-06-23 — session "Agent orchestra paper" (cwd: this folder): work on the paper; `REPORT_2026-06-23.md` is dated the same day (likely TEXT and/or ANALYSIS; verify).
- 2026-07-03 — session "Project critical review and improvements" (cwd: this folder): `CRITICAL_REVIEW_2026-07-03.md` (REVIEW; check whether the review led to AI-written text or design changes).
- 2026-09-08 — session "Project review and loose ends": target journal decided (BJPS), `TASKS_publication_BJPS.md` created (ADMIN).
- Ongoing — the 25-team agent orchestra in `agents/` (`prompt_*.md`, `PLAN.md`, `STATUS.md`, `TIMELINE.md`): AI is the research method (METHOD). Model IDs, versions, and run dates for each team must be recoverable from the pipeline outputs; record them here as they are confirmed.

## Log

### 2026-09-09 — ADMIN — AI_LOG.md
- **Did:** created this log and the reconstructed pre-log list above
- **Output:** `AI_LOG.md`
- **Model:** claude-fable-5-1
- **Human review:** pending
- **Disclose:** no

### 2026-09-09 — ADMIN — folder rename
- **Did:** renamed the paper folder from `Autocracy and science_Agent Orchestra/` to `P02_autocracy-science-agent-orchestra/`; replaced the hard-coded absolute path in `PLAN.md`, `agents/HOWTO_INVOKE.md`, `links.md`, `render_plan.ps1`, `run_team06.ps1`, `run_team06_wrapper.bat`, `scripts/*.R`, `scripts/*.ps1`, and `teams/team_*/analysis/analysis.R` (path string only, no logic changed). These show as uncommitted changes in the git repo.
- **Output:** folder name and path strings only
- **Model:** claude-fable-5-1
- **Human review:** pending
- **Disclose:** no

### 2026-09-09 — EDIT — draft_APSG.tex compile
- **Did:** compiled `draft_APSG.tex` with latexmk (pdflatex + bibtex) at the PI's request; no text changed. Reported two unresolved cross-references (`tab:hypotheses`, `sec:hypotheses`) and overfull boxes.
- **Output:** `draft_APSG.pdf`
- **Model:** claude-fable-5-1
- **Human review:** n/a
- **Disclose:** no

### 2026-09-10 — CODE — scripts/00_prepare_data.R (data correction, task A6)
- **Did:** fixed the country-code join bug identified in `CRITICAL_REVIEW_2026-07-03.md` §4.5. The historical-state map sent USSR→SUN, Czechoslovakia→CSK, Yugoslavia→YUG, codes absent from `vdem_clean.rds`, so 5,049 article-country rows lost their regime scores at the V-Dem join. Changed the map to V-Dem's continuous units (USSR→RUS, Czechoslovakia→CZE, Yugoslavia→SRB); DDR unchanged; trimmed `historical_names` accordingly; replaced the wrong comment ("both coded in V-DEM") with a dated correction note. No other logic touched. The script was **not re-run** (no R on this machine), so the new join rate is unverified.
- **Output:** `scripts/00_prepare_data.R` lines 97–131 (uncommitted in the git repo); corrected corpus description and two new open items in `notes.md`
- **Model:** claude-fable-5-1
- **Human review:** pending — the PI must review the mapping choice (successor-unit mapping rather than dropping the rows), re-run Phase 0, and check the printed V-Dem join rate before any result from the rebuilt corpus is reported
- **Disclose:** yes — methods (as a data correction; the registered ≥1990 tests are unaffected)

### 2026-09-10 — ADMIN — STOPPING_RULE_MEMO_2026-09-10.md (task A1)
- **Did:** drafted the skeleton of the budget-only stopping-rule memo for Teams 05/10/12/06: what was known at writing, cost table from `STATUS.md`, a fixed decision rule, blank decision and signature fields, and disclosure text for both branches. No decision taken; no results consulted beyond the counts already in `STATUS.md`.
- **Output:** `STOPPING_RULE_MEMO_2026-09-10.md`
- **Model:** claude-fable-5-1
- **Human review:** pending — the PI fills in the budget facts, decides, signs, and dates
- **Disclose:** the signed memo goes in the transparency appendix; the drafting itself needs no separate disclosure
