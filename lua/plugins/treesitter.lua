local ensure_installed = {
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

return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    init = function()
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          -- Enable treesitter highlighting and disable regex syntax
          pcall(vim.treesitter.start)
          -- Enable treesitter-based indentation
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      local alreadyInstalled = require('nvim-treesitter.config').get_installed()
      local parsersToInstall = vim
        .iter(ensure_installed)
        :filter(function(parser)
          return not vim.tbl_contains(alreadyInstalled, parser)
        end)
        :totable()
      require('nvim-treesitter').install(parsersToInstall)
    end,

    -- require('nvim-treesitter').setup {
    --   highlight = {
    --     enable = true,
    --   },
    -- }
    -- require('nvim-treesitter').install
    --    --
    -- vim.api.nvim_create_autocmd('FileType', {
    --   callback = function()
    --     local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
    --     if lang then
    --       vim.treesitter.start()
    --     end
    --   end,
    -- })
    --
    -- vim.api.nvim_create_autocmd('FileType', {
    --   pattern = { '<filetype>' },
    --   callback = function()
    --     vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    --     vim.wo[0][0].foldmethod = 'expr'
    --     vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    --     vim.treesitter.start()
    --   end,
    -- })
    --
    -- vim.api.nvim_create_autocmd('User', {
    --   pattern = 'TSUpdate',
    --   callback = function()
    --     require('nvim-treesitter.parsers').lua.install_info.generate = true
    --   end,
    -- })

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
  },
}
