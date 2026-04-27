local M = {}

local PATTERN = '^%s*#:schema%s+(.*)$'

local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end

---@param bufnr integer
---@return { row: integer, url: string } | nil
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local n = vim.api.nvim_buf_line_count(bufnr)
  for i = 0, math.min(10, n - 1) do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ''
    local url = line:match(PATTERN)
    if url then return { row = i, url = trim(url) } end
    -- Stop scanning once we reach a non-comment, non-blank line: directives must be in the
    -- top comment block per Taplo's spec.
    if line ~= '' and not line:match('^%s*#') then break end
  end
  return nil
end

---@param bufnr integer
---@param url string
---@return boolean
function M.apply(bufnr, url)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local existing = M.detect(bufnr)
  local line = '#:schema ' .. url
  if existing then
    vim.api.nvim_buf_set_lines(bufnr, existing.row, existing.row + 1, false, { line })
    return true
  end
  vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { line })
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
