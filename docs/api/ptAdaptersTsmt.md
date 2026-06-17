# tsmt Adapters

Optional adapters for the **tsmt** (Time Series MT) package. Activated when `PT_USE_TSMT`
is defined in `pubtable.dec` — run `pubtableSet()` once after installing tsmt, then use
`library tsmt, pubtable;` in your programs.

## Adapters at a glance

| Procedure | Input struct | Returns | Notes |
|:------- |:------- |:------- |:------- |
| `ptModelFromArimamt(name, out)` | `arimamtOut` | `ptModel` | AR/MA/Constant terms; Log-likelihood/AIC/SBC GOF. |
| `ptFromArimamt(out)` | `arimamtOut` | `ptTable` | Shorthand for single-model ARIMA table. |
| `ptModelFromTsPanel(name, out)` | `tsPanelEstimationOut` | `ptModel` | Panel estimates; N/T/R² GOF. Requires `#include tspanel.src`. |
| `ptFromTsPanel(out)` | `tsPanelEstimationOut` | `ptTable` | Shorthand for panel. |
| `ptModelFromAutomt(name, out)` | `automtOut` | `ptModel` | Autoregression (generic `X1`/`X2`/… labels). |
| `ptFromAutomt(out)` | `automtOut` | `ptTable` | Shorthand for autoregression. |
| `ptModelFromVarmamt(name, out)` | `varmamtOut` | `ptModel` | VAR/VMA (generic labels; uses PV name/value pattern). |
| `ptFromVarmamt(out)` | `varmamtOut` | `ptTable` | Shorthand for VAR/VMA. |
| `ptModelFromLsdvmt(name, out)` | `lsdvmtOut` | `ptModel` | LSDV (least-squares dummy variable; generic labels). |
| `ptFromLsdvmt(out)` | `lsdvmtOut` | `ptTable` | Shorthand for LSDV. |
| `ptModelFromSwitchmt(name, out)` | `switchmtOut` | `ptModel` | Switching regression (PV name/value pattern). |
| `ptFromSwitchmt(out)` | `switchmtOut` | `ptTable` | Shorthand for switching regression. |
| `ptModelFromGarchmt(name, out)` | `garchEstimation` | `ptModel` | GARCH (PV name/value pattern; Log-likelihood/AIC/SBC GOF). |
| `ptFromGarchmt(out)` | `garchEstimation` | `ptTable` | Shorthand for GARCH. |
| `ptModelFromTscsmtDV(name, out)` | `tscsmtOut` | `ptModel` | TSCS within/dummy-variable estimate column. |
| `ptModelFromTscsmtEC(name, out)` | `tscsmtOut` | `ptModel` | TSCS error-components (GLS) estimate column. |
| `ptFromTscsmt(out)` | `tscsmtOut` | `ptTable` | Comparison table with DV and EC columns side-by-side. |

## Prerequisites
1. tsmt is installed (`library tsmt;` loads without error).
2. `pubtableSet()` has been run (creates `pubtable.dec` with `#define PT_USE_TSMT`).
3. For `tsPanelEstimationOut` adapters, also `#include tspanel.src` in your program.

## Usage
```gauss
library tsmt, pubtable;
/* PT_USE_TSMT is activated automatically via lib/pubtable.xml */
```

For dev-path installs:
```gauss
library tsmt;
#include tsmt.sdf;
#include pubtable.dec;
#include pubtable.src;
```

## Label note
`automtOut`, `varmamtOut`, `lsdvmtOut`, `switchmtOut`, `garchEstimation`, and
`tscsmtOut` do not carry the original variable names in their output structs. These
adapters use generic labels (`AR1`, `AR2`, …, `X1`, `X2`, …). Use `ptModelSetNames`
after calling the adapter to supply descriptive labels.

## Example — ARIMA comparison
```gauss
new;
library tsmt, pubtable;

rndseed 42;
n = 200;
y = cumsumc(rndn(n, 1));

ctl = arimaControlCreate();
ctl.quiet = 1;

ar1 = arimaFit(y, 1, 1, 0, ctl);
ar2 = arimaFit(y, 2, 1, 0, ctl);

ar1Mdl = ptModelFromArimamt("ARIMA(1,1,0)", ar1);
ar2Mdl = ptModelFromArimamt("ARIMA(2,1,0)", ar2);

struct ptModel models;
models = reshape(ar1Mdl, 2, 1);
models[2] = ar2Mdl;

tbl = ptModelCompare(models);
tbl = ptSetTitle(tbl, "ARIMA Model Comparison");
call ptExport(tbl, "arima_compare.md");
```

## See Also
`pubtableSet`, `ptModelCreate`, `ptModelSetNames`, `ptModelCompare`, `ptExport`
