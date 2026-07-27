local opt = vim.opt

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmode = false -- statusline shows the mode
opt.termguicolors = true
opt.laststatus = 3   -- single global statusline
opt.cmdheight = 1
opt.pumheight = 10
opt.pumblend = 10
opt.pumborder = "rounded" -- bordered completion popup (0.12+), matches winborder
opt.conceallevel = 2
opt.fillchars = { eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "" }
opt.list = true
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }
opt.winborder = "rounded" -- rounded borders on all floats (0.11+)

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.linebreak = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.inccommand = "split"

-- Splits
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen"

-- Files
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.confirm = true
opt.autowrite = true

-- Performance
opt.updatetime = 200
opt.timeoutlen = 300

-- Completion (0.11+ adds 'popup'/'fuzzy'; 0.12 adds 'nearest' — sort by distance)
opt.completeopt = "menu,menuone,noselect,popup,fuzzy,nearest"
opt.wildmode = "longest:full,full"
opt.wildoptions = "pum,fuzzy"
opt.jumpoptions:append("view") -- restore the window view when jumping the jumplist

-- Folding via treesitter (parsers provide the fold expr)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Mouse & clipboard
opt.mouse = "a"
opt.clipboard = "unnamedplus"

-- Diagnostics (sign text lives here since 0.10; :sign-define is removed in 0.12)
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.HINT]  = "",
      [vim.diagnostic.severity.INFO]  = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})
