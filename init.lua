-- make sure your console font is MesloLGS NF else the gutter does not show 
-- up and Gitsigns stops working.

vim.cmd([[source C:/Users/JonNewton/AppData/Local/nvim/_vimrc]])
vim.cmd([[source C:/Users/JonNewton/AppData/Local/nvim/_other]])

-- From primeagen
-- center page up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("x", "<space>p", [["_dP]])

-- center next/prev search match?
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'equalsraf/neovim-gui-shim',
  'tpope/vim-fugitive',
  'mfussenegger/nvim-dap',
  'rcarriga/nvim-dap-ui',
  'theHamsta/nvim-dap-virtual-text',
  'nvim-telescope/telescope-dap.nvim',

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- needed for telescope
  {
    'nvim-treesitter/nvim-treesitter', 
    build = ':TSUpdate'
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '│' },
        delete       = { text = '-' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      }
    },
  },

  -- others tried:
  -- tundra: too minimal
  -- tokyodark: meh
  --{
  --  'navarasu/onedark.nvim',
  --  priority = 1000,
  --  config = function()
  --    vim.cmd.colorscheme 'onedark'
  --  end,
  --},
  { "ramojus/mellifluous.nvim", name = "mellifluous", priority = 1000 },

  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      }
    },
  },

}, {})

require("mellifluous").setup(
{
  color_set = 'mellifluous',
  mellifluous = {
    color_overrides = {
      dark = {
        -- hl.set('IncSearch', { bg = colors.other_keywords, fg = colors.bg }) -- 'incsearch' highlighting; also used for the text replaced with ':s///c'
        -- Also controls highlight yank feature
        -- other_keywords = '#772828', -- '#2a2d15',

        -- hl.set('Search', { bg = colors.bg4, fg = colors.fg }) -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
         bg4 = '#772828', --82a2d15',
      }
    },
    neutral = true,
    bg_contrast = 'hard'
  }
})
vim.cmd.colorscheme "mellifluous"

-- require("catppuccin").setup({
--   flavour = "Frappe"
-- })
-- vim.cmd.colorscheme "catppuccin"

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

require('telescope').setup()
-- require('telescope').load_extension('dap')

require('nvim-dap-virtual-text').setup()

vim.keymap.set('n', '<leader>g', '<cmd>:Git<cr>')
vim.keymap.set('n', '<leader>t', '<cmd>:Telescope<cr>')

-- DAP
vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
vim.keymap.set('n', '<F12>', function() require('dap').step_out() end)
vim.keymap.set('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)
vim.keymap.set('n', '<Leader>B', function() require('dap').set_breakpoint() end)
vim.keymap.set('n', '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)
vim.keymap.set('n', '<Leader>dr', function() require('dap').repl.open() end)
vim.keymap.set('n', '<Leader>dl', function() require('dap').run_last() end)
vim.keymap.set({'n', 'v'}, '<Leader>dh', function()
  require('dap.ui.widgets').hover()
end)
vim.keymap.set({'n', 'v'}, '<Leader>dp', function()
  require('dap.ui.widgets').preview()
end)
vim.keymap.set('n', '<Leader>df', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.frames)
end)
vim.keymap.set('n', '<Leader>ds', function()
  local widgets = require('dap.ui.widgets')
  widgets.centered_float(widgets.scopes)
end)

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
