# PubTable Roadmap

## Vision

Create a modern GAUSS-native publication table library that supports:

* Model coefficient tables
* Model comparison tables
* Summary statistics tables
* Custom matrix/data tables
* Export to Markdown, LaTeX, CSV, Text, HTML, RTF, and XLSX

Design priorities:

1. Simple user-facing API
2. Strong defaults
3. Publication-quality output
4. GAUSS-native implementation
5. Extensible architecture
6. Backward-compatible migration path where practical

---

# P0: Stabilize MVP

## Validation

- [x] Harden `ptTable`, `ptModel`, and `ptFormat` validation.
- [x] Add dimension checks.
- [x] Add clearer error messages for malformed inputs.
- [x] Ensure invalid export options fail gracefully.

## Testing

Expand `tests/test_pubtable.e` to cover:

- [x] Markdown export
- [x] LaTeX export
- [x] CSV export
- [x] Plain text export
- [x] RTF export
- [x] XLSX export

## Documentation

- [x] Update README examples.
- [x] Ensure install/use instructions reference `pubtable`.
- [x] Remove remaining references to legacy `tabout` workflows.

---

# P1: Improve Model Tables

## Model Comparison

Enhance `ptModelCompare`:

- [x] Flexible term alignment across models.
- [x] Support models with different regressors.
- [x] Consistent handling of missing coefficients.

## Coefficient Presentation

Add support for:

- [x] Coefficient maps / variable renaming
- [x] Custom term ordering
- [x] Optional confidence intervals

## Statistics Rows

Configurable display of:

- [x] Standard errors
- [x] t-statistics
- [x] p-values
- [x] Confidence intervals

## Model Metadata

Support:

- [x] Goodness-of-fit row selection
- [x] GOF row ordering
- [x] Model-specific notes
- [x] Table-level notes

## Rendering Quality

- [x] Improve `ptRenderText` column alignment (computed column widths, left/right padding, dashed header separator)
- [ ] Further polish for `ptRenderMarkdown` / `ptRenderLatex` / `ptRenderRtf` as needed

---

# P1: Add More GAUSS Adapters

## Existing Adapters

Strengthen support for:

- [x] `olsmtOut`
- [x] `glmOut`
- [ ] `gmmOut` (field names verified; real-execution test still pending due to `&meqn` callback complexity)
- [x] `dstatmtOut`

## Additional Adapters

Evaluate support for:

- [ ] `qfitOut` (not present in GAUSS 26 `src`; no action unless added upstream)
- [ ] `ttestOut` (two-group comparison shape; would need a custom-table adapter, not the coefficient-model shape)
- [x] `fglsOut`
- [x] `cmlmt` (optional add-on package; `src/pubtable_cmlmt.src`, requires `library cmlmt;`)
- [x] `maxlikmt` (optional add-on package; `src/pubtable_maxlikmt.src`, requires `library maxlikmt;`)
- [x] `tsmt` (optional add-on package; `src/pubtable_tsmt.src`, covers `arimamtOut`, `tsPanelEstimationOut`, `automtOut`, `varmamtOut`, `lsdvmtOut`, `switchmtOut`, `garchEstimation`, and `tscsmtOut`; `sbOut`/`TAROut` structural-break/threshold structs and the `tspanelOut` wrapper are not covered)
- [x] `optmt` (optional add-on package; `src/pubtable_optmt.src`, `ptTableFromOptmt` builds a parameter/estimate/gradient table since `optmtResults` has no covariance matrix for SE)

## Auto-loading with ptSetup()

Optional adapter auto-loading is implemented via:

