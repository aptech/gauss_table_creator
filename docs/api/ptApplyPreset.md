# ptApplyPreset / ptModelApplyPreset

## Purpose
> Apply a named style preset to the format options of a `ptTable` or `ptModel`.
> Presets offer one-call control over digits, stars, statistic-row wrappers, and
> the statistic rows shown under each coefficient.

## Format
> tbl = ptApplyPreset(tbl, preset)
> mdl = ptModelApplyPreset(mdl, preset)

## Input
| Parameter | Description |
|:------- |:------- |
| tbl / mdl | `ptTable` or `ptModel` struct to modify. |
| preset | String, one of `"journal"`, `"compact"`, `"plain"`, or `"report"`. |

## Output
| Output | Description |
|:------- |:------- |
| tbl / mdl | Modified struct with `fmt` fields overwritten by the preset. |

## Available presets

| Preset | digits | Stars | Wrapper | statRows |
|:------- |:------- |:------- |:------- |:------- |
| `"journal"` | 3 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se` |
| `"compact"` | 2 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se` |
| `"plain"` | 3 | none | none | `se` |
| `"report"` | 3 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se`, `pvalue` |

`"journal"` is equivalent to the default `ptFormat` created by `ptFormatCreate`.

## Notes
- Presets overwrite the entire `fmt` block. Apply a preset first, then use individual
  setters (`ptModelSetStars`, `ptModelSetDigits`, etc.) for fine-tuning.
- `ptModelApplyPreset` does not affect `mdl.estimates`, `mdl.stdErrors`, or any other
  data field — only `mdl.fmt`.
- `ptApplyPreset` applied to a `ptTable` after `ptModelTable` / `ptModelCompare` will
  change formatting for the *next* render, but will not re-format the string body already
  in the table. For model tables, apply the preset to the `ptModel` before calling
  `ptModelTable`.

## Example
```gauss
new;
library pubtable;

struct olsmtControl ctl;
struct olsmtOut out;
ctl = olsmtControlCreate;
ctl.output = 0;
out = olsmt(ctl, getGAUSSHome() $+ "examples/auto.dat", "mpg ~ weight + length");

/* "compact" preset: 2 digits, stars, SE in parens */
cmpMdl = ptModelFrom("", out);
cmpMdl = ptModelApplyPreset(cmpMdl, "compact");
cmpTbl = ptModelTable(cmpMdl);
cmpTbl = ptSetTitle(cmpTbl, "Compact preset");

/* "plain" preset: 3 digits, no stars, no parens */
plnMdl = ptModelFrom("", out);
plnMdl = ptModelApplyPreset(plnMdl, "plain");
plnTbl = ptModelTable(plnMdl);
plnTbl = ptSetTitle(plnTbl, "Plain preset");

call ptExport(cmpTbl, "compact.md");
call ptExport(plnTbl, "plain.md");
```

## See Also
`ptModelSetDigits`, `ptModelSetStars`, `ptModelNoStars`, `ptModelSetStatRows`, `ptModelTable`
