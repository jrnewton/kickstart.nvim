-- Sourced by the `git edit` alias (~/.gitconfig) after the window split.
-- Buffer 1 is the staged diff. Give it its own search term (`diff --git`
-- headers), keep those headers highlighted, and put the cursor there.
-- Searches made in any other buffer stay global and are restored when
-- you leave buffer 1.

local diffbuf = 1
local localterm = [[^diff --git .*]]
local globalterm = vim.fn.getreg('/')

-- Permanent highlight of the headers, independent of the search term.
vim.api.nvim_buf_call(diffbuf, function()
  vim.cmd([[syntax match GitEditHeader /^diff --git .*/]])
end)
vim.api.nvim_set_hl(0, 'GitEditHeader', { link = 'Search' })

-- Swap the search register on entry/exit. setreg('/') sticks even inside
-- an autocmd (see :help autocmd-searchpat).
local group = vim.api.nvim_create_augroup('GitEditSearch', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  buffer = diffbuf,
  callback = function()
    globalterm = vim.fn.getreg('/')
    vim.fn.setreg('/', localterm)
  end,
})
vim.api.nvim_create_autocmd('BufLeave', {
  group = group,
  buffer = diffbuf,
  callback = function()
    localterm = vim.fn.getreg('/')
    vim.fn.setreg('/', globalterm)
  end,
})

-- Focus buffer 1 (fires the BufEnter above).
vim.fn.win_gotoid(vim.fn.bufwinid(diffbuf))
