new;
library qardl;
#include qardl.sdf
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.sdf
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable.src
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable_qardl.src

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

proc (0) = checkStringContains(haystack, needle, label);
    if strindx(haystack, needle, 1) == 0;
        errorlog label $+ " failed. Could not find '" $+ needle $+ "' in rendered output.";
        end;
    endif;
endp;

/*
** Small deterministic ARDL(1,1) dataset.
*/
n = 120;
rndseed 260614;
x1 = zeros(n, 1);
x2 = zeros(n, 1);
y = zeros(n, 1);
e1 = rndn(n, 1);
e2 = rndn(n, 1);
ey = 0.05*rndn(n, 1);
jj = 2;
do until jj > n;
    x1[jj] = 0.5*x1[jj-1] + e1[jj];
    x2[jj] = 0.5*x2[jj-1] + e2[jj];
    y[jj] = 0.4*y[jj-1] + 0.6*x1[jj] + 0.3*x1[jj-1] - 0.2*x2[jj] + 0.1*x2[jj-1] + ey[jj];
    jj = jj + 1;
endo;
data = y~x1~x2;
tau = { 0.25, 0.5, 0.75 };

/*
** ARDL levels and ECM
*/
struct ardlOut arOut;
arOut = ardl(data, 1, 1, "", 0);

struct ptTable arTbl;
arTbl = ptFromArdl(arOut);
checkStringEqual(arTbl.title, "ARDL levels", "ardl table title");
checkScalarEqual(rows(arTbl.body), 2*(arOut.k + rows(arOut.phi) + 2) + 2, "ardl table row count includes statistic and GOF rows");
checkStringEqual(arTbl.rowNames[1], "beta_x1", "ardl first long-run row label");

struct ardlECMOut arECMOut;
arECMOut = ardlECM(data, 1, 1, "", 0);

struct ptTable arECMTbl;
arECMTbl = ptFromArdlECM(arECMOut);
checkStringEqual(arECMTbl.title, "ARDL ECM", "ardl ECM table title");
checkStringEqual(arECMTbl.rowNames[1], "beta_lr_x1", "ardl ECM first long-run row label");

/*
** QARDL levels and ECM (per-quantile comparison columns)
*/
struct qardlOut qaOut;
qaOut = qardl(data, 1, 1, tau, "iid", 0, 0);

struct ptTable qaTbl;
qaTbl = ptFromQardl(qaOut);
checkStringEqual(qaTbl.title, "QARDL results", "qardl table title");
checkScalarEqual(cols(qaTbl.body), rows(tau), "qardl table has one column per quantile");
checkStringEqual(qaTbl.colNames[1], "tau=0.25", "qardl first quantile column header");
checkStringEqual(qaTbl.colNames[3], "tau=0.75", "qardl third quantile column header");
checkStringEqual(qaTbl.rowNames[1], "beta_x1", "qardl first long-run row label");

struct qardlECMOut qECMOut;
qECMOut = qardlECM(data, 1, 1, tau, "iid", 0, 0);

struct ptTable qECMTbl;
qECMTbl = ptFromQardlECM(qECMOut);
checkStringEqual(qECMTbl.title, "QARDL-ECM results", "qardl ECM table title");
checkScalarEqual(cols(qECMTbl.body), rows(tau), "qardl ECM table has one column per quantile");
checkStringEqual(qECMTbl.rowNames[1], "beta_lr_x1", "qardl ECM first long-run row label");

/*
** NARDL levels and ECM
*/
struct nardlOut naOut;
naOut = nardl(data, 1, 1, "", 0);

struct ptTable naTbl;
naTbl = ptFromNardl(naOut);
checkStringEqual(naTbl.title, "NARDL levels", "nardl table title");
checkStringEqual(naTbl.rowNames[1], "beta_pos_x1", "nardl first positive long-run row label");
checkStringEqual(naTbl.rowNames[1 + 2*rows(naOut.decomp_vars)], "beta_neg_x1", "nardl first negative long-run row label");

struct nardlECMOut naECMOut;
naECMOut = nardlECM(data, 1, 1, "", 0);

struct ptTable naECMTbl;
naECMTbl = ptFromNardlECM(naECMOut);
checkStringEqual(naECMTbl.title, "NARDL ECM", "nardl ECM table title");
checkStringEqual(naECMTbl.rowNames[1], "beta_pos_x1", "nardl ECM first positive long-run row label");

/*
** CS-ARDL levels and ECM (small balanced panel)
*/
nunits = 3;
TT = 50;
panel = zeros(nunits*TT, 4);
rndseed 260601;
rr = 1;
for ii(1, nunits, 1);
    x1_prev = 0;
    y_prev = 0;
    for tt(1, TT, 1);
        x1v = 0.5*x1_prev + 0.05*tt + 0.1*ii + rndn(1, 1);
        yv = 0.4*y_prev + 0.3*x1v + 0.05*ii + 0.1*rndn(1, 1);
        panel[rr, .] = ii~yv~x1v~tt;
        x1_prev = x1v;
        y_prev = yv;
        rr = rr + 1;
    endfor;
endfor;
panel = panel[., 1:3];

struct csardlOut csaOut;
csaOut = csardl(panel, 1, 1, 1, "", 0);

struct ptTable csaTbl;
csaTbl = ptFromCsardl(csaOut);
checkStringEqual(csaTbl.title, "CS-ARDL levels", "csardl table title");
checkStringEqual(csaTbl.rowNames[1], "beta_x1", "csardl first long-run row label");

struct csardlECMOut csaECMOut;
csaECMOut = csardlECM(panel, 1, 1, 1, "", 0);

struct ptTable csaECMTbl;
csaECMTbl = ptFromCsardlECM(csaECMOut);
checkStringEqual(csaECMTbl.title, "CS-ARDL ECM", "csardl ECM table title");
checkStringEqual(csaECMTbl.rowNames[1], "beta_lr_x1", "csardl ECM first long-run row label");

/*
** Full workflows
*/
struct ardlFullOut afOut;
afOut = ardlFull(data, 2, 2, "", 0, "bic", 0.1, 3, 0);

struct ptTable afTbl;
afTbl = ptFromArdlFull(afOut);
checkStringEqual(afTbl.title, "ARDL levels", "ardlFull table title");

struct qardlFullOut qfOut;
qfOut = qardlFull(data, 2, 2, tau, "", 0, "bic", "iid", 0, "two-step", 0.1, 0);

struct ptTable qfTbls;
qfTbls = ptTablesFromQardlFull(qfOut);
checkScalarEqual(rows(qfTbls), 2, "qardlFull tables array has levels and ECM tables");
checkStringEqual(qfTbls[1].title, "QARDL results", "qardlFull levels table title");
checkStringEqual(qfTbls[2].title, "QARDL-ECM results", "qardlFull ECM table title");

export_base = "C:\\Users\\eclow\\Documents\\GitHub\\gauss_table_creator\\tests\\_pubtable_test_qardl";
call deleteFile(export_base $+ ".md");
checkScalarEqual(ptExportAll(qfTbls, export_base $+ ".md"), 0, "qardlFull multi-table markdown export");

/*
** Dispatcher
*/
struct ptTable dispTbl;
dispTbl = ptFromArdlFamily(arOut);
checkStringEqual(dispTbl.title, "ARDL levels", "ptFromArdlFamily dispatches ardlOut");

dispTbl = ptFromArdlFamily(qaOut);
checkStringEqual(dispTbl.title, "QARDL results", "ptFromArdlFamily dispatches qardlOut");

print "pubtable qardl adapter tests passed";
