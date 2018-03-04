# tableSetSigFig

## Purpose
> Controls the number of significant figures on numbers printed in the table.

## Format
> tableSetSigFig(&tctl, sigFig)

## Input
| Option | Description |
|:------- |:------- |
|&tctl  | A `tableControl` structure pointer. |
|sigFig | Scalar, number of significant figures on numbers printed in the table.|

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Set column header to independent variable
tableSetSigFig(&myTable, 5);
```
