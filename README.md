# shibboleth.nvim

> *shib·bo·leth* — a small utterance that reveals what one is.

A Neovim plugin that inserts and updates **schema-pointer directives** in
configuration files, so any editor or LSP that reads them can validate the
file against the right schema. Resolves candidate schemas by matching the buffer's path against a [curated set of pairings](./lua/shibboleth/registry/patterns.lua).

This is meant to _complement_, not replace, your existing
LSP / language-server setup. Instead of relying on per-machine editor config to bind a file to a schema,
it writes a directive that rides in version-control within the file itself, so every collaborator's
editor picks up the same schema without having a similar setup as yours.

Supports JSON, YAML, and TOML out of the box. 

**Bonus feature**: Write a Vim filetype modeline so a file's intended filetype rides in version
control — useful for extension-less scripts and ambiguous files.


## What it writes

| Filetype | Directive | Example |
|---|---|---|
| JSON   | top-level `$schema` property                   | `"$schema": "https://json.schemastore.org/package.json"` |
| YAML   | `# yaml-language-server: $schema=...` modeline | `# yaml-language-server: $schema=https://json.schemastore.org/github-workflow.json` |
| YAML (alt) | `# $schema: ...` (IntelliJ-compatible)     | `# $schema: https://json.schemastore.org/github-workflow.json` |
| TOML   | Taplo `#:schema` directive                     | `#:schema https://json.schemastore.org/pyproject.json` |
| any    | Vim filetype modeline                          | `# vim: set ft=ruby:` |


## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'bezhermoso/shibboleth.nvim',
  cmd = { 'Shibboleth', 'ShibbolethModeline' },
  opts = {},
}
```

Requirements:

- Neovim 0.10+
- Tree-sitter `json` parser (for the JSON handler)
- `curl` (only if you use the SchemaStore loader)

Run `:checkhealth shibboleth` to verify.

## Commands

```vim
:Shibboleth                      " open schema picker for current buffer
:Shibboleth <url>                " set schema URL directly (no picker)
:Shibboleth remove               " remove existing directive

:ShibbolethModeline              " write `# vim: set ft=<bo.filetype>:` modeline
:ShibbolethModeline <ft>         " write modeline with explicit filetype
:ShibbolethModeline remove       " remove modeline
```

`:Shibboleth` resolves candidates by **matching the buffer's path against a
curated set of file globs** (e.g. `package.json` → npm schema,
`**/.github/workflows/*.yml` → GitHub Actions schema,
`**/.claude/settings.json` → Claude Code settings).

`:ShibbolethModeline` uses **the buffer's existing filetype** (`vim.bo.filetype`).
If neither the buffer's filetype nor an explicit `<ft>` argument is available,
it prompts for one via `vim.ui.input`. Tab-completion offers Neovim's filetype
list (plus the `remove` keyword).

> [!NOTE]
> For extension-less scripts where you want the filetype detected from a
> shebang, install something like
> [shebang.nvim](https://github.com/LunarLambda/shebang.nvim) or rely on
> Neovim's built-in filetype detection (`vim.filetype`). Then run
> `:ShibbolethModeline` to persist that filetype hint into the file.

## Configuration

```lua
require('shibboleth').setup({
  yaml = {
    style = 'modeline', -- 'modeline' (default) or 'intellij'
  },
  fallback_commentstring = '# %s',

  -- Add custom schemas
  schemas = {
    ['my-thing'] = {
      name = 'My Thing config',
      url = 'https://example.com/my-thing.schema.json',
      ft = { 'yaml' },
    },
  },

  -- Add custom glob patterns. `schema` references a key from the schemas table above.
  patterns = {
    { pattern = '*.mything.{yml,yaml}', schema = 'my-thing' },
  },
})
```

## Optional: load SchemaStore catalog

For the long tail of schemas (1,200+ entries from
[json.schemastore.org](https://www.schemastore.org/)), opt in:

```lua
require('shibboleth.registry.schemastore').load()
```

This fetches the catalog of schemas and merges them into your registry.

To force a refresh:

```lua
require('shibboleth.registry.schemastore').load({ force = true })
```


## Development

```sh
make test          # run the plenary test suite
make test-watch    # re-run on every save (requires entr)
make lint          # luacheck if installed
```


## Why not yaml-companion.nvim / SchemaStore.nvim?

These tools are **complementary**, not competing.

- [yaml-companion.nvim](https://github.com/someone-stole-my-name/yaml-companion.nvim)
  picks a YAML schema and tells the LSP about it via
  `workspace/didChangeConfiguration`. The choice lives in your Neovim
  session and is YAML-only.
- [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim) supplies
  catalog data to your LSP server config.
- shibboleth.nvim writes a **persistent directive into the file itself**,
  across JSON / YAML / TOML, so the schema choice is portable, version-
  controlled, and visible to any editor with the right LSP — not just
  your Neovim.

You can use all three.
