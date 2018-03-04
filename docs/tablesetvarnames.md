# tableSetVarNames

## Purpose
> Controls variable names on table.

## Format
> tableSetVarNames(&tctl, variable_names)

## Input
| Option | Description |
|:------- |:------- |
|&tctl  | A `tableControl` structure pointer |
|variable_names | String, variable names separated by commas. |

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Name variables included in model
tableSetVarNames(&myTable, "Const., Weight, Length");
```
