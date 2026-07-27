-- Neovim 0.12+ minimal config. Two core plugins (mini.nvim + nvim-treesitter),
-- plus optional tokyonight (theme) and mason.nvim (LSP installer).
-- Everything else uses built-in Neovim: vim.pack (manager), vim.lsp.config/enable
-- (LSP), vim.lsp.completion (autocomplete), built-in gc (comments),
-- vim.snippet (snippets), vim.treesitter (highlighting/folds).
--
-- Layout:
--   init.lua             this file
--   lua/config/          options, keymaps, autocmds, plugins, lsp
--
-- First launch: vim.pack prompts to install the 2 plugins — press 'a'.

vim.loader.enable() -- faster Lua module loading (built-in)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins") -- vim.pack.add() + mini setup + treesitter
require("config.lsp")     -- LSP servers + completion + LspAttach
