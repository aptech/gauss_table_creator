# optmt Adapter

Optional adapter for the **optmt** (Optimization MT) package. Activated when
`PT_USE_OPTMT` is defined in `pubtable.dec` — run `pubtableSet()` once after
installing optmt, then use `library optmt, pubtable;` in your programs.

## Format
> tbl = ptTableFromOptmt(out)

## Input
| Parameter | Description |
|:------- |:------- |
| out | `optmtResults` struct returned by `optmt`. |

## Output
| Output | Description |
|:------- |:------- |
| tbl | `ptTable` with columns `Parameter` / `Estimate` / `Gradient`. No standard errors or p-values — `optmtResults` carries no covariance matrix. |

## Notes
- `ptTableFromOptmt` is a table adapter, not a model adapter. It returns a `ptTable`
  directly rather than a `ptModel`, so it is not compatible with `ptModelCompare`.
- For optimization problems where a covariance matrix is available (e.g. from a
  finite-difference Hessian), use `ptModelCreate` directly with the SE you compute.
- Parameter names come from `pvGetParNames(out.par)`.

## Prerequisites
1. optmt is installed (`library optmt;` loads without error).
2. `pubtableSet()` has been run (creates `pubtable.dec` with `#define PT_USE_OPTMT`).

## Example
```gauss
new;
library optmt, pubtable;

proc obj(struct PV p, struct DS d, ind);
    local x;
    struct modelResults mm;

    x = pvUnpack(p, "x");

    if ind[1];
        mm.function = (x[1] - 2)^2 + (x[2] - 3)^2;
    endif;
    retp(mm);
endp;

struct PV p0;
p0 = pvPack(pvCreate, 0 | 0, "x");

struct optmtControl c0;
c0 = optmtControlCreate;
c0.PrintIters = 0;

struct DS d0;
d0 = dsCreate;

struct optmtResults out;
out = optmt(&obj, p0, d0, c0);

tbl = ptTableFromOptmt(out);
tbl = ptSetTitle(tbl, "Optimization Results");
call ptExport(tbl, "optmt.md");
```

## See Also
`pubtableSet`, `ptModelFromMaxlikmt`, `ptModelFromCmlmt`, `ptTableCreate`
