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
  'rust',
  'templ',
  'sql',
  'gloss',
}

return {
  src = {
    -- The rewrite of nvim-treesitter lives on the `main` branch.
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  },
  setup = function()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })

    -- Register the local Gloss grammar. nvim-treesitter's install/update path
    -- reloads the parsers table from scratch (reload_parsers) and fires
    -- `User TSUpdate` so custom parsers can be re-registered onto the fresh
    -- table -- registering here (not via a one-time mutation) is what makes it
    -- survive :TSInstall/:TSUpdate. Compiles gloss.so into site/parser and
    -- symlinks the repo's queries/ dir.
    vim.api.nvim_create_autocmd('User', {
      pattern = 'TSUpdate',
      callback = function()
        require('nvim-treesitter.parsers').gloss = {
          install_info = {
            path = vim.fn.expand '~/dev/gloss/tree-sitter-gloss',
            queries = 'queries',
            generate = true, -- enable if you edit grammar.js and want regen on :TSInstall
          },
          filetype = 'gloss',
        }
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
}
