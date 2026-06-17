/*
** export_formats.e
**
** Export the same table to every supported format in one pass.
**
** Supported formats:
**   .md / .markdown   Markdown (GFM pipe table)
**   .tex              LaTeX (booktabs)
**   .csv              CSV
**   .txt              Plain text
**   .rtf              RTF (Word-compatible)
**   .html / .htm      HTML table
**   .xls              Excel 97-2003 via SpreadsheetWrite
**   .xlsx             Excel 2007+ (requires compatible GAUSS/Excel stack)
**
** Steps:
**   1. Estimate the model.
**   2. Build a pubtable.
**   3. Call ptExport once per format — the file extension selects the renderer.
*/

new;
library pubtable;

/* Step 1: Estimate */
struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;

out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

/* Step 2: Build table */
tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS Regression");

/* Step 3: Export to all formats */
call ptExport(tbl, "ols_table.md");
call ptExport(tbl, "ols_table.tex");
call ptExport(tbl, "ols_table.csv");
call ptExport(tbl, "ols_table.txt");
call ptExport(tbl, "ols_table.rtf");
call ptExport(tbl, "ols_table.html");
call ptExport(tbl, "ols_table.xls");
call ptExport(tbl, "ols_table.xlsx");
