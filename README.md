# Autocracy and SSH: An Agent Orchestra Study

**PI:** Tore Wig, University of Oslo
**Project:** AutoKnow ERC Consolidator Grant

## Overview

This repository contains the research design, scripts, and documentation for a
multi-agent study of how autocratic regimes shape the contents, direction, and
scientific progress of social science and humanities (SSH) research.

The project uses an "agent orchestra" approach: 10 independent research teams,
each consisting of AI agents working through Designer, Analyst, and Writer roles,
independently formulate and investigate a research question addressing the
overarching question:

> **How does autocracy, and type of autocracy, impact on the contents, direction
> and scientific progress of the social sciences and humanities?**

Teams analyze a corpus of ~7.5 million Web of Science articles (filtered to SSH,
1970-2023) linked to V-DEM country-year democracy indicators. Each team's report
is reviewed by an independent peer review agent before the PI writes a synthesis
paper aggregating findings across all teams.

## Repository structure

```
.
|-- PLAN.md              # Full project plan (also rendered as PLAN.pdf)
|-- ssh_fields.txt       # WOS subject categories included as SSH
|-- figures/
|   `-- pipeline.png     # Step-by-step pipeline visualization
|-- data/
|   `-- vdem_codebook.md # V-DEM variable definitions and usage guidance
`-- scripts/
    |-- 00_prepare_data.R  # Phase 0: filters WOS corpus, merges V-DEM, saves agent_corpus.rds
    |-- scaffold_teams.R   # Creates team folder structure and brief.md files
    `-- plot_pipeline.R    # Generates figures/pipeline.png
```

## Data

Data files are **not** tracked in this repository (too large for GitHub):

- `DATA/bibliometric/WOS_scrapes/wos_articles.rds` — full WOS corpus (565 MB)
- `data/agent_corpus.rds` — analysis-ready SSH subset with V-DEM merge (produced by Phase 0)
- `DATA/vdem/vdem_clean.rds` — V-DEM country-year panel (produced by `DATA/vdem/install_github.R`)

## Workflow

See `PLAN.md` for the full workflow. In brief:

1. **Phase 0** — Run `scripts/00_prepare_data.R` to produce `data/agent_corpus.rds`
2. **Phase 1** — Run 10 agent team sessions:
   - Step A: Designer sessions (rq.md + analysis_plan.md)
   - Step B: PI Review Gate (RQ convergence + causal logic check)
   - Step C: Analyst sessions (regression analysis + figures)
   - Step D: PI Review Gate (methodology + identification check)
   - Step E: Writer sessions (4-5 page reports)
   - Step F: Peer Review sessions (independent review of each report)
   - Step G: PI reads all reports + peer reviews; final sign-off
3. **Phase 2** — PI writes synthesis paper assisted by synthesis agent

## Key design decisions

- SSH scope defined by `ssh_fields.txt` (50 WOS subject categories)
- Final analysis must use regression; text analysis permitted for measurement only
- Teams aim for causal identification designs (country FE, year FE, DiD)
- Each team report receives an independent peer review before synthesis

## Dependencies

- R 4.5+ with: `tidyverse`, `countrycode`, `vdemdata`, `fs`, `here`, `ggplot2`
- pandoc + xelatex (for rendering PLAN.pdf)

## Related

- ERC project: AutoKnow (ERC Consolidator Grant)
- V-DEM data: https://www.v-dem.net
