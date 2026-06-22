/*
** addon_tsmt.e
**
** pubtable integration with the tsmt (Time Series MT) package.
** Fits AR(1) and AR(2) models on simulated data, then builds a
** side-by-side comparison table with ptModelCompareWith.
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_TSMT.
**   2. tsmt must be installed (library tsmt loads without error).
**   3. pubtable must be in the GAUSS library search path so that
**      #include pubtable.dec resolves. pubtable.dec must be included
**      BEFORE library pubtable so PT_USE_TSMT is defined when the
**      tsmt adapter is compiled.
**
** Steps:
**   1. Simulate a stationary AR(1) series.
**   2. Estimate AR(1) and AR(2) with arimaFit.
**   3. Wrap each result in a ptModel with ptModelFromArimamt.
**   4. Build a side-by-side comparison table.
**   5. Also render AR(1) alone as a single-model table.
**   6. Export.
*/

new;
library tsmt;
#include tsmt.sdf
#include pubtable.dec
library pubtable;

/* Step 1: Simulate AR(1) data: y_t = 0.65 * y_{t-1} + e_t */
rndseed 12345;
n = 200;
phi = 0.65;
y = zeros(n, 1);
for i(2, n, 1);
    y[i] = phi * y[i-1] + rndn(1, 1);
endfor;

/* Step 2: Estimate — suppress iteration output with ctl.quiet */
ctl = arimaControlCreate();
ctl.quiet = 1;

ar1 = arimaFit(y, 1, 0, 0, ctl);
ar2 = arimaFit(y, 2, 0, 0, ctl);

/* Step 3: Convert to ptModel — no explicit struct declaration needed */
ar1Mdl = ptModelFromArimamt("AR(1)", ar1);
ar2Mdl = ptModelFromArimamt("AR(2)", ar2);

/* Step 4: Build comparison table.
** reshape to a struct array requires an explicit 'struct ptModel' declaration. */
struct ptModel models;
models = reshape(ar1Mdl, 2, 1);
models[2] = ar2Mdl;

opts = ptCompareOptionsCreate();
opts = ptCompareSetNotes(opts, "Simulated AR(1) process: phi = 0.65, n = 200.");

cmpTbl = ptModelCompareWith(models, opts);
cmpTbl = ptSetTitle(cmpTbl, "ARIMA Model Comparison");

/* Step 5: Single-model table for AR(1) */
ar1Tbl = ptModelTable(ar1Mdl);
ar1Tbl = ptSetTitle(ar1Tbl, "AR(1) Estimation");

/* Step 6: Export */
call ptExport(cmpTbl, "addon_tsmt_comparison.md");
call ptExport(cmpTbl, "addon_tsmt_comparison.html");
call ptExport(ar1Tbl, "addon_tsmt_ar1.md");
