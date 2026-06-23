return {
  src = {
    { src = 'https://github.com/lewis6991/gitsigns.nvim' },
    { src = 'https://github.com/kdheepak/lazygit.nvim' },
  },
  setup = function()
    local signs = require 'gitsigns'

    signs.setup {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text_pos = 'eol',
      },
      on_attach = function(bufnr)
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', '<leader>gb', signs.toggle_current_line_blame)
      end,
    }

    vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = '[L]azy [G]it' })
  end,
}
