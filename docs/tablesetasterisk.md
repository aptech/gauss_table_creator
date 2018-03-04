# tableSetAsterisk

## Purpose
> Controls what variable significance markers will be placed on.

## Format
> tableSetAsterisk(&tctl, variable)  
> tableSetAsterisk(&tctl, variable, significance)

## Input
| Option | Description |
|:------- |:------- |
|&tctl  | A `tableControl` structure pointer |
|variable | String, the variable to have significance markers. Options include: "coefficients", "se", "tstat", "pval" |
|Significance | Optional argument, vector, significance markers cutoff levels. For example, `significance = 0.001~0.05~0.01;` results in significance markers at the 1%, 5% and 10% level. Default = 0.001~0.05~0.01 |

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Set coefficient for significance markers
tableSetAsterisk(&myTable, "coefficients");
```
