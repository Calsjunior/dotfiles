vim.opt_local.textwidth = 80
vim.opt_local.spell = true

local ok, image_doc = pcall(require, "snacks.image.doc")
if ok then
  image_doc.attach(vim.api.nvim_get_current_buf())
end

vim.schedule(function()
  vim.keymap.set("i", "<Tab>", function()
    require("neotab").tabout()
  end, { buffer = true, desc = "Force Neotab over markdown-plus" })
end)
