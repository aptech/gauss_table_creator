# Changelog

All notable changes to `pubtable` are documented in this file.

This project does not yet follow strict [Semantic Versioning](https://semver.org/) —
it is in beta (`0.x`) while the modern `pt*` API stabilizes. The format loosely follows
[Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- `"journal_booktabs"` style preset (`ptApplyPreset`/`ptModelApplyPreset`): identical to
  `"journal"`, plus `ptFormat.ruleStyle = "booktabs"`, which makes `ptRenderHtml`/`ptRenderRtf`
  draw only a table-top rule, a header-bottom rule, and a table-bottom rule (no
  vertical/column-divider rules). `ptRenderLatex` needed no change — it already renders
  booktabs-style with no vertical rules by default.
- `ptFormat.preset` now records the name of the last-applied preset (`""` if none), so
  preset-dependent behavior (the title warning below) can be conditioned on it.
- Non-fatal title warning for journal-style tables: `ptExport`, `ptRenderLatex`,
  `ptRenderHtml`, and `ptRenderRtf` print (via `errorlog`, through the shared helper
  `_ptCheckJournalTitle`) "pubtable warning: journal-style table has no title. Use
  ptSetTitle(tbl, ...) before exporting." when `fmt.preset` is `"journal"` or
  `"journal_booktabs"` and `title` is empty. Export/render still completes.
- `ptModelSetDataLabel(model, label)` and `ptModel.dataLabel`: records a dataset
  description as its own `"Data: <label>."` note, rendered separately from
  `ptModelSetNotes` content by `ptModelTable`/`ptModelCompareWith` so callers no longer
  need to hand-concatenate a "Data: ..." string into another note.
- `ptModelSetAicBic(model, tf)` and `ptModel.hasOptionalAicBic`: `ptModelFromCmlmt` and
  `ptModelFromMaxlikmt` now always compute and append `AIC = -2*fval + 2*k` and
  `BIC = -2*fval + 2*k*ln(n)` as the last two GOF rows, but those two rows stay hidden by
  default. `ptModelSetAicBic(model, 1)` reveals them. The new `ptFilterGofRows` helper
  drops exactly the trailing two GOF rows **by position**, gated on
  `hasOptionalAicBic` — never by matching the `"AIC"`/`"BIC"` label text — so models that
  already report their own non-optional AIC/BIC (e.g. `ptModelFromGlm`) are unaffected.

### Fixed
- `ptRenderText` and `ptRenderMarkdown` could misalign a coefficient's stat sub-row
  (SE/t-stat/p-value/CI) against its own coefficient whenever the coefficient's
  significance-star suffix had a different length than other rows in the same column
  (0 vs. 1 vs. 2 characters). Added `ptApplyStarGutter`/`ptTrailingDecorLen`, which
  reserve a fixed-width trailing slot per column for stars and closing
  parentheses/brackets before column widths are computed, so the numeric content lines
  up regardless of star count. `ptRenderMarkdown` previously applied no cell padding at
  all; it now pads the same way `ptRenderText` does.
- `ptModelFromQardl`/`ptModelFromQardlECM` (`src/pubtable_qardl.src`) crashed with
  `Error in 'dynargsGet': input 1 must be a scalar or real 2x1 vector` — the variadic
  argument fetch used `dynargsGet(1|2|3)` (an invalid 3-element enumeration) instead of
  the correct `dynargsGet(1|3)` range form. Any call to `ptFromQardl`/`ptFromQardlECM`
  would have failed.
- `lib/pubtable.xml` (the legacy "Tools > Install Application" manifest) was missing
  `pubtable_model.src`, `pubtable_render.src`, and `pubtable_export.src` — split out of
  `pubtable.src` in an earlier change but never added there. Installing via that path
  produced a package with no `ptModelCreate`, `ptRender*`, or `ptExport*` at all.
- The project's test suite (`tests/test_pubtable*.e`) had not been re-run since
  `ptModelFrom` was extended to dispatch on optional add-on adapters; every adapter test
  file was stale (missing the `pubtable_model.src`/`pubtable_render.src`/
  `pubtable_export.src` includes from an earlier split) and silently un-run. All test
  files now use `library pubtable;` (and `library <addon>, pubtable;`) rather than raw
  multi-file `#include`, which also sidesteps a `modelResults` structure-redefinition
  conflict that raw `#include` of multiple optional adapters can trigger.

### Known limitations
- `tests/test_pubtable_optmt.e` reliably fails with a `modelResults` structure-redefinition
  error (G0465) on any machine where `optmt` *and* any of cmlmt/maxlikmt/tsmt are
  installed, once the script actually calls `optmt()`. Root cause: `library pubtable;`
  unconditionally compiles `pubtable_cmlmt.src`/`pubtable_maxlikmt.src`/
  `pubtable_tsmt.src` too (per `package.json`), and `optmt`'s own `modelResults` shape
  conflicts with theirs once `optmt()` is actually invoked. This is a cross-package
  GAUSS interoperability issue exposed by pubtable's all-adapters-always-compiled
  packaging strategy, not a bug in the optmt adapter code itself.

## [0.3.0-beta.1]

This is the first tagged version, covering the full modernization of the legacy table
creator into the `pt*`-prefixed `pubtable` API. It consolidates everything done before
the `CHANGELOG.md` itself was introduced.

### Added
- Core structs and dispatchers: `ptFormat`, `ptTable`, `ptModel`; `ptTableCreate`,
  `ptTableFromMatrix`, `ptTableFrom`, `ptModelCreate`, `ptModelFrom`, `ptModelTable`.
- Model comparison: `ptModelCompare`/`ptModelCompareWith`, aligning models on the union
  of term names and goodness-of-fit rows (including models with different regressors;
  missing cells render blank). `ptCompareOptions` for term/GOF ordering, label renaming,
  table-level notes, and grouped/spanning column headers across comparison columns.
- Renderers for Markdown, LaTeX (`booktabs`-style), CSV, plain text, RTF (real grid
  borders and bold header row via `\trowd`/`\cellx`/`\cell`/`\row`, not tab-separated
  text), and HTML; `ptExport` dispatches on file extension, `ptExportAll` writes a
  `ptTable` array to one file (one sheet per table for XLS/XLSX), and
  `ptExportAllFormats` batch-exports the same array to several formats in one call.
- Style presets (`ptApplyPreset`/`ptModelApplyPreset`): `"journal"`, `"compact"`,
  `"plain"`, `"report"`.
- Significance stars with configurable cutoffs/symbols (`ptSetStars`/`ptModelSetStars`,
  `ptNoStars`/`ptModelNoStars`); configurable statistic rows under each coefficient
  (`se`, `tstat`, `pvalue`, `ci` via `ptSetStatRows`/`ptModelSetStatRows`).
- Grouped/spanning column headers (`ptSetColGroups`/`ptCompareSetColGroups`), rendered as
  a pseudo-span in Markdown/CSV/Text, `\multicolumn`/`\cmidrule` in LaTeX, `colspan` in
  HTML, and `\clmgf`/`\clmrg` cell merges in RTF.
- Column alignment (`ptSetColAlign`/`ptModelSetColAlign`) driving every renderer, not
  just LaTeX.
- Per-column number reformatting (`ptSetColFormat`) and per-cell styling
  (`ptSetCellStyle`: bold/italic/bold italic).
- Built-in adapters: `olsmtOut`, `glmOut`, `gmmOut`, `dstatmtOut`, `fglsOut`.
- Optional add-on adapters, each in its own source file and auto-loaded via
  `pubtableSet()`/`pubtable.dec`:
  - `pubtable_cmlmt.src` (`cmlmtResults`), `pubtable_maxlikmt.src` (`maxlikmtResults`).
  - `pubtable_tsmt.src`: `arimamtOut`, `tsPanelEstimationOut`, `automtOut`,
    `varmamtOut`, `lsdvmtOut`, `switchmtOut`, `garchEstimation`, `tscsmtOut`.
  - `pubtable_optmt.src`: `optmtResults` (parameter/estimate/gradient table only, since
    `optmtResults` has no covariance matrix).
  - `pubtable_qardl.src`: ARDL/QARDL/NARDL/CS-ARDL family (`ardlOut`/`ardlECMOut`,
    `qardlOut`/`qardlECMOut`, `nardlOut`/`nardlECMOut`, `csardlOut`/`csardlECMOut`, and
    the `*Full` workflow outputs), auto-detected via `qardl.sdf`'s own
    `QARDL_SDF_INCLUDED` guard.
  - Most add-on adapters are wired into the standard `ptModelFrom(name, out)` dispatcher
    via `isStructType`, so callers don't need to know the library-specific function
    name. Not wired in: `optmtResults` (no `ptModel` form), `tscsmtOut` (two distinct
    estimators, no single canonical model), `qardlOut`/`qardlECMOut` (need an extra
    `tauIdx` argument the two-argument dispatcher can't supply).
- Legacy `tableControl`/`tableSet...`/`outputTable` API retained for migration, with a
  [migration guide](docs/migration.md) mapping it onto the modern API.

### Changed
- Core source split across `pubtable.src` (format/presets, utilities, table struct and
  setters, dispatchers, built-in adapters, setup), `pubtable_model.src` (all
  `ptModel*`/`ptCompare*` procedures), `pubtable_render.src` (number formatting and all
  `ptRender*`), and `pubtable_export.src` (all `ptExport*` and file I/O). `library
  pubtable;` compiles all of them automatically via `package.json`.
- Optional adapter files rewritten so each proc is declared **once** with variadic
  `(...)` arguments and fetches typed arguments via `dynargsGet()` inside an inner
  `#ifDef PT_USE_X / #else / #endIf` (or `#ifDef QARDL_SDF_INCLUDED` for qardl) —
  replacing an earlier pattern of two fully duplicated proc bodies per adapter. Each
  `PT_USE_X`-gated file now includes `pubtable.dec` itself, so calling code only needs a
  single combined `library <addon>, pubtable;` statement — no `#include` lines at all.
- `_library_missing_error` consolidated into `pubtable.src` itself (not any adapter
  file), avoiding structure-conflict errors from library-specific `.sdf` type
  definitions compiled alongside it.
- `ptModelFrom` extended to dispatch on most optional add-on output structs (cmlmt,
  maxlikmt, and most of tsmt/qardl), not just the built-in structs.
- All struct-returning procedures declare their return type explicitly
  (`proc (struct ptTable) = procName(...)`), so callers no longer need to pre-declare
  the struct variable before assignment.

### Fixed
- `ptModelFromArimamt` (`src/pubtable_tsmt.src`) crashed for AR(2)+ models —
  `arimamtOut.b` always appends the constant as its last row, but `arimamtOut.vcb`
  covers only the AR/MA terms, so the standard-error vector was one row short. `se` now
  pads a missing value for the constant.
- `N` reported incorrectly in the `olsmt`/`fgls` adapters; Markdown column alignment
  fixed; integer-valued GOF/count cells now render without a decimal point.

### Known limitations
- True `.docx` export is not implemented — it requires generating zipped Office Open
  XML; the practical Word-compatible path is `.rtf`/`.html`.
- `gmmOut` field names are verified but a real-execution adapter test is still pending
  due to `&meqn` callback complexity.
- Diagnostic/structural-break/threshold structs (e.g. `sbOut`, `TAROut`,
  `tspanelOut`'s top-level wrapper) and several QARDL diagnostic/Wald/rolling/QIRF/
  selection output structs are not covered by any adapter.
