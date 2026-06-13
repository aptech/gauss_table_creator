new;
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.sdf
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.src

proc (0) = checkStringEqual(actual, expected, label);
    if actual $/= expected;
        errorlog label $+ " failed. Expected '" $+ expected $+ "', got '" $+ actual $+ "'";
        end;
    endif;
endp;

proc (0) = checkStringContains(actual, expected, label);
    if strindx(actual, expected) == 0;
        errorlog label $+ " failed. Expected to find '" $+ expected $+ "'";
        end;
    endif;
endp;

proc (0) = checkScalarEqual(actual, expected, label);
    if actual /= expected;
        errorlog label $+ " failed.";
        end;
    endif;
endp;

proc (0) = checkScalarNotMissing(actual, label);
    if scalmiss(actual);
        errorlog label $+ " failed. Got scalar missing.";
        end;
    endif;
endp;

struct ptTable tbl;
tbl = ptTableFromMatrix(1.23456, "x", "Model 1", "Demo_table");

checkStringEqual(tbl.body[1, 1], "1.235", "default numeric formatting");
checkStringEqual(ptFormatNumber(1.2, 3), "1.200", "sprintf fixed decimal formatting");
checkScalarEqual(rows(ptRenderArray(tbl)), 2, "rendered row count");
checkScalarEqual(cols(ptRenderArray(tbl)), 2, "rendered column count");
checkStringEqual(ptFileExt("table.xlsx"), "xlsx", "file extension");
checkStringEqual(ptFileExt("table"), "", "missing file extension");

checkStringContains(ptRenderMarkdown(tbl), "# Demo_table", "markdown title");
checkStringContains(ptRenderMarkdown(tbl), "|Model 1", "markdown column header");
checkStringContains(ptRenderLatex(tbl), "\\caption{Demo\\_table}", "latex escaped title");
checkStringContains(ptRenderCsv(tbl), "Model 1", "csv header");
checkStringContains(ptRenderText(tbl), "Demo_table", "text title");
checkStringContains(ptRenderRtf(tbl), "{\\rtf1\\ansi", "rtf header");

struct ptModel mdl;
mdl = ptModelCreate("Model", 1.2 | 0.4, 0.1 | 0.2);
mdl = ptModelSetNames(mdl, "Constant" $| "x");
mdl = ptModelSetPValues(mdl, 0.004 | 0.08);

tbl = ptModelTable(mdl);
checkStringEqual(tbl.body[1, 1], "1.200**", "significance stars");
checkStringEqual(tbl.body[2, 1], "(0.100)", "standard error wrapper");

struct ptModel mdl2;
mdl2 = ptModelCreate("Model2", 0.8 | 0.5, 0.05 | 0.3);
mdl2 = ptModelSetNames(mdl2, "Constant" $| "z");
mdl2 = ptModelSetGOF(mdl2, "N" $| "R2", 100 | 0.5);

struct ptModel cmpModels;
cmpModels = reshape(mdl, 2, 1);
cmpModels[2] = mdl2;

struct ptTable cmpTbl;
cmpTbl = ptModelCompare(cmpModels);

checkScalarEqual(rows(cmpTbl.body), 8, "model comparison row count for unioned terms");
checkScalarEqual(cols(cmpTbl.body), 2, "model comparison column count");
checkStringEqual(cmpTbl.rowNames[1], "Constant", "model comparison shared term row");
checkStringEqual(cmpTbl.rowNames[3], "x", "model comparison term unique to first model");
checkStringEqual(cmpTbl.rowNames[5], "z", "model comparison term unique to second model");
checkStringEqual(cmpTbl.rowNames[7], "N", "model comparison GOF row from second model");
checkStringEqual(cmpTbl.body[3, 2], "", "blank cell for term missing from second model");
checkStringEqual(cmpTbl.body[5, 1], "", "blank cell for term missing from first model");
checkStringEqual(cmpTbl.body[7, 1], "", "blank cell for GOF missing from first model");
checkStringEqual(cmpTbl.body[7, 2], "100.000", "GOF value present for second model");

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

tbl = ptTableFrom(out);
checkStringEqual(tbl.title, "OLS results", "olsmt struct dispatch");
checkScalarEqual(cols(tbl.body), 1, "olsmt table columns");

export_base = "C:\\Users\\eclow\\Documents\\GitHub\\gauss_table_creator\\tests\\_pubtable_test";
call deleteFile(export_base $+ ".md");
call deleteFile(export_base $+ ".tex");
call deleteFile(export_base $+ ".csv");
call deleteFile(export_base $+ ".txt");
call deleteFile(export_base $+ ".rtf");
call deleteFile(export_base $+ ".xls");

checkScalarEqual(ptExport(tbl, export_base $+ ".md"), 0, "markdown export");
checkScalarEqual(ptExport(tbl, export_base $+ ".tex"), 0, "latex export");
checkScalarEqual(ptExport(tbl, export_base $+ ".csv"), 0, "csv export");
checkScalarEqual(ptExport(tbl, export_base $+ ".txt"), 0, "text export");
checkScalarEqual(ptExport(tbl, export_base $+ ".rtf"), 0, "rtf export");
xls_ret = ptExport(tbl, export_base $+ ".xls");
checkScalarNotMissing(xls_ret, "xls export trapped return");

print "pubtable tests passed";
