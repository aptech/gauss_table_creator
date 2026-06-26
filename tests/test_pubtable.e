/*
** Uses `library pubtable;` rather than direct #include of the split source
** files. Since ptModelFrom (in pubtable.src) directly references procs from
** all five optional adapter files, pubtable.src cannot compile standalone --
** even for this core-only test -- without all five also being compiled.
** Raw multi-file #include of all five adapters is unreliable when more than
** one optional library happens to be installed on the test machine (their
** .sdf files can define conflicting same-named structs); `library pubtable;`
** avoids this. This means the *installed* package copy is what's tested --
** sync src/ to the installed package directory before running this test.
*/
new;
library pubtable;

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

/* journal_booktabs preset: same settings as journal, plus booktabs rules */
struct ptTable journalTbl;
journalTbl = ptApplyPreset(ptTableFromMatrix(1.23456, "x", "Model 1", "Demo_table"), "journal");
checkStringEqual(journalTbl.fmt.preset, "journal", "journal preset records its own name");
checkStringEqual(journalTbl.fmt.ruleStyle, "", "journal preset leaves ruleStyle at default (unchanged behavior)");

struct ptTable btTbl;
btTbl = ptApplyPreset(ptTableFromMatrix(1.23456, "x", "Model 1", "Demo_table"), "journal_booktabs");
checkStringEqual(btTbl.fmt.preset, "journal_booktabs", "journal_booktabs preset records its own name");
checkStringEqual(btTbl.fmt.ruleStyle, "booktabs", "journal_booktabs preset sets booktabs rule style");
checkScalarEqual(btTbl.fmt.digits, 3, "journal_booktabs keeps journal's digit count");
checkScalarEqual(btTbl.fmt.stars, 1, "journal_booktabs keeps journal's significance stars");

checkStringContains(ptRenderLatex(btTbl), "\\toprule", "journal_booktabs latex keeps toprule (already booktabs by default)");
checkStringContains(ptRenderLatex(btTbl), "\\bottomrule", "journal_booktabs latex keeps bottomrule");

checkStringContains(ptRenderHtml(btTbl), "border-top:1px solid #000;", "journal_booktabs html adds table top rule");
checkStringContains(ptRenderHtml(btTbl), "border-bottom:1px solid #000;", "journal_booktabs html adds header/bottom rule");
checkScalarEqual(strindx(ptRenderHtml(journalTbl), "border-top", 1), 0, "default journal html has no border styling (unchanged)");

checkStringContains(ptRenderRtf(btTbl), "\\clbrdrt", "journal_booktabs rtf keeps a top rule");
checkStringContains(ptRenderRtf(btTbl), "\\clbrdrb", "journal_booktabs rtf keeps header/bottom rules");
checkScalarEqual(strindx(ptRenderRtf(btTbl), "\\clbrdrl", 1), 0, "journal_booktabs rtf drops left/vertical borders");
checkScalarEqual(strindx(ptRenderRtf(journalTbl), "\\clbrdrl", 1) > 0, 1, "default journal rtf keeps the full grid (unchanged)");

/* journal-style title warning: ptExport/ptRenderLatex/ptRenderHtml/ptRenderRtf
** call _ptCheckJournalTitle, which warns via errorlog but never aborts. */
struct ptTable noTitleTbl;
noTitleTbl = ptApplyPreset(ptTableFromMatrix(1.0, "x", "M", ""), "journal");
call _ptCheckJournalTitle(noTitleTbl.fmt, noTitleTbl.title);
call _ptCheckJournalTitle(journalTbl.fmt, journalTbl.title);
local noTitlePath;
noTitlePath = "C:\\Users\\eclow\\Documents\\GitHub\\gauss_table_creator\\tests\\_pubtable_test_notitle.md";
checkScalarEqual(ptExport(noTitleTbl, noTitlePath), 0, "journal table without a title still exports (warning only, no abort)");
call deleteFile(noTitlePath);

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
checkStringEqual(cmpTbl.body[7, 2], "100", "GOF value present for second model (integer)");

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

/* ptModelSetDataLabel: a separate "Data: <label>." note, decoupled from
** ptModelSetNotes so callers don't have to hand-concatenate it themselves. */
struct ptModel dataLabelMdl;
dataLabelMdl = ptModelCreate("DataLabelTest", 1.0, 0.1);
dataLabelMdl = ptModelSetDataLabel(dataLabelMdl, "mydata");

struct ptTable dataLabelTbl;
dataLabelTbl = ptModelTable(dataLabelMdl);
checkStringEqual(dataLabelTbl.notes[rows(dataLabelTbl.notes)], "Data: mydata.", "ptModelSetDataLabel appends a separate Data note");

dataLabelMdl = ptModelSetNotes(dataLabelMdl, "Some other note.");
dataLabelTbl = ptModelTable(dataLabelMdl);
checkScalarEqual(rows(dataLabelTbl.notes), 3, "dataLabel note coexists with significance note and a regular note");
checkStringEqual(dataLabelTbl.notes[rows(dataLabelTbl.notes)], "Data: mydata.", "Data note stays last and separate from the regular note");

/* ptModelSetAicBic / ptFilterGofRows: AIC/BIC GOF rows stay hidden unless
** explicitly enabled -- but only for models whose adapter marked its
** trailing AIC/BIC pair as optional via hasOptionalAicBic (cmlmt/maxlikmt).
** A model with its own non-optional "AIC"/"BIC" GOF rows (e.g. glm, via
** ptModelFromGlm) must NOT be affected just because the labels match. */
struct ptModel aicMdl;
aicMdl = ptModelCreate("AICTest", 1.0, 0.1);
aicMdl = ptModelSetGOF(aicMdl, "N" $| "Function value" $| "AIC" $| "BIC", 100 | -50.0 | 104.0 | 109.2);
aicMdl.hasOptionalAicBic = 1;

