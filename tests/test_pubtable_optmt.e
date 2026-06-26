new;
library optmt, pubtable;

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
** Quadratic program from Luenberger (1984), p. 219
*/
omega = { 0.78 -0.02 -0.12 -0.14,
         -0.02  0.86 -0.04  0.06,
         -0.12 -0.04  0.72 -0.08,
         -0.14  0.06 -0.08  0.74 };

b = { 0.76, 0.08, 1.12, 0.68 };
x0 = { 1, 1, 1, 1 };

proc qfct(x, omega, b, ind);
    struct modelResults mm;
    if ind[1];
        mm.function = 0.5 * x'omega * x - x'b;
    endif;
    retp(mm);
endp;

struct optmtResults out;
out = optmt(&qfct, x0, omega, b);

struct ptTable optTbl;
optTbl = ptTableFromOptmt(out);
checkStringEqual(optTbl.title, "Optimization results", "optmt table title");
checkScalarEqual(rows(optTbl.body), rows(x0), "optmt table row count matches parameter count");
checkScalarEqual(cols(optTbl.body), 2, "optmt table has estimate and gradient columns");

print "pubtable optmt adapter tests passed";
