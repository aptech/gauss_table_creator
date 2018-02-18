# tableSetColumnHeaders

## Purpose
> Control headers placed on table columns.

## Format
> tableSetColumnHeaders(&tctl, column_headers)
> tableSetExport(&tctl, filename, filetype)

## Input
| Option | Description |
|: ----- |: ------- |
|&tctl  | A `tableControl` structure pointer |
|filename | String, name of export file excluding type extension. |
|column_headers | String array, headers for columns.|

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Set column header to independent variable
tableSetColumnHeaders(&tblCtl, "mpg");

```
