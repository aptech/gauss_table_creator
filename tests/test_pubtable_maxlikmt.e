new;
library maxlikmt, cmlmt, pubtable;
#include C:\Users\eclow\Documents\GitHub\gauss_table_creator\src\pubtable_qardl.src

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
** Shared tobit log-likelihood for maxlikmt and cmlmt probes
*/
proc lpr(struct PV p, struct DS d, ind);
    local s2, b0, b, y, x, yh, u, res, g1, g2;
    struct modelResults mm;

    b0 = pvUnpack(p, "b0");
    b = pvUnpack(p, "b");
    s2 = pvUnpack(p, "variance");
    y = d[1].dataMatrix;
    x = d[2].dataMatrix;

    yh = b0 + x * b;
    res = y - yh;
    u = y[., 1] ./= 0;

    if ind[1];
        mm.function = u .* lnpdfmvn(res, s2) + (1 - u) .* (ln(cdfnc(yh / sqrt(s2))));
    endif;

    if ind[2];
        yh = yh / sqrt(s2);
        g1 = ((res ~ x .* res) / s2) ~ ((res .* res / s2) - 1) / (2 * s2);
        g2 = (-(ones(rows(x), 1) ~ x) / sqrt(s2)) ~ (yh / (2 * s2));
        g2 = (pdfn(yh) ./ cdfnc(yh)) .* g2;
        mm.gradient = u .* g1 + (1 - u) .* g2;
    endif;

    retp(mm);
endp;

struct PV p0;
p0 = pvPack(pvCreate, 1, "b0");
p0 = pvPack(p0, 1 | 1 | 1, "b");
p0 = pvPack(p0, 1, "variance");

struct DS d0;
d0 = reshape(dsCreate, 2, 1);
z = loadd(getGAUSSHome() $+ "pkgs/maxlikmt/examples/maxlikmttobit");
d0[1].dataMatrix = z[., 1];
d0[2].dataMatrix = z[., 2:4];

struct maxlikmtControl mlCtl;
mlCtl = maxlikmtcontrolcreate;
mlCtl.title = "tobit example";
mlCtl.printiters = 0;
mlCtl.algorithm = 4;
mlCtl.Bounds = { -10 10,
                 -10 10,
                 -10 10,
                 -10 10,
                 .1 10 };

struct maxlikmtResults mlOut;
mlOut = maxlikmt(&lpr, p0, d0, mlCtl);

struct ptTable mlTbl;
mlTbl = ptFromMaxlikmt(mlOut);
checkStringEqual(mlTbl.title, "Maximum likelihood results", "maxlikmt table title");
checkScalarEqual(rows(mlTbl.body), 2 * pvLength(mlOut.par) + 2, "maxlikmt table row count includes statistic and GOF rows");
checkStringEqual(mlTbl.rowNames[1], "b0[1,1]", "maxlikmt parameter name from pvGetParNames");

/* AIC/BIC: hidden by default (already covered by the row count check
** above), but always correctly computed by the adapter once revealed. */
local mlK, mlExpectedAic, mlExpectedBic;
struct ptModel mlMdl;
struct ptTable mlAicTbl;

mlMdl = ptModelFromMaxlikmt("MLE AIC/BIC", mlOut);
mlMdl = ptModelSetAicBic(mlMdl, 1);
mlAicTbl = ptModelTable(mlMdl);

mlK = pvLength(mlOut.par);
mlExpectedAic = -2 * mlOut.fct + 2 * mlK;
mlExpectedBic = -2 * mlOut.fct + 2 * mlK * ln(mlOut.numObs);

checkStringEqual(mlAicTbl.rowNames[rows(mlAicTbl.rowNames) - 1], "AIC", "maxlikmt AIC row present once shown");
checkStringEqual(mlAicTbl.rowNames[rows(mlAicTbl.rowNames)], "BIC", "maxlikmt BIC row present once shown");
checkStringEqual(mlAicTbl.body[rows(mlAicTbl.body) - 1, 1], ptFormatGOFValue(mlExpectedAic, mlMdl.fmt.digits), "maxlikmt AIC matches -2*fval + 2*k");
checkStringEqual(mlAicTbl.body[rows(mlAicTbl.body), 1], ptFormatGOFValue(mlExpectedBic, mlMdl.fmt.digits), "maxlikmt BIC matches -2*fval + 2*k*ln(n)");

struct cmlmtControl cmlCtl;
cmlCtl = cmlmtcontrolcreate;
cmlCtl.title = "tobit example";
cmlCtl.Bounds = { -10 10,
                  -10 10,
                  -10 10,
                  -10 10,
                  .1 10 };

struct cmlmtResults cmlOut;
cmlOut = CMLmt(&lpr, p0, d0, cmlCtl);

struct ptTable cmlTbl;
cmlTbl = ptFromCmlmt(cmlOut);
checkStringEqual(cmlTbl.title, "Constrained ML results", "cmlmt table title");
checkScalarEqual(rows(cmlTbl.body), 2 * pvLength(cmlOut.par) + 2, "cmlmt table row count includes statistic and GOF rows");
checkStringEqual(cmlTbl.rowNames[1], "b0[1,1]", "cmlmt parameter name from pvGetParNames");

local cmlK, cmlExpectedAic, cmlExpectedBic;
struct ptModel cmlMdl;
struct ptTable cmlAicTbl;

cmlMdl = ptModelFromCmlmt("CML AIC/BIC", cmlOut);
cmlMdl = ptModelSetAicBic(cmlMdl, 1);
cmlAicTbl = ptModelTable(cmlMdl);

cmlK = pvLength(cmlOut.par);
cmlExpectedAic = -2 * cmlOut.fct + 2 * cmlK;
cmlExpectedBic = -2 * cmlOut.fct + 2 * cmlK * ln(cmlOut.numObs);

checkStringEqual(cmlAicTbl.rowNames[rows(cmlAicTbl.rowNames) - 1], "AIC", "cmlmt AIC row present once shown");
checkStringEqual(cmlAicTbl.rowNames[rows(cmlAicTbl.rowNames)], "BIC", "cmlmt BIC row present once shown");
checkStringEqual(cmlAicTbl.body[rows(cmlAicTbl.body) - 1, 1], ptFormatGOFValue(cmlExpectedAic, cmlMdl.fmt.digits), "cmlmt AIC matches -2*fval + 2*k");
checkStringEqual(cmlAicTbl.body[rows(cmlAicTbl.body), 1], ptFormatGOFValue(cmlExpectedBic, cmlMdl.fmt.digits), "cmlmt BIC matches -2*fval + 2*k*ln(n)");

print "pubtable maxlikmt/cmlmt adapter tests passed";
