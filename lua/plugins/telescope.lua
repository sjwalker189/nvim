return {
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    enabled = false,
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-frecency.nvim', version = '*' },
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },

    config = function()
      local actions = require 'telescope.actions'
      local builtin = require 'telescope.builtin'

      require('telescope').setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden', -- Search hidden files
            '--glob=!.git/', -- Exclude .git directory for speed
          },
          layout_strategy = 'horizontal',
          layout_config = {
            width = 0.95,
            height = 0.95,
            preview_cutoff = 0,
            prompt_position = 'top',
            horizontal = { preview_width = 0.5 },
          },
          sorting_strategy = 'ascending',
          borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          results_title = false,
          prompt_title = false,
          mappings = {
            i = {
              -- Snap uses <Tab> to toggle selection
              ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
              ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,

              -- Snap-style: Send ALL to quickfix
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

              -- Snap-style: Send only SELECTED to quickfix
              ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,

              -- Quick navigation (Snap uses standard j/k or C-n/C-p)
              ['<C-n>'] = actions.move_selection_next,
              ['<C-p>'] = actions.move_selection_previous,
            },
            n = {
              ['<Tab>'] = actions.toggle_selection + actions.move_selection_worse,
              ['<S-Tab>'] = actions.toggle_selection + actions.move_selection_better,
              ['<C-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<M-q>'] = actions.send_selected_to_qflist + actions.open_qflist,
              ['<leader>ff'] = require('telescope.builtin').find_files,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = { 'fd', '--type', 'f', '--strip-cwd-prefix' },
          },
        },
        preview = {
          fileseize_limit = 0.1,
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'smart_case',
          },
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {},
          },
        },
      }

      require('telescope').load_extension 'fzf'
      require('telescope').load_extension 'ui-select'
      require('telescope').load_extension 'frecency'

      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Find Recent Files' })
      vim.keymap.set('n', '<leader>r', builtin.resume, { desc = 'Resume last search' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
      vim.keymap.set('n', '<leader>fq', builtin.quickfix, { desc = 'Find Quick Fix' })
    end,
  },
}
