# ptTable Setters

Procedures that modify individual fields of a `ptTable` struct. Every setter takes a
`ptTable` as its first argument and returns a new (modified) `ptTable`; chain them to
apply several changes.

## Format summary

| Procedure | Description |
|:------- |:------- |
| `ptSetTitle(tbl, title)` | Set the table title string. |
| `ptSetStubName(tbl, stubName)` | Set the stub-column header (the label above the row-name column). |
| `ptSetRowNames(tbl, rowNames)` | Set the row-label column as a string array. Must match `rows(tbl.body)`. |
| `ptSetColNames(tbl, colNames)` | Set the column-header row as a string array. Must match `cols(tbl.body)`. |
| `ptSetColGroups(tbl, colGroups)` | Set spanning column-group headers, one per body column. Contiguous identical labels form a span. |
| `ptSetBody(tbl, body)` | Replace the pre-formatted string-array body of the table. |
| `ptSetNotes(tbl, notes)` | Set the table notes string (appended below the table by all exporters). |
| `ptSetDigits(tbl, digits)` | Set the default decimal-digit count (0–12). Affects subsequent `ptFormatNumber` calls but does not re-format an existing body. |
| `ptSetStars(tbl, cutoffs, symbols)` | Enable significance stars; `cutoffs` and `symbols` are parallel column vectors. |
| `ptNoStars(tbl)` | Disable significance stars. |
| `ptSetLabel(tbl, label)` | Set the LaTeX `\label{}` string used by `ptRenderLatex`. |
| `ptSetColAlign(tbl, colAlign)` | Set column alignment as a string of `l`/`c`/`r` characters, one per column including the stub. Affects all renderers. |
| `ptSetColFormat(tbl, colDigits)` | Re-format already-rendered numeric body cells column by column; `colDigits` is a string array of integer digit counts (`""` leaves a column unchanged). |
| `ptSetCellStyle(tbl, row, col, style)` | Apply a style (`"bold"`, `"italic"`, `"bold italic"`, or `""`) to an individual body cell. |
| `ptSetStatRows(tbl, statRows)` | Set which statistic rows appear under each coefficient in tables produced by `ptModelTable`/`ptModelCompare` (use on a pre-built `ptTable` to change stat rows after the fact). |
| `ptApplyPreset(tbl, preset)` | Apply a named style preset to the table's format. See `ptApplyPreset`. |

## Inputs (common)

| Parameter | Description |
|:------- |:------- |
| tbl | `ptTable` struct to modify. |
| (second parameter) | The new value to set; type varies by setter (see Format summary). |

## Output

| Output | Description |
|:------- |:------- |
| tbl | Modified `ptTable` struct. |

## ptSetStars details
`cutoffs` is a numeric column vector of p-value thresholds (e.g. `0.10 | 0.05 | 0.01`);
`symbols` is a string-array column vector of the same length (e.g. `"+" $| "*" $| "**"`).
Stars are appended to the coefficient cell when `p <= cutoff`. Only the most significant
applicable symbol is used.

## ptSetColAlign details
`colAlign` is a string where each character specifies alignment for one column. The first
character is the stub column; remaining characters are the body columns. Example: `"lrrr"`
for a table with a stub column and three right-aligned data columns.

## ptSetColFormat details
Re-parses each cell with `strtof` and re-formats it with `ptFormatNumber`. Only works
cleanly on plain numeric cells — cells that already contain stars or statistic parentheses
may produce unexpected output.

## ptSetCellStyle details
Valid style strings: `"bold"`, `"italic"`, `"bold italic"`, `""` (no style). CSV and
plain-text renderers ignore `cellStyle`. Row and column indices are 1-based and must be
within the body dimensions.

## ptSetStatRows details
`statRows` is a string-array column vector containing one or more of `"se"`, `"tstat"`,
`"pvalue"`, `"ci"`. The `"ci"` row requires confidence intervals to have been set via
`ptModelSetCI` before the table was built. Default is `"se"`.

## Example
```gauss
new;
library pubtable;

tbl = ptTableFromMatrix(seqm(1,2,4) ~ seqm(1,2,4).^0.5, "a" $| "b" $| "c" $| "d", "Value" $| "Sqrt", "Demo");

/* Chain setters */
tbl = ptSetStubName(tbl, "Row");
tbl = ptSetColAlign(tbl, "lrr");
tbl = ptSetNotes(tbl, "Generated example.");
tbl = ptSetDigits(tbl, 2);
tbl = ptSetCellStyle(tbl, 1, 1, "bold");
tbl = ptSetStars(tbl, 0.05 | 0.01, "*" $| "**");

call ptExport(tbl, "demo.md");
```

## See Also
`ptTableCreate`, `ptTableFromMatrix`, `ptApplyPreset`, `ptModelTable`, `ptExport`
