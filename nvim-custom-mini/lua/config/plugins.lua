-- Plugins installed and loaded via the built-in vim.pack (Neovim 0.12+).
-- No bootstrap, no lazy.nvim. First launch shows a y/n/a prompt — press 'a'.
--
-- Update: :lua vim.pack.update()  (or <leader>pu)   Lockfile: nvim-pack-lock.json
-- Remove: delete a line below, then :lua vim.pack.del({ "name" })

-- Treesitter install/update hook MUST be registered before vim.pack.add().
-- nvim-treesitter is archived but its `main` branch works on 0.12 and is the
-- standard parser installer. (Alternative: drop it entirely — see README.)
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind ~= "delete" then
      if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
      vim.cmd("TSUpdate")
    end
  end,
})

vim.pack.add({
  -- The library that replaces ~10 LazyVim plugins (picker, explorer, statusline,
  -- git signs, which-key, dashboard, notifications, bufferline, pairs, surround,
  -- ai textobjects, bracket motions, indent guides). It also ships colorschemes.
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/folke/tokyonight.nvim",

  -- LSP/DAP/linter/formatter installer. Prepends its bin/ to $PATH so the servers
  -- defined in lsp.lua are found with no extra wiring. Setup + the auto-install
  -- list live in lsp.lua; browse/manage interactively with :Mason.
  "https://github.com/mason-org/mason.nvim",

  -- Treesitter parser installer (main branch = the 0.12-compatible rewrite).
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

----------------------------------------------------------------------
-- nvim-treesitter: install parsers for languages not bundled with Neovim.
-- (Neovim 0.12 bundles c, lua, markdown, query, vim, vimdoc and highlights
--  them automatically; these are the extras.)
----------------------------------------------------------------------
require("nvim-treesitter").setup({ install_dir = vim.fn.stdpath("data") .. "/site" })
do
  local want = {
    "angular", "bash", "css", "diff", "dockerfile", "go", "gomod", "gowork",
    "html", "java", "javascript", "json", "jsonc", "python", "regex", "rust",
    "toml", "tsx", "typescript", "yaml",
  }
  local ok, cfg = pcall(require, "nvim-treesitter.config")
  local installed = ok and cfg.get_installed() or {}
  local todo = vim.tbl_filter(function(p) return not vim.tbl_contains(installed, p) end, want)
  if #todo > 0 then pcall(function() require("nvim-treesitter").install(todo) end) end
end

-- Angular component templates: detect *.component.html as `htmlangular` so the
-- Angular language server (not the generic html LSP) owns them, highlight them
-- with the `angular` treesitter parser, and give them HTML-style comments.
vim.filetype.add({ pattern = { [".*%.component%.html"] = "htmlangular" } })
pcall(vim.treesitter.language.register, "angular", "htmlangular")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmlangular",
  callback = function() vim.bo.commentstring = "<!-- %s -->" end,
})

----------------------------------------------------------------------
-- mini.nvim modules (all from the single dependency above)
----------------------------------------------------------------------
local map = vim.keymap.set
local function d(desc) return { desc = desc } end

-- Appearance
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- let any plugin asking for devicons use mini
require("mini.statusline").setup({ use_icons = true })
require("mini.tabline").setup()    -- bufferline-style tabs at the top
require("mini.indentscope").setup({ symbol = "│", options = { try_as_border = true } })

-- Colorscheme (bundled with mini.nvim — no separate plugin needed).
-- Swap to tokyonight for the authentic LazyVim look: add the repo to vim.pack
-- and call vim.cmd.colorscheme("tokyonight").
vim.cmd.colorscheme("tokyonight")

-- Notifications (replaces nvim-notify); also becomes vim.notify
require("mini.notify").setup()
vim.notify = require("mini.notify").make_notify()

-- Dashboard (replaces alpha/dashboard.nvim)
require("mini.starter").setup()

