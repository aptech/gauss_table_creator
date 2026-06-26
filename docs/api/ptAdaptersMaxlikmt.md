# maxlikmt Adapter

Optional adapter for the **maxlikmt** (Maximum Likelihood MT) package. Activated when
`PT_USE_MAXLIKMT` is defined in `pubtable.dec` — run `pubtableSet()` once after
installing maxlikmt, then use `library maxlikmt, pubtable;` in your programs.

## Format
> mdl = ptModelFrom(name, out)          -- standard dispatcher, recommended
> mdl = ptModelFromMaxlikmt(name, out)  -- equivalent, explicit form
> tbl = ptFromMaxlikmt(out)

## Input
| Parameter | Description |
|:------- |:------- |
| name | String display name for the model (column header in comparison tables). |
| out | `maxlikmtResults` struct returned by `maxlikmt`. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` with parameter names from `pvGetParNames(out.par)`, estimates from `pvGetParVector(out.par)`, SE from `sqrt(diag(out.covPar))`, and p-values from a standard-Normal z-test. |
| tbl | `ptTable` (shorthand via `ptFromMaxlikmt`). |

## GOF rows
- `"N"` — `out.numObs`
- `"Log-likelihood"` — `out.fct`
- `"AIC"` / `"BIC"` — always computed (`-2*fval + 2*k` / `-2*fval + 2*k*ln(n)`) and
  appended, but hidden by default. Call `ptModelSetAicBic(mdl, 1)` to show them. See
  [ptModelSetters](ptModelSetters.md).

## Prerequisites
1. maxlikmt is installed (`library maxlikmt;` loads without error).
2. `pubtableSet()` has been run (creates `pubtable.dec` with `#define PT_USE_MAXLIKMT`).

## Example
```gauss
new;
library maxlikmt, pubtable;

/* Normal log-likelihood for linear regression */
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

struct PV p0;
p0 = pvPack(pvCreate, 50, "b0");
p0 = pvPack(p0, -0.01 | -0.1, "b");
p0 = pvPack(p0, 10, "s2");

struct maxlikmtControl c0;
c0 = maxlikmtcontrolcreate;
c0.Bounds = { -500 500, -10 10, -10 10, 0.01 500 };
c0.PrintIters = 0;

z = loadd(getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

struct DS d0;
d0 = reshape(dsCreate, 2, 1);
d0[1].dataMatrix = z[., 1];
d0[2].dataMatrix = z[., 2:3];

struct maxlikmtResults out;
out = maxlikmt(&lnorm, p0, d0, c0);

mdl = ptModelFrom("Normal MLE", out);
mdl = ptModelSetNotes(mdl, "MLE estimates match OLS.");
mdl = ptModelSetDataLabel(mdl, "auto.dat");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "Normal MLE");
call ptExport(tbl, "maxlikmt.md");

/* To also show the AIC/BIC GOF rows this adapter always computes: */
mdl = ptModelSetAicBic(mdl, 1);
tbl = ptModelTable(mdl);
```

## See Also
`pubtableSet`, `ptModelFromCmlmt`, `ptModelCreate`, `ptModelTable`, `ptModelSetDataLabel`, `ptModelSetAicBic`
