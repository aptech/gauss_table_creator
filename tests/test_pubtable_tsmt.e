new;
library tsmt, pubtable;
#include c:\gauss26\pkgs\tsmt\src\tspanel.src

proc (0) = checkScalarEqual(actual, expected, label);
    if actual /= expected;
        errorlog label $+ " failed.";
        end;
    endif;
endp;

proc (0) = checkStringEqual(actual, expected, label);
    if actual $/= expected;
        errorlog label $+ " failed. Expected '" $+ expected $+ "', got '" $+ actual $+ "'";
        end;
    endif;
endp;

/*
** ARIMA adapter
**
** arimaFit itself triggers an unrelated package conflict in this GAUSS
** install (tsmt vs. timeseries both define `garchControl` with a
** different number of elements, error G0465), so the adapter is
** exercised here against a manually populated arimamtOut struct that
** matches the documented field shapes instead of a live arimaFit call.
**
** out.b always appends the constant as its last row, but out.vcb covers
** only the AR/MA terms (confirmed empirically against a live arimaFit()
** call) — so vcb is sized for just AR1+MA1 here, not the constant.
*/
struct arimamtOut amo;
amo.b = 0.30 | -0.20 | 0.05;
amo.vcb = eye(2) * 0.01;
amo.ll = -120.5;
amo.aic = 247.0;
amo.sbc = 258.4;
amo.p = 1;
amo.q = 1;

struct ptTable arimaTbl;
arimaTbl = ptFromArimamt(amo);
checkStringEqual(arimaTbl.title, "ARIMA results", "arima table title");
checkScalarEqual(rows(arimaTbl.body), 2 * rows(amo.b) + 3, "arima table row count includes statistic and GOF rows");
checkStringEqual(arimaTbl.rowNames[1], "AR1", "arima AR term name");
checkStringEqual(arimaTbl.rowNames[rows(arimaTbl.rowNames) - 4], "Constant", "arima constant term name");

/*
** tspanel adapter (Grunfeld panel data)
*/
data = loadd(getGAUSSHome() $+ "pkgs/tsmt/examples/grunfeld.dat");
py = data[., 3];
px = data[., 4 5];
grp = data[., 1];

struct tsPanelOut panelOut;
panelOut = tspanel(py, px, grp, 0);

struct ptTable feTbl;
feTbl = ptFromTsPanel(panelOut.estFE);
checkStringEqual(feTbl.title, "Fixed effects results", "tspanel FE table title");
checkScalarEqual(rows(feTbl.body), 2 * rows(panelOut.estFE.coef) + 3, "tspanel FE table row count includes statistic and GOF rows");
checkStringEqual(feTbl.rowNames[1], "X1", "tspanel FE has no constant row");

struct ptTable olsTbl;
olsTbl = ptFromTsPanel(panelOut.estPooledOLS);
checkStringEqual(olsTbl.title, "Pooled OLS results", "tspanel OLS table title");
checkStringEqual(olsTbl.rowNames[1], "Constant", "tspanel OLS includes constant row");

print "pubtable tsmt adapter tests passed";
