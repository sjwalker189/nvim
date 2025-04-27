local hl_groups = {
  'DiagnosticUnderlineError',
  'DiagnosticUnderlineWarn',
  'DiagnosticUnderlineInfo',
  'DiagnosticUnderlineHint',
  'DiagnosticUnderlineOk',
}

for _, hl in ipairs(hl_groups) do
  vim.cmd.highlight(hl .. ' gui=undercurl')
end

-- " 1. Modify your config
-- " 2. Restart nvim
-- " 3. Run this command:
-- :KanagawaCompile
--
vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = 'kanagawa',
  callback = function()
    if vim.o.background == 'light' then
      vim.fn.system 'kitty +kitten themes Kanagawa_light'
    elseif vim.o.background == 'dark' then
      vim.fn.system 'kitty +kitten themes Kanagawa_dragon'
    else
      vim.fn.system 'kitty +kitten themes Kanagawa'
    end
  end,
})

return {
  {
    'thesimonho/kanagawa-paper.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      require('kanagawa-paper').setup {
        compile = true,
        colors = {
          palette = {
            fujiWhite = '#d0cfc8',
          },
        },
        overrides = function(colors)
          return {
            -- Normal = { fg = "", bg = "" },
            -- Special1 = { fg = colors.palette.springViolet1 },
          }
        end,
      }
      vim.cmd.colorscheme 'kanagawa-paper'
    end,
  },
}
