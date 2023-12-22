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

  { "ramojus/mellifluous.nvim", name = "mellifluous", priority = 1000 },

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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
