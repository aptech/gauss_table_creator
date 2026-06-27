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

## Journal-style title warning
`ptRenderLatex`, `ptRenderHtml`, and `ptRenderRtf` each print a non-fatal `errorlog`
warning ("pubtable warning: journal-style table has no title. Use ptSetTitle(tbl, ...)
before exporting.") when `tbl.fmt.preset` is `"journal"`/`"journal_booktabs"` and
`tbl.title` is empty, but still return the rendered string. `ptRenderMarkdown`/
`ptRenderCsv`/`ptRenderText` do not check this. See [ptApplyPreset](ptApplyPreset.md).

## Renderer notes

**Markdown** (`ptRenderMarkdown`):
- Column groups (`tbl.colGroups`) render as a pseudo-span row: label in the first column
  of each run, blanks elsewhere.
- Data cells are right-padded (respecting `ptSetColAlign`) so columns line up when the
  raw Markdown source is viewed as plain text, not just after a Markdown renderer
  applies the alignment row. Also reserves a star/wrapper gutter — see below.
- `ptSetColAlign` controls the alignment row (`:---` / `:---:` / `---:`).

**LaTeX** (`ptRenderLatex`):
- Requires `\usepackage{booktabs}` in the document preamble.
- `\multicolumn`/`\cmidrule` used for column groups.
- `ptSetLabel` sets the `\label{}` for cross-referencing.
- `ptSetColAlign` is used directly as the `tabular` column spec string.
- Already renders `booktabs`-style (`\toprule`/`\midrule`/`\bottomrule`, no vertical
  rules) regardless of `fmt.ruleStyle`, so the `"journal_booktabs"` preset changes
  nothing here.
- Table notes (significance note, model notes, `dataLabel`) render as
  `\multicolumn{n}{l}{\footnotesize ...}` rows *inside* the `tabular`, just before
  `\end{tabular}` — not as plain paragraph text after it — so note text wraps to the
  tabular's own rendered width instead of the surrounding page/text width.

**CSV** (`ptRenderCsv`):
- Cell values are quoted if they contain commas.
- Cell styles are ignored.

**Text** (`ptRenderText`):
- Column widths computed from the longest cell in each column.
- `ptSetColAlign` controls `l`/`c`/`r` padding.
- For model/comparison tables (i.e. any table with at least one blank-named stat
  sub-row), reserves a fixed-width trailing "gutter" per column sized to the longest
  configured significance-star symbol, so a coefficient's star suffix (0/1/2
  characters) and its SE/t-stat/p-value/CI row's closing `)`/`]` consume the same
  trailing space — without this, the coefficient's number and its stat row's number
  would land in different columns whenever the star count differs row to row. No-op
  when `fmt.stars` is off or the table has no stat sub-rows (e.g. matrix tables).

**RTF** (`ptRenderRtf`):
- Column groups use `\clmgf`/`\clmrg` cell merges.
- Bold header row; cell styles applied to body cells.
- Suitable for pasting into Microsoft Word.
- Default `fmt.ruleStyle`: every cell gets a full 4-sided grid border (`\clbrdrt`/
  `\clbrdrl`/`\clbrdrb`/`\clbrdrr`). With `fmt.ruleStyle == "booktabs"` (the
  `"journal_booktabs"` preset), only four rules are drawn — a top rule (on the
  column-group row if present, else the header row), a header-bottom rule, a mid-rule
  before the goodness-of-fit block (if any — see `ptGofStartRow`), and a table-bottom
  rule on the last row — with no left/right or other inter-row borders.
- Table notes render as their own single-cell, borderless `\intbl` row, sized to the
  same total width (`\cellx`) as the data table — not as bare `{\i ...}\par` paragraphs
  after the table's last `\row`, which would wrap to the page's full text width in Word.

**HTML** (`ptRenderHtml`):
- Column groups use `colspan` spanning `<th>` elements.
- `ptSetColAlign` adds `style="text-align:..."` to header and data cells. Even when
  `colAlign` is unset, every cell still gets an explicit `text-align` matching the
  stub-left/data-right default used by `ptRenderText`/`ptRenderMarkdown`/`ptRenderLatex`
  (rather than falling back to the browser's own default, which left-aligns `<td>`).
- Cell styles (`bold`, `italic`) wrap text in `<strong>`/`<em>` tags.
- `<table>` always gets `style="border-collapse:collapse;"`, and every `<th>`/`<td>`
  gets `padding:4px 10px;` (merged with any alignment/border styling already on that
  cell), so the default rendering doesn't look loosely/"double" spaced.
- Table notes (significance note, model notes, `dataLabel`) render as a `<tfoot>` row
  per note, each a single `<td colspan="...">` spanning every column — not `<p>` tags
  after `</table>` — so note text stays constrained to the table's own width rather
  than stretching across the page/container.
- Default `fmt.ruleStyle`: no border styling beyond the padding/collapse above. With
  `fmt.ruleStyle == "booktabs"` (the `"journal_booktabs"` preset), inline `border-top`/
  `border-bottom` CSS draws a table-top rule, a header-bottom rule, a mid-rule before the
  goodness-of-fit block (if any), and a table-bottom rule — no column-divider borders.

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
