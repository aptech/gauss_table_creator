/*
**  This examples show how to use the tableset features in GAUSS
**  to set up results tables
*/

new;
library tabout;

// File name with full path 
fname = getGAUSSHome() $+ "examples/detroit.sas7bdat";
				
//Declare 'fit' to be a glmOut structure
struct glmOut fit;
						
//Call 'glm' with no intercept model	
fit = glm(fname, "homicide ~ unemployment + hourly_earn",  "normal");	


//Step one: Declare the tableControl structure
struct tableControl tblCtl;
tblCtl = tableGetDefaults("OLS");

//Set up table title
tableSetTitle(&tblCtl,"Generalized Linear Model: Normal Family");

//Set up values to include in table
tableSetVars(&tblCtl, "coefficients, se, pval");

//Name variables included in model
tableSetVarNames(&tblCtl, "Const., Unemployment, Hourly Earnings");

//Set column header to independent variable
tableSetColumnHeaders(&tblCtl, fit.modelInfo.yName); 

//Significant figures
tableSetSigFig(&tblCtl, 5);

//Set up asterisks
ASigFig = {0.10, 0.05, 0.001};
asteriskVariable = "pval";
tableSetAsterisk(&tblCtl, asteriskVariable);

//Set up brackets
tableSetBrackets(&tblCtl, "pval");


//Print Table
tblCtl.printOut = 1;

//Number of observations
tblCtl.numObs = 13;

//Export Table
tableSetExport(&tblCtl,"TableOutglm");

struct regressEstimateTable regEstTab;
regEstTab = outputTable(tblCtl, fit.coef.estimates, fit.coef.se, fit.coef.pvalue);


