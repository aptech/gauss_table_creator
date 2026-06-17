# ptRender — Format-specific renderers

Procedures that convert a `ptTable` to a formatted string in a specific output format.
These are called internally by `ptExport`; call them directly when you need the
rendered string rather than a file.

## Format summary

| Procedure | Returns |
|:------- |:------- |
| `ptRenderMarkdown(tbl)` | GFM pipe-table string with alignment row (`:---`, `---:`, `:---:`). |
| `ptRenderLatex(tbl)` | `booktabs`-style LaTeX `tabular` environment. |
| `ptRenderCsv(tbl)` | Comma-separated values, one row per line. |
| `ptRenderText(tbl)` | Fixed-width plain text with computed column widths. |
| `ptRenderRtf(tbl)` | RTF document fragment (`{\rtf1…}`) with grid borders and a bold header row. |
| `ptRenderHtml(tbl)` | HTML `<table>` with `<caption>`, `<thead>`, and `<tbody>`. |

## Format
> text = ptRenderMarkdown(tbl)
> text = ptRenderLatex(tbl)
> text = ptRenderCsv(tbl)
> text = ptRenderText(tbl)
> text = ptRenderRtf(tbl)
> text = ptRenderHtml(tbl)

## Input
| Parameter | Description |
|:------- |:------- |
| tbl | `ptTable` struct produced by `ptTableCreate`, `ptTableFromMatrix`, `ptModelTable`, `ptModelCompare`, or `ptModelCompareWith`. |

## Output
| Output | Description |
|:------- |:------- |
| text | String containing the rendered table. |

## Renderer notes

**Markdown** (`ptRenderMarkdown`):
- Column groups (`tbl.colGroups`) render as a pseudo-span row: label in the first column
  of each run, blanks elsewhere.
- `ptSetColAlign` controls the alignment row (`:---` / `:---:` / `---:`).

**LaTeX** (`ptRenderLatex`):
- Requires `\usepackage{booktabs}` in the document preamble.
- `\multicolumn`/`\cmidrule` used for column groups.
- `ptSetLabel` sets the `\label{}` for cross-referencing.
- `ptSetColAlign` is used directly as the `tabular` column spec string.

**CSV** (`ptRenderCsv`):
- Cell values are quoted if they contain commas.
- Cell styles are ignored.

**Text** (`ptRenderText`):
- Column widths computed from the longest cell in each column.
- `ptSetColAlign` controls `l`/`c`/`r` padding.

**RTF** (`ptRenderRtf`):
- Column groups use `\clmgf`/`\clmrg` cell merges.
- Bold header row; cell styles applied to body cells.
- Suitable for pasting into Microsoft Word.

**HTML** (`ptRenderHtml`):
- Column groups use `colspan` spanning `<th>` elements.
- `ptSetColAlign` adds `style="text-align:..."` to header and data cells.
- Cell styles (`bold`, `italic`) wrap text in `<strong>`/`<em>` tags.

## Example — capture output without writing a file
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS Regression");

/* Render to string */
mdText  = ptRenderMarkdown(tbl);
latText = ptRenderLatex(tbl);

/* Print or process the string */
print mdText;
```

## Example — call via ptExport (preferred)
```gauss
call ptExport(tbl, "output.md");   /* calls ptRenderMarkdown internally */
call ptExport(tbl, "output.tex");  /* calls ptRenderLatex   internally */
call ptExport(tbl, "output.html"); /* calls ptRenderHtml    internally */
```

## See Also
`ptExport`, `ptExportAll`, `ptSetColAlign`, `ptSetLabel`, `ptSetColGroups`
