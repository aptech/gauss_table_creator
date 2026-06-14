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
checkStringContains(ptRenderRtf(tbl), "\\trowd", "rtf table row");
checkStringContains(ptRenderRtf(tbl), "\\cellx", "rtf table cell definition");
checkStringContains(ptRenderRtf(tbl), "\\b Model 1\\b0\\cell", "rtf bold header cell");
checkStringContains(ptRenderRtf(tbl), "1.235\\cell", "rtf data cell");
checkStringEqual(ptEscapeRtf("a\\b{c}"), "a\\\\b\\{c\\}", "rtf escaping");

checkStringContains(ptRenderHtml(tbl), "<caption>Demo_table</caption>", "html caption");
checkStringContains(ptRenderHtml(tbl), "<th>Model 1</th>", "html column header");
checkStringContains(ptRenderHtml(tbl), "<td>1.235</td>", "html data cell");
checkStringEqual(ptEscapeHtml("a < b & c > d"), "a &lt; b &amp; c &gt; d", "html escaping");

struct ptTable latexTbl;
latexTbl = ptSetLabel(tbl, "tab:demo");
checkStringContains(ptRenderLatex(latexTbl), "\\label{tab:demo}", "latex label");

latexTbl = ptSetColAlign(tbl, "lc");
checkStringContains(ptRenderLatex(latexTbl), "\\begin{tabular}{lc}", "latex custom column alignment");

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

struct ptModel statMdl;
statMdl = ptModelCreate("StatRows", 1.2 | 0.4, 0.1 | 0.2);
statMdl = ptModelSetNames(statMdl, "Constant" $| "x");
statMdl = ptModelSetPValues(statMdl, 0.004 | 0.08);
statMdl = ptModelSetStatRows(statMdl, "tstat" $| "pvalue");

struct ptTable statTbl;
statTbl = ptModelTable(statMdl);
checkScalarEqual(rows(statTbl.body), 6, "model table row count with two statistic rows per term");
checkStringEqual(statTbl.body[2, 1], "(12.000)", "t-statistic row");
checkStringEqual(statTbl.body[3, 1], "(0.004)", "p-value row");

statMdl = ptModelSetCI(statMdl, 1.0 | 0.2, 1.4 | 0.6);
statMdl = ptModelSetStatRows(statMdl, "ci");
statTbl = ptModelTable(statMdl);
checkStringEqual(statTbl.body[2, 1], "[1.000, 1.400]", "confidence interval row");

statMdl = ptModelSetNotes(statMdl, "Robust standard errors.");
statTbl = ptModelTable(statMdl);
checkScalarEqual(rows(statTbl.notes), 2, "model table combines significance note with model notes");
checkStringEqual(statTbl.notes[2], "Robust standard errors.", "model-level note appended to table notes");

struct ptCompareOptions cmpOpts;
cmpOpts = ptCompareOptionsCreate();
cmpOpts = ptCompareSetTermOrder(cmpOpts, "z" $| "x" $| "Constant");
cmpOpts = ptCompareSetGofOrder(cmpOpts, "R2" $| "N");
cmpOpts = ptCompareSetLabelMap(cmpOpts, "Constant", "(Intercept)");
cmpOpts = ptCompareSetNotes(cmpOpts, "Comparison note.");

mdl = ptModelSetNotes(mdl, "Model A note.");
mdl2 = ptModelSetNotes(mdl2, "Model B note.");
cmpModels[1] = mdl;
cmpModels[2] = mdl2;

struct ptTable cmpTbl2;
cmpTbl2 = ptModelCompareWith(cmpModels, cmpOpts);

