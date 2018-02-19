# tableSetBrackets

## Purpose
> Controls which statistic to put parentheses around.

## Format
> tableSetParentheses(&tctl, variable)

## Input
| Option | Description |
|: ----- |: ------- |
|&tctl  | A `tableControl` structure pointer. |
|variable | String, the statistic to place in parentheses. Options include: "coefficients", "se", "tstat", "pval" |

## Example
```
//Declare tableControl structure
struct tableControl myTable;

//Set up brackets
tableSetParentheses(&myTable, "pval");
```
