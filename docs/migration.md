# Migration Guide: `tableControl`/`tableSet...` -> `pubtable` (`pt*`)

The legacy `tableControl`/`tableSet...`/`outputTable` API (documented in `docs/tableset*.md` and
implemented in `src/pubtable_legacy*.src`) is retained for backward compatibility, but new work
should use the modern `pt*` API described in the top-level [README.md](../README.md) and
[docs/api/](api/). This guide maps the old workflow onto the new one.

## Overall shape

**Legacy:**
```gauss
struct tableControl tCtl;
tCtl = tableGetDefaults("OLS");
tableSetTitle(&tCtl, "OLS Results");
tableSetSigFig(&tCtl, 3);
tableSetExport(&tCtl, "ols_table", "XLSX");

struct regressEstimate regEst;
regEst = tableSetregEst(tCtl, ...);

call outputTable(tCtl, regEst);
```

**Modern:**
```gauss
struct ptModel mdl;
mdl = ptModelFrom("OLS Results", out);   -- out is e.g. an olsmtOut struct
mdl = ptModelSetDigits(mdl, 3);

struct ptTable tbl;
tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "OLS Results");

call ptExport(tbl, "ols_table.xlsx");
```

Where `out` comes directly from a GAUSS estimation command (e.g. `olsmt`, `glm`, `gmm`, `fgls`), so
there is no need to manually populate a `regressEstimate` struct.

## Procedure-by-procedure mapping

| Legacy | Modern equivalent | Notes |
|:------- |:------- |:------- |
| `tableGetDefaults(regType)` + `struct tableControl` | `ptModelCreate(name, estimates, stdErrors)` or `ptModelFrom(name, out)` | `ptModelFrom` builds a `ptModel` directly from a supported estimation output struct; see [ptModelFrom](api/ptModelFrom.md). |
| `tableSetTitle(&tCtl, title)` | `ptSetTitle(tbl, title)` | Title is set on the `ptTable`, after building it with `ptModelTable`/`ptTableFrom`. |
| `tableSetVarNames(&tCtl, varNames)` | `ptModelSetNames(mdl, termNames)` | Adapters (`ptModelFrom`, etc.) populate term names automatically from the estimation output. |
| `tableSetColumnHeaders(&tCtl, colHeaders)` | `ptSetColNames(tbl, colNames)` | For model comparisons, column headers come from each model's `name` (the first argument to `ptModelFrom`/`ptModelCreate`). |
| `tableSetSigFig(&tCtl, sigFig)` | `ptSetDigits(tbl, digits)` / `ptModelSetDigits(mdl, digits)` | Controls decimal places via `sprintf`-based formatting. |
| `tableSetAsterisk(&tCtl, ...)` | `ptSetStars(tbl, cutoffs, symbols)` / `ptNoStars(tbl)` | Significance stars are on by default (`*`/`**`/`***` at the usual cutoffs); use `ptNoStars` to disable, or `ptSetStars` for custom cutoffs/symbols. |
| `tableSetParantheses(&tCtl, paranVars)` / `tableSetBrackets(&tCtl, bracketVars)` | `tbl.fmt.statisticWrapper` (`"paren"` / `"bracket"` / `"none"`, default `"paren"`) | Set directly on the `ptFormat` struct; combine with `ptSetStatRows`/`ptModelSetStatRows` to choose which statistic(s) are wrapped. |
| `tableSetParm(&tCtl, coefficients)` / `tableSetse(&tCtl, se)` | `ptModelCreate(name, estimates, stdErrors)` | Estimates and standard errors are supplied directly when building the model. |
| `tableSetTstat(&tCtl, tstat)` / `tableSetpval(&tCtl, pval)` | `ptModelSetPValues(mdl, pValues)` + `ptModelSetStatRows(mdl, "tstat" $| "pvalue")` | `ptModelSetStatRows` controls which statistic rows render under each coefficient (`se`, `tstat`, `pvalue`, `ci`); confidence intervals also require `ptModelSetCI`. |
| `tableSetStack(&tCtl, stackDir)` | `ptModelCompare(models)` / `ptModelCompareWith(models, opts)` | Aligns multiple models on the union of term names and goodness-of-fit rows; see [ptModelCompare](api/ptModelCompare.md). |
| `tableSetAlignment(&tCtl, alignment)` | `ptSetColAlign(tbl, colAlign)` / `ptModelSetColAlign(mdl, colAlign)` | Currently used by `ptRenderLatex` for the LaTeX `tabular` column spec. |
| `tableSetNotes(&tCtl, note)` | `ptSetNotes(tbl, notes)` / `ptModelSetNotes(mdl, notes)` | Model-level notes are prefixed with the model name when comparing more than one model. |
| `tableSetExport(&tCtl, filename, filetype)` | `ptExport(tbl, fname)` | Format is taken from the file extension; supports `.md`, `.tex`, `.csv`, `.txt`, `.rtf`, `.html`/`.htm`, `.xls`, and (provisionally) `.xlsx` — more formats than the legacy `"XLS"`/`"XLSX"`/`"TXT"` options. |
| `outputTable(tCtl, regEst)` / `createRegEstTable(tCtl, regEst)` | `ptModelTable(mdl)` then `ptExport(tbl, fname)` | `ptModelTable` builds the renderable `ptTable` from a `ptModel`; `ptExport` writes it out. |

## Multiple/comparison tables

The legacy `tableSetStack` direction (`"horizontal"`/`"vertical"`) is replaced by
`ptModelCompare(models)`/`ptModelCompareWith(models, opts)`, which always produces one column per
model and aligns rows on the union of terms and goodness-of-fit statistics — including models with
different regressors, which the legacy stacking did not support directly. Use `ptCompareOptions` (see
[ptModelCompare](api/ptModelCompare.md)) for custom term/GOF ordering, label renaming, and
table-level notes.
