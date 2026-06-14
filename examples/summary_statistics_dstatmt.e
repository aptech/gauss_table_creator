new;
library pubtable;

struct dstatmtOut dstatOutput;
dstatOutput = dstatmt(getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

struct ptTable tbl;
tbl = ptFromDstatmt(dstatOutput);
tbl = ptSetTitle(tbl, "Summary Statistics");

call ptExport(tbl, "summary_statistics_dstatmt.md");
