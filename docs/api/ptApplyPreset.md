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
| preset | String, one of `"journal"`, `"journal_booktabs"`, `"compact"`, `"plain"`, or `"report"`. |

## Output
| Output | Description |
|:------- |:------- |
| tbl / mdl | Modified struct with `fmt` fields overwritten by the preset, including `fmt.preset` (the preset name itself) and, for `"journal_booktabs"`, `fmt.ruleStyle`. |

## Available presets

| Preset | digits | Stars | Wrapper | statRows | ruleStyle |
|:------- |:------- |:------- |:------- |:------- |:------- |
| `"journal"` | 3 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se` | (default) |
| `"journal_booktabs"` | 3 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se` | `"booktabs"` |
| `"compact"` | 2 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se` | (default) |
| `"plain"` | 3 | none | none | `se` | (default) |
| `"report"` | 3 | `+`/`*`/`**` at 0.10/0.05/0.01 | parentheses | `se`, `pvalue` | (default) |

`"journal_booktabs"` is the default `ptFormat` created by `ptFormatCreate` (and so the
default for `ptTableCreate`/`ptModelCreate` whenever no preset is applied explicitly).
`"journal"` is identical except it leaves `ruleStyle` unset.

`"journal_booktabs"` is identical to `"journal"` except for `ruleStyle`: `ptRenderHtml`/
`ptRenderRtf` then draw a table-top rule, a header-bottom rule, a mid-rule separating the
coefficient block from the goodness-of-fit block, and a table-bottom rule — no
vertical/column-divider rules. The mid-rule is found by `ptGofStartRow`: term blocks
always end in a blank-named stat sub-row (since `statRows` requires at least one entry),
so the GOF block — if the table has one — starts right after the *last* blank-named row.
`ptRenderLatex` is unaffected, since it already renders `booktabs`-style with no vertical
rules by default; Markdown is unaffected, since it has no border concept.

## Journal-style title warning

If `fmt.preset` is `"journal"` or `"journal_booktabs"` and the table's `title` is empty,
`ptExport`/`ptRenderLatex`/`ptRenderHtml`/`ptRenderRtf` print a non-fatal `errorlog`
warning ("pubtable warning: journal-style table has no title. Use ptSetTitle(tbl, ...)
before exporting.") but still complete the export/render. Call `ptSetTitle(tbl, ...)`
(or pass a non-empty `name` into `ptModelFrom`/`ptModelCreate`, which becomes the table
title via `ptModelTable`) before exporting to silence it.

## Notes
- Presets overwrite the entire `fmt` block. Apply a preset first, then use individual
  setters (`ptModelSetStars`, `ptModelSetDigits`, etc.) for fine-tuning.
- `ptModelApplyPreset` does not affect `mdl.estimates`, `mdl.stdErrors`, or any other
  data field — only `mdl.fmt`.
- `ptApplyPreset` applied to a `ptTable` after `ptModelTable` / `ptModelCompare` will
  change formatting for the *next* render, but will not re-format the string body already
  in the table. For model tables, apply the preset to the `ptModel` before calling
  `ptModelTable`.
- `fmt.preset` defaults to `"journal_booktabs"` from `ptFormatCreate` itself (not only
  via `ptApplyPreset`/`ptModelApplyPreset`), so the title warning above fires for any
  untitled table unless a different preset (e.g. `"plain"`) is applied explicitly.

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

/* "journal_booktabs" preset: same as "journal", plus booktabs-style rules
** in HTML/RTF. Title is required for the warning above to stay silent. */
btMdl = ptModelFrom("", out);
btMdl = ptModelApplyPreset(btMdl, "journal_booktabs");
btTbl = ptModelTable(btMdl);
btTbl = ptSetTitle(btTbl, "Journal (booktabs) preset");

call ptExport(btTbl, "journal_booktabs.html");
call ptExport(btTbl, "journal_booktabs.rtf");
```

## See Also
`ptModelSetDigits`, `ptModelSetStars`, `ptModelNoStars`, `ptModelSetStatRows`, `ptModelTable`
