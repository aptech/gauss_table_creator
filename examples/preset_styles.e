/*
** preset_styles.e
**
** Demonstrates the four built-in style presets and custom statistic row
** configurations using a single OLS model on the auto.dat dataset.
**
** Presets:
**   "journal"  -- 3 digits, +/*/** stars at 0.10/0.05/0.01, SE in parens
**   "compact"  -- 2 digits, +/*/** stars at 0.10/0.05/0.01, SE in parens
**   "plain"    -- 3 digits, no stars, SE without parentheses
**   "report"   -- 3 digits, +/*/** stars at 0.10/0.05/0.01, SE + p-value
**
** Also shows:
**   - Custom statistic rows (t-statistic, confidence intervals)
**   - Custom significance thresholds
**   - Exporting all tables to a single file
*/

new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;

out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

/* Build base model and pre-compute confidence intervals */
struct ptModel mdl;
mdl = ptModelFrom("", out);
mdl = ptModelSetCI(mdl, out.b - 1.96 .* out.stderr, out.b + 1.96 .* out.stderr);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg");

/* --- journal (default) ------------------------------------------------- */
struct ptModel jMdl;
jMdl = ptModelApplyPreset(mdl, "journal");
jMdl.name = "Coeff.";

struct ptTable jTbl;
jTbl = ptModelTable(jMdl);
jTbl = ptSetTitle(jTbl, "Journal preset (default)");

/* --- compact ------------------------------------------------------------ */
struct ptModel cMdl;
cMdl = ptModelApplyPreset(mdl, "compact");
cMdl.name = "Coeff.";

struct ptTable cTbl;
cTbl = ptModelTable(cMdl);
cTbl = ptSetTitle(cTbl, "Compact preset");

/* --- plain -------------------------------------------------------------- */
struct ptModel pMdl;
pMdl = ptModelApplyPreset(mdl, "plain");
pMdl.name = "Coeff.";

struct ptTable pTbl;
pTbl = ptModelTable(pMdl);
pTbl = ptSetTitle(pTbl, "Plain preset");

/* --- report ------------------------------------------------------------- */
struct ptModel rMdl;
rMdl = ptModelApplyPreset(mdl, "report");
rMdl.name = "Coeff.";

struct ptTable rTbl;
rTbl = ptModelTable(rMdl);
rTbl = ptSetTitle(rTbl, "Report preset (SE + p-value)");

/* --- custom: t-stat + CI, stricter stars -------------------------------- */
struct ptModel xMdl;
xMdl = mdl;
xMdl.name = "Coeff.";
xMdl = ptModelSetStatRows(xMdl, "tstat" $| "ci");
xMdl = ptModelSetStars(xMdl, 0.05 | 0.01 | 0.001, "*" $| "**" $| "***");

struct ptTable xTbl;
xTbl = ptModelTable(xMdl);
xTbl = ptSetTitle(xTbl, "Custom: t-stat rows, 95 pct CI, stricter stars");

/* --- export all five tables to one file --------------------------------- */
struct ptTable tbls;
tbls = reshape(jTbl, 5, 1);
tbls[2] = cTbl;
tbls[3] = pTbl;
tbls[4] = rTbl;
tbls[5] = xTbl;

call ptExportAll(tbls, "preset_styles.md");
call ptExportAll(tbls, "preset_styles.html");

print "preset_styles: tables exported.";
