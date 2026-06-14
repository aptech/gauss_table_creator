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
- [ ] label
- [x] notes
- [ ] alignment controls

## HTML

Add HTML export as a bridge to:

- [ ] Word workflows
- [ ] Web reports
- [ ] Documentation systems

## RTF

- [ ] Improve formatting beyond simple tab-separated rows.

## DOCX

- [ ] Defer until a maintainable GAUSS-native ZIP/XML implementation exists.

---

# P2: Public API Cleanup

## API Review

Finalize names for:

- [ ] setters
- [ ] builders
- [ ] renderers
- [ ] exporters

## Options

Evaluate:

- [ ] `ptOptions`
- [ ] extending `ptFormat`

Use whichever produces the simplest API.

## Legacy Compatibility

Provide compatibility wrappers where practical for:

- [ ] `tableSet...`
- [ ] `outputTable`

## Deprecation Policy

Document:

- [ ] Supported legacy APIs
- [ ] Deprecated APIs
- [ ] Removed APIs

---

# P2: Documentation

## Modernization

Replace or modernize:

- [ ] `docs/tableset*.md`

## Command Reference

Add documentation for:

- [ ] `ptTableFromMatrix`
- [ ] `ptTableFrom`
- [ ] `ptModelFrom`
- [ ] `ptModelCompare`
- [ ] `ptExport`

## Examples

Add examples covering:

- [ ] Summary statistics tables
- [ ] Model comparison tables
- [ ] Custom matrix tables
- [ ] Markdown export
- [ ] LaTeX export
- [ ] HTML export
- [ ] CSV export
- [ ] XLSX export

## Migration Guide

Create:

```text
tabout -> pubtable
```

- [ ] migration documentation.

---

# P3: Advanced Features

## Headers

Support:

- [ ] Grouped headers
- [ ] Spanning headers

## Multi-Equation Models

Support:

- [ ] Equation panels
- [ ] Quantile-model panels
- [ ] Multi-model panels

## Cell Formatting

Support:

- [ ] Alignment controls
- [ ] Number formatting
- [ ] Cell-level styling

## Significance Controls

Support:

- [ ] Custom significance symbols
- [ ] Custom significance thresholds

## Workflow Enhancements

Support:

- [ ] Multi-table export workflows
- [ ] Batch reporting workflows

## Style Presets

Provide optional presets:

- [ ] journal
- [ ] compact
- [ ] plain
- [ ] report

---

# Future Evaluation

Potential future integrations:

- [ ] QARDL reporting helpers
- [ ] TSMT reporting helpers
- [ ] ARDL-family reporting adapters
- [ ] Automatic model-summary generation
- [ ] Publication-ready econometric reporting workflows
