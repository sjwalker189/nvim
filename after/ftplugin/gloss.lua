-- Gloss.
--
-- Everything else the language needs in an editor comes from somewhere already: the grammar
-- is registered in lua/plugins/treesitter.lua and installed from ~/dev/gloss/tree-sitter-gloss,
-- the server config is lsp/gloss.lua, and `gloss fmt` is wired through conform. This file is
-- only for what is per-buffer.

-- Treesitter sets no commentstring for this filetype, so `gc` was a no-op. Comments are `//`
-- and a doc comment is `///`, which is the same prefix and needs no separate entry.
vim.bo.commentstring = '// %s'

-- Statements are semicolon-terminated and blocks are braced, so the C-ish defaults are right.
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.expandtab = true

-- The formatter normalizes indentation but deliberately does not reflow, so it will not
-- rescue a line broken at 120 columns -- the ruler is the only thing keeping that honest.
vim.bo.textwidth = 100

-- `gloss lsp` advertises inlayHintProvider, and hints here are unusually worth showing: every
-- signature in the language is annotated, so the only places anything is inferred are `let`
-- and a loop's carried values. The list is therefore short and every entry is something the
-- reader cannot see otherwise -- unlike a language that infers everywhere, where hints mostly
-- restate what is already on the screen.
--
-- Enabled per-buffer rather than globally, so this says nothing about any other server.
vim.api.nvim_create_autocmd('LspAttach', {
  buffer = 0,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method 'textDocument/inlayHint' then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- Toggle, because hints are worth reading and not always worth having in the way.
vim.keymap.set('n', '<space>ih', function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 })
end, { buffer = true, desc = 'Toggle inlay hints' })
