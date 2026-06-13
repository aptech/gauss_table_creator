new;
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.sdf
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.src

proc (0) = checkStringEqual(actual, expected, label);
    if actual $/= expected;
        errorlog label $+ " failed. Expected '" $+ expected $+ "', got '" $+ actual $+ "'";
        end;
    endif;
endp;

proc (0) = checkScalarEqual(actual, expected, label);
    if actual /= expected;
        errorlog label $+ " failed.";
        end;
    endif;
endp;

struct ptTable tbl;
tbl = ptTableFromMatrix(1.23456, "x", "Model 1", "Demo");

checkStringEqual(tbl.body[1, 1], "1.235", "default numeric formatting");
checkStringEqual(ptFormatNumber(1.2, 3), "1.200", "sprintf fixed decimal formatting");
checkScalarEqual(rows(ptRenderArray(tbl)), 2, "rendered row count");
checkScalarEqual(cols(ptRenderArray(tbl)), 2, "rendered column count");
checkStringEqual(ptFileExt("table.xlsx"), "xlsx", "file extension");

struct ptModel mdl;
mdl = ptModelCreate("Model", 1.2 | 0.4, 0.1 | 0.2);
mdl = ptModelSetNames(mdl, "Constant" $| "x");
mdl = ptModelSetPValues(mdl, 0.004 | 0.08);

tbl = ptModelTable(mdl);
checkStringEqual(tbl.body[1, 1], "1.200**", "significance stars");
checkStringEqual(tbl.body[2, 1], "(0.100)", "standard error wrapper");

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

tbl = ptTableFrom(out);
checkStringEqual(tbl.title, "OLS results", "olsmt struct dispatch");
checkScalarEqual(cols(tbl.body), 1, "olsmt table columns");

print "pubtable tests passed";
