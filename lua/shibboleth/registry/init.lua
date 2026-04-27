local M = {}

M.schemas = vim.deepcopy(require('shibboleth.registry.schemas'))
M.patterns = vim.deepcopy(require('shibboleth.registry.patterns'))

---@param opts? { schemas?: table, patterns?: table }
function M.extend(opts)
  opts = opts or {}
  if opts.schemas then
    for k, v in pairs(opts.schemas) do M.schemas[k] = v end
  end
  if opts.patterns then
    for _, p in ipairs(opts.patterns) do table.insert(M.patterns, p) end
  end
end

local _lpeg_cache = {}
local function compile(glob)
  if _lpeg_cache[glob] ~= nil then return _lpeg_cache[glob] end
  local ok, pat = pcall(vim.glob.to_lpeg, glob)
  _lpeg_cache[glob] = ok and pat or false
  return _lpeg_cache[glob]
end

local function matches(target, glob)
  local pat = compile(glob)
  if not pat then return false end
  return pat:match(target) ~= nil
end

local function relative_to_cwd(path)
  local cwd = (vim.uv and vim.uv.cwd()) or vim.fn.getcwd()
  if cwd and path:sub(1, #cwd + 1) == cwd .. '/' then
    return path:sub(#cwd + 2)
  end
  return path
end

---@param path string  Absolute or relative buffer path.
---@return { schema_id: string, schema: ShibbolethSchema, pattern: string }[]
function M.match_path(path)
  if not path or path == '' then return {} end
  local basename = vim.fs.basename(path)
  local rel = relative_to_cwd(path)

  local hits = {}
  local seen = {}
  for _, p in ipairs(M.patterns) do
    if not seen[p.schema] then
      -- Globs containing path separators or `**` segments match against the cwd-relative
      -- path; basename-only globs match against the basename.
      local has_path = p.pattern:find('/', 1, true) or p.pattern:find('**', 1, true)
      local target = has_path and rel or basename
      if matches(target, p.pattern) then
        local schema = M.schemas[p.schema]
        if schema then
          table.insert(hits, { schema_id = p.schema, schema = schema, pattern = p.pattern })
          seen[p.schema] = true
        end
      end
    end
  end
  return hits
end

---@param ft? string  Limit to schemas applicable to this filetype.
---@return { id: string, schema: ShibbolethSchema }[]
function M.schemas_for_ft(ft)
  local out = {}
  for id, s in pairs(M.schemas) do
    if not ft or vim.tbl_contains(s.ft, ft) then
      table.insert(out, { id = id, schema = s })
    end
  end
  table.sort(out, function(a, b) return a.schema.name < b.schema.name end)
  return out
end

return M
