# ptModelFrom

## Purpose
> Build a `ptModel` from a supported GAUSS estimation output struct, using `isStructType` to
> dispatch to the matching adapter. A `ptModel` carries coefficient estimates, standard errors,
> p-values, optional confidence intervals, and goodness-of-fit statistics, and is the input to
> `ptModelTable`, `ptModelCompare`, and `ptModelCompareWith`.

## Format
> mdl = ptModelFrom(name, out)

## Input
| Option | Description |
|:------- |:------- |
| name | String, the display name for this model (used as the column header in comparison tables). |
| out | A struct returned by a supported GAUSS estimation command. Built in: `olsmtOut`, `glmOut`, `gmmOut`, `fglsOut`. Optional add-on (dispatched automatically once the corresponding library is loaded): `cmlmtResults`, `maxlikmtResults`, `arimamtOut`, `tsPanelEstimationOut`, `automtOut`, `varmamtOut`, `lsdvmtOut`, `switchmtOut`, `garchEstimation`, `ardlOut`, `ardlECMOut`, `nardlOut`, `nardlECMOut`, `csardlOut`, `csardlECMOut`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` struct with `name`, `termNames`, `estimates`, `stdErrors`, `pValues` (where available), and `gofNames`/`gofValues` populated. |

## Notes
- If `out` is not one of the supported struct types, `ptModelFrom` calls `errorlog` and ends execution.
- Use `ptModelSetStatRows`, `ptModelSetCI`, `ptModelSetDigits`, `ptModelSetNotes`,
  `ptModelSetLabel`, and `ptModelSetColAlign` to customize a model before calling `ptModelTable` or
  comparing it with other models.
- Most optional add-on adapters are wired into `ptModelFrom` (see the `out` row above) — load the
  add-on library together with pubtable (e.g. `library cmlmt, pubtable;`) and call `ptModelFrom`
  exactly as you would for a built-in struct.
- Not wired into `ptModelFrom`, because there is no single unambiguous two-argument mapping for
  these — call the dedicated procedure directly instead:
  - `optmtResults` — `optmtResults` has no covariance matrix, so there is no `ptModelFromOptmt`;
    use `ptTableFromOptmt(out)` instead (see [ptAdaptersOptmt](ptAdaptersOptmt.md)).
  - `tscsmtOut` — `tscsFit` produces two distinct estimators (within/dummy-variable and
    error-components) with no single canonical model; use `ptFromTscsmt(out)` or
    `ptModelFromTscsmtDV`/`ptModelFromTscsmtEC` directly.
  - `qardlOut`/`qardlECMOut` — the per-quantile adapters require an additional `tauIdx` argument;
    use `ptFromQardl`/`ptFromQardlECM`, or call `ptModelFromQardl`/`ptModelFromQardlECM` directly.

## Example
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out1;
struct olsmtOut out2;

ctl = olsmtControlCreate;
ctl.output = 0;

out1 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");
out2 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length + foreign");

struct ptModel models;
models = reshape(ptModelFrom("Model 1", out1), 2, 1);
models[2] = ptModelFrom("Model 2", out2);

struct ptTable tbl;
tbl = ptModelCompare(models);
tbl = ptSetTitle(tbl, "Model Comparison");

call ptExport(tbl, "model_comparison.md");
```

## See Also
`ptModelTable`, `ptModelCompare`, `ptModelCompareWith`, `ptTableFrom`
