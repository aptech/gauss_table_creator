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
| out | A struct returned by a supported GAUSS estimation command. Currently dispatches on `olsmtOut`, `glmOut`, `gmmOut`, and `fglsOut`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` struct with `name`, `termNames`, `estimates`, `stdErrors`, `pValues` (where available), and `gofNames`/`gofValues` populated. |

## Notes
- If `out` is not one of the supported struct types, `ptModelFrom` calls `errorlog` and ends execution.
- Use `ptModelSetStatRows`, `ptModelSetCI`, `ptModelSetDigits`, `ptModelSetNotes`,
  `ptModelSetLabel`, and `ptModelSetColAlign` to customize a model before calling `ptModelTable` or
  comparing it with other models.
- Optional add-on adapters (`maxlikmtResults`, `cmlmtResults`, `arimamtOut`, `tsPanelEstimationOut`)
  are not wired into `ptModelFrom`; call `ptModelFromMaxlikmt`, `ptModelFromCmlmt`,
  `ptModelFromArimamt`, or `ptModelFromTsPanel` directly.

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
