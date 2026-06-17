/*
** addon_maxlikmt.e
**
** Demonstrates pubtable integration with the maxlikmt (Maximum Likelihood
** MT) package.  Estimates a Normal linear regression by MLE on the GAUSS
** auto.dat dataset, yielding the same coefficients as OLS.
**
** Parameters: intercept, b_weight, b_length, sigma2 (residual variance)
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_MAXLIKMT.
**   2. maxlikmt must be installed: library maxlikmt must load without error.
**
** Include order matters: maxlikmt.sdf must come before pubtable.dec so that
** the maxlikmt structs are defined before pubtable.src loads the adapter.
*/

new;
library maxlikmt;
library pubtable;

#include maxlikmt.sdf
#include pubtable.dec
#include pubtable.sdf
#include pubtable.src

/* --- Normal log-likelihood ----------------------------------------------- */
proc lnorm(struct PV p, struct DS d, ind);
    local b0, b, s2, y, x, resid;
    struct modelResults mm;

    b0 = pvUnpack(p, "b0");
    b  = pvUnpack(p, "b");
    s2 = pvUnpack(p, "s2");

    y = d[1].dataMatrix;
    x = d[2].dataMatrix;
    resid = y - (b0 + x * b);

    if ind[1];
        mm.function = lnpdfmvn(resid, s2);
    endif;
    retp(mm);
endp;

/* --- Initial parameters ------------------------------------------------- */
struct PV p0;
p0 = pvPack(pvCreate, 50, "b0");
p0 = pvPack(p0, -0.01 | -0.1, "b");
p0 = pvPack(p0, 10, "s2");

/* --- Bounds: s2 > 0 ----------------------------------------------------- */
struct maxlikmtControl c0;
c0 = maxlikmtcontrolcreate;
c0.Bounds = { -500  500,
              -10   10,
              -10   10,
               0.01 500 };
c0.PrintIters = 0;

/* --- Load auto.dat ------------------------------------------------------- */
z = loadd(getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

struct DS d0;
d0 = reshape(dsCreate, 2, 1);
d0[1].dataMatrix = z[., 1];
d0[2].dataMatrix = z[., 2:3];

/* --- Estimate ------------------------------------------------------------ */
struct maxlikmtResults out;
out = maxlikmt(&lnorm, p0, d0, c0);

/* --- Build pubtable output ---------------------------------------------- */
struct ptModel mdl;
mdl = ptModelFromMaxlikmt("Normal MLE", out);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg.  Estimates match OLS.");

struct ptTable tbl;
tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Normal MLE (equivalent to OLS)");

call ptExport(tbl, "addon_maxlikmt.md");
call ptExport(tbl, "addon_maxlikmt.html");

print "addon_maxlikmt: table exported.";
