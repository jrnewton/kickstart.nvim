-- I use a console font of "MesloLGS NF" for clink-flex-prompt and it was
-- also required for Gitsigns to work.

-------- Original vim config
vim.cmd([[source C:/Users/JonNewton/AppData/Local/nvim/_vimrc]])
vim.g.python3_host_prog = "C:/tools/python314/python.exe"


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

-- claude begin
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
-- claude end

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

-- From primeagen
-- center page up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "<space>p", [["_dP]])

-- center next/prev search match?
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Hacks to make MD highlighting suck less. I tried render-markdown plugin but 
-- didn't like how normal mode looked different than edit mode.
-- Claude:
vim.cmd([[
  highlight markdownBold gui=bold guifg=#ffffff cterm=bold ctermfg=15
  highlight markdownItalic gui=italic cterm=italic
  highlight markdownBoldItalic gui=bold,italic guifg=#ffffff cterm=bold,italic ctermfg=15
  highlight markdownCode guibg=#3a3a3a ctermbg=238
  highlight markdownH1 gui=bold guifg=#a0ffa0 guibg=#3d5c3d cterm=bold ctermfg=156 ctermbg=65
  highlight markdownH2 gui=bold guifg=#88dd88 guibg=#325032 cterm=bold ctermfg=114 ctermbg=58
  highlight markdownH3 gui=bold guifg=#70bb70 guibg=#284428 cterm=bold ctermfg=71 ctermbg=28
  highlight markdownH4 gui=bold guifg=#589958 guibg=#1d381d cterm=bold ctermfg=65 ctermbg=22
  highlight markdownH5 gui=bold guifg=#407740 guibg=#132c13 cterm=bold ctermfg=28 ctermbg=233
  highlight markdownH6 gui=bold guifg=#285528 guibg=#0a200a cterm=bold ctermfg=22 ctermbg=232
  highlight markdownTableHeader gui=bold guifg=#78dce8 guibg=#2d4a5c cterm=bold ctermfg=117 ctermbg=24
]])

-- Claude:
-- Custom highlighting for markdown table headers
-- Tables use | separators and --- delimiters, which confuse the H2 parser
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost", "TextChanged", "TextChangedI"}, {
  pattern = "*.md",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ns_id = vim.api.nvim_create_namespace("markdown_table_headers")

    -- print("DEBUG: Markdown table header detection running")

    -- Clear existing highlights
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    -- Get all lines in buffer
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    -- print("DEBUG: Total lines: " .. #lines)

    for i, line in ipairs(lines) do
      -- Check if this line contains table separators (|) and next line is dashes
      if line:match("|") and i < #lines then
        -- print("DEBUG: Found | on line " .. i .. ": " .. line)
        local next_line = lines[i + 1]
        -- print("DEBUG: Next line " .. (i + 1) .. ": " .. next_line)
        -- Check if next line is a table separator (just dashes, with or without |)
        if next_line:match("^%s*[-|:]+%s*$") and next_line:match("[-]+") then
          -- print("DEBUG: Detected table header on line " .. i .. ", applying highlight")
          -- This is a table header row, apply custom highlight
          vim.api.nvim_buf_add_highlight(bufnr, ns_id, "markdownTableHeader", i - 1, 0, -1)
        end
      end
    end
  end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
