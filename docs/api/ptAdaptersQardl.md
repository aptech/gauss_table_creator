# qardl Adapters

Optional adapters for the **qardl** (ARDL/QARDL/NARDL/CS-ARDL) package. Activated
automatically when `qardl.sdf` is included before `pubtable.src` (the `QARDL_SDF_INCLUDED`
guard in `qardl.sdf` controls this — no `pubtableSet` configuration needed).

## Activation

```gauss
library qardl, pubtable;
/* qardl.sdf include sets QARDL_SDF_INCLUDED, activating the adapter block */
```

For dev-path installs:
```gauss
library qardl;
#include qardl.sdf;
#include pubtable.dec;
#include pubtable.src;
```

## Adapters at a glance

### Plain ARDL
| Procedure | Input struct | Returns |
|:------- |:------- |:------- |
| `ptModelFromArdl(name, out)` | `ardlOut` | `ptModel` — ARDL levels equation. |
| `ptFromArdl(out)` | `ardlOut` | `ptTable` (shorthand). |
| `ptModelFromArdlECM(name, out)` | `ardlECMOut` | `ptModel` — ARDL error-correction equation. |
| `ptFromArdlECM(out)` | `ardlECMOut` | `ptTable` (shorthand). |
| `ptFromArdlFull(out)` | `ardlFullOut` | `ptTable` — levels equation (ECM discarded). |

### QARDL (quantile ARDL)
| Procedure | Input struct | Returns |
|:------- |:------- |:------- |
| `ptModelFromQardl(name, out, tauIdx)` | `qardlOut` | `ptModel` for one quantile (`tauIdx` is 1-based index into `out.tau`). |
| `ptFromQardl(out)` | `qardlOut` | `ptTable` comparison with one column per quantile. |
| `ptModelFromQardlECM(name, out, tauIdx)` | `qardlECMOut` | `ptModel` — ECM for one quantile. |
| `ptFromQardlECM(out)` | `qardlECMOut` | `ptTable` comparison with one column per quantile. |
| `ptTablesFromQardlFull(out)` | `qardlFullOut` | 2×1 `ptTable` array: levels table + ECM table. |

### NARDL (nonlinear ARDL)
| Procedure | Input struct | Returns |
|:------- |:------- |:------- |
| `ptModelFromNardl(name, out)` | `nardlOut` | `ptModel` — NARDL levels. |
| `ptFromNardl(out)` | `nardlOut` | `ptTable` (shorthand). |
| `ptModelFromNardlECM(name, out)` | `nardlECMOut` | `ptModel` — NARDL ECM. |
| `ptFromNardlECM(out)` | `nardlECMOut` | `ptTable` (shorthand). |
| `ptTablesFromNardlFull(out)` | `nardlFullOut` | 2×1 `ptTable` array: levels + ECM. |

### CS-ARDL (cross-sectionally augmented ARDL)
| Procedure | Input struct | Returns |
|:------- |:------- |:------- |
| `ptModelFromCsardl(name, out)` | `csardlOut` | `ptModel` — CS-ARDL levels. |
| `ptFromCsardl(out)` | `csardlOut` | `ptTable` (shorthand). |
| `ptModelFromCsardlECM(name, out)` | `csardlECMOut` | `ptModel` — CS-ARDL ECM. |
| `ptFromCsardlECM(out)` | `csardlECMOut` | `ptTable` (shorthand). |
| `ptTablesFromCsardlFull(out)` | `csardlFullOut` | 2×1 `ptTable` array: levels + ECM. |

### Dispatcher
| Procedure | Input | Returns |
|:------- |:------- |:------- |
| `ptFromArdlFamily(out)` | Any of the above output structs | `ptTable` dispatched by `isStructType`. |

## QARDL column labels
`ptFromQardl` and `ptFromQardlECM` build one comparison column per entry in `out.tau`,
labeled `"tau=<value>"`. SE for the levels beta/phi/gamma parameters replicates the
package's internal covariance scaling.

## Full-workflow helpers (`ptTablesFrom*Full`)
`ptTablesFromQardlFull`, `ptTablesFromNardlFull`, and `ptTablesFromCsardlFull` return a
2×1 `ptTable` array suitable for `ptExportAll`. Element 1 is the levels table; element 2
is the ECM table.

## Example — plain ARDL
```gauss
new;
library qardl, pubtable;

/* Estimate ARDL (requires qardl package data) */
ardlCtl = ardlControlCreate;
out = ardlFit(y, x, ardlCtl);

mdl = ptModelFromArdl("ARDL", out);
mdl = ptModelSetNotes(mdl, "Bounds test: F-stat = ...");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "ARDL Levels Equation");
call ptExport(tbl, "ardl.md");
```

## Example — QARDL multi-quantile table
```gauss
new;
library qardl, pubtable;

qCtl = qardlControlCreate;
qout = qardlFit(y, x, qCtl);

tbl = ptFromQardl(qout);
tbl = ptSetTitle(tbl, "QARDL Levels — All Quantiles");
call ptExport(tbl, "qardl.md");
```

## Example — Full workflow export (levels + ECM)
```gauss
new;
library qardl, pubtable;

qfull = qardlFull(y, x, qardlControlCreate);

struct ptTable tbls;
tbls = ptTablesFromQardlFull(qfull);

call ptExportAll(tbls, "qardl_full.md");
call ptExportAll(tbls, "qardl_full.html");
```

## See Also
`pubtableSet`, `ptModelCompare`, `ptExportAll`, `ptModelSetNotes`
