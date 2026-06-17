# Built-in Adapters

Explicit adapters for GAUSS estimation and summary output structs that ship with the
base pubtable package. All are available with `library pubtable;` — no optional
library or `pubtable.dec` configuration required.

## Adapters at a glance

| Procedure | Input struct | Returns | Notes |
|:------- |:------- |:------- |:------- |
| `ptModelFromOlsmt(name, out)` | `olsmtOut` | `ptModel` | Estimates, SE, p-values (t-dist), N/R²/DF GOF. |
| `ptFromOlsmt(out)` | `olsmtOut` | `ptTable` | Shorthand: `ptModelTable(ptModelFromOlsmt("OLS results", out))`. |
| `ptModelFromFgls(name, out)` | `fglsOut` | `ptModel` | FGLS estimates, SE, p-values; CI pre-loaded from `out.ci`. |
| `ptFromFgls(out)` | `fglsOut` | `ptTable` | Shorthand for FGLS. |
| `ptModelFromGlm(name, out)` | `glmOut` | `ptModel` | GLM estimates, SE, p-values; N/DF/AIC/BIC GOF. |
| `ptFromGlm(out)` | `glmOut` | `ptTable` | Shorthand for GLM. |
| `ptModelFromGmm(name, out)` | `gmmOut` | `ptModel` | GMM estimates, SE from `sqrt(diag(out.covPar))`; N/J-statistic/DF GOF. No p-values (set manually with `ptModelSetPValues`). |
| `ptFromDstatmt(out)` | `dstatmtOut` | `ptTable` | Descriptive statistics table: mean, std. dev., min, max, valid N, missing N. |

## Dispatcher
`ptTableFrom(out)` and `ptModelFrom(name, out)` dispatch to the correct adapter using
`isStructType`. `ptFromDstatmt` is wired into `ptTableFrom`; `ptModelFromGmm` is
wired into `ptModelFrom`. Use the explicit adapters directly if you need control over
the model name or want to avoid the dispatcher.

## Format

### ptModelFromOlsmt / ptFromOlsmt
```
mdl = ptModelFromOlsmt(name, out)
tbl = ptFromOlsmt(out)
```

### ptModelFromFgls / ptFromFgls
```
mdl = ptModelFromFgls(name, out)
tbl = ptFromFgls(out)
```

### ptModelFromGlm / ptFromGlm
```
mdl = ptModelFromGlm(name, out)
tbl = ptFromGlm(out)
```

### ptModelFromGmm
```
mdl = ptModelFromGmm(name, out)
```

### ptFromDstatmt
```
tbl = ptFromDstatmt(out)
```

## Input
| Parameter | Description |
|:------- |:------- |
| name | String display name for model-returning adapters (column header in comparison tables). |
| out | The estimation/summary output struct from the corresponding GAUSS command. |

## Output
| Output | Description |
|:------- |:------- |
| mdl | `ptModel` struct populated from the output struct's estimates, SE, p-values, and GOF. |
| tbl | `ptTable` struct (via `ptModelTable`), for the shorthand adapters and `ptFromDstatmt`. |

## Example — OLS
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

mdl = ptModelFromOlsmt("OLS", out);
mdl = ptModelSetNotes(mdl, "Dependent variable: mpg.");

tbl = ptModelTable(mdl);
tbl = ptSetTitle(tbl, "OLS Regression");
call ptExport(tbl, "ols.md");
```

## Example — descriptive statistics
```gauss
new;
library pubtable;

struct dstatmtControl dc;
struct dstatmtOut dout;
dc = dstatmtControlCreate;

dout = dstatmt(dc, getGAUSSHome() $+ "examples/auto.dat", "mpg + weight + length");

tbl = ptFromDstatmt(dout);
tbl = ptSetTitle(tbl, "Summary Statistics");
call ptExport(tbl, "dstats.md");
```

## See Also
`ptModelFrom`, `ptTableFrom`, `ptModelTable`, `ptModelCompare`
