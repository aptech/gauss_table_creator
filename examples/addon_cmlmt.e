/*
** addon_cmlmt.e
**
** Demonstrates pubtable integration with the cmlmt (Constrained Maximum
** Likelihood MT) package.  Fits a Poisson regression with a linear
** equality constraint using the cmlmtpsn dataset that ships with cmlmt.
**
** Model: E[y] = exp(x * b),  b1 = b2 (equality constraint via A*b = 0)
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_CMLMT.
**   2. cmlmt must be installed: library cmlmt must load without error.
**
** Include order matters: cmlmt.sdf must come before pubtable.dec so that
** the cmlmt structs are defined before pubtable.src loads the adapter.
*/

new;
library cmlmt;
library pubtable;

#include cmlmt.sdf
#include pubtable.dec
#include pubtable.sdf
#include pubtable.src

/* --- Poisson log-likelihood --------------------------------------------- */
proc lpsn(struct PV p, struct DS d, ind);
    local m, y, x, b;
    struct modelResults mm;

    y = d.dataMatrix[., 1];
    x = d.dataMatrix[., 2:4];
    b = pvUnpack(p, "b");

    m = x * b;
    if ind[1];
        mm.function = y .* m - exp(m);
    endif;
    if ind[2];
        mm.gradient = (y - exp(x * b)) .* x;
    endif;
    retp(mm);
endp;

/* --- Initial parameters ------------------------------------------------- */
struct PV p0;
p0 = pvPack(pvCreate, .5 | .5 | .5, "b");

/* --- Constraint: b1 = b2  <=>  b1 - b2 = 0 ----------------------------- */
struct cmlmtControl c0;
c0 = cmlmtControlCreate;
c0.A = { 1 -1 0 };
c0.B = { 0 };
c0.PrintIters = 0;

/* --- Load cmlmt sample data --------------------------------------------- */
struct DS d0;
d0 = dsCreate;
d0.dname = getGAUSSHome() $+ "pkgs/cmlmt/examples/cmlmtpsn";

/* --- Estimate ------------------------------------------------------------ */
struct cmlmtResults out;
out = cmlmt(&lpsn, p0, d0, c0);

/* --- Build pubtable output ---------------------------------------------- */
struct ptModel mdl;
mdl = ptModelFromCmlmt("Poisson (b1 = b2)", out);
mdl = ptModelSetNotes(mdl, "Equality constraint: b1 = b2.  Data: cmlmtpsn.");

struct ptTable tbl;
tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Constrained Poisson MLE");

call ptExport(tbl, "addon_cmlmt.md");
call ptExport(tbl, "addon_cmlmt.html");

print "addon_cmlmt: table exported.";
