local map = vim.keymap.set

-- Movement on wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Clear search highlight
map("n", "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch" })

-- Keep selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move lines (built-in :m)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Right window" })
map("n", "<leader>-",  "<C-w>s", { desc = "Split below" })
map("n", "<leader>|",  "<C-w>v", { desc = "Split right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete window" })
map("n", "<C-Up>",    "<cmd>resize +2<cr>")
map("n", "<C-Down>",  "<cmd>resize -2<cr>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>")

-- Buffers (S-h / S-l). [b ]b are provided by mini.bracketed.
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Tabs (mini.bracketed doesn't cover these)
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>",   { desc = "New tab" })
map("n", "<leader><tab>d",     "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "]<tab>", "<cmd>tabnext<cr>",     { desc = "Next tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Prev tab" })

-- Save / quit / new
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<cr>",  { desc = "Quit all" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Diagnostics float (jumping ]d/[d is provided by mini.bracketed)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })

-- Terminal mode escape
map("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- vim.pack management (replaces :Lazy)
map("n", "<leader>pu", function() vim.pack.update() end,                        { desc = "Pack update" })
map("n", "<leader>ps", function() vim.pack.update(nil, { offline = true }) end, { desc = "Pack status" })

-- Floating terminal + lazygit, using only built-in APIs (no plugin).
-- Toggling by `key` hides/reopens the SAME session (scrollback + running shell
-- survive) instead of spawning a fresh shell on every press.
local floats = {}
local function float_win(buf)
  local w, h = math.floor(vim.o.columns * 0.9), math.floor(vim.o.lines * 0.9)
  return vim.api.nvim_open_win(buf, true, {
    relative = "editor", width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal", border = "rounded",
  })
end
local function float_toggle(key, cmd)
  local st = floats[key]
  if st and st.win and vim.api.nvim_win_is_valid(st.win) then
    vim.api.nvim_win_hide(st.win) -- keep buffer + job alive
    st.win = nil
    return
  end
  if st and vim.api.nvim_buf_is_valid(st.buf) then
    st.win = float_win(st.buf) -- reopen existing session
  else
    local buf = vim.api.nvim_create_buf(false, true)
    floats[key] = { buf = buf, win = float_win(buf) }
    vim.fn.jobstart(cmd or { vim.o.shell }, {
      term = true,
      on_exit = function()
        local s = floats[key]
        floats[key] = nil
        if s and s.win and vim.api.nvim_win_is_valid(s.win) then vim.api.nvim_win_close(s.win, true) end
        if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
      end,
    })
  end
  vim.cmd("startinsert")
end
map("n", "<leader>gg", function() float_toggle("lazygit", { "lazygit" }) end, { desc = "Lazygit" })
map({ "n", "t" }, "<c-/>", function() float_toggle("term") end, { desc = "Terminal" })
map("n", "<leader>ft",     function() float_toggle("term") end, { desc = "Terminal" })

-- UI toggles (<leader>u...), mini.clue labels the group "+ui"
map("n", "<leader>uw", function() vim.o.wrap = not vim.o.wrap end,                     { desc = "Toggle wrap" })
map("n", "<leader>us", function() vim.o.spell = not vim.o.spell end,                   { desc = "Toggle spell" })
map("n", "<leader>ul", function() vim.o.number = not vim.o.number end,                 { desc = "Toggle line numbers" })
map("n", "<leader>uL", function() vim.o.relativenumber = not vim.o.relativenumber end, { desc = "Toggle relative numbers" })
map("n", "<leader>ud", function()
  local on = vim.diagnostic.is_enabled()
  vim.diagnostic.enable(not on)
  vim.notify("Diagnostics " .. (on and "disabled" or "enabled"))
end, { desc = "Toggle diagnostics" })
map("n", "<leader>uf", function()
  vim.g.autoformat = (vim.g.autoformat == false) -- nil/true -> off, false -> on
  vim.notify("Format on save " .. (vim.g.autoformat and "enabled" or "disabled"))
end, { desc = "Toggle format on save" })
map("n", "<leader>uv", function()
  local to_lines = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({
    virtual_lines = to_lines and { current_line = true } or false,
    virtual_text = (not to_lines) and { prefix = "●", spacing = 4 } or false,
  })
  vim.notify("Diagnostic virtual " .. (to_lines and "lines" or "text"))
end, { desc = "Toggle diagnostic virtual lines" })
