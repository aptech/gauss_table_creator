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

* Harden `ptTable`, `ptModel`, and `ptFormat` validation.
* Add dimension checks.
* Add clearer error messages for malformed inputs.
* Ensure invalid export options fail gracefully.

## Testing

Expand `tests/test_pubtable.e` to cover:

* Markdown export
* LaTeX export
* CSV export
* Plain text export
* RTF export
* XLSX export

## Documentation

* Update README examples.
* Ensure install/use instructions reference `pubtable`.
* Remove remaining references to legacy `tabout` workflows.

---

# P1: Improve Model Tables

## Model Comparison

Enhance `ptModelCompare`:

* Flexible term alignment across models.
* Support models with different regressors.
* Consistent handling of missing coefficients.

## Coefficient Presentation

Add support for:

* Coefficient maps / variable renaming
* Custom term ordering
* Optional confidence intervals

## Statistics Rows

Configurable display of:

* Standard errors
* t-statistics
* p-values
* Confidence intervals

## Model Metadata

Support:

* Goodness-of-fit row selection
* GOF row ordering
* Model-specific notes
* Table-level notes

---

# P1: Add More GAUSS Adapters

## Existing Adapters

Strengthen support for:

* `olsmtOut`
* `glmOut`
* `gmmOut`
* `dstatmtOut`

## Additional Adapters

Evaluate support for:

* `qfitOut`
* `ttestOut`
* `fglsOut`
* `cmlmt`
* `maxlikmt`

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

* booktabs
* caption
* label
* notes
* alignment controls

## HTML

Add HTML export as a bridge to:

* Word workflows
* Web reports
* Documentation systems

## RTF

Improve formatting beyond simple tab-separated rows.

## DOCX

Defer until a maintainable GAUSS-native ZIP/XML implementation exists.

---

# P2: Public API Cleanup

## API Review

Finalize names for:

* setters
* builders
* renderers
* exporters

## Options

Evaluate:

* `ptOptions`
* extending `ptFormat`

Use whichever produces the simplest API.

## Legacy Compatibility

Provide compatibility wrappers where practical for:

* `tableSet...`
* `outputTable`

## Deprecation Policy

Document:

* Supported legacy APIs
* Deprecated APIs
* Removed APIs

---

# P2: Documentation

## Modernization

Replace or modernize:

* `docs/tableset*.md`

## Command Reference

Add documentation for:

* `ptTableFromMatrix`
* `ptTableFrom`
* `ptModelFrom`
* `ptModelCompare`
* `ptExport`

## Examples

Add examples covering:

* Summary statistics tables
* Model comparison tables
* Custom matrix tables
* Markdown export
* LaTeX export
* HTML export
* CSV export
* XLSX export

## Migration Guide

Create:

```text
tabout -> pubtable
```

migration documentation.

---

# P3: Advanced Features

## Headers

Support:

* Grouped headers
* Spanning headers

## Multi-Equation Models

Support:

* Equation panels
* Quantile-model panels
* Multi-model panels

## Cell Formatting

Support:

* Alignment controls
* Number formatting
* Cell-level styling

## Significance Controls

Support:

* Custom significance symbols
* Custom significance thresholds

## Workflow Enhancements

Support:

* Multi-table export workflows
* Batch reporting workflows

## Style Presets

Provide optional presets:

* journal
* compact
* plain
* report

---

# Future Evaluation

Potential future integrations:

* QARDL reporting helpers
* TSMT reporting helpers
* ARDL-family reporting adapters
* Automatic model-summary generation
* Publication-ready econometric reporting workflows