- [x] `ptSetup()` / `ptSetupAt(srcDir)`: detect installed optional libraries via `fopen(getGAUSSHome()...)` and write `pubtable.dec` with `#define PT_USE_X` entries.
- [x] Adapter `.src` files (`pubtable_cmlmt.src`, `pubtable_maxlikmt.src`, `pubtable_optmt.src`, `pubtable_tsmt.src`, `pubtable_qardl.src`) are listed only in `package.json`'s `"src"` array — NOT `#include`d from `pubtable.src` — so `library pubtable;` compiles them automatically. Each `PT_USE_X`-gated file includes `pubtable.dec` itself (right after `#include pubtable.sdf`), so user programs never need to `#include` it; they just load the optional library together with pubtable in one statement (`library cmlmt, pubtable;`).
- [x] Each adapter proc is declared once with variadic `(...)` args, fetching typed arguments via `dynargsGet()` inside an inner `#ifDef PT_USE_X / #else / #endIf` (real implementation vs. `_library_missing_error` stub) — not two duplicated proc bodies. This avoids a compile error from a typed struct parameter (e.g. `struct cmlmtResults out`) when the library's `.sdf` isn't included.
- [x] qardl: auto-detected via `QARDL_SDF_INCLUDED` (the include guard in `qardl.sdf`) — no `pubtable.dec` entry needed; same inner-`#ifDef` stub pattern used.
- [x] `src/pubtable.dec`: default template ships with the package; `ptSetup()` overwrites it with detected library sentinels. Machine-specific — not committed to source control.
- [x] `_library_missing_error(funcname, libname)`: defined unconditionally in `pubtable.src` itself (not in any adapter file, to avoid structure-conflict errors from library-specific `.sdf` type definitions); called by all adapter stubs.
- [x] Most add-on adapters (cmlmt, maxlikmt, most of tsmt, most of qardl) are wired into the standard `ptModelFrom(name, out)` dispatcher via `isStructType`, so callers don't need to know the library-specific function name. Not wired: `optmtResults` (no covariance matrix, no `ptModel` form), `tscsmtOut` (two distinct estimators, no single canonical model), `qardlOut`/`qardlECMOut` (need an extra `tauIdx` argument).

Users run `ptSetup()` once after install. No further `#include` is needed — loading the optional library together with pubtable in a single `library X, pubtable;` statement is sufficient to enable its adapters.

## Design Constraint

Adapters should remain explicit.

Use:

```gauss
isStructType()
```

only to route to known adapter procedures.

Avoid automatic reflection-style behavior.

---

# P2: Exporter Polish

## LaTeX

Add support for:

- [x] booktabs
- [x] caption
- [x] label (`ptSetLabel`/`ptModelSetLabel`)
- [x] notes
- [x] alignment controls (`ptSetColAlign`/`ptModelSetColAlign`)

## HTML

Add HTML export as a bridge to:

- [x] Word workflows (via `.html`/`.rtf` exporters)
- [x] Web reports (via `ptRenderHtml`/`.html`)
- [x] Documentation systems (via `ptRenderHtml`/`.html`)

## RTF

- [x] Improve formatting beyond simple tab-separated rows (real RTF table with grid borders and bold header row via `\trowd`/`\cellx`/`\cell`/`\row`).

## DOCX

- [ ] Defer until a maintainable GAUSS-native ZIP/XML implementation exists.

---

# P2: Public API Cleanup

## API Review

Finalize names for:

- [x] setters (`ptSet<X>` / `ptModelSet<X>`, consistent across `pubtable.src`)
- [x] builders (`ptTableCreate`, `ptModelCreate`, `ptTableFromMatrix`, `ptCompareOptionsCreate`)
- [x] renderers (`ptRenderMarkdown`/`ptRenderLatex`/`ptRenderCsv`/`ptRenderText`/`ptRenderRtf`/`ptRenderHtml`)
- [x] exporters (`ptExport` dispatches on file extension to the renderers above)

## Options

Evaluate:

- [x] `ptOptions`
- [x] extending `ptFormat`

Decision: extend `ptFormat` for per-table/per-model formatting (digits, stars, statRows, label, colAlign), and use a
separate `ptCompareOptions` struct for comparison-specific configuration (term/GOF order, label map, notes). Both
patterns are documented and in active use.

## Legacy Compatibility

Provide compatibility wrappers where practical for:

- [x] `tableSet...` (retained in `src/pubtable_legacy_setters.src`)
- [x] `outputTable` (retained in `src/pubtable_legacy_output.src`)

## Deprecation Policy

Document:

- [x] Supported legacy APIs
- [x] Deprecated APIs
- [x] Removed APIs

