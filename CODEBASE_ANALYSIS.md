# Codebase Analysis — AutoKnow Agent Orchestra

**Date:** 2026-03-19
**Scope:** Full review of all tracked files in the repository

---

## Summary

The repository is well-structured and well-documented for a multi-agent research orchestration project. However, there are several inconsistencies across documents, a hardcoded path that prevents portability, and documentation gaps that should be resolved before launching Phase 1. Below are findings organized by severity.

---

## Critical Issues

### 1. Hardcoded Windows path in `00_prepare_data.R` (line 28)

```r
base <- "C:/Users/torewig/Dropbox (Privat)/!!!!FORSKNING!!!!!/AUTOKNOW_ERC_COG"
```

This path is specific to a single Windows machine. The script will fail on any other environment (including this Linux host). **Recommendation:** Use an environment variable or `here::here()` (already used in `scaffold_teams.R`) or make the base path a command-line argument:

```r
base <- Sys.getenv("AUTOKNOW_DATA_ROOT",
                   unset = here::here("DATA"))
```

### 2. STATUS.md contains an outdated blocker about data scope

STATUS.md (lines 65-87) contains a "CRITICAL FINDING — PI DECISION REQUIRED" section
claiming the WOS data covers only 1970-1983. **This is incorrect — the data covers
1970-2023 as planned.** The references to "1970-2023" in PLAN.md, README.md,
scaffold_teams.R, and vdem_codebook.md are all correct.

The blocker in STATUS.md should be removed, and the project status should be updated
to reflect that Phase 0 validation can proceed (or has already been completed).
Items affected:
- STATUS.md lines 65-87: remove or mark as resolved
- STATUS.md line 132 (open item 1): close the blocker
- STATUS.md line 10: update current phase status
- STATUS.md line 135: open item 4 ("update PLAN.md to reflect actual time window") is no longer needed

---

## Moderate Issues

### 3. SSH field count: "50" is incorrect everywhere

The ssh_fields.txt header says "50 confirmed" categories. PLAN.md and README.md repeat "50 WOS subject categories." But an actual count of uncommented lines gives:

| Section | Count |
|---------|-------|
| SSCI (Social Sciences) | 43 |
| AHCI (Arts & Humanities) | 23 |
| Borderline (uncommented: Business, Business Finance, Science & Technology Studies) | 3 |
| **Total loaded** | **69** |

STATUS.md correctly says "69 categories loaded" but describes them as "50 confirmed + borderline." The "50 confirmed" figure does not match any counting method (43 SSCI + 23 AHCI = 66 confirmed, + 3 borderline = 69 total). **Recommendation:** Update all references to state "69 categories (66 confirmed + 3 borderline)" or whichever count reflects the PI's intent.

### 4. V-DEM extended variables undocumented in corpus schema

STATUS.md (decision log, 2026-02-27) records that four additional V-DEM variables were added: `v2clacfree`, `v2x_freexp_altinf`, `v2csreprss`, `v2xnp_regcorr`. However:

- PLAN.md's "Key columns available to teams" table (lines 33-59) does not list these variables
- `data/vdem_codebook.md` does not document them
- The brief template (PLAN.md and scaffold_teams.R) does not mention them

Teams will have access to these variables in `agent_corpus.rds` (since `00_prepare_data.R` joins the full vdem table) but won't know they exist unless they inspect the data frame columns directly. **Recommendation:** Add these to the PLAN.md column table and to `vdem_codebook.md`.

### 5. Non-interactive CLI invocation example is broken

In `agents/HOWTO_INVOKE.md` (lines 125-129):

```powershell
claude --print "$(Get-Content agents\prompt_designer.md -Raw)" |
    ForEach-Object { $_ -replace '\[N\]', '01' }
```

The `[N]` replacement happens on the *output* of `claude --print`, not on the *input* message. The agent will receive the prompt with literal `[N]` placeholders. **Fix:**

```powershell
$prompt = (Get-Content agents\prompt_designer.md -Raw) -replace '\[N\]', '01'
claude --print "$prompt"
```

### 6. HOWTO_INVOKE.md references Windows-only paths

Lines 117-118 reference a specific Windows path:
```
C:\Users\torewig\Dropbox (Privat)\...\Autocracy and science_Agent Orchestra
```

This should be generalized or noted as an example.

---

## Minor Issues

### 7. Reviewer prompt could be strengthened

The Peer Reviewer prompt (`agents/prompt_reviewer.md`) instructs the reviewer to read `report.md`, `rq.md`, and `analysis_plan.md`, and "optionally glance at figure filenames." It does **not** instruct reading `analysis/analysis.R`. For a thorough methodological review, reading the actual analysis code would improve review quality. Consider changing "optionally glance at figure filenames" to "read analysis/analysis.R and review the figure files."

### 8. `scaffold_teams.R` brief template duplicates PLAN.md template

The brief template exists in two places:
- `PLAN.md` lines 302-396 (markdown fenced block)
- `scaffold_teams.R` lines 12-98 (R function)

These are nearly identical but have minor formatting differences (e.g., em-dashes vs hyphens, `--` vs `—`). Changes to one won't propagate to the other. **Recommendation:** Keep the canonical version in one place and reference it from the other.

### 9. `doc_type` decision still open but script already filters

STATUS.md open item 3 asks: "Decide whether to include 'Review' doc_type alongside 'Article'." But `00_prepare_data.R` already filters to `doc_type == "Article"` only (line 77). The decision has effectively been made by implementation. Either close this open item or update the script.

### 10. Missing `.Rproj` file

The `.gitignore` excludes `.Rproj.user/` but there is no `.Rproj` file in the repository. If the PI uses RStudio, adding an `.Rproj` file would help with project portability (setting working directory, encoding, etc.).

---

## Consistency Matrix

| Topic | PLAN.md | STATUS.md | README.md | scaffold_teams.R | ssh_fields.txt |
|-------|---------|-----------|-----------|-------------------|----------------|
| Time range | 1970-2023 (correct) | 1970-1983 (STALE) | 1970-2023 (correct) | 1970-2023 (correct) | N/A |
| SSH field count | 50 | 69 (correct) | 50 | N/A | Header says 50, actual 69 |
| V-DEM extended vars | Not listed | Listed | Not listed | N/A | N/A |
| Base data path | Relative | N/A | N/A | `here::here()` | N/A |
| Data prep script path | Hardcoded Windows | N/A | N/A | N/A | N/A |

---

## Recommendations (prioritized)

1. **Clear the outdated data-scope blocker** in STATUS.md — the data covers 1970-2023 as planned; the "CRITICAL FINDING" is stale.
2. **Fix hardcoded path** in `00_prepare_data.R` — use environment variable or `here::here()` for portability.
3. **Correct SSH field count** from "50" to actual count (69 or 66+3) across PLAN.md, README.md, and ssh_fields.txt header.
4. **Document V-DEM extended variables** in PLAN.md column table and vdem_codebook.md.
5. **Fix CLI invocation example** in HOWTO_INVOKE.md.
6. **Close or update open items** in STATUS.md that have been resolved by implementation.
