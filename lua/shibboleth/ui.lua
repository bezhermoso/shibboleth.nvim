local M = {}

---Wrapper around `vim.ui.select` so we can swap or extend it later (telemetry, fuzzy, etc.).
---@param items table[]
---@param opts { prompt?: string, format_item?: fun(item: any): string }
---@param on_choice fun(choice: any|nil, idx: integer|nil)
function M.select(items, opts, on_choice)
  vim.ui.select(items, {
    prompt = opts.prompt,
    format_item = opts.format_item,
  }, on_choice)
end

---@param opts { prompt?: string, default?: string }
---@param on_done fun(value: string|nil)
function M.input(opts, on_done)
  vim.ui.input({ prompt = opts.prompt, default = opts.default }, on_done)
end

return M
