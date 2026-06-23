return {
  src = {
    { src = 'https://github.com/mrcjkb/rustaceanvim', version = vim.version.range '6' },
  },
  setup = function()
    -- rustaceanvim manages rust-analyzer itself via this global; it must be set
    -- before the plugin's ftplugin runs for a Rust buffer.
    vim.g.rustaceanvim = {
      server = {
        default_settings = {
          ['rust-analyzer'] = {
            checkOnSave = { command = 'clippy' },
            cargo = { allFeatures = true },
            inlayHints = {
              closureReturnTypeHints = { enable = 'always' },
              lifetimeElisionHints = { enable = 'always', useParameterNames = true },
            },
          },
        },
        on_attach = function(_, bufnr)
          local opts = { buffer = bufnr }
          -- Override generic LSP maps with Rust-specific equivalents
          vim.keymap.set('n', 'K', function() vim.cmd.RustLsp { 'hover', 'actions' } end, opts)
          vim.keymap.set({ 'n', 'v', 'i', 'x' }, '<C-.>', function() vim.cmd.RustLsp 'codeAction' end, opts)
          vim.keymap.set({ 'n', 'v', 'i', 'x' }, '<F3>', function() vim.cmd.RustLsp 'codeAction' end, opts)
          -- Rust-specific extras
          vim.keymap.set('n', '<leader>re', function() vim.cmd.RustLsp 'expandMacro' end, opts)
          vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp 'runnables' end, opts)
          vim.keymap.set('n', '<leader>rt', function() vim.cmd.RustLsp 'testables' end, opts)
          vim.keymap.set('n', '<leader>rod', function() vim.cmd.RustLsp 'openDocs' end, opts)
        end,
      },
    }
  end,
}
