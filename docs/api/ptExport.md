# ptExport

## Purpose
> Render a `ptTable` and write it to a file, choosing the rendering format from the file
> extension in `fname`.

## Format
> ret = ptExport(tbl, fname)

## Input
| Option | Description |
|:------- |:------- |
| tbl | `ptTable` struct to export. |
| fname | String, output file path. The extension (case-insensitive) selects the export format. |

## Output
| Output | Description |
|:------- |:------- |
| ret | Scalar return code. `0` on success. For `.xls`/`.xlsx`, `ret` is the (possibly trapped) return value of `SpreadsheetWrite`; a missing value indicates a trapped write error. |

## Supported extensions
| Extension | Renderer | Notes |
|:------- |:------- |:------- |
| `.md` | `ptRenderMarkdown` | Pipe-delimited Markdown table. |
| `.tex` | `ptRenderLatex` | `booktabs`-style LaTeX table; supports `ptSetLabel`/`ptSetColAlign`. |
| `.csv` | `ptRenderCsv` | Comma-separated values. |
| `.txt` (or any other/unrecognized extension) | `ptRenderText` | Fixed-width plain text with computed column widths. |
| `.rtf` | `ptRenderRtf` | RTF table with grid borders and a bold header row, for Word. |
| `.html` / `.htm` | `ptRenderHtml` | HTML `<table>` with `<caption>`/`<thead>`/`<tbody>`. |
| `.xls` / `.xlsx` | `SpreadsheetWrite` | `.xlsx` support is provisional and depends on the local GAUSS/Excel stack. |

## Example
```gauss
new;
library pubtable;

struct ptTable tbl;
tbl = ptTableFromMatrix(1.23 | 4.56, "row1" $| "row2", "Value", "Demo");

call ptExport(tbl, "demo.md");
call ptExport(tbl, "demo.tex");
call ptExport(tbl, "demo.csv");
call ptExport(tbl, "demo.txt");
call ptExport(tbl, "demo.rtf");
call ptExport(tbl, "demo.html");

ret = ptExport(tbl, "demo.xlsx");
if scalmiss(ret);
    print "xlsx export failed";
endif;
```

## See Also
`ptRenderMarkdown`, `ptRenderLatex`, `ptRenderCsv`, `ptRenderText`, `ptRenderRtf`, `ptRenderHtml`