Status: the legacy `tableControl`/`outputTable`/`tableSet...` API in `src/pubtable_legacy*.src` is fully retained and
supported for migration; nothing in the modern `pt*` API has been deprecated or removed.

---

# P2: Documentation

## Modernization

Replace or modernize:

- [x] `docs/tableset*.md` (kept as legacy-only reference; `docs/README.md` now indexes them
  separately from the modern `docs/api/` reference and points to `docs/migration.md`)

## Command Reference

Add documentation for:

- [x] `ptTableFromMatrix` (`docs/api/ptTableFromMatrix.md`)
- [x] `ptTableFrom` (`docs/api/ptTableFrom.md`)
- [x] `ptTableCreate` (`docs/api/ptTableCreate.md`)
- [x] `ptModelFrom` (`docs/api/ptModelFrom.md`)
- [x] `ptModelCreate` (`docs/api/ptModelCreate.md`)
- [x] `ptModelCompare` (`docs/api/ptModelCompare.md`, includes `ptModelCompareWith`/`ptCompareOptions`)
- [x] `ptCompareOptions` (`docs/api/ptCompareOptions.md`, covers `ptCompareOptionsCreate` and all `ptCompareSet*`)
- [x] `ptExport` (`docs/api/ptExport.md`)
- [x] `ptExportAll` / `ptExportAllFormats` (`docs/api/ptExportAll.md`)
- [x] Table setters (`docs/api/ptTableSetters.md`, covers all `ptSet*` / `ptNoStars` / `ptSetStatRows`)
- [x] Model setters (`docs/api/ptModelSetters.md`, covers all `ptModelSet*` / `ptModelNoStars`)
- [x] `ptModelTable` (`docs/api/ptModelTable.md`)
- [x] `ptApplyPreset` / `ptModelApplyPreset` (`docs/api/ptApplyPreset.md`)
- [x] Renderers (`docs/api/ptRender.md`, covers all 6 `ptRender*` procs)
- [x] `pubtableSet` / `ptSetup` / `ptSetupAt` (`docs/api/pubtableSet.md`)
- [x] Built-in adapters (`docs/api/ptAdaptersBuiltin.md`, covers olsmt/fgls/glm/gmm/dstatmt)
- [x] tsmt adapters (`docs/api/ptAdaptersTsmt.md`)
- [x] cmlmt adapter (`docs/api/ptAdaptersCmlmt.md`)
- [x] maxlikmt adapter (`docs/api/ptAdaptersMaxlikmt.md`)
- [x] optmt adapter (`docs/api/ptAdaptersOptmt.md`)
- [x] qardl adapters (`docs/api/ptAdaptersQardl.md`)

## Examples

Add examples covering:

- [x] Summary statistics tables (`examples/summary_table.e` via `ptTableFromMatrix`; `examples/summary_statistics_dstatmt.e` via `ptFromDstatmt`)
- [x] Model comparison tables (`examples/model_comparison.e`)
- [x] Custom matrix tables (`examples/summary_table.e`)
- [x] All export formats (`examples/export_formats.e` — Markdown, LaTeX, CSV, text, RTF, HTML, XLS, XLSX)
- [x] Style presets and custom formatting (`examples/preset_styles.e` — journal/compact/plain/report presets and custom star/stat-row config)
- [x] tsmt add-on adapter (`examples/addon_tsmt.e` — ARIMA comparison via `ptModelFromArimamt`)
- [x] cmlmt add-on adapter (`examples/addon_cmlmt.e` — constrained Poisson MLE via `ptModelFromCmlmt`)
- [x] maxlikmt add-on adapter (`examples/addon_maxlikmt.e` — Normal MLE via `ptModelFromMaxlikmt`)

## Migration Guide

Create:

```text
tableControl/tableSet... -> pubtable
```

- [x] migration documentation (`docs/migration.md`).

---

# P3: Advanced Features

## Headers

Support:

- [x] Grouped headers
- [x] Spanning headers

Implemented via `ptTable.colGroups` / `ptSetColGroups(tbl, colGroups)`, one label per body column
(blank for ungrouped columns). Contiguous equal labels form a span. Markdown/CSV/Text render a
pseudo-span (label in the first column of the run, blanks elsewhere); LaTeX renders
`\multicolumn`/`\cmidrule`; HTML renders `colspan`; RTF renders `\clmgf`/`\clmrg` cell merges.

