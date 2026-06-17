# ptModel Setters

Procedures that modify individual fields of a `ptModel` struct. Every setter takes a
`ptModel` as its first argument and returns a new (modified) `ptModel`; chain them to
apply several changes before passing the model to `ptModelTable` or `ptModelCompare`.

## Format summary

| Procedure | Description |
|:------- |:------- |
| `ptModelSetNames(mdl, termNames)` | Set the term (row) label string array; one label per coefficient. |
| `ptModelSetPValues(mdl, pValues)` | Set the p-value column vector used for significance stars. |
| `ptModelSetGOF(mdl, gofNames, gofValues)` | Set goodness-of-fit rows appended below coefficients. |
| `ptModelSetDigits(mdl, digits)` | Set the decimal-digit count (0–12) for formatting coefficients and statistics. |
| `ptModelSetLabel(mdl, label)` | Set the LaTeX `\label{}` string for `ptRenderLatex`. |
| `ptModelSetStars(mdl, cutoffs, symbols)` | Enable significance stars with custom thresholds and symbols. |
| `ptModelNoStars(mdl)` | Disable significance stars. |
| `ptModelSetColAlign(mdl, colAlign)` | Set column alignment (`l`/`c`/`r` characters). |
| `ptModelSetCI(mdl, ciLower, ciUpper)` | Set confidence-interval bounds (required for `"ci"` statistic row). |
| `ptModelSetStatRows(mdl, statRows)` | Choose which statistic rows appear under each coefficient. |
| `ptModelSetNotes(mdl, notes)` | Set the model notes string appended in the final table. |
| `ptModelApplyPreset(mdl, preset)` | Apply a named style preset. See `ptApplyPreset`. |

## Inputs (common)

| Parameter | Description |
|:------- |:------- |
| mdl | `ptModel` struct to modify. |
| (second/third parameters) | The new value(s) to set; types vary by setter (see details below). |

## Output

| Output | Description |
|:------- |:------- |
| mdl | Modified `ptModel` struct. |

## ptModelSetNames
`termNames` — string-array column vector, one entry per coefficient in `mdl.estimates`.

## ptModelSetPValues
`pValues` — numeric column vector matching `mdl.estimates` in length. Stars are
rendered only when p-values are set and `mdl.fmt.stars == 1`.

## ptModelSetGOF
`gofNames` — string-array column vector of row labels.
`gofValues` — numeric column vector of the same length. Rows are appended below the
coefficient block in the rendered table. Values are formatted with `mdl.fmt.digits`
unless they are integral (integer-valued cells render without a decimal point).

## ptModelSetDigits
`digits` — scalar integer 0–12. Default is 3.

## ptModelSetStars
`cutoffs` — numeric column vector of p-value thresholds (ascending or descending order,
lowest threshold gets the strongest symbol; e.g. `0.10 | 0.05 | 0.01`).
`symbols` — string-array column vector of the same length (e.g. `"+" $| "*" $| "**"`).

## ptModelSetCI
`ciLower` — numeric column vector, same length as `mdl.estimates`.
`ciUpper` — numeric column vector, same length as `mdl.estimates`.
Must be set before using `"ci"` in `ptModelSetStatRows`.

## ptModelSetStatRows
`statRows` — string-array column vector; each entry is one of `"se"`, `"tstat"`,
`"pvalue"`, `"ci"`. More than one entry adds multiple rows per coefficient.
Default is `"se"`.

## ptModelSetColAlign
`colAlign` — string of `l`/`c`/`r` characters. For single-model tables the stub
plus one data column means a two-character string (e.g. `"lr"`). For comparison
tables the string must cover the stub plus all model columns.

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

/* Show t-statistics and confidence intervals instead of SE */
mdl = ptModelSetCI(mdl, out.b - 1.96 .* out.stderr, out.b + 1.96 .* out.stderr);
mdl = ptModelSetStatRows(mdl, "tstat" $| "ci");

/* Stricter stars */
mdl = ptModelSetStars(mdl, 0.05 | 0.01 | 0.001, "*" $| "**" $| "***");
mdl = ptModelSetDigits(mdl, 4);
mdl = ptModelSetNotes(mdl, "95% CI in brackets. Dependent variable: mpg.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "OLS with CI");

call ptExport(tbl, "ols_ci.md");
```

## See Also
`ptModelCreate`, `ptModelFrom`, `ptModelTable`, `ptModelCompare`, `ptApplyPreset`
