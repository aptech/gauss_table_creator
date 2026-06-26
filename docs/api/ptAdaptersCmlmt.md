# cmlmt Adapter

Optional adapter for the **cmlmt** (Constrained Maximum Likelihood MT) package.
Activated when `PT_USE_CMLMT` is defined in `pubtable.dec` — run `pubtableSet()` once
after installing cmlmt, then use `library cmlmt, pubtable;` in your programs.

## Format
> mdl = ptModelFrom(name, out)        -- standard dispatcher, recommended
> mdl = ptModelFromCmlmt(name, out)   -- equivalent, explicit form
> tbl = ptFromCmlmt(out)

## Input
| Parameter | Description |
|:------- |:------- |
| name | String display name for the model (column header in comparison tables). |
| out | `cmlmtResults` struct returned by `cmlmt`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` with parameter names from `pvGetParNames(out.par)`, estimates from `pvGetParVector(out.par)`, SE from `sqrt(diag(out.covPar))`, and p-values from a standard-Normal z-test. |
| tbl | `ptTable` (shorthand via `ptFromCmlmt`). |

## GOF rows
- `"N"` — `out.numObs`
- `"Function value"` — `out.fct`
- `"AIC"` / `"BIC"` — always computed (`-2*fval + 2*k` / `-2*fval + 2*k*ln(n)`) and
  appended, but hidden by default. Call `ptModelSetAicBic(mdl, 1)` to show them. See
  [ptModelSetters](ptModelSetters.md).

## Prerequisites
1. cmlmt is installed (`library cmlmt;` loads without error).
2. `pubtableSet()` has been run (creates `pubtable.dec` with `#define PT_USE_CMLMT`).

## Example
```gauss
new;
library cmlmt, pubtable;

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

struct PV p0;
p0 = pvPack(pvCreate, .5 | .5 | .5, "b");

struct cmlmtControl c0;
c0 = cmlmtControlCreate;
c0.A = { 1 -1 0 };
c0.B = { 0 };
c0.PrintIters = 0;

struct DS d0;
d0 = dsCreate;
d0.dname = getGAUSSHome() $+ "pkgs/cmlmt/examples/cmlmtpsn";

struct cmlmtResults out;
out = cmlmt(&lpsn, p0, d0, c0);

mdl = ptModelFrom("Poisson (b1=b2)", out);
mdl = ptModelSetNotes(mdl, "Equality constraint: b1 = b2.");
mdl = ptModelSetDataLabel(mdl, "cmlmtpsn");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Constrained Poisson MLE");
call ptExport(tbl, "cmlmt.md");

/* To also show the AIC/BIC GOF rows this adapter always computes: */
mdl = ptModelSetAicBic(mdl, 1);
tbl = ptModelTable(mdl);
```

## See Also
`pubtableSet`, `ptModelFromMaxlikmt`, `ptModelCreate`, `ptModelTable`, `ptModelSetDataLabel`, `ptModelSetAicBic`
