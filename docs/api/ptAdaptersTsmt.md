# tsmt Adapters

Optional adapters for the **tsmt** (Time Series MT) package. Activated when `PT_USE_TSMT`
is defined in `pubtable.dec` — run `pubtableSet()` once after installing tsmt, then use
`library tsmt, pubtable;` in your programs.

## Adapters at a glance

| Procedure | Input struct | Returns | Notes |
|:------- |:------- |:------- |:------- |
| `ptModelFromArimamt(name, out)` | `arimamtOut` | `ptModel` | AR/MA/Constant terms; Log-likelihood/AIC/SBC GOF. |
| `ptFromArimamt(out)` | `arimamtOut` | `ptTable` | Shorthand for single-model ARIMA table. |
| `ptModelFromTsPanel(name, out)` | `tsPanelEstimationOut` | `ptModel` | Panel estimates; N/R²/Adj R² GOF. Requires `#include tspanel.src`. |
| `ptFromTsPanel(out)` | `tsPanelEstimationOut` | `ptTable` | Shorthand for panel. |
| `ptModelFromAutomt(name, out)` | `automtOut` | `ptModel` | Autoregression (generic `X1`/`X2`/… labels). |
| `ptFromAutomt(out)` | `automtOut` | `ptTable` | Shorthand for autoregression. |
| `ptModelFromVarmamt(name, out)` | `varmamtOut` | `ptModel` | VAR/VMA (generic labels; uses PV name/value pattern). |
| `ptFromVarmamt(out)` | `varmamtOut` | `ptTable` | Shorthand for VAR/VMA. |
| `ptModelFromLsdvmt(name, out)` | `lsdvmtOut` | `ptModel` | LSDV (least-squares dummy variable; generic labels). |
| `ptFromLsdvmt(out)` | `lsdvmtOut` | `ptTable` | Shorthand for LSDV. |
| `ptModelFromSwitchmt(name, out)` | `switchmtOut` | `ptModel` | Switching regression (PV name/value pattern). |
| `ptFromSwitchmt(out)` | `switchmtOut` | `ptTable` | Shorthand for switching regression. |
| `ptModelFromGarchmt(name, out)` | `garchEstimation` | `ptModel` | GARCH (PV name/value pattern; N/AIC/BIC/Fnc value GOF). |
| `ptFromGarchmt(out)` | `garchEstimation` | `ptTable` | Shorthand for GARCH. |
| `ptModelFromTscsmtDV(name, out)` | `tscsmtOut` | `ptModel` | TSCS within/dummy-variable estimate column. |
| `ptModelFromTscsmtEC(name, out)` | `tscsmtOut` | `ptModel` | TSCS error-components (GLS) estimate column. |
| `ptFromTscsmt(out)` | `tscsmtOut` | `ptTable` | Comparison table with DV and EC columns side-by-side. |

All adapters above except `ptModelFromTscsmtDV`/`ptModelFromTscsmtEC` are also reachable through the
standard [`ptModelFrom(name, out)`](ptModelFrom.md) dispatcher once tsmt and pubtable are loaded —
`ptModelFrom("AR(1)", ar1)` is equivalent to `ptModelFromArimamt("AR(1)", ar1)`. `tscsmtOut` is not
wired into the dispatcher because it has two distinct estimators with no single canonical model; use
`ptFromTscsmt` or call `ptModelFromTscsmtDV`/`ptModelFromTscsmtEC` directly.

## Prerequisites
1. tsmt is installed (`library tsmt;` loads without error).
2. `pubtableSet()` has been run (creates `pubtable.dec` with `#define PT_USE_TSMT`).
3. For `tsPanelEstimationOut` adapters, also `#include tspanel.src` in your program.

## Usage
```gauss
library tsmt, pubtable;
/* pubtable_tsmt.src includes pubtable.dec itself, so PT_USE_TSMT is defined
** automatically once pubtableSet() has been run — no further #include needed.
** Loading tsmt and pubtable in one statement matters: library tsmt; library
** pubtable; (two separate statements) would unload tsmt before pubtable_tsmt.src
** compiles, since each library statement unloads every library not named in it. */
```

For dev-path installs (direct `#include` instead of the package manager):
```gauss
library tsmt;
#include tsmt.sdf
#include C:\path\to\gauss_table_creator\src\pubtable.sdf
#include C:\path\to\gauss_table_creator\src\pubtable.src
#include C:\path\to\gauss_table_creator\src\pubtable_model.src
#include C:\path\to\gauss_table_creator\src\pubtable_render.src
#include C:\path\to\gauss_table_creator\src\pubtable_export.src
#include C:\path\to\gauss_table_creator\src\pubtable_tsmt.src
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

ar1Mdl = ptModelFrom("ARIMA(1,1,0)", ar1);
ar2Mdl = ptModelFrom("ARIMA(2,1,0)", ar2);

struct ptModel models;
models = reshape(ar1Mdl, 2, 1);
models[2] = ar2Mdl;

tbl = ptModelCompare(models);
tbl = ptSetTitle(tbl, "ARIMA Model Comparison");
call ptExport(tbl, "arima_compare.md");
```

## See Also
`pubtableSet`, `ptModelCreate`, `ptModelSetNames`, `ptModelCompare`, `ptExport`
