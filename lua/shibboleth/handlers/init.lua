local M = {}

local FT_TO_HANDLER = {
  json = 'shibboleth.handlers.json',
  jsonc = 'shibboleth.handlers.json',
  json5 = 'shibboleth.handlers.json',
  yaml = 'shibboleth.handlers.yaml',
  yml = 'shibboleth.handlers.yaml',
  toml = 'shibboleth.handlers.toml',
}

---@param ft string
---@return table|nil  { detect, apply, remove }
function M.for_filetype(ft)
  local mod = FT_TO_HANDLER[ft]
  if not mod then return nil end
  local ok, h = pcall(require, mod)
  if not ok then return nil end
  return h
end

---@param ft string
---@return boolean
function M.supports(ft)
  return FT_TO_HANDLER[ft] ~= nil
end

---@return string[]
function M.supported_filetypes()
  local fts = {}
  for ft in pairs(FT_TO_HANDLER) do table.insert(fts, ft) end
  table.sort(fts)
  return fts
end

return M