checkStringEqual(cmpTbl2.rowNames[1], "z", "custom term order moves z first");
checkStringEqual(cmpTbl2.rowNames[3], "x", "custom term order keeps x second");
checkStringEqual(cmpTbl2.rowNames[5], "(Intercept)", "coefficient renamed via label map");
checkStringEqual(cmpTbl2.rowNames[7], "R2", "custom GOF order moves R2 first");
checkStringEqual(cmpTbl2.rowNames[8], "N", "custom GOF order keeps N second");
checkScalarEqual(rows(cmpTbl2.notes), 4, "model comparison combines significance, model, and table notes");
checkStringContains(cmpTbl2.notes[2], "Model A note.", "model-specific note prefixed with model name");
checkStringContains(cmpTbl2.notes[3], "Model B note.", "second model note prefixed with model name");
checkStringEqual(cmpTbl2.notes[4], "Comparison note.", "table-level comparison note appended last");

local txtLines;
txtLines = strsplit(ptRenderText(cmpTbl2), "\n");
checkScalarEqual(strlen(txtLines[2]), strlen(txtLines[3]), "text rendering aligns header and data row widths");
checkStringEqual(strtrim(strreplace(txtLines[3], "-", "")), "", "text rendering separator row contains only dashes and spaces");

struct olsmtControl ctl;
struct olsmtOut out;

ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

tbl = ptTableFrom(out);
checkStringEqual(tbl.title, "OLS results", "olsmt struct dispatch");
checkScalarEqual(cols(tbl.body), 1, "olsmt table columns");

struct glmOut glmOutput;
glmOutput = glm(getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length", "normal");

struct ptTable glmTbl;
glmTbl = ptTableFrom(glmOutput);
checkStringEqual(glmTbl.title, "GLM results", "glm struct dispatch");
checkScalarEqual(rows(glmTbl.body), 2 * rows(glmOutput.coef.estimates) + 4, "glm table row count includes GOF rows");

struct dstatmtOut dstatOutput;
dstatOutput = dstatmt(getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

struct ptTable dstatTbl;
dstatTbl = ptFromDstatmt(dstatOutput);
checkStringEqual(dstatTbl.title, "Summary statistics", "dstatmt struct dispatch");
checkScalarEqual(rows(dstatTbl.body), rows(dstatOutput.vnames), "dstatmt table row count matches variable count");
checkScalarEqual(cols(dstatTbl.body), 6, "dstatmt table column count");

struct fglsOut fglsOutput;
fglsOutput = fgls(loadd(getGAUSSHome() $+ "examples/auto.dat"), "mpg ~ weight + length");

struct ptTable fglsTbl;
fglsTbl = ptTableFrom(fglsOutput);
checkStringEqual(fglsTbl.title, "FGLS results", "fgls struct dispatch");
checkScalarEqual(rows(fglsTbl.body), 2 * rows(fglsOutput.beta_fgls) + 3, "fgls table row count includes statistic and GOF rows");
checkStringEqual(fglsTbl.rowNames[1], "Constant", "fgls constant label normalized");

export_base = "C:\\Users\\eclow\\Documents\\GitHub\\gauss_table_creator\\tests\\_pubtable_test";
call deleteFile(export_base $+ ".md");
call deleteFile(export_base $+ ".tex");
call deleteFile(export_base $+ ".csv");
call deleteFile(export_base $+ ".txt");
call deleteFile(export_base $+ ".rtf");
call deleteFile(export_base $+ ".html");
call deleteFile(export_base $+ ".xls");

checkScalarEqual(ptExport(tbl, export_base $+ ".md"), 0, "markdown export");
checkScalarEqual(ptExport(tbl, export_base $+ ".tex"), 0, "latex export");
checkScalarEqual(ptExport(tbl, export_base $+ ".csv"), 0, "csv export");
checkScalarEqual(ptExport(tbl, export_base $+ ".txt"), 0, "text export");
checkScalarEqual(ptExport(tbl, export_base $+ ".rtf"), 0, "rtf export");
checkScalarEqual(ptExport(tbl, export_base $+ ".html"), 0, "html export");
xls_ret = ptExport(tbl, export_base $+ ".xls");
checkScalarNotMissing(xls_ret, "xls export trapped return");

print "pubtable tests passed";
