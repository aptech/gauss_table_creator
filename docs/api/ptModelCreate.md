# ptModelCreate

## Purpose
> Create a `ptModel` struct from coefficient estimates and standard errors. The low-level
> constructor used when building a model manually rather than from a GAUSS estimation
> output struct.

## Format
> mdl = ptModelCreate(name, estimates, stdErrors)

## Input
| Parameter | Description |
|:------- |:------- |
| name | String, the display name for this model (used as the column header in comparison tables, or `""` for single-model tables). |
| estimates | Numeric column vector, the coefficient point estimates. |
| stdErrors | Numeric column vector, the standard errors, same length as `estimates`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` struct. `termNames` defaults to `"x1"`, `"x2"`, … `"xK"`. `pValues` are initialised to missing (no stars rendered until set). `ciLower`/`ciUpper` initialised to missing. `gofNames`/`gofValues` are empty. |

## Notes
- After creating a model, use `ptModelSetNames` to set term labels, `ptModelSetPValues`
  to enable significance stars, `ptModelSetGOF` to add goodness-of-fit rows, and
  `ptModelSetCI` to store confidence intervals.
- For models from GAUSS estimation commands, prefer `ptModelFrom` or the explicit
  adapters (`ptModelFromOlsmt`, etc.) which populate all fields automatically.

## Example
```gauss
new;
library pubtable;

/* Build a model manually from stored results */
coef = 47.0 | -0.006 | -0.074;
se   =  4.71 |  0.001 |  0.054;

mdl = ptModelCreate("OLS", coef, se);
mdl = ptModelSetNames(mdl, "Constant" $| "weight" $| "length");
mdl = ptModelSetPValues(mdl, 0.000 | 0.000 | 0.170);
mdl = ptModelSetGOF(mdl, "N" $| "R-squared", 74 | 0.668);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "OLS Regression");

call ptExport(tbl, "manual_model.md");
```

## See Also
`ptModelFrom`, `ptModelSetNames`, `ptModelSetPValues`, `ptModelSetGOF`, `ptModelSetCI`, `ptModelTable`
