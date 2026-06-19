/*
** addon_cmlmt.e
**
** pubtable integration with the cmlmt (Constrained Maximum Likelihood MT)
** package.  Fits a Poisson regression with a linear equality constraint
** using the cmlmtpsn dataset that ships with cmlmt.
**
** Model: E[y] = exp(x * b),  subject to b1 = b2
**
** Prerequisites:
**   1. Run pubtableSet() once to generate pubtable.dec with PT_USE_CMLMT.
**   2. cmlmt must be installed (library cmlmt loads without error).
**
** Steps:
**   1. Define the Poisson log-likelihood procedure.
**   2. Set initial parameters and the equality constraint.
**   3. Load the sample data.
**   4. Estimate with cmlmt.
**   5. Convert to a pubtable with ptModelFromCmlmt.
**   6. Export.
*/

new;
library cmlmt, pubtable;

/* Step 1: Log-likelihood sum of per-observation Poisson log-densities */
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

/* Step 2a: Pack starting values into a PV parameter vector */
struct PV p0;
p0 = pvPack(pvCreate, .5 | .5 | .5, "b");

/* Step 2b: Equality constraint b1 = b2  <=>  [1 -1 0] * b = 0 */
struct cmlmtControl c0;
c0 = cmlmtControlCreate;
c0.A = { 1 -1 0 };
c0.B = { 0 };
c0.PrintIters = 0;

/* Step 3: Load cmlmt's bundled Poisson sample dataset */
struct DS d0;
d0 = dsCreate;
d0.dname = getGAUSSHome() $+ "pkgs/cmlmt/examples/cmlmtpsn";

/* Step 4: Estimate */
struct cmlmtResults out;
out = cmlmt(&lpsn, p0, d0, c0);

/* Step 5: Convert to pubtable — no 'struct ptModel' or 'struct ptTable' needed */
mdl = ptModelFromCmlmt("Poisson (b1 = b2)", out);
mdl = ptModelSetNotes(mdl, "Equality constraint: b1 = b2.  Data: cmlmtpsn.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Constrained Poisson MLE");

/* Step 6: Export */
call ptExport(tbl, "addon_cmlmt.md");
call ptExport(tbl, "addon_cmlmt.html");
