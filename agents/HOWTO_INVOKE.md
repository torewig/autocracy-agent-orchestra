# How to Invoke Agent Sessions

## What you need

- Claude Code installed and authenticated (`claude` in terminal, or IDE extension)
- The project folder open as the working directory

**All sessions are opened from the project root:**
```
C:\...\P02_autocracy-science-agent-orchestra\
```

See `TIMELINE.md` for the schedule. **Active teams: 27** (Teams 28–30 dropped 2026-04-20).

---

## Step-by-step invocation

### Step A — Run all 27 Designer sessions

Run in batches of 5–8 per day. Can run in parallel — open multiple terminals.

For each team:
1. Open a terminal; navigate to project root
2. Start Claude Code: `claude` (CLI) or open IDE with Claude extension
3. Paste the contents of `agents/prompt_designer.md` as your first message,
   replacing `[N]` with the team number (e.g. `01`)

**Shortcut — copy prompt to clipboard:**
```powershell
Get-Content agents\prompt_designer.md | Set-Clipboard
# Then paste into Claude Code and manually replace [N]
```

The session will:
- Read `teams/team_[N]/brief.md` (domain assignment + self-censorship framing)
- Sample the corpus to understand available data
- Scan other teams' rq.md files for uniqueness check
- Write `teams/team_[N]/rq.md` and `teams/team_[N]/analysis_plan.md`
- Stop and say "Step 1 complete"

**Batching schedule (from TIMELINE.md):**
- Day 2: Teams 01–06
- Day 3: Teams 07–13
- Day 4: Teams 14–20
- Day 5: Teams 21–27 (Teams 23–27 are ideological-alignment, all Complex)

---

### Step B — PI Review Gate (Day 7)

After all 30 Designer sessions finish:

1. Read all 30 `teams/team_##/rq.md` files
2. Check for uniqueness: verify no two teams have the same outcome variable +
   measurement approach. Each rq.md has a "Uniqueness check" note at the bottom.
3. Check self-censorship framing: each RQ must state a clear implication of the
   self-censorship theory. Redirect any team whose mechanism is unclear.
4. Confirm theory family labels match the five approved sub-families:
   `topic-avoidance`, `framing-neutrality`, `collaboration-constraint`,
   `visibility-suppression`, `ideological-alignment`
5. If redirecting a team: open a new session and say:
   > "Read teams/team_[N]/rq.md and teams/team_[N]/brief.md. The PI asks you
   > to revise the RQ: [specific issue]. Update rq.md and analysis_plan.md."
6. When satisfied with all 30 RQs, proceed to Step B'

---

### Step B' — Pre-registration (Day 9)

After PI approval of all 27 RQs and **before starting any Analyst session**:

```powershell
powershell -ExecutionPolicy Bypass -File "scripts\preregister.ps1"
```

The script creates `teams/team_##/preregistration.md` per team,
commits all files to GitHub with a timestamp.

**Verify** the commit appears on GitHub before proceeding.

---

### Step C — Run all 27 Analyst sessions (Days 10–16)

For each approved team (run in batches per the TIMELINE.md schedule):
1. Open a new Claude Code session (NOT a continuation of the Designer session)
2. Paste `agents/prompt_analyst.md` with `[N]` filled in
3. Session reads rq.md + analysis_plan.md, writes analysis.R, runs it,
   saves figures and primary_results.json, stops

**Important:** Fresh session each time. The Analyst reads only the files
the Designer wrote — it has no memory of prior sessions.

**Complex teams (API-dependent) — run on Day 15:**
Teams 05, 06, 10, 12, 23, 24, 25, 26, 27 require external API calls.
Confirm API access and budget before starting their Analyst sessions.
Total estimated API cost: ~$35–75. Run in parallel on Day 15.

---

### Step D — PI Review Gate (Day 18)

1. Open `teams/team_##/analysis/figures/` for each team
2. Verify `teams/team_##/analysis/primary_results.json` exists and looks correct
3. Write feedback to `teams/team_[N]/pi_notes.md` for any team needing revision;
   open a new session and say:
   > "Read teams/team_[N]/rq.md and teams/team_[N]/analysis/analysis.R.
   > PI notes: [specific issue]. Please revise."
