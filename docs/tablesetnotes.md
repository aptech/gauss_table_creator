# tableSetNotes

## Purpose
> Control note placed below table.

## Format
> tableSetNotes(&tctl, notes)

## Input
| Option | Description |
|:------- |:------- |
|&tctl  | A `tableControl` structure pointer |
|notes | String, note to be placed at bottom of table.|

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Make not for data source at bottom of table
tableSetNotes(&myTable, "Data source: FRED");

```
