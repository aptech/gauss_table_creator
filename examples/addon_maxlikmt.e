/*
** addon_maxlikmt.e
**
** pubtable integration with the maxlikmt (Maximum Likelihood MT) package.
** Estimates a Normal linear regression by MLE on the GAUSS auto.dat dataset.
** The MLE estimates match OLS and serve as a cross-check.
**
** Model: y = b0 + X*b + e,  e ~ N(0, s2)
** Parameters packed in PV: b0 (intercept), b (slope vector), s2 (variance)
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_MAXLIKMT.
**   2. maxlikmt must be installed (library maxlikmt loads without error).
**   3. Load maxlikmt and pubtable together in a single library statement
**      so neither library unloads the other.
**
** Steps:
**   1. Define the Normal log-likelihood procedure.
**   2. Set initial parameters and bounds (s2 > 0).
**   3. Load the data.
**   4. Estimate with maxlikmt.
**   5. Convert to a pubtable with ptModelFrom.
**   6. Export.
*/

new;
library maxlikmt, pubtable;

/* Step 1: Log-likelihood — per-observation Normal log-densities via lnpdfmvn */
proc lnorm(struct PV p, struct DS d, ind);
    local b0, b, s2, y, x, resid;
    struct modelResults mm;

    b0    = pvUnpack(p, "b0");
    b     = pvUnpack(p, "b");
    s2    = pvUnpack(p, "s2");
    y     = d[1].dataMatrix;
    x     = d[2].dataMatrix;
    resid = y - (b0 + x * b);

    if ind[1];
        mm.function = lnpdfmvn(resid, s2);
    endif;
    retp(mm);
endp;

/* Step 2a: Pack starting values (intercept near 50, slopes near 0, s2 near 10) */
struct PV p0;
p0 = pvPack(pvCreate, 50, "b0");
p0 = pvPack(p0, -0.01 | -0.1, "b");
p0 = pvPack(p0, 10, "s2");

/* Step 2b: Bounds keep s2 positive throughout optimisation */
struct maxlikmtControl c0;
c0 = maxlikmtcontrolcreate;
c0.Bounds = { -500  500,
              -10   10,
              -10   10,
               0.01 500 };
c0.PrintIters = 0;

/* Step 3: Load auto.dat — mpg as y, weight and length as X */
z = loadd(getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

struct DS d0;
d0 = reshape(dsCreate, 2, 1);
d0[1].dataMatrix = z[., 1];
d0[2].dataMatrix = z[., 2:3];

/* Step 4: Estimate */
struct maxlikmtResults out;
out = maxlikmt(&lnorm, p0, d0, c0);

/* Step 5: Convert to pubtable via the standard dispatcher — no 'struct
** ptModel' or 'struct ptTable' needed */
mdl = ptModelFrom("Normal MLE", out);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg.  MLE estimates match OLS.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Normal MLE (replicates OLS)");

/* Step 6: Export */
call ptExport(tbl, "addon_maxlikmt.md");
call ptExport(tbl, "addon_maxlikmt.html");