4. When satisfied with all 27 teams, proceed to Step D'

---

### Step D' — Bonferroni adjustment (Day 20)

After PI approves all analysis outputs and **before starting any Writer session**:

```powershell
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" "scripts\bonferroni_adjust.R"
```

The script writes:
- `data/adjusted_pvalues.rds` — loaded by each Writer agent
- `data/adjusted_pvalues_report.md` — human-readable table for PI review

**Review `data/adjusted_pvalues_report.md`** before proceeding. Check that:
- Theory family groupings match what you approved at Gate B
- Each of the 5 sub-families has the expected number of teams
- No team is missing from the table

---

### Step E — Run all 30 Writer sessions (Days 20–22)

For each team (run in batches):
1. Open a new Claude Code session
2. Paste `agents/prompt_writer.md` with `[N]` filled in
3. Session reads all prior files, writes `report/report.md` in 8-section
   format, stops

**Batching:** Day 20: teams 01–10; Day 21: teams 11–20; Day 22: teams 21–27

---

### Step F — Run all 30 Reviewer sessions (Days 23–24)

After all Writer sessions are done:
1. Open a new Claude Code session per team
2. Paste `agents/prompt_reviewer.md` with `[N]` filled in
3. Session reads report.md + rq.md, writes `report/peer_review.md`, stops

**Batching:** Day 23: teams 01–15; Day 24: teams 16–27

---

### Step G — PI Final Review (Day 25)

Read all 27 `teams/team_##/report/report.md` and `peer_review.md`.
Flag any reports for revision. When satisfied, proceed to Step S.

---

### Step S — Theory Synthesis (Day 28)

Run once after all 30 reports and peer reviews are complete.

1. Open a new Claude Code session from the project root
2. Paste the full contents of `agents/prompt_synthesizer.md`
   (no `[N]` substitution needed — this is a project-level session)
3. Session reads all 27 rq.md + report.md + peer_review.md + adjusted p-values
4. Writes `synthesis/theory_evaluation.md`

---

### Daily Overseer (any day)

Run at the start of each working day to get a prioritised task list.

1. Open a new Claude Code session from the project root
2. Paste the full contents of `agents/prompt_overseer.md`
   (no `[N]` substitution needed)
3. Session scans all team folders + TIMELINE.md + STATUS.md
4. Outputs a structured report: what was done, what to do today, blockers

---

## CLI tips

### Starting Claude Code
```powershell
# Navigate to project root
Set-Location "C:\Users\torewig\Dropbox (Privat)\!!!!FORSKNING!!!!!\AUTOKNOW_ERC_COG\Papers\P02_autocracy-science-agent-orchestra"
# Start Claude Code
claude
```

### Copy a prompt with team number filled in
```powershell
(Get-Content agents\prompt_designer.md -Raw) -replace '\[N\]', '01' | Set-Clipboard
# Then paste into Claude Code
```

### Parallel invocation (multiple windows)
Open 5–8 PowerShell windows. In each, navigate to project root and start
`claude`, then paste the Designer (or Analyst, Writer) prompt for one team.
This is the recommended approach for batch days.

---

## Context management tips

- **Keep sessions focused**: each session does ONE role only (Designer, Analyst,
  Writer, Reviewer, Overseer, or Synthesizer)
- **Fresh sessions are intentional**: Analyst/Writer/Reviewer sessions have no
  memory of prior work — they read state from files, which is the design
- **Long-running analyses**: if an Analyst session estimates >5 min runtime,
  it will ask before proceeding. Approve explicitly.
- **Session crashes**: if an Analyst crashes mid-run, analysis.R may be
  partially written. Open a new session and say:
  > "Your analysis.R was partially written. Read it and continue from
  > where it stopped."
- **API cost tracking**: Teams 05, 06, 10, 12, 23, 24, 25, 26, 27 use external APIs.
  Each agent will disclose estimated and actual cost in analysis.R comments.
  Total estimated budget: ~$35–75.
