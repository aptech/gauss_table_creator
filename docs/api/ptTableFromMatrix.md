# ptTableFromMatrix

## Purpose
> Build a `ptTable` from a matrix of values plus row and column labels. Used for custom matrix/data
> tables and summary-statistics tables (see `ptFromDstatmt`).

## Format
> tbl = ptTableFromMatrix(x, rowNames, colNames, title)

## Input
| Option | Description |
|:------- |:------- |
| x | Matrix, the table body values. |
| rowNames | String or string array, one label per row of `x`. |
| colNames | String or string array, one label per column of `x`. |
| title | String, the table title. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` struct with `body` formatted using the default digit precision (`ptFormat.digits`), `rowNames`/`colNames` set, and `title` set. |

## Example
```gauss
new;
library pubtable;

x = { 21.0 4.2 12.0 35.0,
      3019.5 777.2 1760.0 4840.0 };

struct ptTable tbl;
tbl = ptTableFromMatrix(x, "MPG" $| "Weight", "Mean" $| "Std. Dev." $| "Min" $| "Max", "Summary Statistics");
tbl = ptSetStubName(tbl, "Variable");

call ptExport(tbl, "summary_table.csv");
```

## See Also
`ptSetStubName`, `ptSetDigits`, `ptSetTitle`, `ptTableFrom`, `ptExport`
