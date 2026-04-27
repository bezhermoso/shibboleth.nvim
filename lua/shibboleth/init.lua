local M = {}

local config = require('shibboleth.config')
local registry = require('shibboleth.registry')
local handlers = require('shibboleth.handlers')
local ui = require('shibboleth.ui')

---@param user_config table?
function M.setup(user_config)
  user_config = user_config or {}
  config.setup(user_config)
  registry.extend({
    schemas = user_config.schemas,
    patterns = user_config.patterns,
  })
end

local function build_schema_items(bufnr, existing)
  local ft = vim.bo[bufnr].filetype
  local path = vim.api.nvim_buf_get_name(bufnr)
  local matches = registry.match_path(path)
  local available = registry.schemas_for_ft(ft)

  local items = {}
  local seen = {}

  if existing then
    table.insert(items, {
      kind = 'remove',
      label = string.format('× Remove existing directive (%s)', existing.url),
    })
  end

  for _, m in ipairs(matches) do
    if not seen[m.schema_id] then
      table.insert(items, {
        kind = 'schema',
        label = string.format('★ %s  (matched %s)', m.schema.name, m.pattern),
        url = m.schema.url,
      })
      seen[m.schema_id] = true
    end
  end
  for _, s in ipairs(available) do
    if not seen[s.id] then
      table.insert(items, {
        kind = 'schema',
        label = '  ' .. s.schema.name,
        url = s.schema.url,
      })
      seen[s.id] = true
    end
  end
  table.insert(items, { kind = 'custom', label = '> Enter URL...' })

  return items, ft
end

---Open the schema picker for the current buffer.
---@param bufnr integer?
function M.pick(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local handler = handlers.for_filetype(ft)
  if not handler then
    vim.notify('shibboleth: no handler for filetype ' .. (ft == '' and '<none>' or ft), vim.log.levels.WARN)
    return
  end

  local existing = handler.detect(bufnr)
  local items = build_schema_items(bufnr, existing)

  ui.select(items, {
    prompt = 'Schema for ' .. (ft == '' and 'buffer' or ft) .. ':',
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    if choice.kind == 'remove' then
      handler.remove(bufnr)
    elseif choice.kind == 'custom' then
      ui.input({
        prompt = 'Schema URL: ',
        default = existing and existing.url or '',
      }, function(url)
        if url and url ~= '' then handler.apply(bufnr, url) end
      end)
    else
      handler.apply(bufnr, choice.url)
    end
  end)
end

---Set a schema URL directly without prompting.
---@param bufnr integer?
---@param url string
function M.set(bufnr, url)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local handler = handlers.for_filetype(vim.bo[bufnr].filetype)
  if not handler then
    vim.notify('shibboleth: no handler for filetype ' .. vim.bo[bufnr].filetype, vim.log.levels.WARN)
    return
  end
  handler.apply(bufnr, url)
end

---Remove an existing directive if present.
---@param bufnr integer?
function M.remove(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local handler = handlers.for_filetype(vim.bo[bufnr].filetype)
  if not handler then return end
  handler.remove(bufnr)
end

---Insert or update a Vim filetype modeline.
---Uses the buffer's existing filetype unless `ft` is given. If neither is set,
---prompts via `vim.ui.input`. Inserts after a shebang line if present.
---@param bufnr integer?
---@param ft string?
function M.modeline(bufnr, ft)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  ft = ft or vim.bo[bufnr].filetype
  if not ft or ft == '' then
    ui.input({ prompt = 'Filetype: ' }, function(input)
      if input and input ~= '' then
        require('shibboleth.handlers.modeline').apply(bufnr, input)
        vim.bo[bufnr].filetype = input
      end
    end)
    return
  end
  require('shibboleth.handlers.modeline').apply(bufnr, ft)
end

---Remove the Vim filetype modeline if present.
---@param bufnr integer?
function M.modeline_remove(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  require('shibboleth.handlers.modeline').remove(bufnr)
end

return M
