# ptModelCompare

## Purpose
> Build a side-by-side model comparison `ptTable` from one or more `ptModel` structs, aligning
> rows on the union of term names (coefficient table rows) and the union of goodness-of-fit row
> names across all models. Models with different regressors are supported; missing cells render
> blank.

## Format
> tbl = ptModelCompare(models)
> tbl = ptModelCompareWith(models, opts)

## Input
| Option | Description |
|:------- |:------- |
| models | `ptModel` array (e.g. built with `reshape(ptModelFrom(...), n, 1)` and indexed assignment), one element per model/column. |
| opts | `ptCompareOptions` struct (see below). `ptModelCompare(models)` is shorthand for `ptModelCompareWith(models, ptCompareOptionsCreate())`. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` with one column per model, one row block per term (coefficient plus configured statistic rows), followed by one row per goodness-of-fit statistic. `tbl.notes` combines the significance note, any per-model notes (prefixed with the model name when comparing more than one model), and any table-level notes from `opts`. |

## Term and row ordering
- Terms appear in order of first appearance across `models`, unless `ptCompareSetTermOrder` is used.
- Goodness-of-fit rows appear in order of first appearance across `models`, unless
  `ptCompareSetGofOrder` is used.
- Each term occupies `1 + length(statRows)` rows, where `statRows` comes from `models[1].fmt.statRows`
  (set via `ptModelSetStatRows`).

## ptCompareOptions
Build with `ptCompareOptionsCreate()` and configure with:

| Procedure | Description |
|:------- |:------- |
| `ptCompareSetTermOrder(opts, termOrder)` | Lists terms in the desired display order; unlisted terms keep their union order and are appended after. |
| `ptCompareSetGofOrder(opts, gofOrder)` | Same ordering behavior for goodness-of-fit rows. |
| `ptCompareSetLabelMap(opts, mapFrom, mapTo)` | Renames term row labels for display only; matching against model term names (for alignment) is unaffected. |
| `ptCompareSetNotes(opts, notes)` | Appends table-level notes after the significance note and any per-model notes. |
| `ptCompareSetColGroups(opts, colGroups)` | One column-group label per model; sets `tbl.colGroups` so the comparison columns render with grouped/spanning headers (e.g. to label equation, quantile, or panel groups). |

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

struct ptCompareOptions opts;
opts = ptCompareOptionsCreate();
opts = ptCompareSetTermOrder(opts, "Constant" $| "weight" $| "length" $| "foreign");
opts = ptCompareSetLabelMap(opts, "Constant", "(Intercept)");
opts = ptCompareSetNotes(opts, "Robust standard errors in parentheses.");

struct ptTable tbl;
tbl = ptModelCompareWith(models, opts);
tbl = ptSetTitle(tbl, "Model Comparison");

call ptExport(tbl, "model_comparison.md");
```

## See Also
`ptModelFrom`, `ptModelTable`, `ptModelSetStatRows`, `ptModelSetNotes`
