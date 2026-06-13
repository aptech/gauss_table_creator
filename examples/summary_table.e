new;
library pubtable;

x = { 21.0 4.2 12.0 35.0,
      3019.5 777.2 1760.0 4840.0 };

struct ptTable tbl;
tbl = ptTableFromMatrix(x, "MPG" $| "Weight", "Mean" $| "Std. Dev." $| "Min" $| "Max", "Summary Statistics");
tbl = ptSetStubName(tbl, "Variable");

call ptExport(tbl, "summary_table.csv");
call ptExport(tbl, "summary_table.txt");
