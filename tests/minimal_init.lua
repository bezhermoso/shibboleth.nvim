-- Minimal init for running the test suite headlessly.
-- Resolves rtp for plenary, nvim-treesitter (for the JSON parser/queries), and the plugin itself.

local function plugin_root()
  local source = debug.getinfo(1, 'S').source:sub(2) -- strip leading '@'
  local file = vim.fn.fnamemodify(source, ':p')
  -- tests/minimal_init.lua → ../
  return vim.fn.fnamemodify(file, ':h:h')
end

local PLUGIN = plugin_root()
local LAZY = vim.fn.expand('~/.local/share/nvim/lazy')

local function add(path)
  if vim.fn.isdirectory(path) == 1 then
    vim.opt.rtp:prepend(path)
  end
end

add(PLUGIN)
add(LAZY .. '/plenary.nvim')
add(LAZY .. '/nvim-treesitter')

vim.cmd('runtime! plugin/plenary.vim')
vim.cmd('runtime! plugin/shibboleth.lua')

-- Force-load the JSON parser so handlers using TreeSitter work in headless mode.
pcall(vim.treesitter.language.add, 'json')
