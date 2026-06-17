# ptTableCreate

## Purpose
> Create an empty `ptTable` struct with a title and all other fields blank. The starting
> point for building a table manually from row names, column names, and a pre-formatted
> body string array.

## Format
> tbl = ptTableCreate(title)

## Input
| Parameter | Description |
|:------- |:------- |
| title | String, the table title rendered above the table by all exporters. Pass `""` for no title. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` struct with `title` set and all other members blank. `tbl.fmt` is initialised to the default `ptFormat` (3 digits, `+`/`*`/`**` stars, SE in parentheses). |

## Notes
- For tables built from a numeric matrix use `ptTableFromMatrix`, which fills `rowNames`,
  `colNames`, and `body` in one call.
- Use the `ptSet*` family of setters to populate members one at a time after `ptTableCreate`.
- The minimum a table needs to be exported is a non-empty `body` and at least one entry
  in `colNames`.

## Example
```gauss
new;
library pubtable;

tbl = ptTableCreate("Coefficient Estimates");
tbl = ptSetColNames(tbl, "Estimate" $| "Std. Error" $| "p-value");
tbl = ptSetRowNames(tbl, "Constant" $| "weight" $| "length");
tbl = ptSetBody(tbl, "47.0" ~ "4.71" ~ "0.000" $|
                     "-0.006" ~ "0.001" ~ "0.000" $|
                     "-0.074" ~ "0.054" ~ "0.170");
tbl = ptSetNotes(tbl, "Standard errors computed by OLS.");

call ptExport(tbl, "manual_table.md");
```

## See Also
`ptTableFromMatrix`, `ptSetTitle`, `ptSetBody`, `ptSetColNames`, `ptSetRowNames`, `ptExport`
