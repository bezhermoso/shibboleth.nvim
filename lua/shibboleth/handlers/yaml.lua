local M = {}

local SCAN_LIMIT = 20

local PATTERN_MODELINE = '^%s*#%s*yaml%-language%-server:%s*%$schema=(.*)$'
local PATTERN_INTELLIJ = '^%s*#%s*%$schema:%s*(.*)$'

local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end

---@param bufnr integer
---@return { row: integer, url: string, style: 'modeline'|'intellij' } | nil
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local n = math.min(SCAN_LIMIT, vim.api.nvim_buf_line_count(bufnr))
  for i = 0, n - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ''
    local url = line:match(PATTERN_MODELINE)
    if url then return { row = i, url = trim(url), style = 'modeline' } end
    url = line:match(PATTERN_INTELLIJ)
    if url then return { row = i, url = trim(url), style = 'intellij' } end
  end
  return nil
end

local function format_line(url, style)
  if style == 'intellij' then
    return '# $schema: ' .. url
  end
  return '# yaml-language-server: $schema=' .. url
end

---@param bufnr integer
---@param url string
---@return boolean
function M.apply(bufnr, url)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local existing = M.detect(bufnr)
  if existing then
    vim.api.nvim_buf_set_lines(bufnr, existing.row, existing.row + 1, false, {
      format_line(url, existing.style),
    })
    return true
  end

  local style = require('shibboleth.config').get().yaml.style or 'modeline'

  local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
  local insert_at = first:match('^%-%-%-%s*$') and 1 or 0
  vim.api.nvim_buf_set_lines(bufnr, insert_at, insert_at, false, { format_line(url, style) })
  return true
end

---@param bufnr integer
---@return boolean
function M.remove(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local existing = M.detect(bufnr)
  if not existing then return false end
  vim.api.nvim_buf_set_lines(bufnr, existing.row, existing.row + 1, false, {})
  return true
end

return M
