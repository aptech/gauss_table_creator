# ptCompareOptions

Procedures for creating and configuring a `ptCompareOptions` struct, which is passed to
`ptModelCompareWith` to control term ordering, label mapping, notes, and column grouping
in model comparison tables.

## Format summary

| Procedure | Description |
|:------- |:------- |
| `ptCompareOptionsCreate()` | Create a default (empty) `ptCompareOptions`. |
| `ptCompareSetTermOrder(opts, termOrder)` | Specify the desired display order for coefficient rows. |
| `ptCompareSetGofOrder(opts, gofOrder)` | Specify the desired display order for goodness-of-fit rows. |
| `ptCompareSetLabelMap(opts, mapFrom, mapTo)` | Rename term labels for display without changing alignment logic. |
| `ptCompareSetNotes(opts, notes)` | Set table-level notes appended after significance and model notes. |
| `ptCompareSetColGroups(opts, colGroups)` | Add spanning column-group headers above the model columns. |

## Input / output (common)
Every setter takes a `ptCompareOptions` as its first argument and returns a modified
`ptCompareOptions`. Chain them before passing to `ptModelCompareWith`.

## ptCompareOptionsCreate
Returns an empty `ptCompareOptions` with all fields blank. `ptModelCompare(models)` is
equivalent to `ptModelCompareWith(models, ptCompareOptionsCreate())`.

## ptCompareSetTermOrder
`termOrder` — string-array column vector of term names in the desired row order. Terms
listed here appear first; terms not listed are appended in their original union order.
Term names must match the values in `mdl.termNames` (not display labels).

## ptCompareSetGofOrder
`gofOrder` — string-array column vector of GOF row names in the desired order. Same
append-unlisted behavior as `ptCompareSetTermOrder`.

## ptCompareSetLabelMap
`mapFrom` — string-array column vector of original term names to rename.
`mapTo` — string-array column vector of replacement display labels (same length as `mapFrom`).
Only affects the displayed row labels; alignment and ordering still use the original names.

## ptCompareSetNotes
`notes` — string. Appended after the significance-symbol note and any per-model notes
(which are prefixed with the model name). Multiple note strings can be separated with
`"\n"`.

## ptCompareSetColGroups
`colGroups` — string-array column vector, one label per model. Contiguous equal labels
form a spanning header group. Sets `tbl.colGroups` on the resulting table.

## Example
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out1, out2, out3;
ctl = olsmtControlCreate;
ctl.output = 0;
out1 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight");
out2 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");
out3 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length + foreign");

struct ptModel models;
models = reshape(ptModelFrom("(1)", out1), 3, 1);
models[2] = ptModelFrom("(2)", out2);
models[3] = ptModelFrom("(3)", out3);

opts = ptCompareOptionsCreate();
opts = ptCompareSetTermOrder(opts, "Constant" $| "weight" $| "length" $| "foreign");
opts = ptCompareSetLabelMap(opts, "Constant" $| "foreign", "Intercept" $| "Foreign car");
opts = ptCompareSetNotes(opts, "Standard errors in parentheses.");
opts = ptCompareSetColGroups(opts, "Baseline" $| "Extended" $| "Extended");

tbl = ptModelCompareWith(models, opts);
tbl = ptSetTitle(tbl, "OLS Model Comparison");

call ptExport(tbl, "compare.md");
```

## See Also
`ptModelCompare`, `ptModelCompareWith`, `ptModelFrom`, `ptSetColGroups`
