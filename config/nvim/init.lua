-- Speed up load time
if vim.loader then vim.loader.enable() end

-- Define main config table to be able to pass data between scripts
_G.Config = {}

-- Use 'mini.nvim'
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- stylua: ignore start
local misc = require('mini.misc')
Config.now         = function(f) misc.safely('now', f) end
Config.later       = function(f) misc.safely('later', f) end
Config.now_if_args = vim.fn.argc(-1) > 0 and Config.now or Config.later
Config.on_event    = function(ev, f) misc.safely('event:' .. ev, f) end
Config.on_filetype = function(ft, f) misc.safely('filetype:' .. ft, f) end
-- stylua: ignore end

-- Load base configs
require("config.functions")
require("config.options")
require("config.keymaps")

-- Load plugins directory automatically
local plugins_dir = vim.fn.stdpath("config") .. "/lua/plugins"
if vim.fn.isdirectory(plugins_dir) == 1 then
  for _, file in ipairs(vim.fn.readdir(plugins_dir)) do
    if file:match("%.lua$") then
      require("plugins." .. file:gsub("%.lua$", ""))
    end
  end
end
