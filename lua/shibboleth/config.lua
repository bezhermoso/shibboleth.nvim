local M = {}

local defaults = {
  yaml = {
    style = 'modeline', -- 'modeline' (default, broad support) | 'intellij' (`# $schema: ...`)
  },
  modeline = {
    position = 'top', -- 'top' (after shebang) | 'bottom'  -- only 'top' is wired up for now
  },
  fallback_commentstring = '# %s',
}

local current = vim.deepcopy(defaults)

function M.setup(user)
  current = vim.tbl_deep_extend('force', current, user or {})
end

function M.get()
  return current
end

function M.defaults()
  return vim.deepcopy(defaults)
end

return M
