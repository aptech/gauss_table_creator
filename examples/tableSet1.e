/*
**  This examples show how to use the tableset features in GAUSS
**  to set up results tables
*/

new;
library tabout;

//Run OLS with auto data
struct olsmtControl oc0;
struct olsmtOut oOut;
oc0 = olsmtControlCreate;

//Load filename
filename = getGAUSShome() $+ "examples/auto.dat";

//Run ols
oOut = olsmt(oc0, filename, "mpg~weight + length");
print;
print;

//Step one: Declare the tableControl structure
struct tableControl tblCtl;
tblCtl = tableGetDefaults("OLS");

//Set up table title
tableSetTitle(&tblCtl,"OLS Regression");

//Set up values to include in table
tableSetVars(&tblCtl, "coefficients, se, tstat");

//Name variables included in model
tableSetVarNames(&tblCtl, "Const., Weight, Length");

//Set column header to independent variable
tableSetColumnHeaders(&tblCtl, "mpg"); 

//Significant figures
tableSetSigFig(&tblCtl, 6);

//Set up asterisks
ASigFig = {0.10, 0.05, 0.001};
asteriskVariable = "coefficients";
tableSetAsterisk(&tblCtl, asteriskVariable);

//Set up brackets
tableSetBrackets(&tblCtl, "se");

//Print Table
tblCtl.printOut = 1;

//Number of observations
tblCtl.numObs = 74;

//Export Table
tableSetExport(&tblCtl,"TableOutDC","XLS");

struct regressEstimateTable regEstTab;
regEstTab = outputTable(tblCtl, oOut.b, oOut.stderr);


