local ts = require('shibboleth.ts')

local M = {}

local QUERY_SCHEMA = [[
(pair
  key: (string (string_content) @key (#eq? @key "$schema"))
  value: (string (string_content) @value)) @pair
]]

---@param bufnr integer
---@return { url: string, value_range: integer[] } | nil
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local node = ts.first_capture(bufnr, 'json', QUERY_SCHEMA, 'value')
  if not node then return nil end
  local sr, sc, er, ec = node:range()
  return {
    url = vim.treesitter.get_node_text(node, bufnr),
    value_range = { sr, sc, er, ec },
  }
end

local function find_root_object(root)
  if root:type() == 'object' then return root end
  for child in root:iter_children() do
    if child:type() == 'object' then return child end
  end
  return nil
end

local function find_first_pair(obj)
  for child in obj:iter_children() do
    if child:type() == 'pair' then return child end
  end
  return nil
end

local function detect_indent(bufnr, ref_row)
  local line = vim.api.nvim_buf_get_lines(bufnr, ref_row, ref_row + 1, false)[1] or ''
  local indent = line:match('^(%s*)')
  if indent and indent ~= '' then return indent end
  return string.rep(vim.bo[bufnr].expandtab and ' ' or '\t',
    vim.bo[bufnr].expandtab and (vim.bo[bufnr].shiftwidth > 0 and vim.bo[bufnr].shiftwidth or 2) or 1)
end

---@param bufnr integer
---@param url string
---@return boolean
function M.apply(bufnr, url)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local existing = M.detect(bufnr)
  if existing then
    local r = existing.value_range
    vim.api.nvim_buf_set_text(bufnr, r[1], r[2], r[3], r[4], { url })
    return true
  end

  local root = ts.get_root(bufnr, 'json')
  if not root then
    vim.notify('shibboleth: JSON tree-sitter parser unavailable; install nvim-treesitter `json` parser', vim.log.levels.ERROR)
    return false
  end

  -- Only treat as empty if the buffer has no content; otherwise refuse rather than overwrite.
  local obj = find_root_object(root)
  if not obj then
    local total = vim.api.nvim_buf_line_count(bufnr)
    local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
    if total <= 1 and first:match('^%s*$') then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
        '{',
        '  "$schema": ' .. vim.fn.json_encode(url),
        '}',
      })
      return true
    end
    vim.notify('shibboleth: no top-level JSON object found in buffer', vim.log.levels.ERROR)
    return false
  end

  local first_pair = find_first_pair(obj)
  local quoted = vim.fn.json_encode(url)

  if not first_pair then
    -- Empty object: rewrite into multi-line form.
    local osr, osc, oer, oec = obj:range()
    vim.api.nvim_buf_set_text(bufnr, osr, osc, oer, oec, {
      '{',
      '  "$schema": ' .. quoted,
      '}',
    })
    return true
  end

  local psr, psc = first_pair:range()
  local osr, _, oer = obj:range()
  local single_line = osr == oer

  if single_line then
    vim.api.nvim_buf_set_text(bufnr, psr, psc, psr, psc, {
      '"$schema": ' .. quoted .. ', ',
    })
  else
    local indent = detect_indent(bufnr, psr)
    vim.api.nvim_buf_set_text(bufnr, psr, psc, psr, psc, {
      '"$schema": ' .. quoted .. ',',
      indent,
    })
  end
  return true
end

---@param bufnr integer
---@return boolean
function M.remove(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  -- Find the enclosing pair node and any trailing comma; remove the whole pair line(s).
  local root = ts.get_root(bufnr, 'json')
  if not root then return false end
  local ok, query = pcall(vim.treesitter.query.parse, 'json', QUERY_SCHEMA)
  if not ok then return false end
  local pair_node
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    if query.captures[id] == 'pair' then
      pair_node = node
      break
    end
  end
  if not pair_node then return false end

  local psr, psc, per, pec = pair_node:range()

  -- Extend `pec` over a trailing comma (and any whitespace) if present.
  local after_text = vim.api.nvim_buf_get_lines(bufnr, per, per + 1, false)[1] or ''
  local rest = after_text:sub(pec + 1)
  local comma_offset = rest:match('^(%s*,)')
  if comma_offset then
    pec = pec + #comma_offset
  end

  -- If the pair occupies its own line, remove the whole line.
  local line_text = vim.api.nvim_buf_get_lines(bufnr, psr, psr + 1, false)[1] or ''
  local before = line_text:sub(1, psc):match('^%s*$')
  local after = (vim.api.nvim_buf_get_lines(bufnr, per, per + 1, false)[1] or ''):sub(pec + 1):match('^%s*$')
  if before and after and psr == per then
    vim.api.nvim_buf_set_lines(bufnr, psr, psr + 1, false, {})
    return true
  end

  vim.api.nvim_buf_set_text(bufnr, psr, psc, per, pec, { '' })
  return true
end

return M
