local M = {}

---@param content string  Multi-line content; '\n' becomes line breaks.
---@param ft? string      Filetype to assign to the buffer.
---@return integer bufnr
function M.make_buf(content, ft)
  local b = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(b, 0, -1, false, vim.split(content, '\n', { plain = true }))
  if ft then vim.bo[b].filetype = ft end
  return b
end

---@param bufnr integer
---@return string
function M.dump(bufnr)
  return table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n')
end

return M
