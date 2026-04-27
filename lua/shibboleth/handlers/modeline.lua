local M = {}

local FALLBACK_COMMENTSTRINGS = {
  awk = '# %s', bash = '# %s', fish = '# %s', julia = '# %s',
  make = '# %s', nu = '# %s', perl = '# %s', python = '# %s',
  r = '# %s', ruby = '# %s', sh = '# %s', tcl = '# %s', toml = '# %s',
  yaml = '# %s', zsh = '# %s',
  c = '// %s', cpp = '// %s', go = '// %s', java = '// %s',
  javascript = '// %s', typescript = '// %s', rust = '// %s',
  php = '// %s', swift = '// %s', scala = '// %s', kotlin = '// %s',
  lua = '-- %s', sql = '-- %s', haskell = '-- %s',
  vim = '" %s',
  applescript = '-- %s',
  json = '// %s',
}

local function commentstring(ft)
  local ok, cs = pcall(vim.filetype.get_option, ft, 'commentstring')
  if ok and type(cs) == 'string' and cs ~= '' then return cs end
  return FALLBACK_COMMENTSTRINGS[ft] or require('shibboleth.config').get().fallback_commentstring
end

local function format_with_comment(cs, body)
  if cs:find('%%s') then return (cs:gsub('%%s', body)) end
  return cs .. ' ' .. body
end

---Find a Vim-prefix anchor (`vim:`, `vi:`, or `ex:`) preceded by start-of-line or whitespace.
---@param line string
---@return integer|nil start_index
---@return integer|nil end_index
---@return string|nil anchor
local function find_anchor(line)
  for _, anchor in ipairs({ 'vim:', 'vi:', 'ex:' }) do
    local s = 1
    while true do
      local i = line:find(anchor, s, true)
      if not i then break end
      local prev = i > 1 and line:sub(i - 1, i - 1) or ''
      if prev == '' or prev:match('%s') then
        return i, i + #anchor - 1, anchor
      end
      s = i + 1
    end
  end
  return nil
end

---@param line string
---@return { kind: 'set'|'short', anchor: string, anchor_start: integer, options: string, trailing: string? } | nil
local function parse_modeline(line)
  local s, e, anchor = find_anchor(line)
  if not s then return nil end
  local rest = line:sub(e + 1):gsub('^%s+', '')
  if rest:match('^set%s+') or rest:match('^se%s+') then
    local options, trailing = rest:match('^se[t]?%s+(.-):(.*)$')
    if options then
      return { kind = 'set', anchor = anchor, anchor_start = s, options = options, trailing = trailing or '' }
    end
  end
  return { kind = 'short', anchor = anchor, anchor_start = s, options = rest }
end

local function update_options(options_str, kind, ft)
  local sep = kind == 'set' and ' ' or ':'
  local parts = vim.split(options_str, sep, { trimempty = true })
  for i, part in ipairs(parts) do
    local key = part:match('^([%w_]+)')
    if key == 'ft' or key == 'filetype' then
      parts[i] = key .. '=' .. ft
      return table.concat(parts, sep), true
    end
  end
  table.insert(parts, 'ft=' .. ft)
  return table.concat(parts, sep), false
end

local function rebuild_line(line, m, new_options)
  local prefix = line:sub(1, m.anchor_start - 1)
  if m.kind == 'set' then
    return prefix .. m.anchor .. ' set ' .. new_options .. ':' .. (m.trailing or '')
  end
  return prefix .. m.anchor .. ' ' .. new_options
end

---@param bufnr integer
---@return { row: integer, ft: string|nil, parsed: table } | nil
function M.detect(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local n = vim.api.nvim_buf_line_count(bufnr)
  local scan = math.min(vim.o.modelines, n)
  for i = 0, scan - 1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or ''
    local m = parse_modeline(line)
    if m then
      local ft
      local sep = m.kind == 'set' and ' ' or ':'
      for _, part in ipairs(vim.split(m.options, sep, { trimempty = true })) do
        local k, v = part:match('^([%w_]+)=(.*)$')
        if k == 'ft' or k == 'filetype' then ft = v; break end
      end
      return { row = i, ft = ft, parsed = m, line = line }
    end
  end
  return nil
end

---@param bufnr integer
---@param ft string
---@return boolean
function M.apply(bufnr, ft)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local existing = M.detect(bufnr)
  if existing then
    local new_options = update_options(existing.parsed.options, existing.parsed.kind, ft)
    local rebuilt = rebuild_line(existing.line, existing.parsed, new_options)
    vim.api.nvim_buf_set_lines(bufnr, existing.row, existing.row + 1, false, { rebuilt })
    return true
  end

  local row = 0
  local first = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
  if first:match('^#!') then row = 1 end

  local cs = commentstring(ft)
  local body = 'vim: set ft=' .. ft .. ':'
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, { format_with_comment(cs, body) })
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
