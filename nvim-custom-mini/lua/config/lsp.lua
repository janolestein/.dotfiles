-- Native LSP (Neovim 0.11+, refined in 0.12). No nvim-lspconfig.
-- Servers are defined inline with vim.lsp.config(name, {...}) and turned on with
-- vim.lsp.enable(...). Server binaries are installed by Mason (below), which puts
-- them on $PATH — or install them yourself (see README) and Mason is optional.

-- Mason: install/manage the LSP server binaries. setup() prepends Mason's bin/ to
-- $PATH, so the servers below are found automatically once installed. The list is
-- the mason package names for the servers enabled at the bottom of this file.
-- Trim it to just the languages you use (missing ones install on the next launch),
-- or set it to {} and install on demand with :Mason / :MasonInstall <name>.
require("mason").setup({ ui = { border = "rounded" } })
do
  local ensure = {
    "lua-language-server", "typescript-language-server", "pyright", "rust-analyzer",
    "gopls", "clangd", "bash-language-server", "json-lsp", "yaml-language-server",
    "html-lsp", "css-lsp", "tailwindcss-language-server", "marksman", "jdtls",
    "angular-language-server",
  }
  local registry = require("mason-registry")
  local function install_missing()
    for _, name in ipairs(ensure) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok and not pkg:is_installed() then pkg:install() end
    end
  end
  -- refresh() pulls the registry (downloading it if needed) then runs the callback.
  if registry.refresh then registry.refresh(install_missing) else install_missing() end
end

-- Capabilities advertised to every server (folding ranges from the LSP)
local caps = vim.lsp.protocol.make_client_capabilities()
caps.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }
vim.lsp.config("*", { capabilities = caps, root_markers = { ".git", ".editorconfig" } })

-- Server definitions ------------------------------------------------------
vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
      diagnostics = { globals = { "vim", "MiniPick", "MiniExtra", "MiniFiles", "MiniDiff", "MiniIcons" } },
      hint = { enable = true },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", "Pipfile", ".git" },
  settings = { python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true } } },
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = { command = "clippy" },
      procMacro = { enable = true },
    },
  },
})

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  settings = {
    gopls = { gofumpt = true, staticcheck = true, completeUnimported = true,
      analyses = { unusedparams = true, shadow = true } },
  },
})

vim.lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt", ".git" },
})

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" },
  root_markers = { ".git" },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  init_options = { provideFormatter = true },
})

vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  settings = { yaml = { keyOrdering = false, format = { enable = true } } },
})

vim.lsp.config("html", {
  cmd = { "vscode-html-language-server", "--stdio" },
  filetypes = { "html" },
  init_options = { provideFormatter = true, embeddedLanguages = { css = true, javascript = true } },
})

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
  filetypes = { "css", "scss", "less" },
  init_options = { provideFormatter = true },
  settings = { css = { lint = { unknownAtRules = "ignore" } } },
})

vim.lsp.config("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "css", "javascriptreact", "typescriptreact", "svelte", "vue" },
  root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git" },
})

vim.lsp.config("marksman", {
  cmd = { "marksman", "server" },
  filetypes = { "markdown" },
  root_markers = { ".marksman.toml", ".git" },
})

-- Java / Spring (jdtls). Install the `jdtls` wrapper: brew install jdtls (or
-- yay -S jdtls). Needs a JDK 21+ to run the server itself. We use a `cmd`
-- function so each project gets its own workspace dir (a single shared one
-- corrupts when you switch projects), and we auto-attach Lombok if you drop a
-- lombok.jar at ~/.local/share/nvim/lombok.jar (Spring projects almost always
-- use Lombok, and jdtls reports false errors for its generated code without it).
-- Plain jdtls covers all LSP features; for Java debugging / test-running /
-- "organize imports" as commands, the nvim-jdtls plugin adds more on top.
vim.lsp.config("jdtls", {
  cmd = function(dispatchers, config)
    local markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "mvnw", "gradlew", ".git" }
    local root = (config and config.root_dir) or vim.fs.root(0, markers) or vim.fn.getcwd()
    local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h:t")
    local cmd = { "jdtls", "-data", workspace }
    local lombok = vim.fn.stdpath("data") .. "/lombok.jar"
    if vim.uv.fs_stat(lombok) then
      table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok)
    end
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
  filetypes = { "java" },
  root_markers = { "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle", "mvnw", "gradlew", ".git" },
  settings = {
    java = {
      configuration = { updateBuildConfiguration = "interactive" },
      signatureHelp = { enabled = true },
      inlayHints = { parameterNames = { enabled = "all" } },
      completion = {
        importOrder = { "java", "javax", "jakarta", "org", "com" },
        favoriteStaticMembers = {
          "org.assertj.core.api.Assertions.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.junit.jupiter.api.Assumptions.*",
          "org.mockito.Mockito.*",
          "org.mockito.ArgumentMatchers.*",
          "java.util.Objects.requireNonNull",
        },
      },
    },
  },
})

