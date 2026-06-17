new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;

fname = getGAUSSHome() $+ "examples/auto.dat";
out = olsmt(ctl, fname, "mpg ~ weight + length");

tbl = ptTableFrom(out);
tbl = ptSetTitle(tbl, "OLS Regression");

call ptExport(tbl, "ols_table.md");
call ptExport(tbl, "ols_table.tex");
call ptExport(tbl, "ols_table.xlsx");