struct ptTable aicTblHidden;
aicTblHidden = ptModelTable(aicMdl);
checkScalarEqual(rows(aicTblHidden.body), 4, "AIC/BIC stay hidden by default (term rows + N + Function value only)");
checkStringEqual(aicTblHidden.rowNames[rows(aicTblHidden.rowNames)], "Function value", "last visible GOF row is Function value when AIC/BIC are hidden");

aicMdl = ptModelSetAicBic(aicMdl, 1);
struct ptTable aicTblShown;
aicTblShown = ptModelTable(aicMdl);
checkScalarEqual(rows(aicTblShown.body), 6, "ptModelSetAicBic(mdl, 1) reveals the AIC and BIC GOF rows");
checkStringEqual(aicTblShown.rowNames[rows(aicTblShown.rowNames) - 1], "AIC", "AIC GOF row present once shown");
checkStringEqual(aicTblShown.rowNames[rows(aicTblShown.rowNames)], "BIC", "BIC GOF row present once shown");

/* A model that never sets hasOptionalAicBic (e.g. glm's own AIC/BIC GOF
** rows) must keep showing them even though showAicBic defaults to 0. */
struct ptModel nonOptionalAicMdl;
nonOptionalAicMdl = ptModelCreate("NonOptionalAIC", 1.0, 0.1);
nonOptionalAicMdl = ptModelSetGOF(nonOptionalAicMdl, "N" $| "DF" $| "AIC" $| "BIC", 100 | 97 | 104.0 | 109.2);
struct ptTable nonOptionalAicTbl;
nonOptionalAicTbl = ptModelTable(nonOptionalAicMdl);
checkScalarEqual(rows(nonOptionalAicTbl.body), 6, "AIC/BIC stay visible when hasOptionalAicBic was never set (matches ptModelFromGlm)");

struct ptModel aicMdl2;
aicMdl2 = ptModelCreate("AICTest2", 2.0, 0.2);
aicMdl2 = ptModelSetGOF(aicMdl2, "N" $| "Function value" $| "AIC" $| "BIC", 100 | -60.0 | 124.0 | 129.2);
aicMdl2.hasOptionalAicBic = 1;
aicMdl2 = ptModelSetAicBic(aicMdl2, 1);

struct ptModel aicModels;
aicModels = reshape(aicMdl, 2, 1);
aicModels[2] = aicMdl2;

struct ptTable aicCmpTbl;
aicCmpTbl = ptModelCompare(aicModels);
checkScalarEqual(rows(aicCmpTbl.body), 6, "ptModelCompare reveals AIC/BIC GOF rows when each model's showAicBic is set");

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

/* Star-gutter alignment: a coefficient's SE row must right-align so its
** number lines up with the coefficient's own number, regardless of how
** many significance-star characters (0/1/2) follow the coefficient. */
struct ptModel gutterMdl;
gutterMdl = ptModelCreate("GutterTest", 1.200 | 0.400, 0.100 | 0.200);
gutterMdl = ptModelSetNames(gutterMdl, "A" $| "B");
gutterMdl = ptModelSetPValues(gutterMdl, 0.001 | 0.500);

struct ptTable gutterTbl;
gutterTbl = ptModelTable(gutterMdl);
checkStringEqual(gutterTbl.body[1, 1], "1.200**", "gutter test: term A has a double-star suffix");
checkStringEqual(gutterTbl.body[3, 1], "0.400", "gutter test: term B has no star suffix");

local gutterLines, estALine, seALine, estBLine, seBLine, numEndA, seNumEndA, numEndB, seNumEndB;
gutterLines = strsplit(ptRenderText(gutterTbl), "\n");
/* strsplit omits empty segments, so there's no blank line for the title's
** trailing "\n\n": [1]=title, [2]=header, [3]=separator, [4]=estA,
** [5]=seA, [6]=estB, [7]=seB, [8]=significance note. */
estALine = gutterLines[4];
seALine = gutterLines[5];
estBLine = gutterLines[6];
seBLine = gutterLines[7];

/* Compare the *number's* ending column in each line (not the closing
** paren, which always sits exactly 1 column after its own number --
** comparing paren-to-number-end would be off by construction). */
numEndA = strindx(estALine, "1.200", 1) + strlen("1.200") - 1;
seNumEndA = strindx(seALine, "0.100", 1) + strlen("0.100") - 1;
checkScalarEqual(numEndA, seNumEndA, "text: SE number aligns under coefficient number (with stars)");

numEndB = strindx(estBLine, "0.400", 1) + strlen("0.400") - 1;
seNumEndB = strindx(seBLine, "0.200", 1) + strlen("0.200") - 1;
checkScalarEqual(numEndB, seNumEndB, "text: SE number aligns under coefficient number (no stars)");

checkScalarEqual(numEndA, numEndB, "text: coefficient numbers align across rows regardless of star count");

local gutterMd;
gutterMd = ptRenderMarkdown(gutterTbl);
checkStringContains(gutterMd, "1.200**", "markdown: term A keeps its double-star suffix");
checkStringContains(gutterMd, "0.400", "markdown: term B value still present");
checkScalarEqual(strindx(gutterMd, "0.400  ", 1) > 0, 1, "markdown: shorter estimate is right-padded to reserve the star gutter");

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
