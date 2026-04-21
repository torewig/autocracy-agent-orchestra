# V-DEM Variable Codebook
# For use by all research teams in the AutoKnow Agent Orchestra

Source: V-Dem Dataset v15, downloaded via `vdemdata` R package (GitHub).
Coverage: 182 countries, 1970-2023.

---

## Variables in `data/agent_corpus.rds` and `DATA/vdem/vdem_clean.rds`

### `v2x_libdem` — Liberal Democracy Index
- **Type:** Continuous, 0-1
- **Interpretation:** Higher = more democratic. Combines electoral, liberal,
  participatory, egalitarian, and deliberative components.
- **Use this as the primary regime measure** in regression analyses. It captures
  gradations in regime quality and avoids the arbitrariness of binary splits.
- **Typical values:** Consolidated democracies ~0.7-0.9; electoral autocracies
  ~0.2-0.4; closed autocracies ~0.0-0.15.

### `v2x_regime` — Regime Type (4-category)
- **Type:** Ordinal integer, 0-3
- **Categories:**
  - 0 = Closed autocracy (no multiparty elections)
  - 1 = Electoral autocracy (multiparty elections, but unfree/unfair)
  - 2 = Electoral democracy (free and fair elections, limited liberal rights)
  - 3 = Liberal democracy (free elections + strong liberal rights)
- **Use for:** Robustness checks; descriptive tables by regime category;
  event-study designs around regime transitions (change in category = transition).
- **Caution:** The 0/1 vs. 2/3 boundary is a theoretical judgment, not an
  empirical threshold. Do not treat ordinal distances as cardinal.

### `e_lexical_index` — Lexical Index of Electoral Democracy (LIED)
- **Type:** Ordinal integer, 0-6
- **Source:** Skaaning, Gerring & Bartusevičius (2015), included in V-DEM v15
- **Categories:**
  - 0 = No elections for legislature or executive
  - 1 = Elections without full suffrage (e.g. property restrictions)
  - 2 = Universal male suffrage only
  - 3 = Universal male and female suffrage, but not truly competitive
  - 4 = Minimally competitive multiparty elections with full suffrage for legislature or executive
  - 5 = Minimally competitive multiparty elections with full suffrage for both legislature and executive
  - 6 = Full electoral democracy (free, fair, competitive)
- **Use for:** Constructing `lied_binary`; comparisons with `v2x_libdem`.

### `lied_binary` — Binary Democracy Indicator (LIED-based)
- **Type:** Integer, 0 or 1
- **Construction:** `lied_binary = as.integer(e_lexical_index >= 4)`
  - 0 = Non-democracy (no minimally competitive multiparty elections with full suffrage)
  - 1 = Democracy (at minimum: minimally competitive multiparty elections with full male and female suffrage for legislature and executive)
- **Threshold rationale:** Level 4 corresponds to the user-specified threshold:
  "Minimally competitive, multiparty elections with full male or female suffrage
  for legislature and executive." This is a more procedurally grounded threshold
  than the V-DEM `v2x_regime`-based binary.
- **Use for:** Robustness checks alongside `v2x_libdem`; simple group comparisons.
  Replaces the old `regime_binary` variable as the recommended binary measure.

### `regime_binary` — (Legacy binary, V-DEM regime-based)
- **Note:** This variable (`ifelse(v2x_regime >= 2, 1, 0)`) remains in the corpus
  for backward compatibility but is superseded by `lied_binary` for robustness checks.
  Use `lied_binary` in new analyses.

### `v2clacfree` — Academic Freedom Index
- **Type:** Continuous, approx. -3 to 3
- **Interpretation:** Higher = more academic freedom. Captures freedom to teach,
  research, and publish without state interference.
- **Use for:** Team 30 primary analysis; alternative mechanism tests for other teams.

### `v2x_freexp_altinf` — Freedom of Expression and Alternative Information
- **Type:** Continuous, 0-1
- **Use for:** Robustness checks on mechanism (freedom of expression channel).

### `e_gdppc` — GDP per Capita
- **Type:** Continuous (thousands, 2011 USD, PPP-adjusted)
- **Source:** Maddison Project / V-DEM economic data
- **Coverage:** ~99.7% of corpus rows
- **Use for:** Economic development control. Log-transform (`log(e_gdppc)`) is standard.

### `e_wb_pop` — Population (World Bank)
- **Type:** Continuous (number of persons)
- **Source:** World Bank via V-DEM
- **Coverage:** ~98.6% of corpus rows
- **Use for:** Country-size control. Log-transform (`log(e_wb_pop)`) is standard.

---

## Guidance: which measure to use when

| Analysis type | Recommended measure | Notes |
|---|---|---|
| Regression (main estimate) | `v2x_libdem` | Continuous; exploits full variation |
| Robustness check (binary) | `lied_binary` | Procedurally grounded LIED threshold |
| Descriptive table | `v2x_regime` | 4-category labels aid readability |
| Event study / transitions | `v2x_regime` | Transition = change in category |
| Academic freedom mechanism | `v2clacfree` | Team 30 primary; others robustness |
| Interaction with year | `v2x_libdem` | Continuous × continuous more tractable |

**Standard robustness practice:** Report main results with `v2x_libdem`.
In a robustness section or appendix, replicate with `lied_binary`. If results
are consistent across both, say so. If they diverge, discuss why.

---

## Country coverage notes

- V-DEM covers 182 countries. Small territories (e.g. Bermuda, Macau, Puerto Rico)
  are not in V-DEM and will have NA regime scores in `agent_corpus.rds`.
- USSR coded through 1991; successor states from 1992 onward.
- German Democratic Republic coded through 1990; unified Germany from 1991.
- Yugoslavia coded through 1991; successor states from 1992 onward.
- Taiwan is included in V-DEM (`country_text_id = "TWN"`).

---

## Citation

Coppedge, Michael, John Gerring, Carl Henrik Knutsen, et al. 2024.
"V-Dem Dataset v15." Varieties of Democracy (V-Dem) Project.
https://doi.org/10.23696/mcwt-fr58

Skaaning, Svend-Erik, John Gerring, and Henrikas Bartusevičius. 2015.
"A Lexical Index of Electoral Democracy." Comparative Political Studies 48(12): 1491-1525.
