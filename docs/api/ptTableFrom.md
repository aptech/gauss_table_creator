# ptTableFrom

## Purpose
> Build a `ptTable` directly from a supported GAUSS estimation/summary output struct, using
> `isStructType` to dispatch to the matching adapter. This is the quickest path from an estimation
> command to a renderable/exportable table.

## Format
> tbl = ptTableFrom(out)

## Input
| Option | Description |
|:------- |:------- |
| out | A struct returned by a supported GAUSS command. Currently dispatches on `olsmtOut`, `glmOut`, `dstatmtOut`, and `fglsOut`. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` struct ready for rendering/export. For estimation outputs (`olsmtOut`, `glmOut`, `fglsOut`) this is equivalent to `ptModelTable(ptModelFrom(<default name>, out))`; for `dstatmtOut` it is a summary-statistics table (see `ptFromDstatmt`). |

## Notes
- If `out` is not one of the supported struct types, `ptTableFrom` calls `errorlog` and ends execution.
  Use `ptModelFrom`/`ptModelTable` (for model adapters such as `gmmOut`) or build the table manually
  with `ptTableFromMatrix`/`ptTableCreate` for unsupported types.
- Optional add-on adapters (`maxlikmtResults`, `cmlmtResults`, `arimamtOut`, `tsPanelEstimationOut`,
  `optmtResults`) are *not* wired into `ptTableFrom`/`ptModelFrom` because the underlying packages may
  not be installed; call their dedicated `ptFrom...`/`ptModelFrom...` procedures directly (see
  `src/pubtable_maxlikmt.src`, `src/pubtable_cmlmt.src`, `src/pubtable_tsmt.src`, `src/pubtable_optmt.src`).

## Example
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;

out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

struct ptTable tbl;
tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS Regression");

call ptExport(tbl, "ols_table.md");
```

## See Also
`ptModelFrom`, `ptModelTable`, `ptFromDstatmt`, `ptExport`
