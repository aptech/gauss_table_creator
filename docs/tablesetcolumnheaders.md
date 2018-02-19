# tableSetColumnHeaders

## Purpose
> Control headers placed on table columns.

## Format
> tableSetColumnHeaders(&tctl, column_headers)

## Input
| Option | Description |
|: ----- |: ------- |
|&tctl  | A `tableControl` structure pointer |
|column_headers | String array, headers for columns.|

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Set column header to independent variable
tableSetColumnHeaders(&myTable, "mpg");

```
