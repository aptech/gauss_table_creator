# cmlmt Adapter

Optional adapter for the **cmlmt** (Constrained Maximum Likelihood MT) package.
Activated when `PT_USE_CMLMT` is defined in `pubtable.dec` — run `pubtableSet()` once
after installing cmlmt, then use `library cmlmt, pubtable;` in your programs.

## Format
> mdl = ptModelFromCmlmt(name, out)
> tbl = ptFromCmlmt(out)

## Input
| Parameter | Description |
|:------- |:------- |
| name | String display name for the model (column header in comparison tables). |
| out | `cmlmtResults` struct returned by `cmlmt`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` with parameter names from `pvGetParNames(out.par)`, estimates from `pvGetParVector(out.par)`, SE from `sqrt(diag(out.acov))`, and p-values from a standard-Normal z-test. |
| tbl | `ptTable` (shorthand via `ptFromCmlmt`). |

## GOF rows
- `"Log-likelihood"` — `out.fct`
- `"AIC"` — `out.aic`
- `"BIC"` — `out.bic`

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

mdl = ptModelFromCmlmt("Poisson (b1=b2)", out);
mdl = ptModelSetNotes(mdl, "Equality constraint: b1 = b2.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Constrained Poisson MLE");
call ptExport(tbl, "cmlmt.md");
```

## See Also
`pubtableSet`, `ptModelFromMaxlikmt`, `ptModelCreate`, `ptModelTable`