-- Angular (angularls). Install: npm i -g @angular/language-server typescript
-- (gives `ngserver`). The probe locations point at the *project's* node_modules
-- so it uses that project's Angular + TypeScript versions. ts_ls also attaches
-- to .ts files for general TypeScript; angularls adds template type-checking and
-- component<->template navigation. Running both together is the standard setup.
-- Component templates (*.component.html) are detected as the `htmlangular`
-- filetype in plugins.lua, which angularls (not the generic html LSP) handles.
vim.lsp.config("angularls", {
  cmd = function(dispatchers, config)
    local root = (config and config.root_dir) or vim.fs.root(0, { "angular.json", "nx.json" }) or vim.fn.getcwd()
    local probe = root .. "/node_modules"
    return vim.lsp.rpc.start({
      "ngserver", "--stdio",
      "--tsProbeLocations", probe,
      "--ngProbeLocations", probe,
    }, dispatchers)
  end,
  filetypes = { "typescript", "html", "htmlangular" },
  root_markers = { "angular.json", "nx.json" },
})

-- Turn them on (a server only starts if its `cmd` is found on $PATH) ------
vim.lsp.enable({
  "lua_ls", "ts_ls", "pyright", "rust_analyzer", "gopls", "clangd",
  "bashls", "jsonls", "yamlls", "html", "cssls", "tailwindcss", "marksman",
  "jdtls", "angularls",
})

-- On-attach: keymaps, inlay hints, document highlight, native completion -----
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    local function m(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "LSP: " .. desc })
    end
    -- gd/gr/gI/gy are mapped globally to the picker in plugins.lua
    m("n", "K",  vim.lsp.buf.hover,          "Hover")
    m("n", "gK", vim.lsp.buf.signature_help, "Signature help")
    m("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
    m({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
    m("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
    m("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")

    if client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      m("n", "<leader>uh", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, "Toggle inlay hints")
    end

    if client:supports_method("textDocument/documentHighlight") then
      local g = vim.api.nvim_create_augroup("user_lsp_hl_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd("CursorHold",  { group = g, buffer = bufnr, callback = vim.lsp.buf.document_highlight })
      vim.api.nvim_create_autocmd("CursorMoved", { group = g, buffer = bufnr, callback = vim.lsp.buf.clear_references })
    end

    -- Native LSP autocompletion (0.11+). No nvim-cmp.
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
    end

    -- Inline color swatches for CSS / Tailwind / etc. (0.12)
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, bufnr)
    end

    -- Code lens (run/test/reference lenses; rendered as virtual lines in 0.12).
    -- The built-in `grx` mapping runs the lens under the cursor.
    if client:supports_method("textDocument/codeLens") then
      local g = vim.api.nvim_create_augroup("user_lsp_codelens_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
        group = g, buffer = bufnr,
        callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
      })
      vim.lsp.codelens.refresh({ bufnr = bufnr })
    end
    -- Format on save is handled by one global autocmd below.
  end,
})

-- Format on save: a single global autocmd (the old per-client one cleared its
-- own group on each attach, so only the last formatter ran). Formats with every
-- attached client that can. Toggle globally with <leader>uf (vim.g.autoformat)
-- or per buffer with vim.b[buf].autoformat = false.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("user_lsp_format_on_save", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].autoformat == false then return end
    if vim.b[buf].autoformat == nil and vim.g.autoformat == false then return end
    if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" }) == 0 then return end
    vim.lsp.buf.format({ bufnr = buf, timeout_ms = 2000 })
  end,
})

-- Insert-mode keys: navigate the popup AND jump snippet placeholders
-- (vim.snippet is built in since 0.10, so LSP snippets expand with no plugin)
vim.keymap.set("i", "<Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-n>" end
  if vim.snippet.active({ direction = 1 }) then return "<cmd>lua vim.snippet.jump(1)<cr>" end
  return "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
  if vim.fn.pumvisible() == 1 then return "<C-p>" end
  if vim.snippet.active({ direction = -1 }) then return "<cmd>lua vim.snippet.jump(-1)<cr>" end
  return "<S-Tab>"
end, { expr = true })
vim.keymap.set("i", "<CR>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true })
