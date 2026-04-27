local M = {}

---@param bufnr integer
---@param lang string
---@return TSNode|nil
function M.get_root(bufnr, lang)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang)
  if not ok or not parser then return nil end
  local trees = parser:parse()
  if not trees or not trees[1] then return nil end
  return trees[1]:root()
end

---Run a query against a buffer's parse tree, returning the first node captured under `capture`.
---@param bufnr integer
---@param lang string
---@param query_string string
---@param capture string
---@return TSNode|nil
function M.first_capture(bufnr, lang, query_string, capture)
  local root = M.get_root(bufnr, lang)
  if not root then return nil end
  local ok, query = pcall(vim.treesitter.query.parse, lang, query_string)
  if not ok then return nil end
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] == capture then return node end
  end
  return nil
end

return M
