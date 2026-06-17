# ptExportAll / ptExportAllFormats

## Purpose
> Export an array of `ptTable` structs to a single file (`ptExportAll`) or to multiple
> formats in one call (`ptExportAllFormats`).

## Format
> ret = ptExportAll(tables, fname)
> ret = ptExportAllFormats(tables, basename, exts)

## Input

### ptExportAll
| Parameter | Description |
|:------- |:------- |
| tables | `ptTable` struct array (e.g. built with `reshape` and indexed assignment). |
| fname | String, output file path. Extension selects format, same as `ptExport`. |

### ptExportAllFormats
| Parameter | Description |
|:------- |:------- |
| tables | `ptTable` struct array. |
| basename | String, file path without extension (e.g. `"results/tables"`). |
| exts | String-array column vector of extensions without dots (e.g. `"md" $| "tex" $| "html"`). |

## Output
| Output | Description |
|:------- |:------- |
| ret | Scalar return code. `0` if all exports succeeded. For `ptExportAllFormats`, the return code of the first format that failed (remaining formats are still attempted). |

## Format-specific behaviour (ptExportAll)

| Extension | Behaviour |
|:------- |:------- |
| `.md` | Tables concatenated with `\n---\n` horizontal rule separators. |
| `.tex` | Tables concatenated with `\n` between them. |
| `.csv` | Tables concatenated with `\n` between them. |
| `.txt` | Tables concatenated with `\n` between them. |
| `.html` / `.htm` | Tables concatenated with `\n` between them. |
| `.rtf` | Tables merged into one `{\rtf1…}` document (RTF headers/footers stripped between tables). |
| `.xls` / `.xlsx` | Each table written to its own sheet. |

## Example — ptExportAll
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out1, out2;
ctl = olsmtControlCreate;
ctl.output = 0;
out1 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight");
out2 = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

tbl1 = ptTableFrom(out1);
tbl1 = ptSetTitle(tbl1, "Model 1");
tbl2 = ptTableFrom(out2);
tbl2 = ptSetTitle(tbl2, "Model 2");

struct ptTable tbls;
tbls = reshape(tbl1, 2, 1);
tbls[2] = tbl2;

call ptExportAll(tbls, "all_tables.md");
call ptExportAll(tbls, "all_tables.html");
call ptExportAll(tbls, "all_tables.xls");
```

## Example — ptExportAllFormats
```gauss
/* Export the same struct array to four formats in one call */
call ptExportAllFormats(tbls, "results/tables", "md" $| "tex" $| "html" $| "csv");
```

## See Also
`ptExport`, `ptTableFrom`, `ptModelCompare`, `ptRenderMarkdown`
