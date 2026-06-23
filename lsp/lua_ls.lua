return {
  settings = {
    Lua = {
      workspace = {
        -- Add Neovim's runtime files for lsp completions
        library = vim.api.nvim_get_runtime_file('', true),
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
}
