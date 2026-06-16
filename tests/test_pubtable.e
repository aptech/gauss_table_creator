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

proc (0) = checkFileExists(fname, label);
    local fh;

    fh = fopen(fname, "r");
    if fh <= 0;
        errorlog label $+ " failed. File not found: " $+ fname;
        end;
    endif;
    call close(fh);
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
checkStringEqual(ptStripRtfHeader("{\\rtf1\\ansi\nbody}\n"), "body}\n", "rtf header strip");
checkStringEqual(ptStripRtfFooter("body}\n"), "body", "rtf footer strip");

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

struct ptModel starMdl;
starMdl = ptModelSetStars(mdl, 0.10 | 0.05, "a" $| "b");
tbl = ptModelTable(starMdl);
checkStringEqual(tbl.body[1, 1], "1.200b", "custom significance symbols");

starMdl = ptModelNoStars(mdl);
tbl = ptModelTable(starMdl);
checkStringEqual(tbl.body[1, 1], "1.200", "no significance stars");

struct ptModel presetMdl;
presetMdl = ptModelApplyPreset(mdl, "compact");
tbl = ptModelTable(presetMdl);
checkStringEqual(tbl.body[1, 1], "1.20**", "compact preset reduces digits");

presetMdl = ptModelApplyPreset(mdl, "plain");
tbl = ptModelTable(presetMdl);
checkStringEqual(tbl.body[1, 1], "1.200", "plain preset disables stars");
checkStringEqual(tbl.body[2, 1], "0.100", "plain preset removes statistic wrapper");

presetMdl = ptModelApplyPreset(mdl, "report");
tbl = ptModelTable(presetMdl);
checkScalarEqual(rows(tbl.body), 6, "report preset adds pvalue statistic row");

struct ptTable presetTbl;
presetTbl = ptApplyPreset(ptTableFromMatrix(1.23456, "x", "Model 1", "Demo_table"), "compact");
checkScalarEqual(presetTbl.fmt.digits, 2, "ptApplyPreset compact sets digits to 2");

presetTbl = ptApplyPreset(presetTbl, "plain");
checkScalarEqual(presetTbl.fmt.stars, 0, "ptApplyPreset plain disables stars");
checkStringEqual(presetTbl.fmt.statisticWrapper, "none", "ptApplyPreset plain removes statistic wrapper");

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

struct ptTable grpTbl;
grpTbl = ptTableFromMatrix(1.1~2.2~3.3~4.4, "x", "A" $| "B" $| "C" $| "D", "Group_table");
grpTbl = ptSetColGroups(grpTbl, "G1" $| "G1" $| "G2" $| "G2");

checkStringContains(ptRenderMarkdown(grpTbl), "G1", "markdown column group label");
checkStringContains(ptRenderCsv(grpTbl), "G1", "csv column group label");
checkStringContains(ptRenderText(grpTbl), "G1", "text column group label");
checkStringContains(ptRenderLatex(grpTbl), "\\multicolumn{2}{c}{G1}", "latex spanning header");
checkStringContains(ptRenderLatex(grpTbl), "\\cmidrule(lr){2-3}", "latex cmidrule under group");
checkStringContains(ptRenderHtml(grpTbl), "<th colspan=\"2\">G1</th>", "html spanning header");
checkStringContains(ptRenderRtf(grpTbl), "\\clmgf", "rtf merged cell start");
checkStringContains(ptRenderRtf(grpTbl), "\\clmrg", "rtf merged cell continuation");

cmpOpts = ptCompareSetColGroups(cmpOpts, "Set A" $| "Set B");
cmpTbl2 = ptModelCompareWith(cmpModels, cmpOpts);
checkStringEqual(cmpTbl2.colGroups[1], "Set A", "compare colGroups first model label");
checkStringEqual(cmpTbl2.colGroups[2], "Set B", "compare colGroups second model label");
checkStringContains(ptRenderMarkdown(cmpTbl2), "Set A", "compare markdown group header");

