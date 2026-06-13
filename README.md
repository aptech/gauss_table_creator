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
- `ptModelCompare(models)` for side-by-side model comparison when models share the same coefficient rows.

Initial automatic adapters:

- `olsmtOut`
- `glmOut`
- `gmmOut` through `ptModelFrom`
- `dstatmtOut`

Initial exporters:

- Markdown: `.md`
- LaTeX: `.tex`
- CSV: `.csv`
- Plain text: `.txt`
- Excel: `.xls` through GAUSS `SpreadsheetWrite`; `.xlsx` is attempted through the same route where supported by the local GAUSS/Excel stack
- Word-compatible rich text: `.rtf`

True `.docx` export is not part of the first version because it requires generating zipped Office Open XML. The practical Word path for now is `.rtf`, with `.html` and true `.docx` good candidates for a later exporter phase.

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
Modern examples are in `examples/model_table_ols.e`, `examples/model_comparison.e`, and `examples/summary_table.e`. Older `tableSet*.e` examples are retained as legacy references.

## Authors
*  Erica Clower - [Aptech Systems, Inc](www.aptech.com)
