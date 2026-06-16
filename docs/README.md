# Documentation Index

This directory documents both the modern `pubtable` (`pt*`) API and the retained legacy
`tableControl`/`tableSet...`/`outputTable` API. See the top-level [README.md](../README.md) for a
general overview and quick-start examples.

## Modern API reference (`docs/api/`)

Command reference for the core modern entry points:

| Function | Description |
| --- | --- |
| [ptTableFromMatrix](api/ptTableFromMatrix.md) | Build a table from a matrix plus row/column labels. |
| [ptTableFrom](api/ptTableFrom.md) | Build a table directly from a supported GAUSS output struct. |
| [ptModelFrom](api/ptModelFrom.md) | Build a `ptModel` from a supported GAUSS estimation output. |
| [ptModelCompare](api/ptModelCompare.md) | Create side-by-side model comparison tables, including `ptModelCompareWith`/`ptCompareOptions`. |
| [ptExport](api/ptExport.md) | Render and write a table, dispatching on file extension. |

Setters (`ptSet*`/`ptModelSet*`), renderers (`ptRender*`), and adapters (`ptModelFrom...`/`ptFrom...`)
are documented inline in `src/pubtable.src` and demonstrated in `examples/`; see `llms.txt` and the
top-level `README.md` for the full current list.

## Migration guide

[migration.md](migration.md) maps the legacy `tableControl`/`tableSet...`/`outputTable` workflow to
the modern `pt*` API.

## Legacy API reference (`docs/tableset*.md`)

The `tablesetasterisk.md`, `tablesetbrackets.md`, `tablesetcolumnheaders.md`, `tablesetexport.md`,
`tablesetnotes.md`, `tablesetparentheses.md`, `tablesetsigfig.md`, `tablesetstack.md`,
`tablesettitle.md`, and `tablesetvarnames.md` files document the original `tableControl`/`tableSet...`
API, which is retained as-is in `src/pubtable_legacy.sdf`, `src/pubtable_legacy_output.src`, and
`src/pubtable_legacy_setters.src` for migration and backward compatibility. New work should use the
modern `pt*` API documented above and in the top-level `README.md`.

## Development docs (`docs/dev/`)

| Document | Description |
| --- | --- |
| [ROADMAP.md](dev/ROADMAP.md) | Project roadmap and status. |
