-- Gleam language server.
--
-- The LSP ships inside the `gleam` compiler binary (`gleam lsp`), so it is NOT
-- mason-managed: it's resolved from $PATH and kept out of mason's
-- `ensure_installed` list. See lua/plugins/lsp.lua.
return {
  cmd = { 'gleam', 'lsp' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
}
