![gauss tables](images/table_shot_one.png)

# GAUSS Table Creator
This package provides tools for creating and exporting publication-quality tables in GAUSS. The modern `pubtable` API is designed for coefficient tables, model comparison tables, summary/statistics tables, and custom matrix/data tables.

Legacy `tableControl` and `tableSet` files are retained for migration experiments, but new work should use the `pubtable` API.

## Modern `pubtable` API

The package now includes an early `pubtable` API for GAUSS-first publication tables. It keeps table construction, formatting, and export separate, and includes convenience adapters for common GAUSS output structures.

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
call ptExport(tbl, "ols_table.tex");
call ptExport(tbl, "ols_table.xlsx");
call ptExport(tbl, "ols_table.rtf");
```

Supported table sources in this first version:

- `ptTableFromMatrix(x, rowNames, colNames, title)` for custom matrix tables.
- `ptTableFrom(out)` for automatic dispatch using `isStructType`.
- `ptModelFrom(name, out)` for typed model adapters.
- `ptModelCompare(models)` for side-by-side model comparison, aligning on the union of term and goodness-of-fit row names across models with different regressors.

Coefficient tables show one statistic row per term (standard errors by default). Use `ptModelSetStatRows(model, statRows)` (or `ptSetStatRows(tbl, statRows)`) to choose any combination of `"se"`, `"tstat"`, `"pvalue"`, and `"ci"`; confidence intervals require calling `ptModelSetCI(model, ciLower, ciUpper)` first.

For more control over model comparisons, build a `ptCompareOptions` struct with `ptCompareOptionsCreate()` and pass it to `ptModelCompareWith(models, opts)`:

- `ptCompareSetTermOrder(opts, termOrder)` puts the listed terms first, in that order, with any remaining terms appended afterward.
- `ptCompareSetGofOrder(opts, gofOrder)` does the same for goodness-of-fit rows.
- `ptCompareSetLabelMap(opts, mapFrom, mapTo)` renames term row labels for display (e.g. `"Constant"` to `"(Intercept)"`) without affecting how terms are matched across models.
- `ptCompareSetNotes(opts, notes)` adds table-level notes. Per-model notes set with `ptModelSetNotes(model, notes)` are also included, prefixed with the model name when comparing more than one model.

`ptModelCompare(models)` is shorthand for `ptModelCompareWith(models, ptCompareOptionsCreate())`.

Initial automatic adapters:

- `olsmtOut`
- `glmOut`
- `gmmOut` through `ptModelFrom`
- `dstatmtOut`
- `fglsOut`

Optional add-on package adapters (not wired into `ptModelFrom`/`ptTableFrom`, since they require packages that may not be installed):

- `maxlikmtResults`: `ptModelFromMaxlikmt`/`ptFromMaxlikmt` in `src/pubtable_maxlikmt.src`. Requires `library maxlikmt;` and `#include maxlikmt.sdf` before including this file.
- `cmlmtResults`: `ptModelFromCmlmt`/`ptFromCmlmt` in `src/pubtable_cmlmt.src`. Requires `library cmlmt;` and `#include cmlmt.sdf` before including this file.
- `arimamtOut` and `tsPanelEstimationOut`: `ptModelFromArimamt`/`ptFromArimamt` and `ptModelFromTsPanel`/`ptFromTsPanel` in `src/pubtable_tsmt.src`. Requires `library tsmt;` and `#include tsmt.sdf` before including this file; `tsPanelEstimationOut` adapters also require `#include tspanel.src` from the tsmt package.
- `optmtResults`: `ptTableFromOptmt` in `src/pubtable_optmt.src` builds a parameter/estimate/gradient table (no standard errors, since `optmtResults` has no covariance matrix). Requires `library optmt;` and `#include optmt.sdf` before including this file.

Initial exporters:

- Markdown: `.md`
- LaTeX: `.tex`
- CSV: `.csv`
- Plain text: `.txt`
- Excel: `.xls` through GAUSS `SpreadsheetWrite`; `.xlsx` is attempted through the same route where supported by the local GAUSS/Excel stack
- Word-compatible rich text: `.rtf` (rendered as a real RTF table with borders and a bold header row, not just tab-separated text)
- HTML: `.html`/`.htm`

True `.docx` export is not part of the first version because it requires generating zipped Office Open XML. The practical Word path for now is `.rtf`/`.html`, with true `.docx` a candidate for a later exporter phase.

### LaTeX options

`ptRenderLatex` (and `ptExport(tbl, "*.tex")`) support a few additional `ptFormat` options:

- `ptSetLabel(tbl, "tab:my-table")` / `ptModelSetLabel(mdl, "tab:my-table")` adds a `\label{...}` after `\caption{...}`.
- `ptSetColAlign(tbl, "lcr")` / `ptModelSetColAlign(mdl, "lcr")` overrides the default column alignment (`l` for the stub column, `r` for data columns). The string must contain one `l`/`c`/`r` character per column, including the stub column.

## Getting Started
### Prerequisites
The program files require a working copy of **GAUSS**. The modern `pubtable` API is currently tested with GAUSS 26.

### Installing
**GAUSS 20+**
The package can be installed and updated directly in GAUSS using the [GAUSS package manager](https://www.aptech.com/blog/gauss-package-manager-basics/) once packaged as `pubtable`.

**GAUSS 18+**
Older application-wizard installation is retained as a provisional legacy workflow. If packaging this repository manually, use the `pubtable` manifest and source files:

1. Zip the package as `pubtable.zip`.
2. Select **Tools > Install Application** from the main GAUSS menu.
![install wizard](images/install_application.png)
3. Follow the installer prompts, making sure to navigate to the downloaded `pubtable.zip`.
4. Before using the package, load the `pubtable` library:
  *   Navigate to the library tool view window and click the small wrench located next to the `pubtable` library. Select `Load Library`.
  ![load library](images/load_library.png)
  *  Enter `library pubtable` in the program input/output window.
  *  Put the line `library pubtable;` at the beginning of your program files.

Note: this installation section is provisional while the package is being modernized.

### Examples
Modern examples are in `examples/model_table_ols.e`, `examples/model_comparison.e`, `examples/summary_table.e`, `examples/summary_statistics_dstatmt.e`, and `examples/export_formats.e`. Older `tableSet*.e` examples are retained as legacy references.

### Further documentation
- [docs/README.md](docs/README.md): documentation index, including a command reference for the modern API in `docs/api/`.
- [docs/migration.md](docs/migration.md): mapping from the legacy `tableControl`/`tableSet...`/`outputTable` workflow to the modern `pt*` API.

## Authors
*  Erica Clower - [Aptech Systems, Inc](www.aptech.com)
