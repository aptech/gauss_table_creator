# ptModelTable

## Purpose
> Render a `ptModel` into a `ptTable` ready for export. Produces a standard
> coefficient table: one row per term (with optional statistic rows below each
> coefficient), followed by goodness-of-fit rows.

## Format
> tbl = ptModelTable(mdl)

## Input
| Parameter | Description |
|:------- |:------- |
| mdl | `ptModel` struct, built with `ptModelCreate`, `ptModelFrom`, or an explicit adapter. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` struct. `rowNames` contains the term labels (plus blank labels for statistic rows and GOF row labels). `body` is a pre-formatted string-array matrix with one body column. `tbl.notes` contains the significance-symbol note (if stars are enabled) and any model notes set via `ptModelSetNotes`. |

## Table structure
For a model with K terms and S statistic rows per term, the body has:
- `K × (1 + S)` coefficient rows — coefficient cell followed by `S` statistic rows.
- Then one row per goodness-of-fit statistic (if `mdl.gofNames` is non-empty).

The coefficient cell contains the formatted estimate plus significance stars (if enabled
and p-values are set). Statistic rows are controlled by `mdl.fmt.statRows`:

| `statRows` value | Content |
|:------- |:------- |
| `"se"` | Standard error in parentheses (or plain, depending on `statisticWrapper`). |
| `"tstat"` | t-statistic in parentheses. |
| `"pvalue"` | p-value in parentheses. |
| `"ci"` | Confidence interval `[lower, upper]` (requires `ptModelSetCI` first). |

## Notes
- For side-by-side model comparisons, use `ptModelCompare` or `ptModelCompareWith`
  instead of `ptModelTable`.
- After calling `ptModelTable`, use `ptSet*` table setters to add a title, notes, or
  other table-level settings before exporting.

## Example
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

mdl = ptModelFrom("", out);
mdl = ptModelSetStatRows(mdl, "se" $| "pvalue");
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "OLS Regression");

call ptExport(tbl, "ols_table.md");
```

## See Also
`ptModelFrom`, `ptModelCreate`, `ptModelSetStatRows`, `ptModelSetCI`, `ptModelCompare`, `ptExport`
