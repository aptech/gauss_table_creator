new;
library tsmt, pubtable;
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable_tsmt.src

proc (0) = checkScalarEqual(actual, expected, label);
    if actual /= expected;
        errorlog label $+ " failed. Expected " $+ ftos(expected, "%g", 1, 0) $+ ", got " $+ ftos(actual, "%g", 1, 0);
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
** automtOut, varmamtOut, lsdvmtOut, switchmtOut, garchEstimation, and
** tscsmtOut all come from estimation procs (autoregFit/varmaFit/lsdvFit/
** switchFit/garchFit/tscsFit) that are not part of the compiled tsmt
** library and depend on private helper procs spread across multiple
** source files (and, for garchFit/garchControlCreate, trigger an unrelated
** garchControl redefinition conflict with the timeseries package, error
** G0465 -- see test_pubtable_tsmt.e for the same issue with arimaFit). So,
** as with arimamtOut in test_pubtable_tsmt.e, each adapter here is
** exercised against a manually populated output struct matching the
** documented field shapes instead of a live estimation call.
*/

/*
** automtOut (autoregFit): 2 regression coefficients + AR(2)
*/
struct automtOut aro;
aro.coefs = 0.50 | -0.30;
aro.vcb = eye(2) * 0.01;
aro.phi = 0.40 | 0.20;
aro.vcphi = eye(2) * 0.02;
aro.sigsq = 1.10;
aro.tobs = 100;
aro.rsq = 0.62;
aro.chisq = 145.2;
aro.vsig = 0.05;

struct ptTable aroTbl;
aroTbl = ptFromAutomt(aro);
checkStringEqual(aroTbl.title, "Autoregression results", "automt table title");
checkStringEqual(aroTbl.rowNames[1], "X1", "automt first regressor row label");
checkStringEqual(aroTbl.rowNames[1 + 2*rows(aro.coefs)], "AR1", "automt first AR row label");
checkScalarEqual(rows(aroTbl.body), 2*(rows(aro.coefs) + rows(aro.phi)) + 4, "automt table row count includes statistic and GOF rows");

/*
** varmamtOut (varmaFit): VAR(1) with 2 series -> PV with 6 parameters
*/
struct varmamtOut vout;
vout.par = pvPacki(pvCreate(), reshape(0.30 | -0.10 | 0.05 | 0.40, 2, 2), "phi", 1);
vout.par = pvPacksi(vout.par, eye(2) * 0.02, "vc", 2);
vout.covpar = eye(pvLength(vout.par)) * 0.01;
vout.aic = 12.4;
vout.bic = 14.1;

struct ptTable varmaTbl;
varmaTbl = ptFromVarmamt(vout);
checkStringEqual(varmaTbl.title, "VARMA results", "varma table title");
checkScalarEqual(rows(varmaTbl.body), 2*rows(pvGetParVector(vout.par)) + 2, "varma table row count includes statistic and GOF rows");

/*
** lsdvmtOut (lsdvFit): AR(2) plus 3 regressors
*/
struct lsdvmtOut lout;
lout.autoCoefficients = 0.35 | 0.15;
lout.autoStderrs = 0.08 | 0.08;
lout.regCoefficients = 0.50 | -0.25 | 0.10;
lout.regStderrs = 0.05 | 0.06 | 0.04;
lout.numObservations = 100;
lout.SSresidual = 24.5;
lout.SSTotal = 80.2;

struct ptTable lsdvTbl;
lsdvTbl = ptFromLsdvmt(lout);
checkStringEqual(lsdvTbl.title, "LSDV results", "lsdv table title");
checkStringEqual(lsdvTbl.rowNames[1], "AR1", "lsdv first AR row label");
checkStringEqual(lsdvTbl.rowNames[1 + 2*rows(lout.autoCoefficients)], "X1", "lsdv first regressor row label");

/*
** switchmtOut (switchFit): 2-state Markov-switching, no AR terms
*/
struct switchmtOut sout;
sout.par = pvPacki(pvCreate(), 3.3 | -2.7, "beta0", 1);
sout.par = pvPacki(sout.par, 10 | 37, "sigma", 4);
sout.par = pvPacki(sout.par, 0.8 | 0.8, "p", 5);
sout.covPar = eye(pvLength(sout.par)) * 0.1;
sout.logl = -100.4;

struct ptTable switchTbl;
switchTbl = ptFromSwitchmt(sout);
checkStringEqual(switchTbl.title, "Markov-switching results", "switchmt table title");
checkScalarEqual(rows(switchTbl.body), 2*rows(pvGetParVector(sout.par)) + 1, "switchmt table row count includes statistic and GOF rows");

/*
** garchEstimation (garchFit): GARCH(1,1)
*/
struct garchEstimation gout;
gout.par = pvPacki(pvCreate(), 0.01, "beta0", 1);
gout.par = pvPacki(gout.par, 0.3, "garch", 4);
gout.par = pvPacki(gout.par, 0.2, "arch", 5);
gout.moment = eye(3) * 1e-4;
gout.aic = -512.3;
gout.bic = -498.7;
gout.fct = 260.1;
gout.numObs = 500;

struct ptTable garchTbl;
garchTbl = ptFromGarchmt(gout);
checkStringEqual(garchTbl.title, "GARCH results", "garch table title");
checkScalarEqual(rows(garchTbl.body), 2*rows(pvGetParVector(gout.par)) + 4, "garch table row count includes statistic and GOF rows");

/*
** tscsmtOut (tscsFit): 2-regressor panel, FE vs error-components estimates
*/
struct tscsmtOut tso;
tso.bdv = 0.40 | 0.15;
tso.vcdv = eye(2) * 0.02;
tso.bec = 1.0 | 0.45 | 0.18;
tso.vcec = eye(3) * 0.01;

struct ptTable tscsTbl;
tscsTbl = ptFromTscsmt(tso);
checkStringEqual(tscsTbl.title, "Panel results", "tscsmt table title");
checkScalarEqual(cols(tscsTbl.body), 2, "tscsmt table has FE and EC columns");
checkStringEqual(tscsTbl.rowNames[1], "x1", "tscsmt first term is x1 (from FE model)");
checkStringEqual(tscsTbl.rowNames[1 + 2*rows(tso.bdv)], "Constant", "tscsmt Constant row appended after FE terms (EC-only term)");

print "pubtable tsmt extra adapter tests passed";
