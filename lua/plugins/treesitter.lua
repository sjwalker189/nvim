return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').install {
        'vim',
        'vimdoc',
        'bash',
        'lua',
        'luadoc',
        'luap',
        'query',
        'regex',
        'toml',
        'yaml',
        'json',
        'jsonc',
        'html',
        'markdown',
        'markdown_inline',
        'css',
        'tsx',
        'typescript',
        'javascript',
        'jsdoc',
        'vue',
        'go',
        'templ',
        'sql',
      }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = { '<filetype>' },
        callback = function()
          vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo[0][0].foldmethod = 'expr'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.treesitter.start()
        end,
      })

      -- -- Add custom parsers
      -- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      --
      -- parser_config.gloss = {
      --   install_info = {
      --     -- Dynamically expands to /Users/swalker or /home/swalker
      --     url = vim.fn.expand '$HOME' .. '/dev/gloss/tree-sitter-gloss',
      --     files = { 'src/parser.c', 'src/scanner.c' },
      --     branch = 'main',
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = false,
      --   },
      --   filetype = 'gloss',
      -- }
      --
      -- parser_config.test = {
      --   install_info = {
      --     url = 'https://github.com/tree-sitter-grammars/tree-sitter-test',
      --     files = { 'src/parser.c' },
      --     branch = 'master',
      --     generate_requires_npm = false,
      --     requires_generate_from_grammar = false,
      --   },
      --   filetype = 'test',
      -- }
      --
      -- require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
