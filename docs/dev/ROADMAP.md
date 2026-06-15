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
- [x] `tsmt` (optional add-on package; `src/pubtable_tsmt.src`, covers `arimamtOut` and `tsPanelEstimationOut`; other tsmt result structs such as `varmamtOut`, `lsdvmtOut`, `switchmtOut` not yet covered)
- [x] `optmt` (optional add-on package; `src/pubtable_optmt.src`, `ptTableFromOptmt` builds a parameter/estimate/gradient table since `optmtResults` has no covariance matrix for SE)

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
- [x] `ptModelFrom` (`docs/api/ptModelFrom.md`)
- [x] `ptModelCompare` (`docs/api/ptModelCompare.md`, includes `ptModelCompareWith`/`ptCompareOptions`)
- [x] `ptExport` (`docs/api/ptExport.md`)

## Examples

Add examples covering:

- [x] Summary statistics tables (`examples/summary_table.e` via `ptTableFromMatrix`; `examples/summary_statistics_dstatmt.e` via `ptFromDstatmt`)
- [x] Model comparison tables (`examples/model_comparison.e`)
- [x] Custom matrix tables (`examples/summary_table.e`)
- [x] Markdown export (`examples/export_formats.e`)
- [x] LaTeX export (`examples/export_formats.e`)
- [x] HTML export (`examples/export_formats.e`)
- [x] CSV export (`examples/export_formats.e`)
- [x] XLSX export (`examples/export_formats.e`)

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
- [ ] Number formatting
- [ ] Cell-level styling

`ptFormat.colAlign` / `ptSetColAlign`/`ptModelSetColAlign` (one `l`/`c`/`r` per column, including the
stub) now drives alignment in every renderer, not just LaTeX: Markdown emits the corresponding
`:---`/`:---:`/`---:` alignment row, HTML adds `style="text-align:..."` to `<th>`/`<td>`, and plain
text left/center/right-pads each column. When `colAlign` is unset, the previous defaults (stub
left-aligned, data columns right-aligned) are unchanged. Number formatting and cell-level styling
remain unimplemented.

## Significance Controls

Support:

- [x] Custom significance symbols (`ptSetStars`/`ptModelSetStars`, `ptNoStars`/`ptModelNoStars`)
- [x] Custom significance thresholds (`ptSetStars`/`ptModelSetStars`)

## Workflow Enhancements

Support:

- [x] Multi-table export workflows
- [ ] Batch reporting workflows

Implemented via `ptExportAll(tables, fname)`, where `tables` is a `ptTable` array (e.g.
`reshape(tbl, n, 1)` with indexed assignment). It dispatches on file extension like `ptExport`:
Markdown/CSV/Text/HTML concatenate each table's rendered output (Markdown tables are separated by a
horizontal rule); RTF merges all tables into a single `{\rtf1...}` document; XLS/XLSX write each
table to its own sheet (sheet `1`, `2`, ... via `SpreadsheetWrite`).

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

- [ ] QARDL reporting helpers
- [ ] TSMT reporting helpers
- [ ] ARDL-family reporting adapters
- [ ] Automatic model-summary generation
- [ ] Publication-ready econometric reporting workflows
