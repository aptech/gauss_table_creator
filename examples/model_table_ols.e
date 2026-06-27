/*
** model_table_ols.e
**
** Quickstart: OLS regression to publication table.
**
** Steps:
**   1. Estimate the model with olsmt.
**   2. Convert the result to a pubtable with ptTableFrom.
**   3. Set the table title.
**   4. Export to Markdown, LaTeX, and Excel.
*/

new;
library pubtable;

/* Step 1: Estimate the model */
fname = getGAUSSHome() $+ "examples/auto.dat";
out = olsmt(fname, "mpg ~ weight + length");

/* Step 2 & 3: Build and title the table.
** pubtable procs declare their return types, so no 'struct ptTable tbl'
** declaration is needed here. */
tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS: Fuel Efficiency");

/* Step 4: Export */
call ptExport(tbl, "ols_table.md");
call ptExport(tbl, "ols_table.tex");
call ptExport(tbl, "ols_table.xlsx");
