/*
** addon_tsmt.e
**
** Demonstrates pubtable integration with the tsmt (Time Series MT) package:
**   - AR(1) and AR(2) estimation with arimaFit on simulated data
**   - Side-by-side model comparison with ptModelCompareWith
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_TSMT.
**   2. tsmt must be installed: library tsmt must load without error.
**
** Include order matters: tsmt.sdf must come before pubtable.dec so that
** the tsmt structs are defined before pubtable.src loads the adapter.
*/

new;
library tsmt, pubtable;


/* --- Simulate a stationary AR(1) series --------------------------------- */
rndseed 12345;
n = 200;
phi = 0.65;
y = zeros(n, 1);
for i(2, n, 1);
    y[i] = phi * y[i-1] + rndn(1, 1);
endfor;

/* Control struct: suppress printed output from arimaFit */
ctl = arimaControlCreate();
ctl.quiet = 1;

/* --- ARIMA(1,0,0) ------------------------------------------------------- */
ar1 = arimaFit(y, 1, 0, 0, ctl);

struct ptModel ar1Mdl;
ar1Mdl = ptModelFromArimamt("AR(1)", ar1);

/* --- ARIMA(2,0,0) ------------------------------------------------------- */
ar2 = arimaFit(y, 2, 0, 0, ctl);

struct ptModel ar2Mdl;
ar2Mdl = ptModelFromArimamt("AR(2)", ar2);

/* --- Compare models side by side ---------------------------------------- */
struct ptModel models;
models = reshape(ar1Mdl, 2, 1);
models[2] = ar2Mdl;

struct ptCompareOptions opts;
opts = ptCompareOptionsCreate();
opts = ptCompareSetNotes(opts, "Simulated AR(1) process: phi = 0.65, n = 200.");

struct ptTable cmpTbl;
cmpTbl = ptModelCompareWith(models, opts);
cmpTbl = ptSetTitle(cmpTbl, "ARIMA Model Comparison");

call ptExport(cmpTbl, "addon_tsmt_arima.md");
call ptExport(cmpTbl, "addon_tsmt_arima.html");

/* --- Single-model table for AR(1) --------------------------------------- */
struct ptTable ar1Tbl;
ar1Tbl = ptModelTable(ar1Mdl);
ar1Tbl = ptSetTitle(ar1Tbl, "ARIMA(1,0,0) Estimation");

call ptExport(ar1Tbl, "addon_tsmt_ar1.md");

print "addon_tsmt: tables exported.";
