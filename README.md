# Autocracy and SSH: An Agent Orchestra Study

**PI:** Tore Wig, University of Oslo
**Project:** AutoKnow ERC Consolidator Grant

## Overview

This repository contains the research design, scripts, and documentation for a
multi-agent study of how autocratic regimes shape the contents, productivity,
disciplinary composition, and progressiveness of social science and humanities
(SSH) research.

The project uses an "agent orchestra" approach: 10 independent research teams,
each consisting of AI agents working through Designer, Analyst, and Writer roles,
independently formulate and investigate a research question addressing the
overarching question:

> **How does autocracy shape social science and the humanities?**

Teams analyze a corpus of ~7.5 million Web of Science articles (filtered to SSH,
1970-2023) linked to V-DEM country-year democracy indicators. The PI then writes
a synthesis paper aggregating findings across all teams.

## Repository structure

```
.
|-- PLAN.md              # Full project plan (also rendered as PLAN.pdf)
|-- ssh_fields.txt       # WOS subject categories included as SSH
|-- data/
|   `-- vdem_codebook.md # V-DEM variable definitions and usage guidance
`-- scripts/
    |-- 00_prepare_data.R  # Phase 0: filters WOS corpus, merges V-DEM, saves agent_corpus.rds
    `-- scaffold_teams.R   # Creates team folder structure and brief.md files
```

## Data

Data files are **not** tracked in this repository (too large for GitHub):

- `DATA/bibliometric/WOS_scrapes/wos_articles.rds` — full WOS corpus (565 MB)
- `data/agent_corpus.rds` — analysis-ready SSH subset with V-DEM merge (produced by Phase 0)
- `DATA/vdem/vdem_clean.rds` — V-DEM country-year panel (produced by `DATA/vdem/install_github.R`)

## Workflow

See `PLAN.md` for the full workflow. In brief:

1. **Phase 0** — Run `scripts/00_prepare_data.R` to produce `data/agent_corpus.rds`
2. **Phase 1** — Run 10 agent team sessions (Designer → PI review → Analyst → PI review → Writer)
3. **Phase 2** — PI writes synthesis paper assisted by outline agent

## Dependencies

- R 4.5+ with: `tidyverse`, `countrycode`, `vdemdata`, `fs`, `here`
- pandoc + xelatex (for rendering PLAN.pdf)

## Related

- ERC project: AutoKnow (ERC Consolidator Grant)
- V-DEM data: https://www.v-dem.net
