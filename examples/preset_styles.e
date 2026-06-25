/*
** preset_styles.e
**
** Demonstrates the four built-in style presets and a fully custom
** statistic-row / star configuration on the same OLS model.
**
** Presets:
**   "journal"  -- 3 digits, + / * / ** stars at 0.10/0.05/0.01, SE in parens
**   "compact"  -- 2 digits, + / * / ** stars at 0.10/0.05/0.01, SE in parens
**   "plain"    -- 3 digits, no stars, SE without parentheses
**   "report"   -- 3 digits, + / * / ** stars at 0.10/0.05/0.01, SE + p-value rows
**
** Steps:
**   1. Estimate the model.
**   2. Build a base ptModel and pre-compute confidence intervals.
**   3. Apply each preset with ptModelApplyPreset (returns a new ptModel).
**   4. Build a custom configuration using individual setters.
**   5. Render each model to a ptTable and collect into a struct array.
**   6. Export all tables to one file with ptExportAll.
*/

new;
library pubtable;

/* Step 1: Estimate */
struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

/* Step 2: Build the base model.
** ptModelFrom and all setters declare typed returns, so no 'struct ptModel'
** or 'struct ptTable' declarations are needed. */
mdl = ptModelFrom("", out);
mdl = ptModelSetCI(mdl, out.b - 1.96 .* out.stderr, out.b + 1.96 .* out.stderr);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg");

/* Step 3a: Journal preset  + / * / ** stars, SE in parentheses, 3 digits */
jMdl = ptModelApplyPreset(mdl, "journal");
jMdl.name = "Coeff.";
jTbl = ptModelTable(jMdl);
jTbl = ptSetTitle(jTbl, "Journal preset");

/* Step 3b: Compact preset same as journal but 2 digits */
cMdl = ptModelApplyPreset(mdl, "compact");
cMdl.name = "Coeff.";
cTbl = ptModelTable(cMdl);
cTbl = ptSetTitle(cTbl, "Compact preset");

/* Step 3c: Plain preset no stars, no parentheses */
pMdl = ptModelApplyPreset(mdl, "plain");
pMdl.name = "Coeff.";
pTbl = ptModelTable(pMdl);
pTbl = ptSetTitle(pTbl, "Plain preset");

/* Step 3d: Report preset stars + p-value row under each coefficient */
rMdl = ptModelApplyPreset(mdl, "report");
rMdl.name = "Coeff.";
rTbl = ptModelTable(rMdl);
rTbl = ptSetTitle(rTbl, "Report preset");

/* Step 4: Custom — t-statistic + CI rows, stricter * / ** / *** stars.
** Plain copy from another inferred-type variable does not carry struct
** type inference, so xMdl needs an explicit declaration before .name. */
struct ptModel xMdl;
xMdl = mdl;
xMdl.name = "Coeff.";
xMdl = ptModelSetStatRows(xMdl, "tstat" $| "ci");
xMdl = ptModelSetStars(xMdl, 0.05 | 0.01 | 0.001, "*" $| "**" $| "***");
xTbl = ptModelTable(xMdl);
xTbl = ptSetTitle(xTbl, "Custom: t-stat + CI, stricter stars");

/* Step 5: Collect into a struct array.
** reshape on a struct expression requires an explicit struct declaration. */
struct ptTable tbls;
tbls = reshape(jTbl, 5, 1);
tbls[2] = cTbl;
tbls[3] = pTbl;
tbls[4] = rTbl;
tbls[5] = xTbl;

/* Step 6: Export all tables to one file each format */
call ptExportAll(tbls, "preset_styles.md");
call ptExportAll(tbls, "preset_styles.html");
