local M = {}

local CATALOG_URL = 'https://www.schemastore.org/api/json/catalog.json'

local function cache_path()
  return vim.fs.joinpath(vim.fn.stdpath('cache'), 'shibboleth', 'catalog.json')
end

local function fetch()
  local path = cache_path()
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  local result = vim.system({ 'curl', '-fsSL', '-o', path, CATALOG_URL }, { text = true }):wait()
  if result.code ~= 0 then
    return nil, 'curl exit ' .. result.code .. ': ' .. (result.stderr or '')
  end
  return path
end

local function read_cached_or_fetch(force)
  local path = cache_path()
  if not force and (vim.uv or vim.loop).fs_stat(path) then return path end
  return fetch()
end

local function guess_ft(entry)
  local fts = {}
  local seen = {}
  for _, glob in ipairs(entry.fileMatch or {}) do
    local ext = glob:match('%.(%w+)$')
    local ft
    if ext == 'json' then ft = 'json'
    elseif ext == 'yaml' or ext == 'yml' then ft = 'yaml'
    elseif ext == 'toml' then ft = 'toml'
    end
    if ft and not seen[ft] then
      table.insert(fts, ft)
      seen[ft] = true
    end
  end
  if #fts == 0 then fts = { 'json', 'yaml' } end
  return fts
end

---Load the SchemaStore catalog and merge it into the registry.
---Synchronous; uses curl. The catalog is cached at stdpath('cache')/shibboleth/catalog.json.
---@param opts? { force?: boolean }
---@return boolean ok
---@return { schemas: integer, patterns: integer } | string  stats on success, error message on failure
function M.load(opts)
  opts = opts or {}
  local path, err = read_cached_or_fetch(opts.force)
  if not path then return false, err or 'unknown error' end

  local f = io.open(path, 'r')
  if not f then return false, 'could not open ' .. path end
  local content = f:read('*a')
  f:close()

  local ok, parsed = pcall(vim.json.decode, content)
  if not ok or type(parsed) ~= 'table' or type(parsed.schemas) ~= 'table' then
    return false, 'catalog parse error'
  end

  local registry = require('shibboleth.registry')
  local n_schemas, n_patterns = 0, 0
  for _, entry in ipairs(parsed.schemas) do
    if entry.url and entry.name then
      local id = 'schemastore:' .. entry.url
      if not registry.schemas[id] then
        registry.schemas[id] = {
          name = entry.name,
          url = entry.url,
          ft = guess_ft(entry),
        }
        n_schemas = n_schemas + 1
      end
      for _, glob in ipairs(entry.fileMatch or {}) do
        table.insert(registry.patterns, { pattern = glob, schema = id })
        n_patterns = n_patterns + 1
      end
    end
  end
  return true, { schemas = n_schemas, patterns = n_patterns }
end

return M