-- Editing
require("mini.ai").setup({ n_lines = 500 })   -- better a/i text objects
require("mini.surround").setup()              -- ys/ds/cs surround
require("mini.pairs").setup()                 -- autopairs
require("mini.bracketed").setup()             -- ]b [b ]d [d ]q [q ]t [t ]i [i ...
-- (commenting uses built-in gc/gcc, no module needed since Neovim 0.10)

-- Git (replaces gitsigns) — gutter signs + inline diff overlay + :Git + blame
require("mini.diff").setup({
  view = { style = "sign", signs = { add = "▎", change = "▎", delete = "" } },
})
require("mini.git").setup()
map("n", "<leader>gd", function() MiniDiff.toggle_overlay() end, d("Diff overlay"))
map("n", "<leader>gb", function() vim.cmd("Git blame -- " .. vim.fn.expand("%")) end, d("Git blame"))
map("n", "]h", function() MiniDiff.goto_hunk("next") end, d("Next hunk"))
map("n", "[h", function() MiniDiff.goto_hunk("prev") end, d("Prev hunk"))

-- File explorer (replaces neo-tree)
require("mini.files").setup()
map("n", "<leader>e", function()
  if not MiniFiles.close() then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end
end, d("Explorer"))

-- Picker (replaces telescope) + extra pickers (LSP/diagnostics/git/etc.)
require("mini.pick").setup()
require("mini.extra").setup()
vim.ui.select = MiniPick.ui_select -- nice vim.ui.select via the picker

map("n", "<leader><space>", function() MiniPick.builtin.files() end,      d("Find files"))
map("n", "<leader>ff",      function() MiniPick.builtin.files() end,      d("Find files"))
map("n", "<leader>fg",      function() MiniExtra.pickers.git_files() end, d("Git files"))
map("n", "<leader>fr",      function() MiniExtra.pickers.oldfiles() end,  d("Recent files"))
map("n", "<leader>fb",      function() MiniPick.builtin.buffers() end,    d("Buffers"))
map("n", "<leader>fc",      function() MiniPick.builtin.files(nil, { source = { cwd = vim.fn.stdpath("config") } }) end, d("Config files"))
map("n", "<leader>/",       function() MiniPick.builtin.grep_live() end,  d("Grep"))
map("n", "<leader>sg",      function() MiniPick.builtin.grep_live() end,  d("Grep"))
map("n", "<leader>sw",      function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end, d("Grep word"))
map("n", "<leader>sh",      function() MiniPick.builtin.help() end,       d("Help"))
map("n", "<leader>sk",      function() MiniExtra.pickers.keymaps() end,   d("Keymaps"))
map("n", "<leader>sd",      function() MiniExtra.pickers.diagnostic() end, d("Diagnostics"))
map("n", "<leader>sR",      function() MiniPick.builtin.resume() end,     d("Resume picker"))
map("n", "<leader>ss",      function() MiniExtra.pickers.lsp({ scope = "document_symbol" }) end,  d("Document symbols"))
map("n", "<leader>sS",      function() MiniExtra.pickers.lsp({ scope = "workspace_symbol" }) end, d("Workspace symbols"))

-- LSP navigation via the picker (nicer than raw quickfix lists)
map("n", "gd", function() MiniExtra.pickers.lsp({ scope = "definition" }) end,      d("Goto definition"))
map("n", "gr", function() MiniExtra.pickers.lsp({ scope = "references" }) end,      d("References"))
map("n", "gI", function() MiniExtra.pickers.lsp({ scope = "implementation" }) end,  d("Goto implementation"))
map("n", "gy", function() MiniExtra.pickers.lsp({ scope = "type_definition" }) end, d("Goto type definition"))

-- which-key replacement: shows key hints after a short delay
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = "n", keys = "<Leader>" }, { mode = "x", keys = "<Leader>" },
    { mode = "n", keys = "g" },        { mode = "x", keys = "g" },
    { mode = "n", keys = "z" },        { mode = "x", keys = "z" },
    { mode = "n", keys = "]" },        { mode = "n", keys = "[" },
    { mode = "n", keys = '"' },        { mode = "x", keys = '"' },
    { mode = "n", keys = "'" },        { mode = "n", keys = "`" },
    { mode = "n", keys = "<C-w>" },
    { mode = "i", keys = "<C-r>" },    { mode = "c", keys = "<C-r>" },
  },
  clues = {
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
    { mode = "n", keys = "<Leader>f", desc = "+file/find" },
    { mode = "n", keys = "<Leader>s", desc = "+search" },
    { mode = "n", keys = "<Leader>g", desc = "+git" },
    { mode = "n", keys = "<Leader>c", desc = "+code" },
    { mode = "n", keys = "<Leader>b", desc = "+buffer" },
    { mode = "n", keys = "<Leader>w", desc = "+window" },
    { mode = "n", keys = "<Leader>u", desc = "+ui" },
    { mode = "n", keys = "<Leader>p", desc = "+pack" },
    { mode = "n", keys = "<Leader>q", desc = "+quit" },
  },
  window = { delay = 300 },
})
