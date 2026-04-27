if vim.g.loaded_shibboleth then return end
vim.g.loaded_shibboleth = 1

local function err(msg)
  vim.notify('shibboleth: ' .. msg, vim.log.levels.ERROR)
end

local function notify_load_result(ok, result)
  if ok then
    vim.notify(string.format(
      'shibboleth: loaded %d schemas, %d patterns from SchemaStore',
      result.schemas, result.patterns
    ), vim.log.levels.INFO)
  else
    err('SchemaStore load failed: ' .. tostring(result))
  end
end

local function dispatch(args)
  local m = require('shibboleth')

  if #args == 0 then
    m.pick()
    return
  end

  local first = args[1]

  if first == 'remove' then
    m.remove()
    return
  end

  if first == 'modeline' then
    if #args == 1 then
      m.modeline(0)
    elseif args[2] == 'remove' then
      m.modeline_remove()
    else
      m.modeline(0, args[2])
    end
    return
  end

  if first == 'schemastore' then
    if #args == 1 then
      notify_load_result(require('shibboleth.registry.schemastore').load())
    elseif args[2] == 'refresh' then
      notify_load_result(require('shibboleth.registry.schemastore').load({ force = true }))
    else
      err('unknown schemastore subcommand: ' .. args[2])
    end
    return
  end

  if first:match('^https?://') then
    m.set(0, first)
    return
  end

  err('unknown subcommand: ' .. first)
end

local function complete(arglead, cmdline, cursorpos)
  local before = cmdline:sub(1, cursorpos)
  local args_str = before:gsub('^%s*%S+%s*', '', 1)
  local tokens = vim.split(args_str, '%s+', { trimempty = false })
  local position = #tokens

  if position == 1 then
    return vim.tbl_filter(
      function(s) return vim.startswith(s, arglead) end,
      { 'modeline', 'remove', 'schemastore' }
    )
  end

  if position == 2 then
    if tokens[1] == 'modeline' then
      local fts = vim.fn.getcompletion(arglead, 'filetype')
      if vim.startswith('remove', arglead) then table.insert(fts, 1, 'remove') end
      return fts
    end
    if tokens[1] == 'schemastore' then
      return vim.startswith('refresh', arglead) and { 'refresh' } or {}
    end
  end

  return {}
end

vim.api.nvim_create_user_command('Shibboleth', function(opts)
  dispatch(vim.split(opts.args, '%s+', { trimempty = true }))
end, {
  nargs = '*',
  desc = 'Manage schema directives, modelines, and registry catalog',
  complete = complete,
})
