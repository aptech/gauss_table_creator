# CLAUDE.md

Repository-specific instructions for AI coding agents working on this GAUSS table-generation library.

## Project Purpose

This repository modernizes an older GAUSS table creator into a GAUSS-first library for publication-quality tables from estimation results, summary statistics, matrices, and custom data. A clean redesign is acceptable. Preserve legacy code only when it improves maintainability, migration, or compatibility.

Current direction:

- Modern API prefix: `pt`
- Core structs: `ptFormat`, `ptTable`, `ptModel`
- Core source: `src/pubtable.sdf`, `src/pubtable.src`
- Legacy compatibility source: `src/pubtable_legacy.sdf`, `src/pubtable_legacy_output.src`, `src/pubtable_legacy_setters.src`

## Design Priorities

- Prefer simple, composable GAUSS procedures over complex abstractions.
- Keep table construction, formatting, rendering, and export separate.
- Use explicit typed adapters for GAUSS output structs, with dispatcher helpers where useful.
- Use `isStructType()` for routing from common GAUSS output structures when practical.
- Keep user-facing APIs stable, documented, and example-backed.
- Favor MVP-first changes, then expand once behavior is tested.
- Do not assume the old `tableControl`/`outputTable` design must be preserved.

## Table Scope

The library should support:

- Coefficient tables.
- Model comparison tables.
- Summary/statistics tables.
- Custom matrix/data tables.
- Exporters for Markdown, LaTeX, CSV, and plain text.
- Additional practical exporters where feasible, currently including `.xls`/`.xlsx` through `SpreadsheetWrite` and `.rtf` for Word-compatible output.

True `.docx` export is provisional/future work unless a maintainable GAUSS-native implementation is designed.

## GAUSS Guardrails

- GAUSS is not MATLAB, Python, R, Julia, or Stata. Verify syntax and built-ins.
- Do not invent unsupported GAUSS functions. Check existing GAUSS examples or the GAUSS reference repo first.
- Use documented string and formatting functions such as `sprintf`, `strindx`, `strsect`, `strreplace`, and `strtof`.
- Remember `strindx()` returns `0` when a pattern is not found.
- GAUSS is case-insensitive; do not rely on names that differ only by case.
- Use `getorders()` for arrays; `rows()` and `cols()` are for matrices.
- Check struct member names against actual `.sdf` files before writing adapters.
- Keep source filenames package-specific. Avoid names that collide with native GAUSS source files.

Reference repo for GAUSS syntax/style guidance:

- `C:\Users\eclow\Documents\GitHub\gauss-programming-llm`
- https://github.com/ec78/gauss-programming-llm

Relevant files in that repo include:

- `GAUSS_DEVELOPEMENT_STANDARDS.md`
- `GAUSS_KNOWLEDGE.md`
- `implementation_patterns/procedure_design.md`
- `implementation_patterns/string_parsing.md`
- `lessons_learned/testing_pitfalls.md`

## Coding Conventions

- Write readable GAUSS procedures with clear stages: validate, prepare, build, render/export.
- Add short dimension comments near non-trivial matrix or array logic.
- Validate dimensions and option values early.
- Prefer `sprintf` for convenient user-facing numeric/string formatting.
- Keep public procedure names descriptive and consistent with the `pt` API.
- Keep legacy compatibility wrappers separate from the modern implementation.
- Avoid broad refactors unless they directly support the requested feature.
- Preserve useful existing behavior only when it does not compromise the new design.

## Workflow

Before code changes:

1. Inspect existing source, tests, examples, and docs.
2. Check current public API usage in `README.md`, `examples/`, and `tests/`.
3. For major rewrites or API changes, summarize the design choice before implementing.
4. Use the GAUSS reference repo for syntax, struct, testing, and style questions.

When implementing:

1. Start with the smallest useful MVP.
2. Update source, examples, tests, and docs together.
3. Add or update source tests for every meaningful feature.
4. Keep exporters thin and table-format agnostic.
5. Keep adapters explicit: e.g. `ptModelFromOlsmt`, `ptModelFromGlm`, `ptFromDstatmt`.
6. Use `ptTableFrom(...)` / `ptModelFrom(...)` as convenience dispatchers, not as places for brittle generic reflection.

After changes:

1. Run the GAUSS tests.
2. Run `git diff --check`.
3. Search for stale filenames, API names, or old package names if files were renamed.
4. Summarize limitations and next steps.

## Testing

Current smoke/source test:

```powershell
C:\gauss26\tgauss.exe C:\Users\eclow\Documents\GitHub\gauss_table_creator\tests\test_pubtable.e
```

The GAUSS executable may print a command-log permission warning in this environment; treat the test result itself as authoritative.

Also run:

```powershell
git -C C:\Users\eclow\Documents\GitHub\gauss_table_creator diff --check
```

## Current API Notes

Current implemented/provisional public API includes:

- `ptTableCreate`
- `ptTableFromMatrix`
- `ptTableFrom`
- `ptModelCreate`
- `ptModelFrom`
- `ptModelTable`
- `ptModelCompare`
- `ptExport`
- `ptRenderMarkdown`, `ptRenderLatex`, `ptRenderCsv`, `ptRenderText`, `ptRenderRtf`

Current automatic adapters:

- `olsmtOut`
- `glmOut`
- `gmmOut` through `ptModelFrom`
- `dstatmtOut`

Current limitation: `ptModelCompare` expects models with the same coefficient row layout. Flexible term-union alignment is future work unless explicitly implemented.

## Documentation

- `README.md`: user-facing overview and current modern API examples.
- `examples/`: runnable usage examples.
- `docs/`: older legacy `tableSet` command docs; update or replace as the modern API matures.
- `tests/`: source tests/smoke tests.

