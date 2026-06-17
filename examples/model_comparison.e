/*
** model_comparison.e
**
** Side-by-side model comparison table using ptModelCompare.
**
** Steps:
**   1. Estimate two OLS models.
**   2. Wrap each in a ptModel with ptModelFrom.
**   3. Build a struct array and pass to ptModelCompare.
**   4. Title and export the comparison table.
*/

new;
library pubtable;

/* Step 1: Estimate two models */
struct olsmtControl ctl;
struct olsmtOut out1;
struct olsmtOut out2;
ctl = olsmtControlCreate;
ctl.output = 0;

fname = getGAUSSHome() $+ "examples/auto.dat";
out1 = olsmt(ctl, fname, "mpg ~ weight");
out2 = olsmt(ctl, fname, "mpg ~ weight + length");

/* Step 2: Wrap in ptModel — no 'struct ptModel mdl' declaration needed */
mdl1 = ptModelFrom("(1)", out1);
mdl2 = ptModelFrom("(2)", out2);

/* Step 3: Build a struct array for comparison.
** reshape creates a 2x1 ptModel array initialised from mdl1;
** explicit 'struct ptModel' declaration is required for struct arrays. */
struct ptModel models;
models = reshape(mdl1, 2, 1);
models[2] = mdl2;

/* Step 4: Compare, title, and export */
tbl = ptModelCompare(models);
tbl = ptSetTitle(tbl, "Model Comparison: Fuel Efficiency");

call ptExport(tbl, "model_comparison.md");
call ptExport(tbl, "model_comparison.rtf");
