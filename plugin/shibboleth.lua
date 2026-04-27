if vim.g.loaded_shibboleth then return end
vim.g.loaded_shibboleth = 1

vim.api.nvim_create_user_command('Shibboleth', function(opts)
  local m = require('shibboleth')
  if opts.args == '' then
    m.pick()
  elseif opts.args == 'remove' then
    m.remove()
  else
    m.set(0, opts.args)
  end
end, {
  nargs = '?',
  desc = 'Insert/update/remove schema directive in current buffer',
  complete = function(arglead)
    if vim.startswith('remove', arglead) then return { 'remove' } end
    return {}
  end,
})

vim.api.nvim_create_user_command('ShibbolethModeline', function(opts)
  local m = require('shibboleth')
  if opts.args == 'remove' then
    m.modeline_remove()
  else
    m.modeline(0, opts.args ~= '' and opts.args or nil)
  end
end, {
  nargs = '?',
  desc = 'Insert/update/remove Vim filetype modeline in current buffer',
  complete = function(arglead)
    local out = vim.fn.getcompletion(arglead, 'filetype')
    if vim.startswith('remove', arglead) then table.insert(out, 1, 'remove') end
    return out
  end,
})

vim.api.nvim_create_user_command('ShibbolethSchemaStore', function(opts)
  local ok, result = require('shibboleth.registry.schemastore').load({ force = opts.bang })
  if ok then
    vim.notify(string.format(
      'shibboleth: loaded %d schemas, %d patterns from SchemaStore',
      result.schemas, result.patterns
    ), vim.log.levels.INFO)
  else
    vim.notify('shibboleth: SchemaStore load failed: ' .. tostring(result), vim.log.levels.ERROR)
  end
end, {
  bang = true,
  desc = 'Load SchemaStore catalog into the registry (use ! to force a refresh)',
})
