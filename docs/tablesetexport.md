# tableSetExport

## Purpose
> Control file name and file type for exporting table.

## Format
> tableSetExport(&tctl, filename)
> tableSetExport(&tctl, filename, filetype)

## Input
| Option | Description |
|: ----- |: ------- |
|&tctl  | A `tableControl` structure pointer |
|filename | String, name of export file excluding type extension. |
|filetype | Optional input, string, file extension. Options include: "XLS", "XLSX", "TXT". Default = "XLSX". |

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Export Table
tableSetExport(&myTable,"TableOutDC","XLS");

```
