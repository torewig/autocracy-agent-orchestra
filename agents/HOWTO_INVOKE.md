# How to Invoke Agent Sessions

## What you need

- Claude Code installed and authenticated (`claude` in terminal, or IDE extension)
- The project folder open as the working directory

**All sessions are opened from the project root:**
```
C:\...\Autocracy and science_Agent Orchestra\
```

---

## Step-by-step invocation

### Step A — Run all 10 Designer sessions

For each team (can run in parallel — open 10 terminals):

1. Open a terminal
2. Navigate to the project root (or open the folder in your IDE)
3. Start Claude Code: `claude` (CLI) or open IDE with Claude extension
4. Paste the contents of `agents/prompt_designer.md` as your first message,
   replacing `[N]` with the team number (e.g. `01`)

**Shortcut — open the prompt file and copy:**
```powershell
Get-Content agents\prompt_designer.md
# Copy the output, replace [N] with 01, paste into Claude Code
```

The session will:
- Read `teams/team_01/brief.md`
- Sample the corpus to understand available data
- Write `teams/team_01/rq.md` and `teams/team_01/analysis_plan.md`
- Stop and say "Step 1 complete"

You can run all 10 simultaneously in separate terminal windows.

---

### Step B — PI review gate

After all 10 Designer sessions finish:

1. Read all 10 `teams/team_##/rq.md` files
2. Check for RQ convergence (two teams with the same angle) and redirect if needed
3. Check that each `rq.md` includes a `Theoretical mechanism` and a proposed
   `Theory family` label
4. **Consolidate theory family labels:** each Designer proposes their own label —
   review all 10 proposals and decide the final groupings. Teams testing
   hypotheses rooted in the same theoretical argument should share an identical
   label; this determines the Bonferroni families later. Edit `rq.md` directly
   for any team whose label you want to change.
5. If redirecting a team: open a new session for that team and say:
   > "Read teams/team_[N]/rq.md. The PI would like you to revise the RQ
   > toward [different angle]. Update rq.md and analysis_plan.md."
6. When satisfied with all 10 RQs and all theory family labels are finalised,
   proceed to Step B'

---

### Step B' — Pre-registration (run before any analysis)

After PI approval of all RQs and **before starting any Analyst session**, run
the pre-registration script. This commits each team's `rq.md` and
`analysis_plan.md` to GitHub with a timestamp, creating a public record that
hypotheses were fixed before data were analysed.

```powershell
powershell -ExecutionPolicy Bypass -File "scripts\preregister.ps1"
```

The script will:
- Create `teams/team_##/preregistration.md` for each approved team
- Git commit all pre-registration files with a timestamped message
- Git push to the remote repository

**Verify** the commit appears on GitHub before proceeding to Step C. The
commit hash serves as the pre-registration timestamp.

---

### Step C — Run all 10 Analyst sessions

For each approved team:

1. Open a new Claude Code session (NOT a continuation of the Designer session)
2. Paste `agents/prompt_analyst.md` with `[N]` filled in
3. The session will read rq.md + analysis_plan.md, write analysis.R, run it,
   save figures, stop

**Important:** This is a FRESH session. The Analyst does not have memory of
the Designer session — it reads the files the Designer wrote.

---

### Step D — PI review gate

1. Open `teams/team_##/analysis/figures/` for each team
2. Check methodology and figures
3. Verify `teams/team_##/analysis/primary_results.json` exists and looks correct
4. If redirecting: open a session and say:
   > "Read teams/team_[N]/rq.md and teams/team_[N]/analysis/analysis.R.
   > The PI notes: [specific issue]. Please revise."
   Write feedback to `teams/team_[N]/pi_notes.md` for the agent to pick up.
5. When satisfied with all teams, proceed to Step D'

---

### Step D' — Bonferroni adjustment (run before Writers)

After PI approves all analysis outputs and **before starting any Writer session**,
run the Bonferroni adjustment script. It reads all teams' `primary_results.json`,
groups hypotheses by `theory_family`, and applies Bonferroni correction within
each family.

```powershell
& "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" "scripts\bonferroni_adjust.R"
```

The script writes:
- `data/adjusted_pvalues.rds` — loaded by each Writer agent
- `data/adjusted_pvalues_report.md` — human-readable table for PI review

**Review `data/adjusted_pvalues_report.md`** before proceeding. Check that:
- Theory family groupings are sensible (correct any misassigned labels by
  editing the relevant `rq.md` and rerunning)
- The number of tests per family is plausible
- No team is missing from the table

Then proceed to Step E.

---

### Step E — Run all 10 Writer sessions

For each approved team:

1. Open a new Claude Code session
2. Paste `agents/prompt_writer.md` with `[N]` filled in
3. Session reads all prior files, writes `report/report.md`, stops

---

### Step F — Run all 10 Reviewer sessions

After all Writer sessions are done:

1. Open a new Claude Code session per team
2. Paste `agents/prompt_reviewer.md` with `[N]` filled in
3. Session reads report.md + rq.md, writes `report/peer_review.md`, stops

Note: The reviewer for team_01 is a completely independent session — it has
no connection to the sessions that worked on team_01. This is intentional.

---

### Step G — PI final review

Read all `teams/team_##/report/report.md` and `teams/team_##/report/peer_review.md`.
When satisfied, proceed to Phase 2 synthesis.

---

## CLI tips

### Starting Claude Code from terminal (Windows)
```powershell
# Navigate to project root
Set-Location "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\Autocracy and science_Agent Orchestra"
# Start Claude Code
claude
```

### Non-interactive mode (for scripted invocation)
```powershell
# Pass the opening message directly (no interactive session)
claude --print "$(Get-Content agents\prompt_designer.md -Raw)" |
    ForEach-Object { $_ -replace '\[N\]', '01' }
```
This runs the session to completion and exits. Useful for running all 10
Designer sessions one after another from a script.

### Parallel invocation (10 windows)
Open 10 PowerShell windows. In each, run:
```powershell
Set-Location "C:\...\Autocracy and science_Agent Orchestra"
claude
# Then paste the Designer prompt for team 01, 02, ... 10
```

---

## Context management tips

- **Keep sessions focused**: each session should do ONE role only
- **File reads are cheap**: agents re-reading brief.md, rq.md etc. at the
  start of each session is intentional and correct
- **Long-running analyses**: if an Analyst session says the analysis will
  take >5 min, it should ask you before running. Approve explicitly.
- **Session crashes**: if a session crashes mid-analysis, the partially
  written analysis.R may be intact. Open a new session, tell it:
  > "Your analysis.R was partially written. Read it and continue from
  > where it stopped."
