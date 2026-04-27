local M = {}

local function check_treesitter_parser(lang)
  local ok = pcall(vim.treesitter.language.add, lang)
  if ok then
    vim.health.ok(string.format('tree-sitter parser for `%s` is available', lang))
  else
    vim.health.warn(
      string.format('tree-sitter parser for `%s` not found', lang),
      { string.format(':TSInstall %s   (or install via your TS plugin)', lang) }
    )
  end
end

function M.check()
  vim.health.start('shibboleth.nvim')

  if vim.fn.has('nvim-0.10') == 1 then
    vim.health.ok('Neovim ' .. tostring(vim.version()))
  else
    vim.health.error('Neovim 0.10+ required (uses vim.glob.to_lpeg for glob matching)')
  end

  vim.health.start('shibboleth.nvim — registry')

  local ok, registry = pcall(require, 'shibboleth.registry')
  if not ok then
    vim.health.error('failed to load shibboleth.registry: ' .. tostring(registry))
    return
  end

  vim.health.ok(string.format('%d schemas loaded', vim.tbl_count(registry.schemas)))
  vim.health.ok(string.format('%d glob patterns loaded', #registry.patterns))

  vim.health.start('shibboleth.nvim — handlers')

  local handlers = require('shibboleth.handlers')
  local fts = handlers.supported_filetypes()
  vim.health.ok('handlers registered for: ' .. table.concat(fts, ', '))

  vim.health.start('shibboleth.nvim — tree-sitter parsers')
  check_treesitter_parser('json')

  vim.health.start('shibboleth.nvim — SchemaStore loader (optional)')
  if vim.fn.executable('curl') == 1 then
    vim.health.ok('curl is available (required for `require("shibboleth.registry.schemastore").load()`)')
  else
    vim.health.warn('curl not found — SchemaStore loader will be unavailable',
      { 'install curl, or skip the SchemaStore loader' })
  end
end

return M