## Multi-Equation Models

Support:

- [x] Equation panels
- [x] Quantile-model panels
- [x] Multi-model panels

Implemented via `ptCompareSetColGroups(opts, colGroups)` (one label per model, passed to
`ptModelCompareWith`), which populates the comparison table's `colGroups` so the same
spanning-header rendering groups comparison columns by equation, quantile, or panel name.

## Cell Formatting

Support:

- [x] Alignment controls
- [x] Number formatting
- [x] Cell-level styling

`ptFormat.colAlign` / `ptSetColAlign`/`ptModelSetColAlign` (one `l`/`c`/`r` per column, including the
stub) now drives alignment in every renderer, not just LaTeX: Markdown emits the corresponding
`:---`/`:---:`/`---:` alignment row, HTML adds `style="text-align:..."` to `<th>`/`<td>`, and plain
text left/center/right-pads each column. When `colAlign` is unset, the previous defaults (stub
left-aligned, data columns right-aligned) are unchanged.

`ptSetColFormat(tbl, colDigits)` re-formats already-rendered numeric cells in `tbl.body`, applying
a per-column decimal-digit count (one entry per body column; `""` leaves a column unchanged). It
re-parses each cell with `strtof` and re-applies `ptFormatNumber`, so it works on plain numeric
cells but not cells already wrapped with significance stars or statistic parentheses.

`ptSetCellStyle(tbl, row, col, style)` marks an individual body cell (1-based row/col into
`tbl.body`) with `"bold"`, `"italic"`, `"bold italic"`, or `""` (no styling), stored in the new
`tbl.cellStyle` string array. Markdown, LaTeX, HTML, and RTF renderers apply the styling
(`**bold**`, `\textbf{...}`, `<strong>...</strong>`, `\b ... \b0`, etc.); CSV and plain text
renderers ignore `cellStyle` since those formats cannot represent styled text.

## Significance Controls

Support:

- [x] Custom significance symbols (`ptSetStars`/`ptModelSetStars`, `ptNoStars`/`ptModelNoStars`)
- [x] Custom significance thresholds (`ptSetStars`/`ptModelSetStars`)

## Workflow Enhancements

Support:

- [x] Multi-table export workflows
- [x] Batch reporting workflows

Implemented via `ptExportAll(tables, fname)`, where `tables` is a `ptTable` array (e.g.
`reshape(tbl, n, 1)` with indexed assignment). It dispatches on file extension like `ptExport`:
Markdown/CSV/Text/HTML concatenate each table's rendered output (Markdown tables are separated by a
horizontal rule); RTF merges all tables into a single `{\rtf1...}` document; XLS/XLSX write each
table to its own sheet (sheet `1`, `2`, ... via `SpreadsheetWrite`).

`ptExportAllFormats(tables, basename, exts)` builds on `ptExportAll` for batch reporting: given the
same `ptTable` array and a list of extensions (e.g. `"md" $| "tex" $| "html"`), it writes
`basename + "." + ext` for each extension via `ptExportAll`, producing a full report in several
formats with one call. Returns `0` if every format exported successfully, otherwise the return code
of the first format that failed (the remaining formats are still attempted).

## Style Presets

Provide optional presets:

- [x] journal
- [x] compact
- [x] plain
- [x] report

Implemented via `ptApplyPreset(tbl, preset)` / `ptModelApplyPreset(mdl, preset)`, which set
`ptFormat.digits`, `stars`/`starCutoffs`/`starSymbols`, `statRows`, and `statisticWrapper` together.

---

# Future Evaluation

Potential future integrations:

- [x] QARDL reporting helpers
- [x] TSMT reporting helpers
- [x] ARDL-family reporting adapters
- [ ] Automatic model-summary generation
- [ ] Publication-ready econometric reporting workflows

