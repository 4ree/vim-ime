if vim.g.loaded_input_method_auto then
  return
end
vim.g.loaded_input_method_auto = true

require("ime").setup()
