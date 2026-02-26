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
  event-study designs around regime transitions.
- **Caution:** The 0/1 vs. 2/3 boundary is a theoretical judgment, not an
  empirical threshold. Do not treat ordinal distances as cardinal.

### `regime_binary` — Binary Autocracy/Democracy
- **Type:** Integer, 0 or 1
- **Construction:** `regime_binary = ifelse(v2x_regime >= 2, 1, 0)`
  - 0 = Autocracy (closed or electoral autocracy)
  - 1 = Democracy (electoral or liberal democracy)
- **Use for:** Simple group comparisons; interaction terms; robustness checks
  alongside `v2x_libdem`.
- **Caution:** The cutpoint (>= 2) is a reasonable but debatable choice.
  Robustness to alternative cutpoints (>= 3) is worth checking for key results.

---

## Guidance: which measure to use when

| Analysis type | Recommended measure | Notes |
|---|---|---|
| Regression (main estimate) | `v2x_libdem` | Continuous; exploits full variation |
| Robustness check | `regime_binary` | Simple binary; easy to interpret |
| Descriptive table | `v2x_regime` | 4-category labels aid readability |
| Event study / transitions | `v2x_regime` | Transition = change in category |
| Interaction with year | `v2x_libdem` | Continuous x continuous more tractable |

**Standard robustness practice:** Report main results with `v2x_libdem`.
In a robustness section or appendix table, replicate the main specification
using `regime_binary`. If results are consistent across both, say so.
If they diverge, discuss why.

---

## Country coverage notes

- V-DEM covers 182 countries. Small territories (e.g. Bermuda, Macau, Puerto Rico)
  are not in V-DEM and will have NA regime scores in `agent_corpus.rds`.
- USSR is coded through 1991; successor states from 1992 onward.
- German Democratic Republic coded through 1990; unified Germany from 1991.
- Yugoslavia coded through 1991; successor states from 1992 onward.
- Taiwan is included in V-DEM (`country_text_id = "TWN"`).

## Citation

Coppedge, Michael, John Gerring, Carl Henrik Knutsen, et al. 2024.
"V-Dem Dataset v15." Varieties of Democracy (V-Dem) Project.
https://doi.org/10.23696/mcwt-fr58
