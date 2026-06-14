new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;

out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

struct ptTable tbl;
tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS Regression");

call ptExport(tbl, "ols_table.md");
call ptExport(tbl, "ols_table.tex");
call ptExport(tbl, "ols_table.csv");
call ptExport(tbl, "ols_table.txt");
call ptExport(tbl, "ols_table.rtf");
call ptExport(tbl, "ols_table.html");
call ptExport(tbl, "ols_table.xls");
call ptExport(tbl, "ols_table.xlsx");