TSMT reporting helpers implemented in `src/pubtable_tsmt.src`: `ptModelFromAutomt`/`ptFromAutomt`
(`automtOut`), `ptModelFromVarmamt`/`ptFromVarmamt` (`varmamtOut`), `ptModelFromLsdvmt`/
`ptFromLsdvmt` (`lsdvmtOut`), `ptModelFromSwitchmt`/`ptFromSwitchmt` (`switchmtOut`),
`ptModelFromGarchmt`/`ptFromGarchmt` (`garchEstimation`), and `ptFromTscsmt` (`tscsmtOut`,
comparing within/fixed-effects vs. error-components estimates), alongside the existing
`arimamtOut`/`tsPanelEstimationOut` adapters. `sbOut`/`TAROut` (structural break / threshold AR)
and the `tspanelOut` wrapper struct are not covered.

Implemented via `src/pubtable_qardl.src` (optional add-on package adapter, requires `library qardl;`
and `#include qardl.sdf`): `ptModelFromArdl`/`ptFromArdl` (`ardlOut`), `ptModelFromArdlECM`/
`ptFromArdlECM` (`ardlECMOut`), `ptModelFromQardl`/`ptFromQardl` and `ptModelFromQardlECM`/
`ptFromQardlECM` (`qardlOut`/`qardlECMOut`, one comparison column per quantile via
`ptModelCompare`), `ptModelFromNardl`/`ptFromNardl` and `ptModelFromNardlECM`/`ptFromNardlECM`
(`nardlOut`/`nardlECMOut`), `ptModelFromCsardl`/`ptFromCsardl` and `ptModelFromCsardlECM`/
`ptFromCsardlECM` (`csardlOut`/`csardlECMOut`), `ptFromArdlFull` and `ptTablesFromQardlFull`/
`ptTablesFromNardlFull`/`ptTablesFromCsardlFull` for the `*Full` workflow outputs, and the
`ptFromArdlFamily` dispatcher. Diagnostic/Wald/rolling/QIRF/selection/AutoCase/SparseGETS output
structs are not covered.

---

# P3: Journal Submission Aesthetics

Improve table presentation for camera-ready/journal-style output, with a focus on
`cmlmt` output applying to all renderers where appropriate. See `CHANGELOG.md`
`[Unreleased]` for full detail.

- [x] `"journal_booktabs"` preset (`ptApplyPreset`/`ptModelApplyPreset`): `"journal"`
  settings plus `ptFormat.ruleStyle = "booktabs"`, drawing only top/header-bottom/
  table-bottom rules in `ptRenderHtml`/`ptRenderRtf` (no vertical/column-divider
  rules). `ptRenderLatex` already rendered this way by default; `"journal"` itself is
  unchanged.
- [x] Non-fatal title warning for journal-style tables: `ptExport`/`ptRenderLatex`/
  `ptRenderHtml`/`ptRenderRtf` warn via `errorlog` (does not abort) when
  `fmt.preset` is `"journal"`/`"journal_booktabs"` and `title` is empty. Required
  adding `ptFormat.preset` to track which preset (if any) was last applied.
- [x] Consistent SE/stat-row alignment in `ptRenderText`/`ptRenderMarkdown`:
  `ptApplyStarGutter`/`ptTrailingDecorLen` reserve a fixed trailing width per column for
  significance stars and closing `)`/`]`, so a coefficient and its stat sub-row's
  numbers line up regardless of star count. `ptRenderMarkdown` previously had no cell
  padding at all.
- [x] `ptModelSetDataLabel(model, label)` / `ptModel.dataLabel`: a dataset description
  rendered as its own `"Data: <label>."` note, separate from `ptModelSetNotes`.
  (`ptModelFromCmlmt` itself never auto-generated a "Data: ..." note — that text came
  from the `addon_cmlmt.e` example's own hand-written note string, now updated to use
  this setter instead.)
- [x] Optional AIC/BIC GOF rows for `ptModelFromCmlmt`/`ptModelFromMaxlikmt`: always
  computed and appended, hidden by default, revealed via `ptModelSetAicBic(model, 1)`.
  Implemented via `ptModel.hasOptionalAicBic` + `ptFilterGofRows`, which drops the
  trailing two GOF rows by *position* (never by matching the `"AIC"`/`"BIC"` label
  text), so it doesn't collide with adapters that already report their own
  non-optional AIC/BIC (e.g. `ptModelFromGlm`).
