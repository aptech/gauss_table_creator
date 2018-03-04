# tableSetTitle

## Purpose
> Controls the settings for the title for a graph.

## Format
> tableSetTitle(&tctl, title)

## Input
| Option | Description |
|:------- |:------- |
|&tctl  | A `tableControl` structure pointer |
|title | String, the desired table title |

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Initialize tableControl structure
myTable = tableGetDefaults("OLS");

//Set the title
tableSetTitle(&myTable, "GAUSS Example Table");
```