struct ptTable alignTbl;
alignTbl = ptSetColAlign(grpTbl, "lcrrc");
checkStringContains(ptRenderMarkdown(alignTbl), ":---:", "markdown center alignment marker");
checkStringContains(ptRenderMarkdown(alignTbl), "---:", "markdown right alignment marker");
checkStringContains(ptRenderHtml(alignTbl), "style=\"text-align:center\"", "html center alignment style");
checkStringContains(ptRenderHtml(alignTbl), "style=\"text-align:right\"", "html right alignment style");
checkStringContains(ptRenderHtml(alignTbl), "style=\"text-align:left\"", "html left alignment style");

local alignLines;
alignLines = strsplit(ptRenderText(alignTbl), "\n");
checkScalarEqual(strlen(alignLines[3]), strlen(alignLines[5]), "text rendering with colAlign aligns header and data row widths");

struct ptTable fmtTbl;
fmtTbl = ptTableFromMatrix(1.23456~7.891, "x", "A" $| "B", "Format_table");
checkStringEqual(fmtTbl.body[1, 1], "1.235", "default 3-digit formatting before colFormat");

fmtTbl = ptSetColFormat(fmtTbl, "0" $| "");
checkStringEqual(fmtTbl.body[1, 1], "1", "ptSetColFormat overrides digits for first column");
checkStringEqual(fmtTbl.body[1, 2], "7.891", "ptSetColFormat leaves unlisted column unchanged");

fmtTbl = ptSetCellStyle(fmtTbl, 1, 2, "bold");
checkStringContains(ptRenderMarkdown(fmtTbl), "**7.891**", "markdown bold cell styling");
checkStringContains(ptRenderLatex(fmtTbl), "\\textbf{7.891}", "latex bold cell styling");
checkStringContains(ptRenderHtml(fmtTbl), "<strong>7.891</strong>", "html bold cell styling");
checkStringContains(ptRenderRtf(fmtTbl), "\\b 7.891\\b0", "rtf bold cell styling");

fmtTbl = ptSetCellStyle(fmtTbl, 1, 1, "bold italic");
checkStringContains(ptRenderMarkdown(fmtTbl), "***1***", "markdown bold italic cell styling");
checkStringContains(ptRenderLatex(fmtTbl), "\\textbf{\\textit{1}}", "latex bold italic cell styling");
checkStringContains(ptRenderHtml(fmtTbl), "<strong><em>1</em></strong>", "html bold italic cell styling");
checkStringContains(ptRenderRtf(fmtTbl), "\\b\\i 1\\i0\\b0", "rtf bold italic cell styling");

struct ptTable multiTbl;
multiTbl = reshape(ptTableFromMatrix(1.1, "x", "Model 1", "Table One"), 2, 1);
multiTbl[2] = ptTableFromMatrix(2.2, "y", "Model 2", "Table Two");

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

call deleteFile(export_base $+ "_multi.md");
call deleteFile(export_base $+ "_multi.rtf");
call deleteFile(export_base $+ "_multi.xls");

checkScalarEqual(ptExportAll(multiTbl, export_base $+ "_multi.md"), 0, "multi-table markdown export");
checkScalarEqual(ptExportAll(multiTbl, export_base $+ "_multi.rtf"), 0, "multi-table rtf export");
xls_ret = ptExportAll(multiTbl, export_base $+ "_multi.xls");
checkScalarNotMissing(xls_ret, "multi-table xls export trapped return");

call deleteFile(export_base $+ "_batch.md");
call deleteFile(export_base $+ "_batch.tex");
call deleteFile(export_base $+ "_batch.html");

checkScalarEqual(ptExportAllFormats(multiTbl, export_base $+ "_batch", "md" $| "tex" $| "html"), 0, "batch report export to multiple formats");
checkFileExists(export_base $+ "_batch.md", "batch report markdown file written");
checkFileExists(export_base $+ "_batch.tex", "batch report latex file written");
checkFileExists(export_base $+ "_batch.html", "batch report html file written");

/* pubtableSet / ptSetupAt: write pubtable.dec to tests/ dir to avoid modifying src/ */
ptSetupTest = "C:/Users/eclow/Documents/GitHub/gauss_table_creator/tests/";
call deleteFile(ptSetupTest $+ "pubtable.dec");
checkScalarEqual(ptSetupAt(ptSetupTest), 0, "ptSetupAt returns 0");
checkFileExists(ptSetupTest $+ "pubtable.dec", "ptSetupAt writes pubtable.dec");
call deleteFile(ptSetupTest $+ "pubtable.dec");

print "pubtable tests passed";
