-- I use a console font of "MesloLGS NF" for clink-flex-prompt and it was
-- also required for Gitsigns to work.

-------- Original vim config
vim.cmd([[source C:/Users/JonNewton/AppData/Local/nvim/_vimrc]])
vim.g.python3_host_prog = "C:/Users/JonNewton/AppData/Local/Programs/Python/Python311/python3.exe"


-------- Random stuff
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

--   -------- Lazy vim plugins
--   -- auto install lazy
--   local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
--   if not vim.loop.fs_stat(lazypath) then
--     vim.fn.system {
--       'git',
--       'clone',
--       '--filter=blob:none',
--       'https://github.com/folke/lazy.nvim.git',
--       '--branch=stable', -- latest stable release
--       lazypath,
--     }
--   end
--   vim.opt.rtp:prepend(lazypath)
--   
--   require('lazy').setup({
--     -- installed to fix https://github.com/nvim-lua/kickstart.nvim/pull/1040
--     {
--       'folke/lazydev.nvim',
--       ft = 'lua',
--       opts = {
--         library = {
--           -- Load luvit types when the `vim.uv` word is found
--           { path = 'luvit-meta/library', words = { 'vim%.uv' } },
--         },
--       },
--     },
--   
--     {
--       'Bilal2453/luvit-meta',
--       lazy = true
--     },
--   
--     -- end of fix for kickstart.nvim/1040
--   
--     {
--       -- Set lualine as statusline
--       'nvim-lualine/lualine.nvim',
--       -- See `:help lualine.txt`
--       opts = {
--         options = {
--           icons_enabled = false,
--           theme = 'onedark',
--           component_separators = '|',
--           section_separators = '',
--         }
--       },
--     },
--   
--     {
--       'VonHeikemen/lsp-zero.nvim',
--       branch = 'v3.x',
--       dependencies = {
--         'neovim/nvim-lspconfig',
--         'hrsh7th/cmp-nvim-lsp',
--         {
--           'hrsh7th/nvim-cmp',
--           dependencies =
--           { 'L3MON4D3/LuaSnip' }
--         },
--       }
--     },
--   
--   }, {})

-------- LSP Configuration (using built-in package manager)
-- Configure diagnostic display
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = '●',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "E",
      [vim.diagnostic.severity.WARN] = "W",
      [vim.diagnostic.severity.HINT] = "H",
      [vim.diagnostic.severity.INFO] = "I",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Set up keybindings when LSP attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Buffer local mappings
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- Configure PowerShell LSP using Neovim 0.11+ native API
local temp_dir = vim.fn.stdpath('cache')
vim.lsp.config.powershell_es = {
  cmd = {
    'pwsh',
    '-NoLogo',
    '-NoProfile',
    '-Command',
    string.format(
      [[& '%s' -HostName nvim -HostProfileId nvim -HostVersion 1.0.0 -BundledModulesPath '%s' -LogPath '%s/powershell_es.log' -SessionDetailsPath '%s/powershell_es_session.json' -LanguageServiceOnly -Stdio]],
      'C:/tools/lsp/PowerShellEditorServices/PowerShellEditorServices/Start-EditorServices.ps1',
      'C:/tools/lsp/PowerShellEditorServices',
      temp_dir,
      temp_dir
    )
  },
  filetypes = { 'ps1', 'psm1', 'psd1' },
  root_dir = vim.fs.root(0, { '.git', 'PSScriptRoot' }),
}

-- Enable the LSP for PowerShell files
vim.lsp.enable('powershell_es')

-- try out new default scheme
vim.cmd.colorscheme "habamax"

--   -------- Language server config
--   local lsp_zero = require("lsp-zero")
--   
--   -- only enable keymaps when lsp is active for buffer
--   lsp_zero.on_attach(function(_, bufnr)
--     -- see :help lsp-zero-keybindings
--     -- to learn the available actions
--     lsp_zero.default_keymaps({
--       buffer = bufnr,
--       -- overwrite existing mappings
--       preserve_mappings = false
--     })
--   end)
--   
--   require('lspconfig').lua_ls.setup({})
--   
--   require('lspconfig').powershell_es.setup({
--     bundle_path = 'C:/tools/lsp/PowerShellEditorServices',
--     shell = 'powershell.exe'
--   })

-- deno LSP configuration
-- To appropriately highlight codefences returned from denols, you will need to augment vim.g.markdown_fenced languages in your init.lua
--vim.g.markdown_fenced_languages = {
--  "ts=typescript"
--}
--require('lspconfig').denols.setup({})
--
-- require('lspconfig').tsserver.setup({})
-- 
-- require('lspconfig').rust_analyzer.setup({})

--  require('lspconfig').gopls.setup({})

-------- Key mappings

-- From primeagen
-- center page up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "<space>p", [["_dP]])

-- center next/prev search match?
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
